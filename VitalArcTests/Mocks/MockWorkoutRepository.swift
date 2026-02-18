//
//  MockWorkoutRepository.swift
//  VitalArcTests
//
//  Mock implementation of WorkoutRepository for testing
//

import Foundation
@testable import VitalArc

final class MockWorkoutRepository: WorkoutRepository {
    // MARK: - Mock Data

    var mockExercises: [Exercise] = []
    var mockWorkouts: [Workout] = []

    // MARK: - Call Tracking

    var savedExercises: [Exercise] = []
    var savedWorkouts: [Workout] = []
    var deletedWorkoutIds: [UUID] = []
    var searchQueries: [String] = []

    // MARK: - Error Simulation

    var shouldThrowOnSave = false
    var shouldThrowOnDelete = false
    var shouldThrowOnGet = false
    var shouldThrowOnSearch = false

    // MARK: - Exercise Operations

    func getExercises() async throws -> [Exercise] {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        return mockExercises
    }

    func getExercise(id: UUID) async throws -> Exercise? {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        return mockExercises.first { $0.id == id }
    }

    func searchExercises(query: String) async throws -> [Exercise] {
        searchQueries.append(query)
        if shouldThrowOnSearch {
            throw MockError.searchFailed
        }
        return mockExercises.filter { $0.name.lowercased().contains(query.lowercased()) }
    }

    func saveExercise(_ exercise: Exercise) async throws {
        if shouldThrowOnSave {
            throw MockError.saveFailed
        }
        savedExercises.append(exercise)
        if !mockExercises.contains(where: { $0.id == exercise.id }) {
            mockExercises.append(exercise)
        }
    }

    func updateExercise(_ exercise: Exercise) async throws {
        if shouldThrowOnSave {
            throw MockError.saveFailed
        }
        if let index = mockExercises.firstIndex(where: { $0.id == exercise.id }) {
            mockExercises[index] = exercise
        }
    }

    func deleteExercise(id: UUID) async throws {
        if shouldThrowOnDelete {
            throw MockError.deleteFailed
        }
        mockExercises.removeAll { $0.id == id }
    }

    func isExerciseUsedInWorkouts(_ exerciseId: UUID) async throws -> Bool {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        return mockWorkouts.contains { workout in
            workout.sets.contains { $0.exerciseId == exerciseId }
        }
    }

    // MARK: - Workout Operations

    func getWorkouts() async throws -> [Workout] {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        return mockWorkouts
    }

    func getWorkout(id: UUID) async throws -> Workout? {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        return mockWorkouts.first { $0.id == id }
    }

    func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout] {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        return mockWorkouts.filter { workout in
            workout.date >= startDate && workout.date <= endDate
        }
    }

    func getWorkoutByHealthKitId(_ healthKitId: String) async throws -> Workout? {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        return mockWorkouts.first { $0.healthKitId == healthKitId }
    }

    func saveWorkout(_ workout: Workout) async throws {
        if shouldThrowOnSave {
            throw MockError.saveFailed
        }
        savedWorkouts.append(workout)
        if let existingIndex = mockWorkouts.firstIndex(where: { $0.id == workout.id }) {
            mockWorkouts[existingIndex] = workout
        } else {
            mockWorkouts.append(workout)
        }
    }

    func deleteWorkout(id: UUID) async throws {
        if shouldThrowOnDelete {
            throw MockError.deleteFailed
        }
        deletedWorkoutIds.append(id)
        mockWorkouts.removeAll { $0.id == id }
    }

    // MARK: - Progression

    func getLastWorkoutForExercise(_ exerciseId: UUID) async throws -> Workout? {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        // Find workouts that contain sets for this exercise
        let relevantWorkouts = mockWorkouts.filter { workout in
            workout.sets.contains { $0.exerciseId == exerciseId }
        }
        // Return the most recent one
        return relevantWorkouts.sorted { $0.date > $1.date }.first
    }

    // MARK: - Custom Categories

    var mockCustomCategories: [CustomCategory] = []
    var savedCustomCategories: [CustomCategory] = []
    var deletedCustomCategoryIds: [UUID] = []

    func getCustomCategories() async throws -> [CustomCategory] {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        return mockCustomCategories
    }

    func saveCustomCategory(_ category: CustomCategory) async throws {
        if shouldThrowOnSave {
            throw MockError.saveFailed
        }
        savedCustomCategories.append(category)
        if let idx = mockCustomCategories.firstIndex(where: { $0.id == category.id }) {
            mockCustomCategories[idx] = category
        } else {
            mockCustomCategories.append(category)
        }
    }

    func deleteCustomCategory(id: UUID) async throws {
        if shouldThrowOnDelete {
            throw MockError.deleteFailed
        }
        deletedCustomCategoryIds.append(id)
        mockCustomCategories.removeAll { $0.id == id }
    }

    // MARK: - Test Helpers

    func reset() {
        mockExercises = []
        mockWorkouts = []
        savedExercises = []
        savedWorkouts = []
        deletedWorkoutIds = []
        searchQueries = []
        shouldThrowOnSave = false
        shouldThrowOnDelete = false
        shouldThrowOnGet = false
        shouldThrowOnSearch = false
    }

    // MARK: - Mock Error

    enum MockError: Error, LocalizedError {
        case saveFailed
        case deleteFailed
        case getFailed
        case searchFailed

        var errorDescription: String? {
            switch self {
            case .saveFailed: return "Save failed"
            case .deleteFailed: return "Delete failed"
            case .getFailed: return "Get failed"
            case .searchFailed: return "Search failed"
            }
        }
    }
}
