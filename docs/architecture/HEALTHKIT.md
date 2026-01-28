# VitalArc - HealthKit Integration Guide

## Overview

VitalArc deeply integrates with Apple HealthKit to read health metrics and write workout data. This document covers all HealthKit interactions, permissions, and best practices.

---

## Required Permissions

### Read Permissions

| Data Type | Identifier | Purpose |
|-----------|------------|---------|
| Heart Rate | `HKQuantityType.heartRate` | Recovery, strain, workout analysis |
| Heart Rate Variability | `HKQuantityType.heartRateVariabilitySDNN` | Recovery score calculation |
| Resting Heart Rate | `HKQuantityType.restingHeartRate` | Recovery baseline |
| Blood Oxygen | `HKQuantityType.oxygenSaturation` | Health monitoring |
| Respiratory Rate | `HKQuantityType.respiratoryRate` | Sleep quality |
| Wrist Temperature | `HKQuantityType.appleSleepingWristTemperature` | Health trends |
| Sleep Analysis | `HKCategoryType.sleepAnalysis` | Sleep tracking |
| Step Count | `HKQuantityType.stepCount` | Activity tracking |
| Active Energy | `HKQuantityType.activeEnergyBurned` | Strain calculation |
| Workouts | `HKWorkoutType.workoutType()` | Workout history |
| Body Mass | `HKQuantityType.bodyMass` | Weight tracking |
| Height | `HKQuantityType.height` | BMR calculations |
| Date of Birth | `HKCharacteristicType.dateOfBirth` | Age-based calculations |
| Biological Sex | `HKCharacteristicType.biologicalSex` | Algorithm adjustments |

### Write Permissions

| Data Type | Identifier | Purpose |
|-----------|------------|---------|
| Workouts | `HKWorkoutType.workoutType()` | Save completed workouts |
| Active Energy | `HKQuantityType.activeEnergyBurned` | Workout calories |
| Body Mass | `HKQuantityType.bodyMass` | Weight logging |

---

## HealthKit Manager Implementation

```swift
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var isAuthorized = false
    @Published var authorizationError: Error?

    // MARK: - Authorization

    var readTypes: Set<HKObjectType> {
        Set([
            // Quantities
            HKQuantityType(.heartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKQuantityType(.restingHeartRate),
            HKQuantityType(.oxygenSaturation),
            HKQuantityType(.respiratoryRate),
            HKQuantityType(.bodyMass),
            HKQuantityType(.height),
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.appleSleepingWristTemperature),

            // Categories
            HKCategoryType(.sleepAnalysis),

            // Workouts
            HKWorkoutType.workoutType(),

            // Characteristics
            HKCharacteristicType(.dateOfBirth),
            HKCharacteristicType(.biologicalSex)
        ])
    }

    var writeTypes: Set<HKSampleType> {
        Set([
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.bodyMass),
            HKWorkoutType.workoutType()
        ])
    }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        try await healthStore.requestAuthorization(
            toShare: writeTypes,
            read: readTypes
        )

        isAuthorized = true
    }

    // MARK: - Heart Rate Data

    func getHeartRateSamples(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [HKQuantitySample] {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let quantitySamples = samples as? [HKQuantitySample] ?? []
                continuation.resume(returning: quantitySamples)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - HRV Data

    func getHRVSamples(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [HKQuantitySample] {
        let hrvType = HKQuantityType(.heartRateVariabilitySDNN)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: hrvType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let quantitySamples = samples as? [HKQuantitySample] ?? []
                continuation.resume(returning: quantitySamples)
            }

            healthStore.execute(query)
        }
    }

    /// Get overnight HRV (during sleep)
    func getOvernightHRV(for date: Date) async throws -> Double? {
        // Get sleep samples to determine sleep period
        let sleepSamples = try await getSleepSamples(for: date)
        guard let sleepStart = sleepSamples.first?.startDate,
              let sleepEnd = sleepSamples.last?.endDate else {
            return nil
        }

        // Get HRV samples during sleep
        let hrvSamples = try await getHRVSamples(from: sleepStart, to: sleepEnd)
        guard !hrvSamples.isEmpty else { return nil }

        // Calculate average
        let unit = HKUnit.secondUnit(with: .milli)
        let values = hrvSamples.map { $0.quantity.doubleValue(for: unit) }
        return values.reduce(0, +) / Double(values.count)
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

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: rhrType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: bpm)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Sleep Data

    func getSleepSamples(for date: Date) async throws -> [HKCategorySample] {
        let sleepType = HKCategoryType(.sleepAnalysis)

        // Sleep that ends on this date (previous night's sleep)
        let startOfDay = Calendar.current.startOfDay(for: date)
        let previousNight = Calendar.current.date(byAdding: .hour, value: -12, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: previousNight,
            end: Calendar.current.date(byAdding: .hour, value: 12, to: startOfDay)!,
            options: .strictEndDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let categorySamples = samples as? [HKCategorySample] ?? []
                continuation.resume(returning: categorySamples)
            }

            healthStore.execute(query)
        }
    }

    /// Parse sleep samples into structured data
    func parseSleepData(samples: [HKCategorySample]) -> SleepData? {
        guard !samples.isEmpty else { return nil }

        // Filter to actual sleep (not InBed)
        let sleepSamples = samples.filter { sample in
            if #available(iOS 16.0, *) {
                let value = HKCategoryValueSleepAnalysis(rawValue: sample.value)
                return value != .inBed
            } else {
                return sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue
            }
        }

        guard let first = sleepSamples.first, let last = sleepSamples.last else {
            return nil
        }

        // Calculate stages
        var awake = 0, rem = 0, core = 0, deep = 0

        for sample in samples {
            let minutes = Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)

            if #available(iOS 16.0, *) {
                switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                case .awake:
                    awake += minutes
                case .asleepREM:
                    rem += minutes
                case .asleepCore:
                    core += minutes
                case .asleepDeep:
                    deep += minutes
                default:
                    break
                }
            } else {
                // Pre-iOS 16: only asleep/awake
                if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                    core += minutes  // Treat all sleep as core
                } else {
                    awake += minutes
                }
            }
        }

        let totalSleep = rem + core + deep
        let totalInBed = totalSleep + awake

        return SleepData(
            id: UUID(),
            date: Calendar.current.startOfDay(for: last.endDate),
            bedtime: first.startDate,
            wakeTime: last.endDate,
            totalSleepMinutes: totalSleep,
            sleepScore: 0,  // Calculate separately
            stages: SleepStages(
                awakeMinutes: awake,
                remMinutes: rem,
                lightMinutes: core,
                deepMinutes: deep
            ),
            efficiency: totalInBed > 0 ? Double(totalSleep) / Double(totalInBed) : 0,
            latency: 0,  // Would need InBed -> Asleep transition
            interruptions: 0  // Would need to count awake periods
        )
    }

    // MARK: - Workouts

    func getWorkouts(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [HKWorkout] {
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
                    continuation.resume(throwing: error)
                    return
                }

                let workouts = samples as? [HKWorkout] ?? []
                continuation.resume(returning: workouts)
            }

            healthStore.execute(query)
        }
    }

    /// Save a completed workout to HealthKit
    func saveWorkout(
        activityType: HKWorkoutActivityType,
        start: Date,
        end: Date,
        energyBurned: Double?,
        metadata: [String: Any]? = nil
    ) async throws {
        var samples: [HKSample] = []

        // Create energy sample if provided
        if let calories = energyBurned {
            let energyType = HKQuantityType(.activeEnergyBurned)
            let energyQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
            let energySample = HKQuantitySample(
                type: energyType,
                quantity: energyQuantity,
                start: start,
                end: end
            )
            samples.append(energySample)
        }

        // Create workout
        let workout = HKWorkout(
            activityType: activityType,
            start: start,
            end: end,
            workoutEvents: nil,
            totalEnergyBurned: energyBurned.map { HKQuantity(unit: .kilocalorie(), doubleValue: $0) },
            totalDistance: nil,
            metadata: metadata
        )

        // Save workout
        try await healthStore.save(workout)

        // Associate samples with workout
        if !samples.isEmpty {
            try await healthStore.addSamples(samples, to: workout)
        }
    }

    // MARK: - Weight

    func getWeightSamples(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [HKQuantitySample] {
        let weightType = HKQuantityType(.bodyMass)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let quantitySamples = samples as? [HKQuantitySample] ?? []
                continuation.resume(returning: quantitySamples)
            }

            healthStore.execute(query)
        }
    }

    func saveWeight(_ weight: Double, unit: HKUnit, date: Date) async throws {
        let weightType = HKQuantityType(.bodyMass)
        let quantity = HKQuantity(unit: unit, doubleValue: weight)
        let sample = HKQuantitySample(
            type: weightType,
            quantity: quantity,
            start: date,
            end: date
        )

        try await healthStore.save(sample)
    }

    // MARK: - Statistics

    func getHeartRateStatistics(
        from startDate: Date,
        to endDate: Date
    ) async throws -> HKStatistics? {
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
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: statistics)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Background Delivery

    func enableBackgroundDelivery() async throws {
        let types: [HKSampleType] = [
            HKQuantityType(.heartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKCategoryType(.sleepAnalysis),
            HKQuantityType(.bodyMass)
        ]

        for type in types {
            try await healthStore.enableBackgroundDelivery(
                for: type,
                frequency: .immediate
            )
        }
    }

    // MARK: - Observers

    func observeHeartRate(
        updateHandler: @escaping ([HKQuantitySample]) -> Void
    ) -> HKObserverQuery {
        let heartRateType = HKQuantityType(.heartRate)

        let query = HKObserverQuery(
            sampleType: heartRateType,
            predicate: nil
        ) { [weak self] _, completionHandler, error in
            guard error == nil else {
                completionHandler()
                return
            }

            // Fetch recent samples
            Task {
                do {
                    let samples = try await self?.getHeartRateSamples(
                        from: Date().addingTimeInterval(-3600),  // Last hour
                        to: Date()
                    )
                    await MainActor.run {
                        updateHandler(samples ?? [])
                    }
                } catch {
                    print("Error fetching HR samples: \(error)")
                }
                completionHandler()
            }
        }

        healthStore.execute(query)
        return query
    }
}

// MARK: - Errors

enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case queryFailed(Error)
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit access not authorized"
        case .queryFailed(let error):
            return "Failed to query HealthKit: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save to HealthKit: \(error.localizedDescription)"
        }
    }
}
```

---

## Background Refresh

### Enabling Background Delivery

```swift
// In AppDelegate or App init
func setupHealthKitBackgroundDelivery() {
    Task {
        do {
            try await healthKitManager.enableBackgroundDelivery()
        } catch {
            print("Failed to enable background delivery: \(error)")
        }
    }
}
```

### Info.plist Configuration

```xml
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
    <string>fetch</string>
</array>

<key>NSHealthShareUsageDescription</key>
<string>VitalArc needs access to your health data to track recovery, strain, and provide personalized insights.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>VitalArc saves your workouts and weight measurements to Apple Health.</string>
```

---

## Best Practices

### 1. Request Permissions Gradually

```swift
// Only request what you need for current feature
func requestWorkoutPermissions() async throws {
    let types: Set<HKSampleType> = [
        HKQuantityType(.heartRate),
        HKQuantityType(.activeEnergyBurned),
        HKWorkoutType.workoutType()
    ]

    try await healthStore.requestAuthorization(toShare: types, read: types)
}
```

### 2. Handle Missing Data Gracefully

```swift
func getRecoveryData(for date: Date) async -> RecoveryData? {
    do {
        let hrv = try await getOvernightHRV(for: date)
        let rhr = try await getRestingHeartRate(for: date)

        // If missing HRV, can still show partial data
        if let rhr = rhr {
            return RecoveryData(hrv: hrv, rhr: rhr, isComplete: hrv != nil)
        }

        return nil
    } catch {
        // Log error but don't crash
        Logger.health.error("Failed to get recovery data: \(error)")
        return nil
    }
}
```

### 3. Efficient Queries

```swift
// Use statistics queries for aggregated data
func getAverageRestingHR(days: Int) async throws -> Double? {
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
                continuation.resume(throwing: error)
                return
            }

            let avg = statistics?.averageQuantity()?.doubleValue(
                for: HKUnit.count().unitDivided(by: .minute())
            )
            continuation.resume(returning: avg)
        }

        healthStore.execute(query)
    }
}
```

### 4. Cache Appropriately

```swift
actor HealthDataCache {
    private var hrvCache: [Date: Double] = [:]
    private var cacheExpiry: Date = Date()

    func getHRV(for date: Date, fetch: () async throws -> Double?) async throws -> Double? {
        let dayStart = Calendar.current.startOfDay(for: date)

        // Check cache
        if Date() < cacheExpiry, let cached = hrvCache[dayStart] {
            return cached
        }

        // Fetch fresh
        let value = try await fetch()
        if let value = value {
            hrvCache[dayStart] = value
        }

        // Cache for 1 hour
        cacheExpiry = Date().addingTimeInterval(3600)

        return value
    }

    func invalidate() {
        hrvCache.removeAll()
        cacheExpiry = Date()
    }
}
```

---

## Workout Activity Types Mapping

```swift
extension HKWorkoutActivityType {
    static func from(exerciseType: String) -> HKWorkoutActivityType {
        switch exerciseType.lowercased() {
        case "weight training", "strength", "resistance":
            return .traditionalStrengthTraining
        case "running", "run":
            return .running
        case "cycling", "bike":
            return .cycling
        case "swimming", "swim":
            return .swimming
        case "hiit", "crossfit":
            return .highIntensityIntervalTraining
        case "yoga":
            return .yoga
        case "walking", "walk":
            return .walking
        case "rowing":
            return .rowing
        case "elliptical":
            return .elliptical
        case "stair climbing":
            return .stairClimbing
        default:
            return .other
        }
    }
}
```

---

## Testing

### Mock HealthKit Manager

```swift
protocol HealthKitManaging {
    func requestAuthorization() async throws
    func getHRVSamples(from: Date, to: Date) async throws -> [HKQuantitySample]
    func getRestingHeartRate(for: Date) async throws -> Double?
    // ... other methods
}

class MockHealthKitManager: HealthKitManaging {
    var mockHRV: Double = 55.0
    var mockRHR: Double = 58.0
    var shouldThrowError = false

    func requestAuthorization() async throws {
        if shouldThrowError { throw HealthKitError.notAuthorized }
    }

    func getHRVSamples(from: Date, to: Date) async throws -> [HKQuantitySample] {
        // Return mock samples for testing
        return []
    }

    func getRestingHeartRate(for: Date) async throws -> Double? {
        if shouldThrowError { throw HealthKitError.queryFailed(NSError()) }
        return mockRHR
    }
}
```

### Unit Tests

```swift
@Test
func testRecoveryCalculation() async throws {
    let mockHealthKit = MockHealthKitManager()
    mockHealthKit.mockHRV = 60.0  // Above baseline
    mockHealthKit.mockRHR = 55.0  // Below baseline

    let calculator = RecoveryCalculator()
    let result = calculator.calculate(
        currentHRV: 60.0,
        hrvBaseline: 50.0,
        currentRHR: 55.0,
        rhrBaseline: 60.0
    )

    #expect(result.score > 70)  // Should be "good" recovery
    #expect(result.category == .good || result.category == .excellent)
}
```
