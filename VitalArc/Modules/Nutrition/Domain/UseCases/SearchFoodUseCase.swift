//
//  SearchFoodUseCase.swift
//  VitalArc
//
//  Use case for searching foods via USDA API and caching results
//

import Foundation

protocol SearchFoodUseCaseProtocol {
    func execute(query: String) async throws -> [Food]
}

/// Use case for searching foods
final class SearchFoodUseCase: SearchFoodUseCaseProtocol {
    private let repository: NutritionRepository
    private let api: USDAFoodAPIProtocol

    init(
        repository: NutritionRepository,
        api: USDAFoodAPIProtocol = USDAFoodAPI()
    ) {
        self.repository = repository
        self.api = api
    }

    /// Search for foods using USDA API and cache results
    /// - Parameter query: Search query string
    /// - Returns: Array of Food entities
    func execute(query: String) async throws -> [Food] {
        // Trim query
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Return empty if query is too short
        guard trimmedQuery.count >= 2 else {
            return []
        }

        // Search via USDA API
        let foods = try await api.searchFoods(query: trimmedQuery)

        // Cache results in repository
        for food in foods {
            try? await repository.saveFood(food)
        }

        return foods
    }
}
