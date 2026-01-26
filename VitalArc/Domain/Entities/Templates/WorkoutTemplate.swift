//
//  WorkoutTemplate.swift
//  VitalArc
//
//  Domain entity for workout templates
//

import Foundation

/// A reusable workout template
struct WorkoutTemplate: Identifiable, Equatable {
    let id: UUID
    var name: String
    var description: String?
    var exercises: [TemplateExercise]
    var category: TemplateCategory
    var estimatedDuration: Int // minutes
    var createdAt: Date
    var lastUsed: Date?
    var useCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        exercises: [TemplateExercise] = [],
        category: TemplateCategory = .custom,
        estimatedDuration: Int = 60,
        createdAt: Date = Date(),
        lastUsed: Date? = nil,
        useCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.exercises = exercises
        self.category = category
        self.estimatedDuration = estimatedDuration
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.useCount = useCount
    }

    /// Total number of sets in template
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets }
    }

    /// Exercise count
    var exerciseCount: Int {
        exercises.count
    }

    /// Mark template as used
    mutating func markAsUsed() {
        useCount += 1
        lastUsed = Date()
    }
}

/// Exercise configuration within a template
struct TemplateExercise: Identifiable, Equatable {
    let id: UUID
    let exerciseId: UUID
    let orderIndex: Int
    var sets: Int
    var repsMin: Int
    var repsMax: Int
    var restSeconds: Int
    var notes: String?

    init(
        id: UUID = UUID(),
        exerciseId: UUID,
        orderIndex: Int,
        sets: Int = 3,
        repsMin: Int = 8,
        repsMax: Int = 12,
        restSeconds: Int = 90,
        notes: String? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.orderIndex = orderIndex
        self.sets = sets
        self.repsMin = repsMin
        self.repsMax = repsMax
        self.restSeconds = restSeconds
        self.notes = notes
    }

    /// Display string for reps
    var repsDisplay: String {
        if repsMin == repsMax {
            return "\(repsMin)"
        } else {
            return "\(repsMin)-\(repsMax)"
        }
    }

    /// Display string for rest
    var restDisplay: String {
        let minutes = restSeconds / 60
        let seconds = restSeconds % 60

        if minutes > 0 && seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}

/// Template categories for organization
enum TemplateCategory: String, CaseIterable, Codable {
    case pushPullLegs = "Push/Pull/Legs"
    case upperLower = "Upper/Lower"
    case fullBody = "Full Body"
    case bodybuilding = "Bodybuilding"
    case powerlifting = "Powerlifting"
    case custom = "Custom"

    var displayName: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .pushPullLegs:
            return "figure.strengthtraining.traditional"
        case .upperLower:
            return "figure.arms.open"
        case .fullBody:
            return "figure.mixed.cardio"
        case .bodybuilding:
            return "dumbbell.fill"
        case .powerlifting:
            return "trophy.fill"
        case .custom:
            return "star.fill"
        }
    }

    var description: String {
        switch self {
        case .pushPullLegs:
            return "Split workouts into push, pull, and leg days"
        case .upperLower:
            return "Alternate between upper and lower body workouts"
        case .fullBody:
            return "Work entire body in each session"
        case .bodybuilding:
            return "Focus on muscle hypertrophy and aesthetics"
        case .powerlifting:
            return "Focus on strength in squat, bench, and deadlift"
        case .custom:
            return "Custom workout program"
        }
    }
}
