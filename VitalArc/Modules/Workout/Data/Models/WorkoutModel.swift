//
//  WorkoutModel.swift
//  VitalArc
//
//  SwiftData Model for Workout
//

import Foundation
import SwiftData

@Model
final class WorkoutModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var name: String?
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSetModel]
    var notes: String?
    var duration: TimeInterval?
    var source: String?
    var healthKitId: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        name: String? = nil,
        sets: [WorkoutSetModel] = [],
        notes: String? = nil,
        duration: TimeInterval? = nil,
        source: String? = nil,
        healthKitId: String? = nil
    ) {
        self.id = id
        self.date = date
        self.name = name
        self.sets = sets
        self.notes = notes
        self.duration = duration
        self.source = source
        self.healthKitId = healthKitId
    }

    /// Convert to domain entity
    func toDomain() -> Workout {
        Workout(
            id: id,
            date: date,
            name: name,
            sets: sets.map { $0.toDomain() },
            notes: notes,
            duration: duration,
            source: WorkoutSource(rawValue: source ?? "local") ?? .local,
            healthKitId: healthKitId
        )
    }

    /// Create from domain entity
    static func fromDomain(_ workout: Workout, sets: [WorkoutSetModel]) -> WorkoutModel {
        WorkoutModel(
            id: workout.id,
            date: workout.date,
            name: workout.name,
            sets: sets,
            notes: workout.notes,
            duration: workout.duration,
            source: workout.source.rawValue,
            healthKitId: workout.healthKitId
        )
    }
}
