//
//  WorkoutSet.swift
//  VitalArc
//
//  Domain Entity for Workout Set
//

import Foundation

/// Domain entity representing a single set in a workout
struct WorkoutSet: Identifiable, Equatable {
    let id: UUID
    let exerciseId: UUID
    let weight: Double // in kg
    let reps: Int
    let rir: Int? // Reps in Reserve (optional)
    let setNumber: Int
    let completed: Bool

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

    /// Volume for this set (weight × reps)
    var volume: Double {
        weight * Double(reps)
    }
}
