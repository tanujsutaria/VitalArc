//
//  GetTodayWorkoutsUseCase.swift
//  VitalArc
//
//  Use case for fetching workouts for a specific date
//

import Foundation

protocol GetTodayWorkoutsUseCaseProtocol {
    func execute(for date: Date) async throws -> [Workout]
}

/// Use case for getting workouts for a specific date
final class GetTodayWorkoutsUseCase: GetTodayWorkoutsUseCaseProtocol {
    private let repository: WorkoutRepository

    init(repository: WorkoutRepository) {
        self.repository = repository
    }

    /// Get all workouts for a specific date
    /// - Parameter date: The date to fetch workouts for
    /// - Returns: Array of Workout for the given date
    func execute(for date: Date) async throws -> [Workout] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return try await repository.getWorkouts(from: startOfDay, to: endOfDay)
    }
}
