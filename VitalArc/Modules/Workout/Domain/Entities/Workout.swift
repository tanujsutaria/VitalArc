//
//  Workout.swift
//  VitalArc
//
//  Domain Entity for Workout
//

import Foundation

/// Domain entity representing a workout session
struct Workout: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let name: String?
    let sets: [WorkoutSet]
    let notes: String?
    let duration: TimeInterval?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        name: String? = nil,
        sets: [WorkoutSet] = [],
        notes: String? = nil,
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.date = date
        self.name = name
        self.sets = sets
        self.notes = notes
        self.duration = duration
    }

    /// Total volume for this workout (weight × reps)
    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }

    /// Total number of sets
    var totalSets: Int {
        sets.count
    }

    /// Unique exercises in this workout
    var exercises: [UUID] {
        Array(Set(sets.map { $0.exerciseId }))
    }
}
