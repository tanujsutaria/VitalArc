//
//  Mesocycle.swift
//  VitalArc
//
//  Domain Entity for Mesocycle (Training Program)
//

import Foundation

/// Domain entity representing a mesocycle - a multi-week training program
struct Mesocycle: Identifiable, Equatable {
    let id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var phases: [MesocyclePhase]
    var trainingBlocks: [TrainingBlock]
    var goal: TrainingGoal
    var status: MesocycleStatus
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date,
        endDate: Date,
        phases: [MesocyclePhase] = [],
        trainingBlocks: [TrainingBlock] = [],
        goal: TrainingGoal,
        status: MesocycleStatus = .planned,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.phases = phases
        self.trainingBlocks = trainingBlocks
        self.goal = goal
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Total duration in weeks
    var durationWeeks: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: startDate, to: endDate)
        return (components.weekOfYear ?? 0) + 1
    }

    /// Current week number (1-based)
    var currentWeek: Int? {
        guard status == .active else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: startDate, to: Date())
        let week = (components.weekOfYear ?? 0) + 1
        return week <= durationWeeks ? week : nil
    }

    /// Current phase based on today's date
    var currentPhase: MesocyclePhase? {
        guard let week = currentWeek else { return nil }
        return phases.first { $0.weekNumber == week }
    }

    /// Progress percentage (0-100)
    var progressPercentage: Double {
        guard status == .active, let week = currentWeek else {
            return status == .completed ? 100 : 0
        }
        return (Double(week) / Double(durationWeeks)) * 100
    }
}

/// Training goal for the mesocycle
enum TrainingGoal: String, CaseIterable, Codable {
    case strength = "Strength"
    case hypertrophy = "Hypertrophy"
    case peaking = "Peaking"
    case endurance = "Endurance"

    var description: String {
        switch self {
        case .strength:
            return "Build maximum strength"
        case .hypertrophy:
            return "Increase muscle size"
        case .peaking:
            return "Peak performance for competition"
        case .endurance:
            return "Improve muscular endurance"
        }
    }

    var icon: String {
        switch self {
        case .strength:
            return "bolt.fill"
        case .hypertrophy:
            return "figure.strengthtraining.traditional"
        case .peaking:
            return "trophy.fill"
        case .endurance:
            return "timer"
        }
    }
}

/// Status of the mesocycle
enum MesocycleStatus: String, CaseIterable, Codable {
    case planned = "Planned"
    case active = "Active"
    case completed = "Completed"

    var color: String {
        switch self {
        case .planned:
            return "gray"
        case .active:
            return "blue"
        case .completed:
            return "green"
        }
    }
}
