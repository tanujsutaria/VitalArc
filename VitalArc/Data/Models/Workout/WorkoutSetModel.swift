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
    var setNumber: Int
    var completed: Bool

    init(
        id: UUID = UUID(),
        exerciseId: UUID,
        weight: Double,
        reps: Int,
        rir: Int? = nil,
        setNumber: Int,
        completed: Bool = true
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.weight = weight
        self.reps = reps
        self.rir = rir
        self.setNumber = setNumber
        self.completed = completed
    }

    /// Convert to domain entity
    func toDomain() -> WorkoutSet {
        WorkoutSet(
            id: id,
            exerciseId: exerciseId,
            weight: weight,
            reps: reps,
            rir: rir,
            setNumber: setNumber,
            completed: completed
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
            setNumber: set.setNumber,
            completed: set.completed
        )
    }
}
