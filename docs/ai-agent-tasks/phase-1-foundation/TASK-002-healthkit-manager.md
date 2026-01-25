# TASK-002: HealthKit Manager

## Metadata
- **Phase**: 1 - Foundation
- **Priority**: P0 (Critical)
- **Estimated Hours**: 8
- **Dependencies**: TASK-001
- **Blocked By**: None

## Objective
Implement a comprehensive HealthKitManager class that handles all health data reading and writing operations, including authorization, real-time observation, and background delivery.

## Context
HealthKit integration is critical for VitalArc's health analytics features. This manager will be the single point of contact for all Apple Health data, ensuring consistent data handling and proper permission management.

## Requirements

### Functional Requirements
- [ ] Request and manage HealthKit authorization
- [ ] Read heart rate samples with date filtering
- [ ] Read HRV samples (SDNN from Apple + custom RMSSD calculation)
- [ ] Read resting heart rate
- [ ] Read sleep analysis data with stage breakdown
- [ ] Read/write body mass (weight)
- [ ] Read step count and active energy
- [ ] Write completed workouts to HealthKit
- [ ] Support background delivery for key metrics
- [ ] Observe real-time heart rate updates

### Non-Functional Requirements
- Async/await API for all operations
- Graceful handling of missing permissions
- Efficient batching of queries
- Memory-efficient for large datasets

## Technical Specification

### Files to Create

```
Infrastructure/
└── HealthKit/
    ├── HealthKitManager.swift
    ├── HRVAnalyzer.swift
    ├── SleepAnalyzer.swift
    └── HealthKitError.swift
```

### HealthKitError.swift

```swift
import Foundation

enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case dataNotAvailable
    case queryFailed(Error)
    case saveFailed(Error)
    case invalidDateRange
    case insufficientData(required: Int, actual: Int)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit access has not been authorized"
        case .dataNotAvailable:
            return "The requested health data is not available"
        case .queryFailed(let error):
            return "Failed to query HealthKit: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save to HealthKit: \(error.localizedDescription)"
        case .invalidDateRange:
            return "Invalid date range specified"
        case .insufficientData(let required, let actual):
            return "Insufficient data: need \(required), have \(actual)"
        }
    }
}
```

### HealthKitManager.swift

```swift
import HealthKit
import OSLog

@MainActor
final class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private var observerQueries: [HKObserverQuery] = []

    @Published private(set) var isAuthorized = false
    @Published private(set) var authorizationStatus: [String: HKAuthorizationStatus] = [:]

    // MARK: - Type Definitions

    private var readTypes: Set<HKObjectType> {
        Set([
            // Quantity Types
            HKQuantityType(.heartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKQuantityType(.restingHeartRate),
            HKQuantityType(.oxygenSaturation),
            HKQuantityType(.respiratoryRate),
            HKQuantityType(.bodyMass),
            HKQuantityType(.height),
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.basalEnergyBurned),

            // Category Types
            HKCategoryType(.sleepAnalysis),

            // Workout Type
            HKWorkoutType.workoutType(),

            // Characteristics
            HKCharacteristicType(.dateOfBirth),
            HKCharacteristicType(.biologicalSex),
        ])
    }

    private var writeTypes: Set<HKSampleType> {
        Set([
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.bodyMass),
            HKWorkoutType.workoutType(),
        ])
    }

    // MARK: - Authorization

    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }

        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
        await updateAuthorizationStatus()
        isAuthorized = true

        Logger.health.info("HealthKit authorization granted")
    }

    private func updateAuthorizationStatus() async {
        var status: [String: HKAuthorizationStatus] = [:]

        for type in readTypes {
            if let sampleType = type as? HKSampleType {
                status[type.identifier] = healthStore.authorizationStatus(for: sampleType)
            }
        }

        authorizationStatus = status
    }

    // MARK: - Heart Rate

    func getHeartRateSamples(from startDate: Date, to endDate: Date) async throws -> [HeartRateSample] {
        guard startDate < endDate else {
            throw HealthKitError.invalidDateRange
        }

        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let samples = try await querySamples(
            type: heartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit
        )

        let unit = HKUnit.count().unitDivided(by: .minute())
        return samples.map { sample in
            HeartRateSample(
                timestamp: sample.startDate,
                heartRate: sample.quantity.doubleValue(for: unit),
                source: sample.sourceRevision.source.name
            )
        }
    }

    // MARK: - HRV

    func getHRVSamples(from startDate: Date, to endDate: Date) async throws -> [HRVSample] {
        let hrvType = HKQuantityType(.heartRateVariabilitySDNN)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let samples = try await querySamples(
            type: hrvType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit
        )

        let unit = HKUnit.secondUnit(with: .milli)
        return samples.map { sample in
            HRVSample(
                timestamp: sample.startDate,
                sdnn: sample.quantity.doubleValue(for: unit),
                source: sample.sourceRevision.source.name
            )
        }
    }

    /// Get overnight HRV (during sleep period)
    func getOvernightHRV(for date: Date) async throws -> Double? {
        let sleepData = try await getSleepSamples(for: date)
        guard let sleepStart = sleepData.first?.startDate,
              let sleepEnd = sleepData.last?.endDate else {
            return nil
        }

        let hrvSamples = try await getHRVSamples(from: sleepStart, to: sleepEnd)
        guard !hrvSamples.isEmpty else { return nil }

        let average = hrvSamples.map(\.sdnn).reduce(0, +) / Double(hrvSamples.count)
        return average
    }

    // MARK: - Resting Heart Rate

    func getRestingHeartRate(for date: Date) async throws -> Double? {
        let rhrType = HKQuantityType(.restingHeartRate)
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        let samples = try await querySamples(
            type: rhrType,
            predicate: predicate,
            limit: 1,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        )

        guard let sample = samples.first else { return nil }

        let unit = HKUnit.count().unitDivided(by: .minute())
        return sample.quantity.doubleValue(for: unit)
    }

    /// Get average RHR over a period
    func getAverageRestingHeartRate(days: Int) async throws -> Double? {
        let rhrType = HKQuantityType(.restingHeartRate)
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date(),
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: rhrType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                let unit = HKUnit.count().unitDivided(by: .minute())
                let avg = statistics?.averageQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: avg)
            }

            self.healthStore.execute(query)
        }
    }

    // MARK: - Sleep

    func getSleepSamples(for date: Date) async throws -> [HKCategorySample] {
        let sleepType = HKCategoryType(.sleepAnalysis)

        // Sleep that ends on this date's morning
        let startOfDay = Calendar.current.startOfDay(for: date)
        let searchStart = Calendar.current.date(byAdding: .hour, value: -12, to: startOfDay)!
        let searchEnd = Calendar.current.date(byAdding: .hour, value: 12, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: searchStart,
            end: searchEnd,
            options: .strictEndDate
        )

        return try await queryCategorySamples(
            type: sleepType,
            predicate: predicate
        )
    }

    // MARK: - Weight

    func getWeightSamples(from startDate: Date, to endDate: Date) async throws -> [WeightSample] {
        let weightType = HKQuantityType(.bodyMass)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let samples = try await querySamples(
            type: weightType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit
        )

        return samples.map { sample in
            WeightSample(
                timestamp: sample.startDate,
                weightKg: sample.quantity.doubleValue(for: .gramUnit(with: .kilo)),
                source: sample.sourceRevision.source.name
            )
        }
    }

    func saveWeight(_ weightKg: Double, date: Date = Date()) async throws {
        let weightType = HKQuantityType(.bodyMass)
        let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: weightKg)
        let sample = HKQuantitySample(
            type: weightType,
            quantity: quantity,
            start: date,
            end: date
        )

        try await healthStore.save(sample)
        Logger.health.info("Saved weight: \(weightKg) kg")
    }

    // MARK: - Workouts

    func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [HKWorkout] {
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                let workouts = samples as? [HKWorkout] ?? []
                continuation.resume(returning: workouts)
            }

            self.healthStore.execute(query)
        }
    }

    func saveWorkout(
        activityType: HKWorkoutActivityType,
        start: Date,
        end: Date,
        energyBurned: Double?,
        metadata: [String: Any]? = nil
    ) async throws {
        let workout = HKWorkout(
            activityType: activityType,
            start: start,
            end: end,
            workoutEvents: nil,
            totalEnergyBurned: energyBurned.map { HKQuantity(unit: .kilocalorie(), doubleValue: $0) },
            totalDistance: nil,
            metadata: metadata
        )

        try await healthStore.save(workout)
        Logger.health.info("Saved workout: \(activityType.rawValue)")
    }

    // MARK: - Statistics

    func getHeartRateStatistics(from startDate: Date, to endDate: Date) async throws -> HeartRateStatistics? {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: [.discreteAverage, .discreteMin, .discreteMax]
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                guard let stats = statistics else {
                    continuation.resume(returning: nil)
                    return
                }

                let unit = HKUnit.count().unitDivided(by: .minute())
                let result = HeartRateStatistics(
                    average: stats.averageQuantity()?.doubleValue(for: unit),
                    min: stats.minimumQuantity()?.doubleValue(for: unit),
                    max: stats.maximumQuantity()?.doubleValue(for: unit)
                )
                continuation.resume(returning: result)
            }

            self.healthStore.execute(query)
        }
    }

    // MARK: - Background Delivery

    func enableBackgroundDelivery() async throws {
        let typesToObserve: [HKSampleType] = [
            HKQuantityType(.heartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKCategoryType(.sleepAnalysis),
            HKQuantityType(.bodyMass),
        ]

        for type in typesToObserve {
            try await healthStore.enableBackgroundDelivery(for: type, frequency: .immediate)
        }

        Logger.health.info("Background delivery enabled for \(typesToObserve.count) types")
    }

    // MARK: - Observers

    func observeHeartRate(handler: @escaping ([HeartRateSample]) -> Void) {
        let heartRateType = HKQuantityType(.heartRate)

        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, completionHandler, error in
            guard error == nil else {
                completionHandler()
                return
            }

            Task { @MainActor in
                do {
                    let samples = try await self?.getHeartRateSamples(
                        from: Date().addingTimeInterval(-3600),
                        to: Date()
                    )
                    handler(samples ?? [])
                } catch {
                    Logger.health.error("Observer query failed: \(error)")
                }
                completionHandler()
            }
        }

        healthStore.execute(query)
        observerQueries.append(query)
    }

    func stopAllObservers() {
        for query in observerQueries {
            healthStore.stop(query)
        }
        observerQueries.removeAll()
    }

    // MARK: - User Characteristics

    func getUserAge() -> Int? {
        guard let dateOfBirth = try? healthStore.dateOfBirthComponents() else {
            return nil
        }

        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth.date!, to: now)
        return ageComponents.year
    }

    func getUserBiologicalSex() -> HKBiologicalSex? {
        try? healthStore.biologicalSex().biologicalSex
    }

    // MARK: - Private Helpers

    private func querySamples(
        type: HKQuantityType,
        predicate: NSPredicate,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
    ) async throws -> [HKQuantitySample] {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: limit,
                sortDescriptors: sortDescriptors
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                let quantitySamples = samples as? [HKQuantitySample] ?? []
                continuation.resume(returning: quantitySamples)
            }

            self.healthStore.execute(query)
        }
    }

    private func queryCategorySamples(
        type: HKCategoryType,
        predicate: NSPredicate
    ) async throws -> [HKCategorySample] {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                let categorySamples = samples as? [HKCategorySample] ?? []
                continuation.resume(returning: categorySamples)
            }

            self.healthStore.execute(query)
        }
    }
}

// MARK: - Supporting Types

struct HeartRateSample: Identifiable {
    let id = UUID()
    let timestamp: Date
    let heartRate: Double
    let source: String
}

struct HRVSample: Identifiable {
    let id = UUID()
    let timestamp: Date
    let sdnn: Double
    let source: String
}

struct WeightSample: Identifiable {
    let id = UUID()
    let timestamp: Date
    let weightKg: Double
    let source: String

    var weightLbs: Double {
        weightKg * 2.20462
    }
}

struct HeartRateStatistics {
    let average: Double?
    let min: Double?
    let max: Double?
}
```

### HRVAnalyzer.swift

```swift
import Foundation

struct HRVAnalyzer {
    /// Calculate RMSSD from RR intervals (in milliseconds)
    static func calculateRMSSD(rrIntervals: [Double]) -> Double? {
        guard rrIntervals.count >= 2 else { return nil }

        // Filter outliers
        let filtered = filterOutliers(rrIntervals)
        guard filtered.count >= 2 else { return nil }

        // Calculate successive differences squared
        var sumSquaredDiff: Double = 0
        for i in 0..<(filtered.count - 1) {
            let diff = filtered[i + 1] - filtered[i]
            sumSquaredDiff += diff * diff
        }

        // RMSSD
        return sqrt(sumSquaredDiff / Double(filtered.count - 1))
    }

    /// Calculate SDNN from RR intervals
    static func calculateSDNN(rrIntervals: [Double]) -> Double? {
        guard rrIntervals.count >= 2 else { return nil }

        let filtered = filterOutliers(rrIntervals)
        guard filtered.count >= 2 else { return nil }

        let mean = filtered.reduce(0, +) / Double(filtered.count)

        var sumSquaredDeviation: Double = 0
        for interval in filtered {
            let deviation = interval - mean
            sumSquaredDeviation += deviation * deviation
        }

        return sqrt(sumSquaredDeviation / Double(filtered.count - 1))
    }

    /// Filter outliers using median-based approach
    private static func filterOutliers(_ intervals: [Double]) -> [Double] {
        guard intervals.count >= 3 else { return intervals }

        let sorted = intervals.sorted()
        let median = sorted[sorted.count / 2]

        // Keep intervals within 25% of median
        let lowerBound = median * 0.75
        let upperBound = median * 1.25

        return intervals.filter { $0 >= lowerBound && $0 <= upperBound }
    }
}
```

### SleepAnalyzer.swift

```swift
import HealthKit

struct SleepAnalyzer {
    /// Parse HealthKit sleep samples into structured sleep data
    static func analyzeSleep(samples: [HKCategorySample]) -> SleepAnalysis? {
        guard !samples.isEmpty else { return nil }

        // Filter to actual sleep (not just in bed)
        let sleepSamples = samples.filter { sample in
            if #available(iOS 16.0, *) {
                let value = HKCategoryValueSleepAnalysis(rawValue: sample.value)
                return value != .inBed
            } else {
                return sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue
            }
        }

        guard let firstSleep = sleepSamples.first,
              let lastSleep = sleepSamples.last else {
            return nil
        }

        // Calculate stages
        var stages = SleepStages()

        for sample in samples {
            let minutes = Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)

            if #available(iOS 16.0, *) {
                switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                case .awake:
                    stages.awakeMinutes += minutes
                case .asleepREM:
                    stages.remMinutes += minutes
                case .asleepCore:
                    stages.lightMinutes += minutes
                case .asleepDeep:
                    stages.deepMinutes += minutes
                case .inBed:
                    break  // Don't count in bed time
                default:
                    break
                }
            } else {
                // Pre-iOS 16: only asleep/awake
                if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                    stages.lightMinutes += minutes
                } else if sample.value == HKCategoryValueSleepAnalysis.awake.rawValue {
                    stages.awakeMinutes += minutes
                }
            }
        }

        let totalSleepMinutes = stages.remMinutes + stages.lightMinutes + stages.deepMinutes
        let totalInBedMinutes = totalSleepMinutes + stages.awakeMinutes

        let efficiency = totalInBedMinutes > 0
            ? Double(totalSleepMinutes) / Double(totalInBedMinutes)
            : 0

        return SleepAnalysis(
            bedtime: firstSleep.startDate,
            wakeTime: lastSleep.endDate,
            totalSleepMinutes: totalSleepMinutes,
            stages: stages,
            efficiency: efficiency
        )
    }
}

struct SleepAnalysis {
    let bedtime: Date
    let wakeTime: Date
    let totalSleepMinutes: Int
    let stages: SleepStages
    let efficiency: Double

    var totalHours: Double {
        Double(totalSleepMinutes) / 60.0
    }
}

struct SleepStages {
    var awakeMinutes: Int = 0
    var remMinutes: Int = 0
    var lightMinutes: Int = 0
    var deepMinutes: Int = 0

    var remPercent: Double {
        let total = remMinutes + lightMinutes + deepMinutes
        return total > 0 ? Double(remMinutes) / Double(total) * 100 : 0
    }

    var deepPercent: Double {
        let total = remMinutes + lightMinutes + deepMinutes
        return total > 0 ? Double(deepMinutes) / Double(total) * 100 : 0
    }

    var lightPercent: Double {
        let total = remMinutes + lightMinutes + deepMinutes
        return total > 0 ? Double(lightMinutes) / Double(total) * 100 : 0
    }
}
```

## Implementation Guide

### Step 1: Create Files
Create all four files in the Infrastructure/HealthKit/ folder.

### Step 2: Update DependencyContainer
Add HealthKitManager to the dependency container:
```swift
lazy var healthKitManager = HealthKitManager()
```

### Step 3: Create Authorization View
Create a simple view to request HealthKit access on first launch.

### Step 4: Test on Device
HealthKit requires a physical device for most operations.

## Acceptance Criteria

- [ ] HealthKitManager compiles without errors
- [ ] Authorization request shows correct data types
- [ ] Heart rate samples retrieved successfully
- [ ] HRV samples retrieved successfully
- [ ] Resting heart rate retrieved successfully
- [ ] Sleep data parsed into stages correctly
- [ ] Weight can be read and written
- [ ] Workouts can be saved to Apple Health
- [ ] Background delivery enabled successfully
- [ ] Observer queries work for real-time updates
- [ ] All methods handle missing data gracefully

## Testing Requirements

### Unit Tests

```swift
import XCTest
@testable import VitalArc

final class HRVAnalyzerTests: XCTestCase {
    func testRMSSDCalculation() {
        // Known values for verification
        let rrIntervals = [800.0, 810.0, 795.0, 820.0, 805.0]
        let rmssd = HRVAnalyzer.calculateRMSSD(rrIntervals: rrIntervals)

        XCTAssertNotNil(rmssd)
        XCTAssertGreaterThan(rmssd!, 0)
    }

    func testRMSSDWithInsufficientData() {
        let rrIntervals = [800.0]
        let rmssd = HRVAnalyzer.calculateRMSSD(rrIntervals: rrIntervals)

        XCTAssertNil(rmssd)
    }

    func testOutlierFiltering() {
        // Include an obvious outlier
        let rrIntervals = [800.0, 810.0, 1500.0, 795.0, 820.0]
        let rmssd = HRVAnalyzer.calculateRMSSD(rrIntervals: rrIntervals)

        // Should still calculate after filtering outlier
        XCTAssertNotNil(rmssd)
    }
}

final class SleepAnalyzerTests: XCTestCase {
    func testEmptySamplesReturnsNil() {
        let analysis = SleepAnalyzer.analyzeSleep(samples: [])
        XCTAssertNil(analysis)
    }

    func testSleepStagePercentages() {
        var stages = SleepStages()
        stages.remMinutes = 90
        stages.lightMinutes = 240
        stages.deepMinutes = 90

        // Total = 420 minutes
        XCTAssertEqual(stages.remPercent, 90.0 / 420.0 * 100, accuracy: 0.1)
        XCTAssertEqual(stages.deepPercent, 90.0 / 420.0 * 100, accuracy: 0.1)
    }
}
```

### Integration Tests (Device Required)

```swift
final class HealthKitManagerIntegrationTests: XCTestCase {
    var manager: HealthKitManager!

    @MainActor
    override func setUp() {
        super.setUp()
        manager = HealthKitManager()
    }

    @MainActor
    func testAuthorizationRequest() async throws {
        // This will prompt user on first run
        try await manager.requestAuthorization()
        XCTAssertTrue(manager.isAuthorized)
    }

    @MainActor
    func testHeartRateQuery() async throws {
        try await manager.requestAuthorization()

        let samples = try await manager.getHeartRateSamples(
            from: Date().addingTimeInterval(-86400),
            to: Date()
        )

        // May be empty if no data, but shouldn't throw
        XCTAssertNotNil(samples)
    }
}
```

## References

- [HealthKit Integration Guide](../../architecture/HEALTHKIT.md)
- [Apple HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [HRV Analysis Methods](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5624990/)

## Notes for AI Agent

- Test on a real device - simulator has limited HealthKit support
- Handle all optionals gracefully
- Use async/await consistently
- Log all errors with appropriate severity
- Consider privacy - never log actual health values in production
