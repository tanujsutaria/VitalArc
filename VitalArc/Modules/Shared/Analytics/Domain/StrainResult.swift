//
//  StrainResult.swift
//  VitalArc
//
//  Domain entity for training strain/TRIMP calculation results
//

import Foundation

/// Result of TRIMP (Training Impulse) calculation for a workout or day
struct StrainResult: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let trimpScore: Double           // Raw TRIMP value
    let strainScore: Double          // Normalized to 0-21 (WHOOP-style)
    let duration: TimeInterval       // Total workout duration in seconds
    let averageHeartRate: Double?    // Average HR across all workouts
    let maxHeartRate: Double?        // Peak HR reached
    let heartRateReserve: Double?    // HR Reserve % utilized
    let workoutCount: Int            // Number of workouts aggregated
    let calculationMethod: TRIMPMethod
    let strainLevel: StrainLevel
    let recommendation: String

    init(
        id: UUID = UUID(),
        date: Date,
        trimpScore: Double,
        strainScore: Double,
        duration: TimeInterval,
        averageHeartRate: Double? = nil,
        maxHeartRate: Double? = nil,
        heartRateReserve: Double? = nil,
        workoutCount: Int = 1,
        calculationMethod: TRIMPMethod,
        recommendation: String? = nil
    ) {
        self.id = id
        self.date = date
        self.trimpScore = trimpScore
        self.strainScore = strainScore
        self.duration = duration
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.heartRateReserve = heartRateReserve
        self.workoutCount = workoutCount
        self.calculationMethod = calculationMethod
        self.strainLevel = StrainLevel(score: strainScore)
        self.recommendation = recommendation ?? StrainLevel(score: strainScore).defaultRecommendation
    }

    /// TRIMP calculation methodology used
    enum TRIMPMethod: String, Codable {
        case banister = "Banister (Exponential)"
        case edwards = "Edwards (Zone-Based)"
        case estimated = "Estimated (No HR Data)"
    }

    /// Strain level interpretation (0-21 scale)
    enum StrainLevel: String, Codable {
        case rest = "Rest"               // 0-2.9
        case light = "Light"             // 3-5.9
        case moderate = "Moderate"       // 6-9.9
        case hard = "Hard"               // 10-13.9
        case veryHard = "Very Hard"      // 14-17.9
        case allOut = "All Out"          // 18-21

        init(score: Double) {
            switch score {
            case 0..<3: self = .rest
            case 3..<6: self = .light
            case 6..<10: self = .moderate
            case 10..<14: self = .hard
            case 14..<18: self = .veryHard
            default: self = .allOut
            }
        }

        var defaultRecommendation: String {
            switch self {
            case .rest:
                return "Minimal training load. Good day for rest or active recovery."
            case .light:
                return "Light training load. Suitable for recovery sessions or skill work."
            case .moderate:
                return "Moderate training load. Good balance of training stimulus and recovery."
            case .hard:
                return "High training load. Ensure adequate recovery before next hard session."
            case .veryHard:
                return "Very high training load. Monitor recovery closely. Consider rest day tomorrow."
            case .allOut:
                return "Maximal training load. Extended recovery required. Prioritize sleep and nutrition."
            }
        }
    }
}
