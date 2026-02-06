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

    func execute(todayMetrics: HealthMetrics, weekMetrics: [HealthMetrics]) -> ReadinessScore {
        // Compute 7-day baselines
        let baselineHRV = average(weekMetrics.compactMap { $0.heartRateVariability })
        let baselineRHR = average(weekMetrics.compactMap { $0.restingHeartRate })
        let baselineSleepQuality = average(weekMetrics.compactMap { $0.sleepStages?.qualityScore })
        let baselineSleepDuration = average(weekMetrics.compactMap { $0.sleepHours })

        // HRV contribution (40% weight) - higher relative to baseline is better
        let hrvContribution: Double = {
            guard let todayHRV = todayMetrics.heartRateVariability, let baseline = baselineHRV, baseline > 0 else {
                return 20 // neutral if no data
            }
            let ratio = todayHRV / baseline
            // Baseline (ratio=1.0) → 34/40 (85%); ratio 1.1 → 40; ratio 0.5 → 4
            return min(40, max(0, 34 + (ratio - 1.0) * 60))
        }()

        // RHR contribution (25% weight) - lower relative to baseline is better
        let rhrContribution: Double = {
            guard let todayRHR = todayMetrics.restingHeartRate, let baseline = baselineRHR,
                  baseline > 0, todayRHR > 0 else {
                return 12.5 // neutral if no data
            }
            let ratio = baseline / todayRHR
            // Baseline (ratio=1.0) → 21/25 (84%); ratio 1.1 → 25; ratio 0.5 → 1
            return min(25, max(0, 21 + (ratio - 1.0) * 40))
        }()

        // Sleep quality contribution (20% weight) - based on stage composition score
        let sleepQualityContribution: Double = {
            guard let todayQuality = todayMetrics.sleepStages?.qualityScore else {
                if let baseline = baselineSleepQuality {
                    return min(20, max(0, baseline / 100 * 20))
                }
                return 10 // neutral if no data
            }
            return min(20, max(0, todayQuality / 100 * 20))
        }()

        // Sleep duration contribution (15% weight) - 7-9 hours optimal
        // Prefer sleepStages.total (excludes awake time) over raw sleepHours
        let sleepDurationContribution: Double = {
            let actualSleep = todayMetrics.sleepStages?.total ?? todayMetrics.sleepHours
            guard let todaySleep = actualSleep else {
                if let baseline = baselineSleepDuration {
                    return sleepDurationScore(baseline)
                }
                return 7.5 // neutral if no data
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
        if hours >= 7 && hours <= 9 {
            return 15
        } else if hours >= 6 && hours < 7 {
            return 10
        } else if hours > 9 && hours <= 10 {
            return 12
        } else {
            return max(0, 15 - abs(hours - 8) * 3)
        }
    }

    private func generateRecommendation(
        score: Double,
        hrvContribution: Double,
        rhrContribution: Double,
        sleepQualityContribution: Double,
        sleepDurationContribution: Double
    ) -> String {
        if score >= 80 {
            return "Great recovery. You're ready for high-intensity training."
        } else if score >= 60 {
            // Find the weakest area using explicit tracking to avoid float equality issues
            let normalized: [(key: String, value: Double)] = [
                ("hrv", hrvContribution / 40),
                ("rhr", rhrContribution / 25),
                ("sleepQuality", sleepQualityContribution / 20),
                ("sleepDuration", sleepDurationContribution / 15)
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
        } else if score >= 40 {
            return "Below average recovery. Focus on rest and light activity today."
        } else {
            return "Low recovery. Prioritize rest, hydration, and an early bedtime."
        }
    }
}
