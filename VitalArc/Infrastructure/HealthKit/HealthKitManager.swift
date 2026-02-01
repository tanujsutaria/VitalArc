//
//  HealthKitManager.swift
//  VitalArc
//
//  Manages HealthKit data reading and synchronization
//

import Foundation
import HealthKit

/// Manages HealthKit data access and synchronization.
///
/// Note: This class is intentionally NOT @MainActor to allow background HealthKit queries.
/// ViewModels using this class are @MainActor isolated and handle thread transitions.
final class HealthKitManager {

    // MARK: - Properties

    private let healthStore = HKHealthStore()
    private var backgroundQueryAnchor: HKQueryAnchor?

    // MARK: - Initialization

    init() {}

    // MARK: - Authorization

    /// Request authorization for HealthKit access
    func requestAuthorization() async throws -> Bool {
        return try await HealthKitPermissions.requestAuthorization(healthStore: healthStore)
    }

    /// Check if HealthKit is available
    func isHealthKitAvailable() -> Bool {
        return HealthKitPermissions.isHealthKitAvailable()
    }

    // MARK: - Fetch Data

    /// Fetch health metrics for a specific date
    func fetchHealthMetrics(for date: Date) async throws -> HealthMetrics? {
        let dateRange = HealthKitQuery.dateRangeForDate(date)

        async let hrv = fetchHRV(start: dateRange.start, end: dateRange.end)
        async let heartRate = fetchRestingHeartRate(start: dateRange.start, end: dateRange.end)
        async let activeEnergy = fetchActiveEnergy(start: dateRange.start, end: dateRange.end)
        async let steps = fetchSteps(start: dateRange.start, end: dateRange.end)
        async let sleep = fetchSleepHours(start: dateRange.start, end: dateRange.end)
        async let sleepStages = fetchSleepStages(start: dateRange.start, end: dateRange.end)
        async let weight = fetchWeight(start: dateRange.start, end: dateRange.end)

        let (hrvValue, hrValue, energyValue, stepsValue, sleepValue, sleepStagesValue, weightValue) =
            await (try? hrv, try? heartRate, try? activeEnergy, try? steps, try? sleep, try? sleepStages, try? weight)

        return HealthMetrics(
            date: date,
            heartRateVariability: hrvValue,
            restingHeartRate: hrValue,
            activeEnergy: energyValue,
            steps: stepsValue,
            sleepHours: sleepValue,
            sleepStages: sleepStagesValue,
            weight: weightValue
        )
    }

    /// Fetch health metrics for a date range
    func fetchHealthMetrics(from startDate: Date, to endDate: Date) async throws -> [HealthMetrics] {
        let calendar = Calendar.current
        var metrics: [HealthMetrics] = []
        var currentDate = startDate

        while currentDate <= endDate {
            if let dayMetrics = try await fetchHealthMetrics(for: currentDate) {
                metrics.append(dayMetrics)
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return metrics
    }

    // MARK: - Individual Metric Queries

    /// Fetch heart rate variability (HRV) during sleep periods
    /// Uses the Oura-style approach: average all HRV readings during sleep
    private func fetchHRV(start: Date, end: Date) async throws -> Double? {
        // First, get sleep periods for this date range
        let sleepPeriods = try await fetchSleepPeriods(start: start, end: end)

        guard !sleepPeriods.isEmpty else {
            // No sleep data - fall back to any HRV reading
            return try await fetchAnyHRV(start: start, end: end)
        }

        // Fetch all HRV samples during sleep periods
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            throw HealthKitError.queryFailed
        }

        var allSleepHRVValues: [Double] = []

        for period in sleepPeriods {
            let hrvValues = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[Double], Error>) in
                let query = HealthKitQuery.sampleQuery(
                    for: hrvType,
                    start: period.start,
                    end: period.end
                ) { samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let hrvSamples = samples as? [HKQuantitySample] else {
                        continuation.resume(returning: [])
                        return
                    }

                    let values = hrvSamples.map { sample in
                        sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                    }
                    continuation.resume(returning: values)
                }

                healthStore.execute(query)
            }

            allSleepHRVValues.append(contentsOf: hrvValues)
        }

        // Return average of all sleep HRV readings (Oura-style)
        guard !allSleepHRVValues.isEmpty else {
            return try await fetchAnyHRV(start: start, end: end)
        }

        return allSleepHRVValues.reduce(0, +) / Double(allSleepHRVValues.count)
    }

    /// Fetch sleep periods (start/end times) for HRV correlation
    private func fetchSleepPeriods(start: Date, end: Date) async throws -> [(start: Date, end: Date)] {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: sleepType,
                start: start,
                end: end
            ) { samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: [])
                    return
                }

                // Filter to actual sleep states and extract periods
                let periods = sleepSamples
                    .filter { sample in
                        sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                        sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                        sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                        sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
                    }
                    .map { (start: $0.startDate, end: $0.endDate) }

                continuation.resume(returning: periods)
            }

            healthStore.execute(query)
        }
    }

    /// Fallback: fetch any HRV reading when no sleep data available
    private func fetchAnyHRV(start: Date, end: Date) async throws -> Double? {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: hrvType,
                start: start,
                end: end,
                limit: 1
            ) { samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let value = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch resting heart rate
    private func fetchRestingHeartRate(start: Date, end: Date) async throws -> Double? {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: hrType,
                start: start,
                end: end,
                limit: 1
            ) { samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let value = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch active energy burned
    private func fetchActiveEnergy(start: Date, end: Date) async throws -> Double? {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.statisticsQuery(
                for: energyType,
                start: start,
                end: end,
                options: .cumulativeSum
            ) { statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sum = statistics?.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }

                let value = sum.doubleValue(for: .kilocalorie())
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch step count
    private func fetchSteps(start: Date, end: Date) async throws -> Int? {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.statisticsQuery(
                for: stepsType,
                start: start,
                end: end,
                options: .cumulativeSum
            ) { statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sum = statistics?.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }

                let value = Int(sum.doubleValue(for: .count()))
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch sleep hours
    private func fetchSleepHours(start: Date, end: Date) async throws -> Double? {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: sleepType,
                start: start,
                end: end
            ) { samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }

                let totalHours = HealthKitMapper.calculateTotalSleepHours(from: sleepSamples)
                continuation.resume(returning: totalHours)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch sleep stage breakdown
    func fetchSleepStages(start: Date, end: Date) async throws -> SleepStages? {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: sleepType,
                start: start,
                end: end
            ) { samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sleepSamples = samples as? [HKCategorySample], !sleepSamples.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }

                // Calculate duration for each sleep stage
                var deepSleep: Double = 0
                var remSleep: Double = 0
                var coreSleep: Double = 0
                var awake: Double = 0

                for sample in sleepSamples {
                    let duration = sample.endDate.timeIntervalSince(sample.startDate) / 3600 // hours

                    switch sample.value {
                    case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                        deepSleep += duration
                    case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                        remSleep += duration
                    case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                        coreSleep += duration
                    case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                        // Unspecified counts as core/light sleep
                        coreSleep += duration
                    case HKCategoryValueSleepAnalysis.awake.rawValue:
                        awake += duration
                    default:
                        break
                    }
                }

                // Only return stages if we have any sleep data
                if deepSleep + remSleep + coreSleep > 0 {
                    let stages = SleepStages(
                        deepSleep: deepSleep,
                        remSleep: remSleep,
                        coreSleep: coreSleep,
                        awake: awake
                    )
                    continuation.resume(returning: stages)
                } else {
                    continuation.resume(returning: nil)
                }
            }

            healthStore.execute(query)
        }
    }

    /// Fetch body weight
    private func fetchWeight(start: Date, end: Date) async throws -> Double? {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: weightType,
                start: start,
                end: end,
                limit: 1
            ) { samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let value = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Workout Queries

    /// Fetch workouts for a date range
    func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [HKWorkout] {
        let workoutType = HKObjectType.workoutType()

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: workoutType,
                start: startDate,
                end: endDate
            ) { samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let workouts = (samples as? [HKWorkout]) ?? []
                continuation.resume(returning: workouts)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch workouts for a specific date
    func fetchWorkouts(for date: Date) async throws -> [HKWorkout] {
        let dateRange = HealthKitQuery.dateRangeForDate(date)
        return try await fetchWorkouts(from: dateRange.start, to: dateRange.end)
    }

    // MARK: - Heart Rate Queries

    /// Fetch heart rate samples during a time period
    func fetchHeartRateSamples(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [HeartRateSample] {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: hrType,
                start: startDate,
                end: endDate
            ) { samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let hrSamples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }

                let heartRateSamples = hrSamples.map { sample in
                    HeartRateSample(
                        timestamp: sample.startDate,
                        bpm: sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    )
                }
                continuation.resume(returning: heartRateSamples)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch heart rate samples for a specific workout
    func fetchHeartRateSamples(for workout: HKWorkout) async throws -> [HeartRateSample] {
        return try await fetchHeartRateSamples(from: workout.startDate, to: workout.endDate)
    }

    /// Fetch average heart rate for a workout
    func fetchAverageHeartRate(for workout: HKWorkout) async throws -> Double? {
        let samples = try await fetchHeartRateSamples(for: workout)
        guard !samples.isEmpty else { return nil }
        let sum = samples.reduce(0.0) { $0 + $1.bpm }
        return sum / Double(samples.count)
    }

    /// Convert HKWorkout to WorkoutData with HR information
    func convertToWorkoutData(_ workout: HKWorkout) async throws -> WorkoutData {
        let samples = try await fetchHeartRateSamples(for: workout)
        let averageHR: Double? = samples.isEmpty ? nil : samples.reduce(0.0) { $0 + $1.bpm } / Double(samples.count)

        return WorkoutData(
            id: workout.uuid,
            startDate: workout.startDate,
            endDate: workout.endDate,
            duration: workout.duration,
            workoutType: workout.workoutActivityType.name,
            averageHeartRate: averageHR,
            heartRateSamples: samples
        )
    }

    /// Fetch all workout data for a date with HR samples
    func fetchWorkoutData(for date: Date) async throws -> [WorkoutData] {
        let workouts = try await fetchWorkouts(for: date)
        var workoutDataList: [WorkoutData] = []

        for workout in workouts {
            let data = try await convertToWorkoutData(workout)
            workoutDataList.append(data)
        }

        return workoutDataList
    }

    // MARK: - Background Sync

    /// Enable background delivery for health data
    func enableBackgroundDelivery() async throws {
        let types = HealthKitPermissions.requiredReadTypes()

        for type in types {
            guard let sampleType = type as? HKSampleType else { continue }

            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                healthStore.enableBackgroundDelivery(for: sampleType, frequency: .hourly) { success, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if success {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: HealthKitError.queryFailed)
                    }
                }
            }
        }
    }

    /// Disable background delivery for health data
    func disableBackgroundDelivery() async throws {
        let types = HealthKitPermissions.requiredReadTypes()

        for type in types {
            guard let sampleType = type as? HKSampleType else { continue }

            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                healthStore.disableBackgroundDelivery(for: sampleType) { success, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if success {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: HealthKitError.queryFailed)
                    }
                }
            }
        }
    }
}

// MARK: - HKWorkoutActivityType Extension

extension HKWorkoutActivityType {
    /// Human-readable name for the workout activity type
    var name: String {
        switch self {
        case .americanFootball: return "American Football"
        case .archery: return "Archery"
        case .australianFootball: return "Australian Football"
        case .badminton: return "Badminton"
        case .baseball: return "Baseball"
        case .basketball: return "Basketball"
        case .bowling: return "Bowling"
        case .boxing: return "Boxing"
        case .climbing: return "Climbing"
        case .cricket: return "Cricket"
        case .crossTraining: return "Cross Training"
        case .curling: return "Curling"
        case .cycling: return "Cycling"
        case .dance: return "Dance"
        case .elliptical: return "Elliptical"
        case .equestrianSports: return "Equestrian Sports"
        case .fencing: return "Fencing"
        case .fishing: return "Fishing"
        case .functionalStrengthTraining: return "Functional Strength Training"
        case .golf: return "Golf"
        case .gymnastics: return "Gymnastics"
        case .handball: return "Handball"
        case .hiking: return "Hiking"
        case .hockey: return "Hockey"
        case .hunting: return "Hunting"
        case .lacrosse: return "Lacrosse"
        case .martialArts: return "Martial Arts"
        case .mindAndBody: return "Mind and Body"
        case .paddleSports: return "Paddle Sports"
        case .play: return "Play"
        case .preparationAndRecovery: return "Preparation and Recovery"
        case .racquetball: return "Racquetball"
        case .rowing: return "Rowing"
        case .rugby: return "Rugby"
        case .running: return "Running"
        case .sailing: return "Sailing"
        case .skatingSports: return "Skating Sports"
        case .snowSports: return "Snow Sports"
        case .soccer: return "Soccer"
        case .softball: return "Softball"
        case .squash: return "Squash"
        case .stairClimbing: return "Stair Climbing"
        case .surfingSports: return "Surfing Sports"
        case .swimming: return "Swimming"
        case .tableTennis: return "Table Tennis"
        case .tennis: return "Tennis"
        case .trackAndField: return "Track and Field"
        case .traditionalStrengthTraining: return "Strength Training"
        case .volleyball: return "Volleyball"
        case .walking: return "Walking"
        case .waterFitness: return "Water Fitness"
        case .waterPolo: return "Water Polo"
        case .waterSports: return "Water Sports"
        case .wrestling: return "Wrestling"
        case .yoga: return "Yoga"
        case .barre: return "Barre"
        case .coreTraining: return "Core Training"
        case .crossCountrySkiing: return "Cross Country Skiing"
        case .downhillSkiing: return "Downhill Skiing"
        case .flexibility: return "Flexibility"
        case .highIntensityIntervalTraining: return "HIIT"
        case .jumpRope: return "Jump Rope"
        case .kickboxing: return "Kickboxing"
        case .pilates: return "Pilates"
        case .snowboarding: return "Snowboarding"
        case .stairs: return "Stairs"
        case .stepTraining: return "Step Training"
        case .wheelchairWalkPace: return "Wheelchair Walk Pace"
        case .wheelchairRunPace: return "Wheelchair Run Pace"
        case .taiChi: return "Tai Chi"
        case .mixedCardio: return "Mixed Cardio"
        case .handCycling: return "Hand Cycling"
        case .discSports: return "Disc Sports"
        case .fitnessGaming: return "Fitness Gaming"
        case .other: return "Other"
        @unknown default: return "Workout"
        }
    }
}
