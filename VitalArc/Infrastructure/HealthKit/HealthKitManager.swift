//
//  HealthKitManager.swift
//  VitalArc
//
//  Manages HealthKit data reading and synchronization
//

import Foundation
import HealthKit

/// Manages HealthKit data access and synchronization
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
        async let weight = fetchWeight(start: dateRange.start, end: dateRange.end)

        let (hrvValue, hrValue, energyValue, stepsValue, sleepValue, weightValue) =
            await (try? hrv, try? heartRate, try? activeEnergy, try? steps, try? sleep, try? weight)

        return HealthMetrics(
            date: date,
            heartRateVariability: hrvValue,
            restingHeartRate: hrValue,
            activeEnergy: energyValue,
            steps: stepsValue,
            sleepHours: sleepValue,
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

    /// Fetch heart rate variability (HRV)
    private func fetchHRV(start: Date, end: Date) async throws -> Double? {
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
