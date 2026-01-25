//
//  HealthKitMapper.swift
//  VitalArc
//
//  Maps HealthKit samples to domain entities
//

import Foundation
import HealthKit

/// Maps HealthKit data to domain HealthMetrics entity
struct HealthKitMapper {

    /// Map HealthKit samples to HealthMetrics domain entity
    static func mapToHealthMetrics(
        date: Date,
        hrvSample: HKQuantitySample?,
        heartRateSample: HKQuantitySample?,
        activeEnergySample: HKQuantitySample?,
        stepsSample: HKQuantitySample?,
        sleepSample: HKCategorySample?,
        weightSample: HKQuantitySample?
    ) -> HealthMetrics? {

        // Extract HRV (in milliseconds)
        let hrv = hrvSample?.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))

        // Extract heart rate (in BPM)
        let heartRate = heartRateSample?.quantity.doubleValue(
            for: HKUnit.count().unitDivided(by: .minute())
        )

        // Extract active energy (in kcal)
        let activeEnergy = activeEnergySample?.quantity.doubleValue(for: .kilocalorie())

        // Extract steps (count)
        let steps = stepsSample?.quantity.doubleValue(for: .count())

        // Extract sleep hours
        let sleepHours: Double? = {
            guard let sample = sleepSample,
                  sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                  sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                  sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                  sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue else {
                return nil
            }
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            return duration / 3600 // Convert seconds to hours
        }()

        // Extract weight (in kg)
        let weight = weightSample?.quantity.doubleValue(for: .gramUnit(with: .kilo))

        return HealthMetrics(
            date: date,
            heartRateVariability: hrv,
            restingHeartRate: heartRate,
            activeEnergy: activeEnergy,
            steps: steps.map { Int($0) },
            sleepHours: sleepHours,
            weight: weight
        )
    }

    /// Extract HRV value from sample
    static func extractHRV(from sample: HKQuantitySample?) -> Double? {
        guard let sample = sample else { return nil }
        return sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
    }

    /// Extract heart rate value from sample
    static func extractHeartRate(from sample: HKQuantitySample?) -> Double? {
        guard let sample = sample else { return nil }
        return sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
    }

    /// Extract active energy value from sample
    static func extractActiveEnergy(from sample: HKQuantitySample?) -> Double? {
        guard let sample = sample else { return nil }
        return sample.quantity.doubleValue(for: .kilocalorie())
    }

    /// Extract steps value from sample
    static func extractSteps(from sample: HKQuantitySample?) -> Int? {
        guard let sample = sample else { return nil }
        return Int(sample.quantity.doubleValue(for: .count()))
    }

    /// Extract weight value from sample
    static func extractWeight(from sample: HKQuantitySample?) -> Double? {
        guard let sample = sample else { return nil }
        return sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
    }

    /// Calculate total sleep hours from multiple sleep samples
    static func calculateTotalSleepHours(from samples: [HKCategorySample]) -> Double? {
        guard !samples.isEmpty else { return nil }

        let totalSeconds = samples
            .filter { sample in
                // Only count actual sleep states
                sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
            }
            .reduce(0.0) { result, sample in
                result + sample.endDate.timeIntervalSince(sample.startDate)
            }

        return totalSeconds / 3600 // Convert to hours
    }
}
