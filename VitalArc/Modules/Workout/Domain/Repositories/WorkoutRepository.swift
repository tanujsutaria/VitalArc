//
//  WorkoutRepository.swift
//  VitalArc
//
//  Repository Protocol for Workout Domain
//

import Foundation

protocol WorkoutRepository {
    // Exercise operations
    func getExercises() async throws -> [Exercise]
    func getExercise(id: UUID) async throws -> Exercise?
    func searchExercises(query: String) async throws -> [Exercise]
    func saveExercise(_ exercise: Exercise) async throws

    // Workout operations
    func getWorkouts() async throws -> [Workout]
    func getWorkout(id: UUID) async throws -> Workout?
    func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout]
    func saveWorkout(_ workout: Workout) async throws
    func deleteWorkout(id: UUID) async throws

    // Progression
    func getLastWorkoutForExercise(_ exerciseId: UUID) async throws -> Workout?
}
