//
//  ReadinessScore.swift
//  VitalArc
//
//  Domain entity for personalized readiness/recovery scoring
//

import Foundation

/// Configurable weights for readiness score components.
/// All weights should sum to 1.0 for proper scoring.
struct ReadinessConfiguration: Equatable {
    var sleepWeight: Double = 0.30
    var hrvWeight: Double = 0.25
    var rhrWeight: Double = 0.20
    var activityWeight: Double = 0.15
    var streakWeight: Double = 0.10

    /// Default configuration with standard weights
    static let `default` = ReadinessConfiguration()

    /// Total of all weights (should be 1.0 for proper scoring)
    var totalWeight: Double {
        sleepWeight + hrvWeight + rhrWeight + activityWeight + streakWeight
    }
}

/// Readiness level classification based on score ranges
enum ReadinessLevel: String, CaseIterable {
    case rest = "Rest"
    case low = "Low"
    case moderate = "Moderate"
    case good = "Good"
    case optimal = "Optimal"

    /// Classify a score (0-100) into a readiness level
    static func from(score: Double) -> ReadinessLevel {
        switch score {
        case ..<20: return .rest
        case 20..<40: return .low
        case 40..<60: return .moderate
        case 60..<80: return .good
        case 80...: return .optimal
        default: return .rest
        }
    }
}

/// Trend of readiness scores over time
enum ReadinessTrend: String {
    case improving = "Improving"
    case stable = "Stable"
    case declining = "Declining"
}

/// Structured result from readiness score calculation
struct ReadinessResult: Equatable {
    let score: Double
    let level: ReadinessLevel
    let trend: ReadinessTrend
    let componentScores: [String: Double]
    let recommendation: String

    /// Convenience for backward compatibility
    var overallScore: Double { score }
}

/// Readiness score computed from personalized baselines using 7-day rolling averages
struct ReadinessScore: Equatable {
    let overallScore: Double // 0-100
    let hrvContribution: Double // contribution from HRV
    let rhrContribution: Double // contribution from RHR
    let sleepQualityContribution: Double // contribution from sleep quality
    let sleepDurationContribution: Double // contribution from sleep duration
    let recommendation: String
    let result: ReadinessResult?

    init(
        overallScore: Double,
        hrvContribution: Double,
        rhrContribution: Double,
        sleepQualityContribution: Double,
        sleepDurationContribution: Double,
        recommendation: String,
        result: ReadinessResult? = nil
    ) {
        self.overallScore = overallScore
        self.hrvContribution = hrvContribution
        self.rhrContribution = rhrContribution
        self.sleepQualityContribution = sleepQualityContribution
        self.sleepDurationContribution = sleepDurationContribution
        self.recommendation = recommendation
        self.result = result
    }

    var level: ReadinessLevel {
        if let result = result {
            return result.level
        }
        return ReadinessLevel.from(score: overallScore)
    }

    var trend: ReadinessTrend {
        result?.trend ?? .stable
    }
}
