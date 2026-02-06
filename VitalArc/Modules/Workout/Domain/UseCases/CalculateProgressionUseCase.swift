//
//  CalculateProgressionUseCase.swift
//  VitalArc
//
//  Use Case: Calculate progression for an exercise
//

import Foundation

final class CalculateProgressionUseCase {
    private let repository: WorkoutRepository
    private let progressionRate: Double = 1.05 // 5% increase
    private let startingWeight: Double = 20.0 // Default starting weight in kg

    init(repository: WorkoutRepository) {
        self.repository = repository
    }

    /// Calculate suggested weight for next workout
    /// Returns last workout's max weight + 5%, or starting weight if no history
    func execute(exerciseId: UUID) async throws -> Double {
        // Get last workout that included this exercise
        guard let lastWorkout = try await repository.getLastWorkoutForExercise(exerciseId) else {
            return startingWeight
        }

        // Find the highest weight used for this exercise in the last workout
        let setsForExercise = lastWorkout.sets.filter { $0.exerciseId == exerciseId }
        guard let maxWeight = setsForExercise.map({ $0.weight }).max() else {
            return startingWeight
        }

        // Return weight + 5%
        return maxWeight * progressionRate
    }
}
