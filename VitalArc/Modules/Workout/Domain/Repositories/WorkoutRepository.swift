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
    func updateExercise(_ exercise: Exercise) async throws
    func deleteExercise(id: UUID) async throws
    func isExerciseUsedInWorkouts(_ exerciseId: UUID) async throws -> Bool

    // Workout operations
    func getWorkouts() async throws -> [Workout]
    func getWorkout(id: UUID) async throws -> Workout?
    func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout]
    func saveWorkout(_ workout: Workout) async throws
    func deleteWorkout(id: UUID) async throws

    // HealthKit import
    func getWorkoutByHealthKitId(_ healthKitId: String) async throws -> Workout?

    // Progression
    func getLastWorkoutForExercise(_ exerciseId: UUID) async throws -> Workout?

    // Custom Categories
    func getCustomCategories() async throws -> [CustomCategory]
    func saveCustomCategory(_ category: CustomCategory) async throws
    func deleteCustomCategory(id: UUID) async throws
}
