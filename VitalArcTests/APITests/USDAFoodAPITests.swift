//
//  USDAFoodAPITests.swift
//  VitalArcTests
//
//  Tests for USDAFoodAPI client
//

import XCTest
@testable import VitalArc

final class USDAFoodAPITests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var api: USDAFoodAPI!

    override func setUp() {
        mockNetworkService = MockNetworkService()
        api = USDAFoodAPI(
            networkService: mockNetworkService,
            apiKey: "test-api-key"
        )
    }

    override func tearDown() {
        mockNetworkService = nil
        api = nil
    }

    // MARK: - Test Helpers

    private func makeUSDAFood(
        name: String = "Chicken Breast",
        fdcId: Int = 12345,
        calories: Double = 165
    ) -> USDAFood {
        USDAFood(
            fdcId: fdcId,
            description: name,
            brandOwner: nil,
            servingSize: 100,
            servingSizeUnit: "g",
            foodNutrients: [
                USDANutrient(nutrientId: 1008, nutrientName: "Energy", value: calories),
                USDANutrient(nutrientId: 1003, nutrientName: "Protein", value: 31),
                USDANutrient(nutrientId: 1005, nutrientName: "Carbohydrate", value: 0),
                USDANutrient(nutrientId: 1004, nutrientName: "Total lipid (fat)", value: 3.6)
            ]
        )
    }

    // MARK: - searchFoods Tests

    func testSearchFoodsReturnsEmptyForEmptyQuery() async throws {
        // When
        let results = try await api.searchFoods(query: "")

        // Then
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(mockNetworkService.requestedURLs.isEmpty)
    }

    func testSearchFoodsReturnsEmptyForWhitespaceQuery() async throws {
        // When
        let results = try await api.searchFoods(query: "   ")

        // Then
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(mockNetworkService.requestedURLs.isEmpty)
    }

    func testSearchFoodsReturnsFoods() async throws {
        // Given
        let response = USDASearchResponse(
            foods: [makeUSDAFood(name: "Chicken Breast", calories: 165)],
            totalHits: 1
        )
        mockNetworkService.mockResponse = response

        // When
        let results = try await api.searchFoods(query: "chicken")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Chicken Breast")
        XCTAssertEqual(results.first?.source, .usda)
    }

    func testSearchFoodsBuildsCorrectURL() async throws {
        // Given
        let response = USDASearchResponse(foods: [], totalHits: 0)
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.searchFoods(query: "test food")

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("foods/search") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("query=test%20food") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("api_key=test-api-key") ?? false)
    }

    func testSearchFoodsIncludesPageSize() async throws {
        // Given
        let response = USDASearchResponse(foods: [], totalHits: 0)
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.searchFoods(query: "chicken")

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertTrue(url?.absoluteString.contains("pageSize=25") ?? false)
    }

    func testSearchFoodsIncludesDataType() async throws {
        // Given
        let response = USDASearchResponse(foods: [], totalHits: 0)
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.searchFoods(query: "chicken")

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertTrue(url?.absoluteString.contains("dataType=") ?? false)
    }

    func testSearchFoodsThrowsOnNetworkError() async {
        // Given
        mockNetworkService.mockError = NetworkError.serverError(statusCode: 429)

        // When/Then
        do {
            _ = try await api.searchFoods(query: "chicken")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 429)
            } else {
                XCTFail("Expected serverError")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testSearchFoodsReturnsMultipleFoods() async throws {
        // Given
        let response = USDASearchResponse(
            foods: [
                makeUSDAFood(name: "Chicken Breast", fdcId: 1),
                makeUSDAFood(name: "Chicken Thigh", fdcId: 2),
                makeUSDAFood(name: "Chicken Wing", fdcId: 3)
            ],
            totalHits: 3
        )
        mockNetworkService.mockResponse = response

        // When
        let results = try await api.searchFoods(query: "chicken")

        // Then
        XCTAssertEqual(results.count, 3)
    }

    func testSearchFoodsFiltersOutFoodsWithoutCalories() async throws {
        // Given - food without calories should be filtered out
        let validFood = makeUSDAFood(name: "Valid Food", calories: 100)
        let invalidFood = USDAFood(
            fdcId: 99999,
            description: "Invalid Food",
            brandOwner: nil,
            servingSize: 100,
            servingSizeUnit: "g",
            foodNutrients: [
                // No calories nutrient (1008)
                USDANutrient(nutrientId: 1003, nutrientName: "Protein", value: 10)
            ]
        )
        let response = USDASearchResponse(
            foods: [validFood, invalidFood],
            totalHits: 2
        )
        mockNetworkService.mockResponse = response

        // When
        let results = try await api.searchFoods(query: "food")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Valid Food")
    }

    func testSearchFoodsTrimsQuery() async throws {
        // Given
        let response = USDASearchResponse(foods: [], totalHits: 0)
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.searchFoods(query: "  chicken  ")

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertTrue(url?.absoluteString.contains("query=chicken") ?? false)
    }

    // MARK: - getFood Tests

    func testGetFoodReturnsFood() async throws {
        // Given
        let detail = USDAFoodDetail(
            fdcId: 12345,
            description: "Chicken Breast",
            brandOwner: nil,
            servingSize: 100,
            servingSizeUnit: "g",
            foodNutrients: [
                USDANutrientDetail(
                    nutrient: USDANutrientInfo(id: 1008, name: "Energy", unitName: "kcal"),
                    amount: 165
                ),
                USDANutrientDetail(
                    nutrient: USDANutrientInfo(id: 1003, name: "Protein", unitName: "g"),
                    amount: 31
                ),
                USDANutrientDetail(
                    nutrient: USDANutrientInfo(id: 1005, name: "Carbohydrate", unitName: "g"),
                    amount: 0
                ),
                USDANutrientDetail(
                    nutrient: USDANutrientInfo(id: 1004, name: "Fat", unitName: "g"),
                    amount: 3.6
                )
            ]
        )
        mockNetworkService.mockResponse = detail

        // When
        let food = try await api.getFood(fdcId: 12345)

        // Then
        XCTAssertNotNil(food)
        XCTAssertEqual(food?.name, "Chicken Breast")
        XCTAssertEqual(food?.calories, 165)
    }

    func testGetFoodBuildsCorrectURL() async throws {
        // Given
        let detail = USDAFoodDetail(
            fdcId: 12345,
            description: "Test",
            brandOwner: nil,
            servingSize: 100,
            servingSizeUnit: "g",
            foodNutrients: [
                USDANutrientDetail(
                    nutrient: USDANutrientInfo(id: 1008, name: "Energy", unitName: "kcal"),
                    amount: 100
                )
            ]
        )
        mockNetworkService.mockResponse = detail

        // When
        _ = try await api.getFood(fdcId: 12345)

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("food/12345") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("api_key=test-api-key") ?? false)
    }

    func testGetFoodReturnsNilForFoodWithoutCalories() async throws {
        // Given - detail without calories
        let detail = USDAFoodDetail(
            fdcId: 12345,
            description: "Invalid Food",
            brandOwner: nil,
            servingSize: 100,
            servingSizeUnit: "g",
            foodNutrients: [
                USDANutrientDetail(
                    nutrient: USDANutrientInfo(id: 1003, name: "Protein", unitName: "g"),
                    amount: 10
                )
            ]
        )
        mockNetworkService.mockResponse = detail

        // When
        let food = try await api.getFood(fdcId: 12345)

        // Then
        XCTAssertNil(food)
    }
}
