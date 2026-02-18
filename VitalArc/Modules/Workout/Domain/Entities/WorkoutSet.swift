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
    let rir: Int? // Reps in Reserve (0-5)
    let rpe: Double? // Rate of Perceived Exertion (1-10)
    let mesocycleId: UUID? // Link to active mesocycle
    let setNumber: Int
    let completed: Bool
    let notes: String?

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

    /// Volume for this set (weight × reps)
    var volume: Double {
        weight * Double(reps)
    }
}
