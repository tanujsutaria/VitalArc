//
//  ReadinessScore.swift
//  VitalArc
//
//  Domain entity for personalized readiness/recovery scoring
//

import Foundation

/// Readiness score computed from personalized baselines using 7-day rolling averages
struct ReadinessScore: Equatable {
    let overallScore: Double // 0-100
    let hrvContribution: Double // 0-40
    let rhrContribution: Double // 0-25
    let sleepQualityContribution: Double // 0-20
    let sleepDurationContribution: Double // 0-15
    let recommendation: String

    var level: ReadinessLevel {
        switch overallScore {
        case 0..<30: return .poor
        case 30..<50: return .fair
        case 50..<70: return .moderate
        case 70..<85: return .good
        default: return .optimal
        }
    }
}

enum ReadinessLevel: String {
    case poor = "Poor"
    case fair = "Fair"
    case moderate = "Moderate"
    case good = "Good"
    case optimal = "Optimal"
}
