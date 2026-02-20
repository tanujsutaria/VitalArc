//
//  CalculateReadinessScoreUseCase.swift
//  VitalArc
//
//  Calculates a personalized readiness score using 7-day rolling baselines
//

import Foundation

protocol CalculateReadinessScoreUseCaseProtocol {
    func execute(todayMetrics: HealthMetrics, weekMetrics: [HealthMetrics]) -> ReadinessScore
    func execute(todayMetrics: HealthMetrics, weekMetrics: [HealthMetrics], configuration: ReadinessConfiguration) -> ReadinessScore
    func executeV2(todayMetrics: HealthMetrics, weekMetrics: [HealthMetrics], historicalScores: [Double], configuration: ReadinessConfiguration) -> ReadinessResult
}

/// Calculates readiness score using personalized 7-day baselines.
/// Supports both legacy scoring (fixed weights) and v2 scoring (configurable weights + trend detection).
final class CalculateReadinessScoreUseCase: CalculateReadinessScoreUseCaseProtocol {

    // MARK: - Scoring Constants (Legacy)

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

    /// Trend detection thresholds
    private enum TrendThreshold {
        /// Percentage deviation from rolling average to be considered a trend change
        static let significantDeviation: Double = 5.0
    }

    // MARK: - Legacy Execute (backward compatible)

    func execute(todayMetrics: HealthMetrics, weekMetrics: [HealthMetrics]) -> ReadinessScore {
        return executeLegacy(todayMetrics: todayMetrics, weekMetrics: weekMetrics)
    }

    // MARK: - Configurable Execute

    func execute(todayMetrics: HealthMetrics, weekMetrics: [HealthMetrics], configuration: ReadinessConfiguration) -> ReadinessScore {
        let result = executeV2(todayMetrics: todayMetrics, weekMetrics: weekMetrics, historicalScores: [], configuration: configuration)

        return ReadinessScore(
            overallScore: result.score,
            hrvContribution: result.componentScores["hrv"] ?? 0,
            rhrContribution: result.componentScores["rhr"] ?? 0,
            sleepQualityContribution: result.componentScores["sleep"] ?? 0,
            sleepDurationContribution: result.componentScores["activity"] ?? 0,
            recommendation: result.recommendation,
            result: result
        )
    }

    // MARK: - V2 Execute with Trend Detection

    func executeV2(
        todayMetrics: HealthMetrics,
        weekMetrics: [HealthMetrics],
        historicalScores: [Double],
        configuration: ReadinessConfiguration
    ) -> ReadinessResult {
        // Compute 7-day baselines
        let baselineHRV = average(weekMetrics.compactMap { $0.heartRateVariability })
        let baselineRHR = average(weekMetrics.compactMap { $0.restingHeartRate })
        let baselineSleepQuality = average(weekMetrics.compactMap { $0.sleepStages?.qualityScore })

        // HRV component (0-100, scaled by weight)
        let hrvScore: Double = {
            guard let todayHRV = todayMetrics.heartRateVariability, let baseline = baselineHRV, baseline > 0 else {
                return 50 // neutral
            }
            let ratio = todayHRV / baseline
            return min(100, max(0, 85 + (ratio - 1.0) * 150))
        }()

        // RHR component (0-100, lower is better)
        let rhrScore: Double = {
            guard let todayRHR = todayMetrics.restingHeartRate, let baseline = baselineRHR,
                  baseline > 0, todayRHR > 0 else {
                return 50 // neutral
            }
            let ratio = baseline / todayRHR
            return min(100, max(0, 84 + (ratio - 1.0) * 160))
        }()

        // Sleep component (0-100, combining quality and duration)
        let sleepScore: Double = {
            var qualityPart: Double = 50
            if let todayQuality = todayMetrics.sleepStages?.qualityScore {
                qualityPart = todayQuality
            } else if let baseline = baselineSleepQuality {
                qualityPart = baseline
            }

            let actualSleep = todayMetrics.sleepStages?.total ?? todayMetrics.sleepHours
            var durationPart: Double = 50
            if let hours = actualSleep {
                if hours >= SleepDuration.optimalMin && hours <= SleepDuration.optimalMax {
                    durationPart = 100
                } else if hours >= SleepDuration.acceptableMin && hours < SleepDuration.optimalMin {
                    durationPart = 70
                } else if hours > SleepDuration.optimalMax && hours <= SleepDuration.acceptableMax {
                    durationPart = 80
                } else {
                    durationPart = max(0, 100 - abs(hours - SleepDuration.targetHours) * 20)
                }
            }

            return (qualityPart * 0.6 + durationPart * 0.4)
        }()

        // Activity component (0-100, based on steps and energy)
        let activityScore: Double = {
            var score: Double = 50 // neutral
            if let steps = todayMetrics.steps {
                let stepScore = min(Double(steps) / 10000.0 * 100.0, 100.0)
                score = stepScore
            }
            if let energy = todayMetrics.activeEnergy {
                let energyScore = min(energy / 500.0 * 100.0, 100.0)
                score = (score + energyScore) / 2
            }
            return score
        }()

        // Streak component (based on consistency of week data)
        let streakScore: Double = {
            let daysWithData = weekMetrics.filter { metrics in
                metrics.heartRateVariability != nil || metrics.restingHeartRate != nil || metrics.sleepHours != nil
            }.count
            return min(100, Double(daysWithData) / 7.0 * 100.0)
        }()

        // Weighted overall score
        let overallScore = min(100, max(0,
            hrvScore * configuration.hrvWeight +
            rhrScore * configuration.rhrWeight +
            sleepScore * configuration.sleepWeight +
            activityScore * configuration.activityWeight +
            streakScore * configuration.streakWeight
        ))

        // Trend detection
        let trend = detectTrend(currentScore: overallScore, historicalScores: historicalScores)

        // Level classification
        let level = ReadinessLevel.from(score: overallScore)

        // Component scores dictionary
        let componentScores: [String: Double] = [
            "hrv": round(hrvScore * 10) / 10,
            "rhr": round(rhrScore * 10) / 10,
            "sleep": round(sleepScore * 10) / 10,
            "activity": round(activityScore * 10) / 10,
            "streak": round(streakScore * 10) / 10
        ]

        // Generate recommendation
        let recommendation = generateV2Recommendation(
            level: level,
            trend: trend,
            componentScores: componentScores
        )

        return ReadinessResult(
            score: round(overallScore * 10) / 10,
            level: level,
            trend: trend,
            componentScores: componentScores,
            recommendation: recommendation
        )
    }

    // MARK: - Trend Detection

    func detectTrend(currentScore: Double, historicalScores: [Double]) -> ReadinessTrend {
        guard !historicalScores.isEmpty else { return .stable }

        let rollingAverage = historicalScores.reduce(0, +) / Double(historicalScores.count)
        guard rollingAverage > 0 else { return .stable }

        let deviation = ((currentScore - rollingAverage) / rollingAverage) * 100

        if deviation > TrendThreshold.significantDeviation {
            return .improving
        } else if deviation < -TrendThreshold.significantDeviation {
            return .declining
        }
        return .stable
    }

    // MARK: - Legacy Implementation

    private func executeLegacy(todayMetrics: HealthMetrics, weekMetrics: [HealthMetrics]) -> ReadinessScore {
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

        // Also compute v2 result for the structured data
        let v2Result = ReadinessResult(
            score: overallScore,
            level: ReadinessLevel.from(score: overallScore),
            trend: .stable,
            componentScores: [
                "hrv": round(hrvContribution * 10) / 10,
                "rhr": round(rhrContribution * 10) / 10,
                "sleep": round(sleepQualityContribution * 10) / 10,
                "activity": round(sleepDurationContribution * 10) / 10,
                "streak": 0
            ],
            recommendation: recommendation
        )

        return ReadinessScore(
            overallScore: overallScore,
            hrvContribution: hrvContribution,
            rhrContribution: rhrContribution,
            sleepQualityContribution: sleepQualityContribution,
            sleepDurationContribution: sleepDurationContribution,
            recommendation: recommendation,
            result: v2Result
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

    private func generateV2Recommendation(
        level: ReadinessLevel,
        trend: ReadinessTrend,
        componentScores: [String: Double]
    ) -> String {
        let weakest = componentScores.min(by: { $0.value < $1.value })?.key ?? "sleep"

        let trendSuffix: String
        switch trend {
        case .improving: trendSuffix = " Your recovery trend is improving."
        case .declining: trendSuffix = " Watch your recovery trend - it's been declining."
        case .stable: trendSuffix = ""
        }

        switch level {
        case .optimal:
            return "Excellent recovery. You're primed for peak performance.\(trendSuffix)"
        case .good:
            return "Good recovery. You can train at moderate to high intensity.\(trendSuffix)"
        case .moderate:
            let advice: String
            switch weakest {
            case "hrv": advice = "HRV is below baseline - consider lighter training."
            case "rhr": advice = "Elevated resting heart rate - monitor stress levels."
            case "sleep": advice = "Sleep needs attention - prioritize rest tonight."
            case "activity": advice = "Activity levels are low - try to move more today."
            default: advice = "Focus on balanced recovery across all areas."
            }
            return "Moderate recovery. \(advice)\(trendSuffix)"
        case .low:
            return "Below average recovery. Focus on rest and light activity.\(trendSuffix)"
        case .rest:
            return "Low recovery. Prioritize rest, hydration, and an early bedtime.\(trendSuffix)"
        }
    }
}
