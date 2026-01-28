//
//  TrainingBlock.swift
//  VitalArc
//
//  Domain Entity for Training Block
//

import Foundation

/// Domain entity representing a training block (e.g., one workout day in the week)
struct TrainingBlock: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var dayOfWeek: Int // 1 = Sunday, 2 = Monday, etc. (matches Calendar.component(.weekday))
    var exercises: [TrainingBlockExercise]
    var mesocycleId: UUID

    init(
        id: UUID = UUID(),
        name: String,
        dayOfWeek: Int,
        exercises: [TrainingBlockExercise] = [],
        mesocycleId: UUID
    ) {
        self.id = id
        self.name = name
        self.dayOfWeek = dayOfWeek
        self.exercises = exercises
        self.mesocycleId = mesocycleId
    }

    /// Day of week name
    var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let weekdaySymbols = formatter.weekdaySymbols ?? []
        let index = (dayOfWeek - 1) % 7
        return weekdaySymbols[index]
    }

    /// Total number of sets in this block
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.targetSets }
    }

    /// Estimated duration in minutes (3 min per set as baseline)
    var estimatedDuration: Int {
        totalSets * 3
    }
}

/// Exercise within a training block
struct TrainingBlockExercise: Identifiable, Equatable, Codable {
    let id: UUID
    var exerciseId: UUID
    var orderIndex: Int
    var targetSets: Int
    var targetRepsMin: Int
    var targetRepsMax: Int
    var targetRIR: Int // Reps in Reserve
    var progressionScheme: ProgressionScheme
    var notes: String?

    init(
        id: UUID = UUID(),
        exerciseId: UUID,
        orderIndex: Int,
        targetSets: Int,
        targetRepsMin: Int,
        targetRepsMax: Int,
        targetRIR: Int = 2,
        progressionScheme: ProgressionScheme = .doubleProgression,
        notes: String? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.orderIndex = orderIndex
        self.targetSets = targetSets
        self.targetRepsMin = targetRepsMin
        self.targetRepsMax = targetRepsMax
        self.targetRIR = targetRIR
        self.progressionScheme = progressionScheme
        self.notes = notes
    }

    /// Rep range as string
    var repRange: String {
        if targetRepsMin == targetRepsMax {
            return "\(targetRepsMin)"
        }
        return "\(targetRepsMin)-\(targetRepsMax)"
    }

    /// Full prescription string (e.g., "3 sets x 8-12 reps @ 2 RIR")
    var prescription: String {
        let setsText = targetSets == 1 ? "1 set" : "\(targetSets) sets"
        let repsText = repRange
        return "\(setsText) x \(repsText) reps @ \(targetRIR) RIR"
    }
}

/// Progression scheme for an exercise
enum ProgressionScheme: String, CaseIterable, Codable {
    case linear = "Linear"
    case doubleProgression = "Double Progression"
    case wave = "Wave"
    case `static` = "Static"

    var description: String {
        switch self {
        case .linear:
            return "Add weight each week (e.g., +2.5kg)"
        case .doubleProgression:
            return "Add reps until max reached, then add weight"
        case .wave:
            return "Undulating intensity week to week"
        case .static:
            return "Maintain current weight and reps"
        }
    }

    var icon: String {
        switch self {
        case .linear:
            return "arrow.up.right"
        case .doubleProgression:
            return "arrow.up.and.down"
        case .wave:
            return "waveform"
        case .static:
            return "equal"
        }
    }
}

/// Auto-regulation advice based on performance
struct AutoRegulationAdvice: Equatable {
    let recommendation: Recommendation
    let reason: String
    let suggestedWeightChange: Double? // in kg

    enum Recommendation: String {
        case increaseWeight = "Increase Weight"
        case decreaseWeight = "Decrease Weight"
        case maintain = "Maintain"
        case deload = "Deload"
    }
}
