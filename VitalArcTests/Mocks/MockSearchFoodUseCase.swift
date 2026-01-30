//
//  MockSearchFoodUseCase.swift
//  VitalArcTests
//
//  Mock implementations of food search use cases for testing
//

import Foundation
@testable import VitalArc

// MARK: - MockSearchFoodUseCase

/// Mock SearchFoodUseCase for unit testing
class MockSearchFoodUseCase: SearchFoodUseCaseProtocol {
    // MARK: - Mock Data

    var mockResults: [Food] = []

    // MARK: - Call Tracking

    var executeCallCount = 0
    var lastSearchQuery: String?

    // MARK: - Error Simulation

    var shouldThrowOnSearch = false
    var errorToThrow: Error?

    // MARK: - Delay Simulation

    var searchDelay: UInt64 = 0 // nanoseconds

    // MARK: - SearchFoodUseCaseProtocol

    func execute(query: String) async throws -> [Food] {
        executeCallCount += 1
        lastSearchQuery = query

        if searchDelay > 0 {
            try await Task.sleep(nanoseconds: searchDelay)
        }

        if shouldThrowOnSearch {
            throw errorToThrow ?? MockSearchError.searchFailed
        }

        return mockResults
    }

    // MARK: - Helper Methods

    func reset() {
        mockResults = []
        executeCallCount = 0
        lastSearchQuery = nil
        shouldThrowOnSearch = false
        errorToThrow = nil
        searchDelay = 0
    }
}

// MARK: - MockSearchMultiSourceFoodUseCase

/// Mock SearchMultiSourceFoodUseCase for unit testing
class MockSearchMultiSourceFoodUseCase: SearchMultiSourceFoodUseCaseProtocol {
    // MARK: - Mock Data

    var mockResults: [Food] = []
    var mockBarcodeResult: Food?

    // MARK: - Call Tracking

    var executeCallCount = 0
    var searchByBarcodeCallCount = 0
    var lastSearchQuery: String?
    var lastBarcode: String?

    // MARK: - Error Simulation

    var shouldThrowOnSearch = false
    var shouldThrowOnBarcode = false
    var errorToThrow: Error?

    // MARK: - Delay Simulation

    var searchDelay: UInt64 = 0 // nanoseconds

    // MARK: - SearchMultiSourceFoodUseCaseProtocol

    func execute(query: String) async throws -> [Food] {
        executeCallCount += 1
        lastSearchQuery = query

        if searchDelay > 0 {
            try await Task.sleep(nanoseconds: searchDelay)
        }

        if shouldThrowOnSearch {
            throw errorToThrow ?? MockSearchError.searchFailed
        }

        return mockResults
    }

    func searchByBarcode(barcode: String) async throws -> Food {
        searchByBarcodeCallCount += 1
        lastBarcode = barcode

        if shouldThrowOnBarcode {
            throw errorToThrow ?? MockSearchError.barcodeNotFound
        }

        guard let result = mockBarcodeResult else {
            throw MockSearchError.barcodeNotFound
        }

        return result
    }

    // MARK: - Helper Methods

    func reset() {
        mockResults = []
        mockBarcodeResult = nil
        executeCallCount = 0
        searchByBarcodeCallCount = 0
        lastSearchQuery = nil
        lastBarcode = nil
        shouldThrowOnSearch = false
        shouldThrowOnBarcode = false
        errorToThrow = nil
        searchDelay = 0
    }

    /// Create a sample food for testing
    static func createSampleFood(
        name: String = "Test Food",
        calories: Double = 200,
        protein: Double = 10,
        carbs: Double = 25,
        fat: Double = 8
    ) -> Food {
        return Food(
            name: name,
            brand: "Test Brand",
            servingSize: 100,
            servingUnit: "g",
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            source: .custom
        )
    }

    /// Create sample search results
    static func createSampleResults(count: Int = 5) -> [Food] {
        return (0..<count).map { index in
            Food(
                name: "Food \(index + 1)",
                brand: "Brand \(index + 1)",
                servingSize: 100,
                servingUnit: "g",
                calories: Double(100 + index * 50),
                protein: Double(5 + index * 2),
                carbs: Double(15 + index * 3),
                fat: Double(3 + index),
                source: .openFoodFacts
            )
        }
    }
}

// MARK: - Mock Errors

enum MockSearchError: LocalizedError {
    case searchFailed
    case barcodeNotFound
    case networkError
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .searchFailed: return "Mock: Search operation failed"
        case .barcodeNotFound: return "Mock: No product found for barcode"
        case .networkError: return "Mock: Network error occurred"
        case .rateLimited: return "Mock: Rate limit exceeded"
        }
    }
}
