//
//  GetExercisesUseCase.swift
//  VitalArc
//
//  Use Case: Get and filter exercises
//

import Foundation

final class GetExercisesUseCase {
    private let repository: WorkoutRepository

    init(repository: WorkoutRepository) {
        self.repository = repository
    }

    /// Get all exercises, optionally filtered by category and search query
    func execute(
        category: ExerciseCategory? = nil,
        searchQuery: String? = nil
    ) async throws -> [Exercise] {
        var exercises = try await repository.getExercises()

        // Filter by category if provided
        if let category = category {
            exercises = exercises.filter { $0.category == category }
        }

        // Filter by search query if provided
        if let query = searchQuery, !query.isEmpty {
            exercises = try await repository.searchExercises(query: query)
            // Apply category filter after search
            if let category = category {
                exercises = exercises.filter { $0.category == category }
            }
        }

        return exercises
    }
}
