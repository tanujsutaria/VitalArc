//
//  WorkoutSetModel.swift
//  VitalArc
//
//  SwiftData Model for Workout Set
//

import Foundation
import SwiftData

@Model
final class WorkoutSetModel {
    @Attribute(.unique) var id: UUID
    var exerciseId: UUID
    var weight: Double
    var reps: Int
    var rir: Int?
    var rpe: Double?
    var mesocycleId: UUID?
    var setNumber: Int
    var completed: Bool
    var notes: String?

    init(
        id: UUID = UUID(),
        exerciseId: UUID,
        weight: Double,
        reps: Int,
        rir: Int? = nil,
        rpe: Double? = nil,
        mesocycleId: UUID? = nil,
        setNumber: Int,
        completed: Bool = true,
        notes: String? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.weight = weight
        self.reps = reps
        self.rir = rir
        self.rpe = rpe
        self.mesocycleId = mesocycleId
        self.setNumber = setNumber
        self.completed = completed
        self.notes = notes
    }

    /// Convert to domain entity
    func toDomain() -> WorkoutSet {
        WorkoutSet(
            id: id,
            exerciseId: exerciseId,
            weight: weight,
            reps: reps,
            rir: rir,
            rpe: rpe,
            mesocycleId: mesocycleId,
            setNumber: setNumber,
            completed: completed,
            notes: notes
        )
    }

    /// Create from domain entity
    static func fromDomain(_ set: WorkoutSet) -> WorkoutSetModel {
        WorkoutSetModel(
            id: set.id,
            exerciseId: set.exerciseId,
            weight: set.weight,
            reps: set.reps,
            rir: set.rir,
            rpe: set.rpe,
            mesocycleId: set.mesocycleId,
            setNumber: set.setNumber,
            completed: set.completed,
            notes: set.notes
        )
    }
}
