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
            return min(40, max(0, ratio * 30))
        }()

        // RHR contribution (25% weight) - lower relative to baseline is better
        let rhrContribution: Double = {
            guard let todayRHR = todayMetrics.restingHeartRate, let baseline = baselineRHR, baseline > 0 else {
                return 12.5 // neutral if no data
            }
            let ratio = baseline / todayRHR
            return min(25, max(0, ratio * 18))
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
        let sleepDurationContribution: Double = {
            guard let todaySleep = todayMetrics.sleepHours else {
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
            // Find the weakest area
            let weakest = min(
                hrvContribution / 40,
                rhrContribution / 25,
                sleepQualityContribution / 20,
                sleepDurationContribution / 15
            )
            if weakest == hrvContribution / 40 {
                return "Moderate recovery. HRV is below your baseline - consider lighter training."
            } else if weakest == rhrContribution / 25 {
                return "Moderate recovery. Elevated resting heart rate - monitor for stress."
            } else if weakest == sleepQualityContribution / 20 {
                return "Moderate recovery. Sleep quality was low - prioritize deep sleep tonight."
            } else {
                return "Moderate recovery. Sleep duration was short - aim for 7-9 hours."
            }
        } else if score >= 40 {
            return "Below average recovery. Focus on rest and light activity today."
        } else {
            return "Low recovery. Prioritize rest, hydration, and an early bedtime."
        }
    }
}
