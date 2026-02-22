//
//  WorkoutDataProviding.swift
//  VitalArc
//
//  Cross-domain protocol for read-only workout data access
//

import Foundation

/// Protocol for cross-domain read-only access to workout data.
/// Used by Analytics and other domains that need workout information
/// without depending on the full WorkoutRepository.
protocol WorkoutDataProviding {
    func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout]
    func getTodayWorkouts() async throws -> [Workout]
    func getLastWorkoutForExercise(_ exerciseId: UUID) async throws -> Workout?
    func getExercise(id: UUID) async throws -> Exercise?
}
