//
//  SearchMultiSourceFoodUseCaseTests.swift
//  VitalArcTests
//
//  Tests for SearchMultiSourceFoodUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class SearchMultiSourceFoodUseCaseTests: XCTestCase {
    var coordinator: MockFoodAPICoordinator!
    var useCase: SearchMultiSourceFoodUseCase!

    override func setUp() async throws {
        coordinator = MockFoodAPICoordinator()
        useCase = SearchMultiSourceFoodUseCase(coordinator: coordinator)
    }

    override func tearDown() async throws {
        coordinator = nil
        useCase = nil
    }

    // MARK: - Test Helpers

    private func makeTestFood(
        name: String,
        source: FoodSource = .usda
    ) -> Food {
        Food(
            name: name,
            servingSize: 100,
            servingUnit: "g",
            calories: 165,
            protein: 31,
            carbs: 0,
            fat: 3.6,
            source: source
        )
    }

    // MARK: - Search Tests

    func testSearchDelegatesToCoordinator() async throws {
        // Given
        let chicken = makeTestFood(name: "Chicken Breast")
        coordinator.mockSearchResults = [chicken]

        // When
        let results = try await useCase.execute(query: "chicken")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Chicken Breast")
        XCTAssertTrue(coordinator.searchQueries.contains("chicken"))
    }

    func testSearchReturnsMultipleResults() async throws {
        // Given
        let foods = [
            makeTestFood(name: "Chicken Breast"),
            makeTestFood(name: "Chicken Thigh"),
            makeTestFood(name: "Chicken Wing")
        ]
        coordinator.mockSearchResults = foods

        // When
        let results = try await useCase.execute(query: "chicken")

        // Then
        XCTAssertEqual(results.count, 3)
    }

    func testSearchWithEmptyResults() async throws {
        // Given
        coordinator.mockSearchResults = []

        // When
        let results = try await useCase.execute(query: "xyznonexistent")

        // Then
        XCTAssertTrue(results.isEmpty)
    }

    func testSearchTracksQuery() async throws {
        // Given
        coordinator.mockSearchResults = []

        // When
        _ = try await useCase.execute(query: "test query")

        // Then
        XCTAssertEqual(coordinator.searchQueries.count, 1)
        XCTAssertEqual(coordinator.searchQueries.first, "test query")
    }

    func testSearchThrowsOnError() async throws {
        // Given
        coordinator.shouldThrowOnSearch = true

        // When/Then
        do {
            _ = try await useCase.execute(query: "chicken")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockFoodAPICoordinator.MockError)
        }
    }

    // MARK: - Barcode Search Tests

    func testSearchByBarcodeDelegatesToCoordinator() async throws {
        // Given
        let product = makeTestFood(name: "Protein Bar")
        coordinator.mockBarcodeResult = product

        // When
        let result = try await useCase.searchByBarcode(barcode: "123456789")

        // Then
        XCTAssertEqual(result.name, "Protein Bar")
        XCTAssertTrue(coordinator.barcodeQueries.contains("123456789"))
    }

    func testSearchByBarcodeTracksQuery() async throws {
        // Given
        let product = makeTestFood(name: "Snack")
        coordinator.mockBarcodeResult = product

        // When
        _ = try await useCase.searchByBarcode(barcode: "987654321")

        // Then
        XCTAssertEqual(coordinator.barcodeQueries.count, 1)
        XCTAssertEqual(coordinator.barcodeQueries.first, "987654321")
    }

    func testSearchByBarcodeThrowsOnError() async throws {
        // Given
        coordinator.shouldThrowOnBarcode = true

        // When/Then
        do {
            _ = try await useCase.searchByBarcode(barcode: "123456789")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockFoodAPICoordinator.MockError)
        }
    }

    func testSearchByBarcodeThrowsWhenNotFound() async throws {
        // Given
        coordinator.mockBarcodeResult = nil

        // When/Then
        do {
            _ = try await useCase.searchByBarcode(barcode: "000000000")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockFoodAPICoordinator.MockError)
        }
    }

    // MARK: - Multiple Calls Tests

    func testMultipleSearches() async throws {
        // Given
        coordinator.mockSearchResults = [makeTestFood(name: "Result")]

        // When
        _ = try await useCase.execute(query: "first")
        _ = try await useCase.execute(query: "second")
        _ = try await useCase.execute(query: "third")

        // Then
        XCTAssertEqual(coordinator.searchQueries.count, 3)
        XCTAssertEqual(coordinator.searchQueries, ["first", "second", "third"])
    }

    func testSearchAndBarcodeAreSeparate() async throws {
        // Given
        coordinator.mockSearchResults = [makeTestFood(name: "Search Result")]
        coordinator.mockBarcodeResult = makeTestFood(name: "Barcode Result")

        // When
        let searchResults = try await useCase.execute(query: "test")
        let barcodeResult = try await useCase.searchByBarcode(barcode: "123")

        // Then
        XCTAssertEqual(searchResults.first?.name, "Search Result")
        XCTAssertEqual(barcodeResult.name, "Barcode Result")
        XCTAssertEqual(coordinator.searchQueries.count, 1)
        XCTAssertEqual(coordinator.barcodeQueries.count, 1)
    }

    // MARK: - Edge Cases

    func testSearchWithSpecialCharacters() async throws {
        // Given
        coordinator.mockSearchResults = []

        // When
        _ = try await useCase.execute(query: "chicken & rice")

        // Then
        XCTAssertEqual(coordinator.searchQueries.first, "chicken & rice")
    }

    func testSearchWithWhitespace() async throws {
        // Given
        coordinator.mockSearchResults = []

        // When
        _ = try await useCase.execute(query: "  chicken  ")

        // Then
        XCTAssertEqual(coordinator.searchQueries.first, "  chicken  ")
    }

    func testBarcodeWithDifferentFormats() async throws {
        // Given
        let product = makeTestFood(name: "Product")
        coordinator.mockBarcodeResult = product

        // When - UPC format
        _ = try await useCase.searchByBarcode(barcode: "012345678905")

        // Then
        XCTAssertEqual(coordinator.barcodeQueries.first, "012345678905")
    }

    // MARK: - Results Preservation Tests

    func testSearchResultsPreserveAllProperties() async throws {
        // Given
        let originalFood = Food(
            name: "Full Food",
            brand: "Test Brand",
            servingSize: 150,
            servingUnit: "g",
            calories: 250,
            protein: 30,
            carbs: 10,
            fat: 12,
            fiber: 3,
            sugar: 2,
            source: .nutritionix,
            barcode: "123456",
            imageURL: "https://example.com/image.jpg"
        )
        coordinator.mockSearchResults = [originalFood]

        // When
        let results = try await useCase.execute(query: "full food")

        // Then
        let result = results.first!
        XCTAssertEqual(result.name, originalFood.name)
        XCTAssertEqual(result.brand, originalFood.brand)
        XCTAssertEqual(result.servingSize, originalFood.servingSize)
        XCTAssertEqual(result.calories, originalFood.calories)
        XCTAssertEqual(result.protein, originalFood.protein)
        XCTAssertEqual(result.source, originalFood.source)
    }
}
