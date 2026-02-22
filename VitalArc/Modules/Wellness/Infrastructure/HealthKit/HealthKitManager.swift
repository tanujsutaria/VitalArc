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
/// This class is intentionally **not** `@MainActor`-isolated so that HealthKit queries
/// execute on background cooperative threads. When called from `@MainActor`-isolated code
/// (e.g., `SwiftDataHealthRepository.syncFromHealthKit()`), Swift structured concurrency
/// automatically hops off the main actor for the duration of each `await` call here,
/// then hops back for SwiftData saves. This keeps the UI responsive during multi-day syncs.
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

    /// Check if authorization was previously requested but may have been denied.
    /// After initial denial, iOS won't show the prompt again — the user must go to Settings.
    var authorizationPreviouslyRequested: Bool {
        HealthKitPermissions.hasRequiredAuthorization(healthStore: healthStore)
    }

    /// Retry authorization after a previous denial.
    /// If the system prompt was already shown, clears the flag and re-requests.
    /// Returns `true` if the system showed the authorization prompt,
    /// `false` if the user must be directed to Settings instead.
    func retryAuthorization() async throws -> Bool {
        guard isHealthKitAvailable() else {
            throw HealthKitError.notAvailable
        }

        // Clear the tracked flag so we can re-request
        HealthKitPermissions.clearAuthorizationFlag()

        // Re-request authorization. iOS will only show the prompt if it hasn't been
        // shown before for these types. If already shown, this is a no-op and the
        // user must go to Settings → Privacy → Health to grant access.
        return try await HealthKitPermissions.requestAuthorization(healthStore: healthStore)
    }

    // MARK: - Fetch Data

    /// Fetch health metrics for a specific date
    func fetchHealthMetrics(for date: Date) async throws -> HealthMetrics? {
        guard isHealthKitAvailable() else {
            throw HealthKitError.notAvailable
        }
        let dateRange = HealthKitQuery.dateRangeForDate(date)
        // Use wider window for sleep to capture overnight sessions (6 PM prev → noon current)
        let sleepRange = HealthKitQuery.sleepDateRangeForDate(date)

        async let hrv = fetchHRV(start: dateRange.start, end: dateRange.end)
        async let heartRate = fetchRestingHeartRate(start: dateRange.start, end: dateRange.end)
        async let activeEnergy = fetchActiveEnergy(start: dateRange.start, end: dateRange.end)
        async let steps = fetchSteps(start: dateRange.start, end: dateRange.end)
        async let sleep = fetchSleepHours(start: sleepRange.start, end: sleepRange.end)
        async let sleepStages = fetchSleepStages(start: sleepRange.start, end: sleepRange.end)
        async let weight = fetchWeight(start: dateRange.start, end: dateRange.end)
        async let bodyFat = fetchBodyFatPercentage(start: dateRange.start, end: dateRange.end)
        async let leanMass = fetchLeanBodyMass(start: dateRange.start, end: dateRange.end)
        async let respRate = fetchRespiratoryRate(start: dateRange.start, end: dateRange.end)
        async let spo2 = fetchOxygenSaturation(start: dateRange.start, end: dateRange.end)
        async let vo2 = fetchVO2Max(start: dateRange.start, end: dateRange.end)
        async let water = fetchWaterIntake(start: dateRange.start, end: dateRange.end)

        // Intentional `try?`: individual metric failures (e.g., user lacks a sensor for
        // respiratory rate, or a specific HealthKit type is unauthorized) should not block
        // the entire sync. We collect whatever data IS available and return nil for the rest.
        let (hrvValue, hrValue, energyValue, stepsValue, sleepValue, sleepStagesValue, weightValue,
             bodyFatValue, leanMassValue, respRateValue, spo2Value, vo2Value, waterValue) =
            await (try? hrv, try? heartRate, try? activeEnergy, try? steps, try? sleep, try? sleepStages, try? weight,
                   try? bodyFat, try? leanMass, try? respRate, try? spo2, try? vo2, try? water)

        return HealthMetrics(
            date: date,
            heartRateVariability: hrvValue,
            restingHeartRate: hrValue,
            activeEnergy: energyValue,
            steps: stepsValue,
            sleepHours: sleepValue,
            sleepStages: sleepStagesValue,
            weight: weightValue,
            bodyFatPercentage: bodyFatValue,
            leanBodyMass: leanMassValue,
            respiratoryRate: respRateValue,
            oxygenSaturation: spo2Value,
            vo2Max: vo2Value,
            waterIntake: waterValue
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

    /// Fetch body fat percentage
    private func fetchBodyFatPercentage(start: Date, end: Date) async throws -> Double? {
        guard let bodyFatType = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: bodyFatType,
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

                let value = sample.quantity.doubleValue(for: .percent())
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch lean body mass (in kg)
    private func fetchLeanBodyMass(start: Date, end: Date) async throws -> Double? {
        guard let leanMassType = HKQuantityType.quantityType(forIdentifier: .leanBodyMass) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: leanMassType,
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

    /// Fetch respiratory rate (breaths per minute)
    private func fetchRespiratoryRate(start: Date, end: Date) async throws -> Double? {
        guard let respType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: respType,
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

    /// Fetch blood oxygen saturation (SpO2) as percentage 0-100
    private func fetchOxygenSaturation(start: Date, end: Date) async throws -> Double? {
        guard let spo2Type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: spo2Type,
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

                // HealthKit stores SpO2 as a fraction (0.0-1.0), convert to percentage
                let value = sample.quantity.doubleValue(for: .percent()) * 100
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch VO2 Max (mL/kg/min)
    /// Physiological range: ~15 mL/kg/min (sedentary) to ~97 mL/kg/min (elite athletes).
    /// Values outside 5-100 are clamped to prevent overflow in downstream calculations.
    private func fetchVO2Max(start: Date, end: Date) async throws -> Double? {
        guard let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: vo2MaxType,
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

                let unit = HKUnit(from: "mL/kg/min")
                let rawValue = sample.quantity.doubleValue(for: unit)

                // Clamp to physiologically plausible range to prevent overflow
                guard rawValue.isFinite else {
                    continuation.resume(returning: nil)
                    return
                }
                let clampedValue = min(100, max(5, rawValue))
                continuation.resume(returning: clampedValue)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch all HRV samples for a date, tagged as daytime or sleep context
    func fetchHRVReadings(for date: Date) async throws -> [HRVReading] {
        guard isHealthKitAvailable() else { throw HealthKitError.notAvailable }

        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            throw HealthKitError.queryFailed
        }

        let dateRange = HealthKitQuery.dateRangeForDate(date)
        let sleepRange = HealthKitQuery.sleepDateRangeForDate(date)

        // Fetch sleep periods and all HRV samples concurrently
        async let sleepPeriodsTask = fetchSleepPeriods(start: sleepRange.start, end: sleepRange.end)
        async let hrvSamplesTask: [HKQuantitySample] = withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.sampleQuery(
                for: hrvType,
                start: dateRange.start,
                end: dateRange.end
            ) { samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let quantitySamples = (samples as? [HKQuantitySample]) ?? []
                continuation.resume(returning: quantitySamples)
            }
            healthStore.execute(query)
        }

        let (sleepPeriods, hrvSamples) = try await (sleepPeriodsTask, hrvSamplesTask)

        return hrvSamples.map { sample in
            let timestamp = sample.startDate
            let value = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            let isDuringSleep = sleepPeriods.contains { period in
                timestamp >= period.start && timestamp <= period.end
            }
            return HRVReading(
                timestamp: timestamp,
                value: value,
                context: isDuringSleep ? .sleep : .daytime
            )
        }.sorted { $0.timestamp < $1.timestamp }
    }

    /// Fetch dietary water intake (in mL) for the day
    private func fetchWaterIntake(start: Date, end: Date) async throws -> Double? {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            throw HealthKitError.queryFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HealthKitQuery.statisticsQuery(
                for: waterType,
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

                let value = sum.doubleValue(for: .literUnit(with: .milli))
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

// MARK: - WorkoutImportSource Adapter

/// Adapts HealthKitManager to the WorkoutImportSource protocol for testability
final class HealthKitWorkoutImportSource: WorkoutImportSource, @unchecked Sendable {
    private let healthKitManager: HealthKitManager

    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
    }

    func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [ImportedWorkoutData] {
        let hkWorkouts = try await healthKitManager.fetchWorkouts(from: startDate, to: endDate)
        return hkWorkouts.map { workout in
            ImportedWorkoutData(
                healthKitId: workout.uuid.uuidString,
                startDate: workout.startDate,
                activityName: workout.workoutActivityType.name,
                duration: workout.duration
            )
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
