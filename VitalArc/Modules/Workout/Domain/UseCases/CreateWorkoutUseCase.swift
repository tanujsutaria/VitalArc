//
//  CreateWorkoutUseCase.swift
//  VitalArc
//
//  Use Case: Create and save a workout
//

import Foundation

final class CreateWorkoutUseCase {
    private let repository: WorkoutRepository

    init(repository: WorkoutRepository) {
        self.repository = repository
    }

    /// Create and save a new workout
    func execute(
        name: String? = nil,
        sets: [WorkoutSet],
        notes: String? = nil,
        date: Date = Date(),
        duration: TimeInterval? = nil
    ) async throws -> Workout {
        let workout = Workout(
            date: date,
            name: name,
            sets: sets,
            notes: notes,
            duration: duration
        )

        try await repository.saveWorkout(workout)
        return workout
    }
}
