//
//  MockGetExercisesUseCase.swift
//  VitalArcTests
//
//  Mock implementation of GetExercisesUseCase for testing
//

import Foundation
@testable import VitalArc

final class MockGetExercisesUseCase {
    // MARK: - Mock Data

    var mockExercises: [Exercise] = []

    // MARK: - Call Tracking

    var executeCallCount = 0
    var lastCategory: ExerciseCategory?
    var lastSearchQuery: String?

    // MARK: - Error Simulation

    var shouldThrowOnExecute = false
    var errorToThrow: Error?

    // MARK: - Execute

    func execute(
        category: ExerciseCategory? = nil,
        searchQuery: String? = nil
    ) async throws -> [Exercise] {
        executeCallCount += 1
        lastCategory = category
        lastSearchQuery = searchQuery

        if shouldThrowOnExecute {
            throw errorToThrow ?? MockGetExercisesError.executeFailed
        }

        var results = mockExercises

        // Filter by category if provided
        if let category = category {
            results = results.filter { $0.category == category }
        }

        // Filter by search query if provided
        if let query = searchQuery, !query.isEmpty {
            results = results.filter { $0.name.lowercased().contains(query.lowercased()) }
        }

        return results
    }

    // MARK: - Test Helpers

    func reset() {
        mockExercises = []
        executeCallCount = 0
        lastCategory = nil
        lastSearchQuery = nil
        shouldThrowOnExecute = false
        errorToThrow = nil
    }

    /// Create sample exercises for testing
    static func createSampleExercises() -> [Exercise] {
        [
            Exercise(
                name: "Bench Press",
                category: .push,
                primaryMuscles: [.chest],
                secondaryMuscles: [.triceps, .shoulders],
                equipment: .barbell,
                instructions: "Lie on bench, lower bar to chest, press up"
            ),
            Exercise(
                name: "Squat",
                category: .legs,
                primaryMuscles: [.quadriceps],
                secondaryMuscles: [.glutes, .hamstrings],
                equipment: .barbell,
                instructions: "Stand with bar on back, squat down, stand up"
            ),
            Exercise(
                name: "Deadlift",
                category: .pull,
                primaryMuscles: [.back],
                secondaryMuscles: [.hamstrings, .glutes],
                equipment: .barbell,
                instructions: "Lift bar from floor to standing"
            ),
            Exercise(
                name: "Pull Up",
                category: .pull,
                primaryMuscles: [.back],
                secondaryMuscles: [.biceps],
                equipment: .bodyweight,
                instructions: "Hang from bar, pull up until chin over bar"
            ),
            Exercise(
                name: "Overhead Press",
                category: .push,
                primaryMuscles: [.shoulders],
                secondaryMuscles: [.triceps],
                equipment: .barbell,
                instructions: "Press bar overhead from shoulders"
            )
        ]
    }

    // MARK: - Mock Error

    enum MockGetExercisesError: Error, LocalizedError {
        case executeFailed

        var errorDescription: String? {
            switch self {
            case .executeFailed: return "Failed to get exercises"
            }
        }
    }
}
