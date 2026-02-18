//
//  ExerciseHistoryPoint.swift
//  VitalArc
//
//  Domain entity for exercise progress tracking data point
//

import Foundation

/// A single data point in an exercise's progression history
struct ExerciseHistoryPoint: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let maxWeight: Double // in kg
    let totalVolume: Double // weight x reps summed across all sets
    let estimated1RM: Double // Epley formula: weight * (1 + reps/30)

    init(
        id: UUID = UUID(),
        date: Date,
        maxWeight: Double,
        totalVolume: Double,
        estimated1RM: Double
    ) {
        self.id = id
        self.date = date
        self.maxWeight = maxWeight
        self.totalVolume = totalVolume
        self.estimated1RM = estimated1RM
    }
}
