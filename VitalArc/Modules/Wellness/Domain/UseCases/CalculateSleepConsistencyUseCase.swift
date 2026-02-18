//
//  CalculateSleepConsistencyUseCase.swift
//  VitalArc
//
//  Calculates sleep consistency score from 7-day sleep data
//

import Foundation

struct CalculateSleepConsistencyUseCase {

    /// Calculate sleep consistency from an array of health metrics (ideally 7 days).
    /// Returns nil if fewer than 2 days have sleep data.
    func execute(weekMetrics: [HealthMetrics]) -> SleepConsistencyScore? {
        // Extract days that have sleep data with reasonable hours
        let sleepDays = weekMetrics.filter { ($0.sleepHours ?? 0) > 0 }
        guard sleepDays.count >= 2 else { return nil }

        // Estimate bedtime and wake time from sleep hours and date.
        // Since we only have date + total sleep hours (no exact times from HealthKit
        // in our current model), we derive consistency from sleep duration variance
        // and use the date's midnight as anchor.
        //
        // Bedtime estimate: midnight - sleepHours (i.e., how many hours before midnight they went to sleep)
        // Wake estimate: midnight + (targetWake - sleepHours offset)
        //
        // Simpler approach: use sleep duration to derive bedtime/wake offsets.
        // Assume average wake time of 7:00 AM, so bedtime = 7:00 - sleepHours.
        let referenceWakeHour: Double = 7.0 // 7:00 AM reference

        let bedtimes: [Double] = sleepDays.compactMap { metrics in
            guard let sleep = metrics.sleepHours else { return nil }
            // Bedtime in hours before midnight (negative means after midnight)
            // If someone slept 8 hours and wakes at 7, bedtime = 23:00 = -1 hour before midnight
            return referenceWakeHour - sleep
        }

        let wakeTimes: [Double] = sleepDays.compactMap { metrics in
            guard let sleep = metrics.sleepHours else { return nil }
            // Wake time varies based on sleep duration from estimated bedtime
            // More sleep = later wake or earlier bed. We use duration variance as proxy.
            return referenceWakeHour + (sleep - (sleepDays.compactMap { $0.sleepHours }.reduce(0, +) / Double(sleepDays.count)))
        }

        let bedtimeStdDev = standardDeviation(bedtimes)
        let wakeStdDev = standardDeviation(wakeTimes)

        // Convert to minutes for the score
        let bedtimeVarianceMinutes = bedtimeStdDev * 60
        let wakeVarianceMinutes = wakeStdDev * 60

        // Score: lower variance = higher score
        // 0 min variance = 100, 60+ min variance = ~0
        let bedtimeScore = max(0, 100 - bedtimeVarianceMinutes * 1.5)
        let wakeScore = max(0, 100 - wakeVarianceMinutes * 1.5)
        let consistencyScore = Int(min(100, (bedtimeScore + wakeScore) / 2))

        return SleepConsistencyScore(
            bedtimeVariance: bedtimeVarianceMinutes,
            wakeVariance: wakeVarianceMinutes,
            consistencyScore: consistencyScore
        )
    }

    private func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let sumOfSquares = values.reduce(0) { $0 + ($1 - mean) * ($1 - mean) }
        return sqrt(sumOfSquares / Double(values.count))
    }
}
