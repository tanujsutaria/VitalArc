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

    /// Get all exercises, optionally filtered by category, muscle group, and search query
    func execute(
        category: ExerciseCategory? = nil,
        muscleGroup: MuscleGroup? = nil,
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

        // Filter by muscle group if provided (matches primary or secondary)
        if let muscleGroup = muscleGroup {
            exercises = exercises.filter {
                $0.primaryMuscles.contains(muscleGroup) || $0.secondaryMuscles.contains(muscleGroup)
            }
        }

        return exercises
    }
}
