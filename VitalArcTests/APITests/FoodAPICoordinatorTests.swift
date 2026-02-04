//
//  FoodAPICoordinatorTests.swift
//  VitalArcTests
//
//  Tests for FoodAPICoordinator - multi-source food search coordination
//

import XCTest
@testable import VitalArc

@MainActor
final class FoodAPICoordinatorTests: XCTestCase {
    var mockNutritionix: MockNutritionixAPI!
    var mockOpenFoodFacts: MockOpenFoodFactsAPI!
    var mockUSDA: MockUSDAFoodAPI!
    var mockCache: MockFoodCache!
    var coordinator: FoodAPICoordinator!

    override func setUp() async throws {
        mockNutritionix = MockNutritionixAPI()
        mockOpenFoodFacts = MockOpenFoodFactsAPI()
        mockUSDA = MockUSDAFoodAPI()
        mockCache = MockFoodCache()
        coordinator = FoodAPICoordinator(
            nutritionix: mockNutritionix,
            openFoodFacts: mockOpenFoodFacts,
            usda: mockUSDA,
            cache: mockCache
        )
    }

    override func tearDown() async throws {
        mockNutritionix = nil
        mockOpenFoodFacts = nil
        mockUSDA = nil
        mockCache = nil
        coordinator = nil
    }

    // MARK: - Test Helpers

    private func makeTestFood(
        name: String,
        brand: String? = nil,
        source: FoodSource = .usda
    ) -> Food {
        Food(
            name: name,
            brand: brand,
            servingSize: 100,
            servingUnit: "g",
            calories: 100,
            protein: 10,
            carbs: 10,
            fat: 5,
            source: source
        )
    }

    // MARK: - Search Tests

    func testSearchReturnsEmptyForEmptyQuery() async throws {
        // When
        let results = try await coordinator.search(query: "")

        // Then
        XCTAssertTrue(results.isEmpty)
    }

    func testSearchReturnsEmptyForWhitespaceQuery() async throws {
        // When
        let results = try await coordinator.search(query: "   ")

        // Then
        XCTAssertTrue(results.isEmpty)
    }

    func testSearchReturnsCachedResultsFirst() async throws {
        // Given
        let cachedFoods = [makeTestFood(name: "Cached Chicken")]
        mockCache.mockSearchResults = cachedFoods

        // When
        let results = try await coordinator.search(query: "chicken")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Cached Chicken")
        // APIs should not be called when cache hits
        XCTAssertTrue(mockNutritionix.searchQueries.isEmpty)
        XCTAssertTrue(mockOpenFoodFacts.searchQueries.isEmpty)
        XCTAssertTrue(mockUSDA.searchQueries.isEmpty)
    }

    func testSearchCombinesResultsFromAllSources() async throws {
        // Given
        mockNutritionix.mockSearchResults = [makeTestFood(name: "NX Chicken", source: .nutritionix)]
        mockOpenFoodFacts.mockSearchResults = [makeTestFood(name: "OFF Chicken", source: .openFoodFacts)]
        mockUSDA.mockSearchResults = [makeTestFood(name: "USDA Chicken", source: .usda)]
        mockCache.mockSearchResults = nil // No cache hit

        // When
        let results = try await coordinator.search(query: "chicken")

        // Then
        XCTAssertEqual(results.count, 3)
        let names = results.map { $0.name }
        XCTAssertTrue(names.contains("NX Chicken"))
        XCTAssertTrue(names.contains("OFF Chicken"))
        XCTAssertTrue(names.contains("USDA Chicken"))
    }

    func testSearchDeduplicatesByNameAndBrand() async throws {
        // Given - same food from multiple sources
        mockNutritionix.mockSearchResults = [makeTestFood(name: "Chicken Breast", brand: "Generic", source: .nutritionix)]
        mockOpenFoodFacts.mockSearchResults = [makeTestFood(name: "Chicken Breast", brand: "Generic", source: .openFoodFacts)]
        mockUSDA.mockSearchResults = [makeTestFood(name: "Chicken Breast", brand: "Generic", source: .usda)]
        mockCache.mockSearchResults = nil

        // When
        let results = try await coordinator.search(query: "chicken")

        // Then - should be deduplicated to 1
        XCTAssertEqual(results.count, 1)
    }

    func testSearchPreservesUniqueNameBrandCombinations() async throws {
        // Given - different brands should not be deduplicated
        mockNutritionix.mockSearchResults = [makeTestFood(name: "Chicken Breast", brand: "Brand A", source: .nutritionix)]
        mockOpenFoodFacts.mockSearchResults = [makeTestFood(name: "Chicken Breast", brand: "Brand B", source: .openFoodFacts)]
        mockUSDA.mockSearchResults = [makeTestFood(name: "Chicken Breast", brand: nil, source: .usda)]
        mockCache.mockSearchResults = nil

        // When
        let results = try await coordinator.search(query: "chicken")

        // Then - all 3 should be preserved (different brands)
        XCTAssertEqual(results.count, 3)
    }

    func testSearchCachesResults() async throws {
        // Given
        mockUSDA.mockSearchResults = [makeTestFood(name: "USDA Chicken")]
        mockCache.mockSearchResults = nil

        // When
        _ = try await coordinator.search(query: "chicken")

        // Then
        XCTAssertTrue(mockCache.storedSearchQueries.contains("chicken"))
    }

    func testSearchSkipsNutritionixWhenNotConfigured() async throws {
        // Given
        mockNutritionix.isConfiguredValue = false
        mockNutritionix.mockSearchResults = [makeTestFood(name: "Should Not Appear")]
        mockUSDA.mockSearchResults = [makeTestFood(name: "USDA Food")]
        mockCache.mockSearchResults = nil

        // When
        let results = try await coordinator.search(query: "food")

        // Then - Nutritionix results should not appear
        XCTAssertFalse(results.contains { $0.name == "Should Not Appear" })
        XCTAssertTrue(results.contains { $0.name == "USDA Food" })
    }

    func testSearchContinuesWhenOneSourceFails() async throws {
        // Given - Nutritionix will throw, others succeed
        mockNutritionix.shouldThrowOnSearch = true
        mockOpenFoodFacts.mockSearchResults = [makeTestFood(name: "OFF Food", source: .openFoodFacts)]
        mockUSDA.mockSearchResults = [makeTestFood(name: "USDA Food", source: .usda)]
        mockCache.mockSearchResults = nil

        // When
        let results = try await coordinator.search(query: "food")

        // Then - should still get results from other sources
        XCTAssertEqual(results.count, 2)
    }

    func testSearchCachesEmptyResultsWhenAPISucceeds() async throws {
        // Given - APIs succeed but return empty results (legitimate "no results")
        mockNutritionix.isConfiguredValue = false
        mockOpenFoodFacts.mockSearchResults = [] // Success with empty results
        mockUSDA.mockSearchResults = [] // Success with empty results
        mockCache.mockSearchResults = nil

        // When
        let results = try await coordinator.search(query: "xyznonexistent")

        // Then - empty results should be cached (legitimate "no results")
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(mockCache.storedSearchQueries.contains("xyznonexistent"))
    }

    func testSearchDoesNotCacheWhenAllAPIsFail() async throws {
        // Given - All APIs throw errors
        mockNutritionix.isConfiguredValue = false
        mockOpenFoodFacts.shouldThrowOnSearch = true
        mockUSDA.shouldThrowOnSearch = true
        mockCache.mockSearchResults = nil

        // When
        let results = try await coordinator.search(query: "food")

        // Then - should not cache (transient failure)
        XCTAssertTrue(results.isEmpty)
        XCTAssertFalse(mockCache.storedSearchQueries.contains("food"))
    }

    func testSearchReturnsCachedEmptyResults() async throws {
        // Given - Cache has empty results for this query (previously searched, no results found)
        mockCache.mockSearchResults = []
        mockUSDA.mockSearchResults = [makeTestFood(name: "Should Not Appear")]

        // When
        let results = try await coordinator.search(query: "cached-empty")

        // Then - should return cached empty results, not call APIs
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(mockUSDA.searchQueries.isEmpty)
    }

    // MARK: - Barcode Search Tests

    func testSearchByBarcodeThrowsForEmptyBarcode() async {
        // When/Then
        do {
            _ = try await coordinator.searchByBarcode(barcode: "")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testSearchByBarcodeReturnsCachedResultFirst() async throws {
        // Given
        let cachedFood = makeTestFood(name: "Cached Product")
        mockCache.mockBarcodeResult = cachedFood

        // When
        let result = try await coordinator.searchByBarcode(barcode: "123456789")

        // Then
        XCTAssertEqual(result.name, "Cached Product")
        XCTAssertTrue(mockNutritionix.barcodeQueries.isEmpty)
        XCTAssertTrue(mockOpenFoodFacts.barcodeQueries.isEmpty)
    }

    func testSearchByBarcodeTruesNutritionixFirstWhenConfigured() async throws {
        // Given
        mockNutritionix.isConfiguredValue = true
        mockNutritionix.mockBarcodeResult = makeTestFood(name: "NX Product", source: .nutritionix)
        mockOpenFoodFacts.mockBarcodeResult = makeTestFood(name: "OFF Product", source: .openFoodFacts)
        mockCache.mockBarcodeResult = nil

        // When
        let result = try await coordinator.searchByBarcode(barcode: "123456789")

        // Then - should return Nutritionix result
        XCTAssertEqual(result.name, "NX Product")
        XCTAssertEqual(result.source, .nutritionix)
    }

    func testSearchByBarcodeFallsBackToOpenFoodFacts() async throws {
        // Given - Nutritionix not configured
        mockNutritionix.isConfiguredValue = false
        mockOpenFoodFacts.mockBarcodeResult = makeTestFood(name: "OFF Product", source: .openFoodFacts)
        mockCache.mockBarcodeResult = nil

        // When
        let result = try await coordinator.searchByBarcode(barcode: "123456789")

        // Then
        XCTAssertEqual(result.name, "OFF Product")
        XCTAssertEqual(result.source, .openFoodFacts)
    }

    func testSearchByBarcodeFallsBackWhenNutritionixFails() async throws {
        // Given - Nutritionix configured but throws
        mockNutritionix.isConfiguredValue = true
        mockNutritionix.shouldThrowOnBarcode = true
        mockOpenFoodFacts.mockBarcodeResult = makeTestFood(name: "OFF Product", source: .openFoodFacts)
        mockCache.mockBarcodeResult = nil

        // When
        let result = try await coordinator.searchByBarcode(barcode: "123456789")

        // Then - should fallback to OpenFoodFacts
        XCTAssertEqual(result.name, "OFF Product")
    }

    func testSearchByBarcodeCachesResult() async throws {
        // Given
        mockOpenFoodFacts.mockBarcodeResult = makeTestFood(name: "Product")
        mockCache.mockBarcodeResult = nil

        // When
        _ = try await coordinator.searchByBarcode(barcode: "123456789")

        // Then
        XCTAssertTrue(mockCache.storedBarcodes.contains("123456789"))
    }
}

// MARK: - Mock Implementations

final class MockNutritionixAPI: NutritionixAPIProtocol {
    var mockSearchResults: [Food] = []
    var mockBarcodeResult: Food?
    var mockNutrientsResults: [Food] = []
    var shouldThrowOnSearch = false
    var shouldThrowOnBarcode = false
    var searchQueries: [String] = []
    var barcodeQueries: [String] = []
    var isConfiguredValue = true

    var isConfigured: Bool { isConfiguredValue }

    func search(query: String) async throws -> [Food] {
        searchQueries.append(query)
        if shouldThrowOnSearch {
            throw NetworkError.serverError(statusCode: 500)
        }
        return mockSearchResults
    }

    func getByUPC(barcode: String) async throws -> Food {
        barcodeQueries.append(barcode)
        if shouldThrowOnBarcode {
            throw NetworkError.serverError(statusCode: 500)
        }
        guard let result = mockBarcodeResult else {
            throw NetworkError.invalidResponse
        }
        return result
    }

    func getNutrients(query: String) async throws -> [Food] {
        return mockNutrientsResults
    }
}

final class MockOpenFoodFactsAPI: OpenFoodFactsAPIProtocol {
    var mockSearchResults: [Food] = []
    var mockBarcodeResult: Food?
    var shouldThrowOnSearch = false
    var shouldThrowOnBarcode = false
    var searchQueries: [String] = []
    var barcodeQueries: [String] = []

    func search(query: String, page: Int) async throws -> [Food] {
        searchQueries.append(query)
        if shouldThrowOnSearch {
            throw NetworkError.serverError(statusCode: 500)
        }
        return mockSearchResults
    }

    func getByBarcode(barcode: String) async throws -> Food {
        barcodeQueries.append(barcode)
        if shouldThrowOnBarcode {
            throw NetworkError.serverError(statusCode: 500)
        }
        guard let result = mockBarcodeResult else {
            throw NetworkError.invalidResponse
        }
        return result
    }
}

final class MockUSDAFoodAPI: USDAFoodAPIProtocol {
    var mockSearchResults: [Food] = []
    var shouldThrowOnSearch = false
    var searchQueries: [String] = []

    func searchFoods(query: String) async throws -> [Food] {
        searchQueries.append(query)
        if shouldThrowOnSearch {
            throw NetworkError.serverError(statusCode: 500)
        }
        return mockSearchResults
    }
}

@MainActor
final class MockFoodCache: FoodCacheProtocol {
    var mockSearchResults: [Food]?
    var mockBarcodeResult: Food?
    var storedSearchQueries: [String] = []
    var storedBarcodes: [String] = []

    func search(query: String) -> [Food]? {
        return mockSearchResults
    }

    func store(query: String, foods: [Food]) {
        storedSearchQueries.append(query)
    }

    func getByBarcode(_ barcode: String) -> Food? {
        return mockBarcodeResult
    }

    func storeBarcode(_ barcode: String, food: Food) {
        storedBarcodes.append(barcode)
    }
}
