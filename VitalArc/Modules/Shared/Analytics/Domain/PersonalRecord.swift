//
//  PersonalRecord.swift
//  VitalArc
//
//  Domain entity for tracking personal records
//

import Foundation

/// A personal record for a specific exercise
struct PersonalRecord: Identifiable, Equatable {
    let id: UUID
    let exerciseId: UUID
    let exerciseName: String
    let recordType: RecordType
    let value: Double
    let reps: Int?
    let date: Date
    let videoURL: String?
    let notes: String?

    init(
        id: UUID = UUID(),
        exerciseId: UUID,
        exerciseName: String,
        recordType: RecordType,
        value: Double,
        reps: Int? = nil,
        date: Date,
        videoURL: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.recordType = recordType
        self.value = value
        self.reps = reps
        self.date = date
        self.videoURL = videoURL
        self.notes = notes
    }

    /// Display string for the record
    var displayValue: String {
        switch recordType {
        case .oneRepMax, .threeRepMax, .fiveRepMax, .tenRepMax:
            return "\(Int(value)) kg"
        case .maxVolume:
            return "\(Int(value)) kg total"
        case .maxReps:
            return "\(reps ?? 0) reps"
        }
    }

    /// Days since record was set
    var daysSince: Int {
        Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }

    /// Whether record is recent (within 30 days)
    var isRecent: Bool {
        daysSince <= 30
    }
}

/// Types of personal records
enum RecordType: String, CaseIterable, Codable {
    case oneRepMax = "1RM"
    case threeRepMax = "3RM"
    case fiveRepMax = "5RM"
    case tenRepMax = "10RM"
    case maxVolume = "Max Volume"
    case maxReps = "Max Reps"

    var displayName: String {
        rawValue
    }

    var description: String {
        switch self {
        case .oneRepMax:
            return "One Rep Max"
        case .threeRepMax:
            return "Three Rep Max"
        case .fiveRepMax:
            return "Five Rep Max"
        case .tenRepMax:
            return "Ten Rep Max"
        case .maxVolume:
            return "Maximum Volume"
        case .maxReps:
            return "Maximum Reps"
        }
    }

    var icon: String {
        switch self {
        case .oneRepMax:
            return "trophy.fill"
        case .threeRepMax, .fiveRepMax, .tenRepMax:
            return "medal.fill"
        case .maxVolume:
            return "chart.bar.fill"
        case .maxReps:
            return "number.circle.fill"
        }
    }
}

/// Comprehensive progress report
struct ProgressReport: Equatable {
    let period: DateInterval
    let bodyWeightChange: Double?
    let volumeChange: Double
    let recordsBroken: [PersonalRecord]
    let workoutConsistency: Double // percentage
    let avgCalorieAdherence: Double // percentage
    let avgSleepHours: Double?
    let avgHRV: Double?

    init(
        period: DateInterval,
        bodyWeightChange: Double? = nil,
        volumeChange: Double,
        recordsBroken: [PersonalRecord],
        workoutConsistency: Double,
        avgCalorieAdherence: Double,
        avgSleepHours: Double? = nil,
        avgHRV: Double? = nil
    ) {
        self.period = period
        self.bodyWeightChange = bodyWeightChange
        self.volumeChange = volumeChange
        self.recordsBroken = recordsBroken
        self.workoutConsistency = workoutConsistency
        self.avgCalorieAdherence = avgCalorieAdherence
        self.avgSleepHours = avgSleepHours
        self.avgHRV = avgHRV
    }

    /// Overall progress score (0-100)
    var progressScore: Double {
        var score = 0.0
        var factors = 0

        // Workout consistency (30%)
        score += workoutConsistency * 0.3
        factors += 1

        // Calorie adherence (20%)
        score += avgCalorieAdherence * 0.2
        factors += 1

        // Volume change (20%)
        let volumeScore = min(max(volumeChange + 50, 0), 100)
        score += volumeScore * 0.2
        factors += 1

        // Records broken (20%)
        let recordScore = min(Double(recordsBroken.count) * 10, 100)
        score += recordScore * 0.2
        factors += 1

        // Sleep (10%) - if available
        if let sleepHours = avgSleepHours {
            let sleepScore = min(max((sleepHours - 5) / 3 * 100, 0), 100)
            score += sleepScore * 0.1
            factors += 1
        }

        return score
    }

    /// Progress summary
    var summary: String {
        let score = progressScore
        if score >= 80 {
            return "Excellent Progress"
        } else if score >= 60 {
            return "Good Progress"
        } else if score >= 40 {
            return "Moderate Progress"
        } else {
            return "Needs Improvement"
        }
    }
}
