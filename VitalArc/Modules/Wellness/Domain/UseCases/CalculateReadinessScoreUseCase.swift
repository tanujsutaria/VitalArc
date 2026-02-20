//
//  CalculateReadinessScoreUseCase.swift
//  VitalArc
//
//  Calculates a personalized readiness score using 7-day rolling baselines
//

import Foundation

protocol CalculateReadinessScoreUseCaseProtocol {
    func execute(todayMetrics: HealthMetrics, weekMetrics: [HealthMetrics]) -> ReadinessScore
}

/// Calculates readiness score using personalized 7-day baselines.
/// Weights: HRV 40%, RHR 25%, Sleep Quality 20%, Sleep Duration 15%.
final class CalculateReadinessScoreUseCase: CalculateReadinessScoreUseCaseProtocol {

    // MARK: - Scoring Constants

    /// Component weight allocations (must sum to 100)
    private enum Weight {
        /// HRV is the strongest recovery signal from autonomic nervous system
        static let hrv: Double = 40
        /// Resting heart rate reflects cardiovascular recovery
        static let rhr: Double = 25
        /// Sleep stage composition affects recovery quality
        static let sleepQuality: Double = 20
        /// Total sleep duration affects recovery completeness
        static let sleepDuration: Double = 15
    }

    /// Baseline-relative scoring parameters
    private enum BaselineScoring {
        /// HRV: score at baseline ratio (1.0) — 85% of max weight
        static let hrvAtBaseline: Double = 34
        /// HRV: sensitivity multiplier for ratio deviations
        static let hrvSensitivity: Double = 60

        /// RHR: score at baseline ratio (1.0) — 84% of max weight
        static let rhrAtBaseline: Double = 21
        /// RHR: sensitivity multiplier for ratio deviations
        static let rhrSensitivity: Double = 40
    }

    /// Neutral scores returned when no data is available (50% of each weight)
    private enum NeutralScore {
        static let hrv: Double = 20          // 50% of 40
        static let rhr: Double = 12.5        // 50% of 25
        static let sleepQuality: Double = 10 // 50% of 20
        static let sleepDuration: Double = 7.5 // 50% of 15
    }

    /// Sleep duration thresholds (hours)
    private enum SleepDuration {
        static let optimalMin: Double = 7
        static let optimalMax: Double = 9
        static let acceptableMin: Double = 6
        static let acceptableMax: Double = 10
        /// Points awarded in the acceptable-but-suboptimal range
        static let suboptimalScore: Double = 10
        static let slightOverScore: Double = 12
        /// Penalty per hour deviation from 8h target
        static let penaltyPerHour: Double = 3
        /// Target hours used as center of the scoring curve
        static let targetHours: Double = 8
    }

    /// Recommendation score thresholds
    private enum Threshold {
        static let highReadiness: Double = 80
        static let moderateReadiness: Double = 60
        static let belowAverage: Double = 40
    }

    func execute(todayMetrics: HealthMetrics, weekMetrics: [HealthMetrics]) -> ReadinessScore {
        // Compute 7-day baselines
        let baselineHRV = average(weekMetrics.compactMap { $0.heartRateVariability })
        let baselineRHR = average(weekMetrics.compactMap { $0.restingHeartRate })
        let baselineSleepQuality = average(weekMetrics.compactMap { $0.sleepStages?.qualityScore })
        let baselineSleepDuration = average(weekMetrics.compactMap { $0.sleepHours })

        // HRV contribution — higher relative to baseline is better
        let hrvContribution: Double = {
            guard let todayHRV = todayMetrics.heartRateVariability, let baseline = baselineHRV, baseline > 0 else {
                return NeutralScore.hrv
            }
            let ratio = todayHRV / baseline
            return min(Weight.hrv, max(0,
                BaselineScoring.hrvAtBaseline + (ratio - 1.0) * BaselineScoring.hrvSensitivity))
        }()

        // RHR contribution — lower relative to baseline is better
        let rhrContribution: Double = {
            guard let todayRHR = todayMetrics.restingHeartRate, let baseline = baselineRHR,
                  baseline > 0, todayRHR > 0 else {
                return NeutralScore.rhr
            }
            let ratio = baseline / todayRHR
            return min(Weight.rhr, max(0,
                BaselineScoring.rhrAtBaseline + (ratio - 1.0) * BaselineScoring.rhrSensitivity))
        }()

        // Sleep quality contribution — based on stage composition score (0-100)
        let sleepQualityContribution: Double = {
            guard let todayQuality = todayMetrics.sleepStages?.qualityScore else {
                if let baseline = baselineSleepQuality {
                    return min(Weight.sleepQuality, max(0, baseline / 100 * Weight.sleepQuality))
                }
                return NeutralScore.sleepQuality
            }
            return min(Weight.sleepQuality, max(0, todayQuality / 100 * Weight.sleepQuality))
        }()

        // Sleep duration contribution — 7-9 hours optimal
        // Prefer sleepStages.total (excludes awake time) over raw sleepHours
        let sleepDurationContribution: Double = {
            let actualSleep = todayMetrics.sleepStages?.total ?? todayMetrics.sleepHours
            guard let todaySleep = actualSleep else {
                if let baseline = baselineSleepDuration {
                    return sleepDurationScore(baseline)
                }
                return NeutralScore.sleepDuration
            }
            return sleepDurationScore(todaySleep)
        }()

        let overallScore = min(100, max(0,
            hrvContribution + rhrContribution + sleepQualityContribution + sleepDurationContribution
        ))

        let recommendation = generateRecommendation(
            score: overallScore,
            hrvContribution: hrvContribution,
            rhrContribution: rhrContribution,
            sleepQualityContribution: sleepQualityContribution,
            sleepDurationContribution: sleepDurationContribution
        )

        return ReadinessScore(
            overallScore: overallScore,
            hrvContribution: hrvContribution,
            rhrContribution: rhrContribution,
            sleepQualityContribution: sleepQualityContribution,
            sleepDurationContribution: sleepDurationContribution,
            recommendation: recommendation
        )
    }

    // MARK: - Private Helpers

    private func average(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private func sleepDurationScore(_ hours: Double) -> Double {
        if hours >= SleepDuration.optimalMin && hours <= SleepDuration.optimalMax {
            return Weight.sleepDuration
        } else if hours >= SleepDuration.acceptableMin && hours < SleepDuration.optimalMin {
            return SleepDuration.suboptimalScore
        } else if hours > SleepDuration.optimalMax && hours <= SleepDuration.acceptableMax {
            return SleepDuration.slightOverScore
        } else {
            return max(0, Weight.sleepDuration - abs(hours - SleepDuration.targetHours) * SleepDuration.penaltyPerHour)
        }
    }

    private func generateRecommendation(
        score: Double,
        hrvContribution: Double,
        rhrContribution: Double,
        sleepQualityContribution: Double,
        sleepDurationContribution: Double
    ) -> String {
        if score >= Threshold.highReadiness {
            return "Great recovery. You're ready for high-intensity training."
        } else if score >= Threshold.moderateReadiness {
            // Find the weakest area using explicit tracking to avoid float equality issues
            let normalized: [(key: String, value: Double)] = [
                ("hrv", hrvContribution / Weight.hrv),
                ("rhr", rhrContribution / Weight.rhr),
                ("sleepQuality", sleepQualityContribution / Weight.sleepQuality),
                ("sleepDuration", sleepDurationContribution / Weight.sleepDuration)
            ]
            let weakestKey = normalized.min(by: { $0.value < $1.value })?.key ?? "sleepDuration"
            switch weakestKey {
            case "hrv":
                return "Moderate recovery. HRV is below your baseline - consider lighter training."
            case "rhr":
                return "Moderate recovery. Elevated resting heart rate - monitor for stress."
            case "sleepQuality":
                return "Moderate recovery. Sleep quality was low - prioritize deep sleep tonight."
            default:
                return "Moderate recovery. Sleep duration was short - aim for 7-9 hours."
            }
        } else if score >= Threshold.belowAverage {
            return "Below average recovery. Focus on rest and light activity today."
        } else {
            return "Low recovery. Prioritize rest, hydration, and an early bedtime."
        }
    }
}
