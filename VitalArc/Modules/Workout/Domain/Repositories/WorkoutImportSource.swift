//
//  WorkoutImportSource.swift
//  VitalArc
//
//  Protocol abstracting workout import data source for testability
//

import Foundation

/// Data transferred from an external workout source (e.g., HealthKit)
struct ImportedWorkoutData: Sendable, Equatable {
    let healthKitId: String
    let startDate: Date
    let activityName: String
    let duration: TimeInterval
}

/// Protocol for fetching workouts from an external source
protocol WorkoutImportSource: Sendable {
    func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [ImportedWorkoutData]
}
