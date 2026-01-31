//
//  GetFoodEntriesUseCase.swift
//  VitalArc
//
//  Use case for fetching food entries for a specific date
//

import Foundation

protocol GetFoodEntriesUseCaseProtocol {
    func execute(for date: Date) async throws -> [FoodEntry]
}

/// Use case for getting food entries for a specific date
final class GetFoodEntriesUseCase: GetFoodEntriesUseCaseProtocol {
    private let repository: NutritionRepository

    init(repository: NutritionRepository) {
        self.repository = repository
    }

    /// Get all food entries for a specific date
    /// - Parameter date: The date to fetch entries for
    /// - Returns: Array of FoodEntry for the given date
    func execute(for date: Date) async throws -> [FoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return try await repository.getFoodEntries(from: startOfDay, to: endOfDay)
    }
}
