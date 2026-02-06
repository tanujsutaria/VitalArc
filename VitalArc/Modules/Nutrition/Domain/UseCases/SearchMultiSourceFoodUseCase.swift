//
//  SearchMultiSourceFoodUseCase.swift
//  VitalArc
//
//  Use case for searching foods across multiple data sources
//

import Foundation

protocol SearchMultiSourceFoodUseCaseProtocol {
    func execute(query: String) async throws -> [Food]
    func searchByBarcode(barcode: String) async throws -> Food
}

/// Search foods across multiple sources (Nutritionix, OpenFoodFacts, USDA)
final class SearchMultiSourceFoodUseCase: SearchMultiSourceFoodUseCaseProtocol {
    private let coordinator: FoodAPICoordinatorProtocol

    init(coordinator: FoodAPICoordinatorProtocol) {
        self.coordinator = coordinator
    }

    /// Search for foods by query string
    /// Returns combined results from all available sources
    func execute(query: String) async throws -> [Food] {
        return try await coordinator.search(query: query)
    }

    /// Search for food by barcode (UPC/EAN)
    /// Tries Nutritionix first, then OpenFoodFacts
    func searchByBarcode(barcode: String) async throws -> Food {
        return try await coordinator.searchByBarcode(barcode: barcode)
    }
}
