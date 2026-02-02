//
//  NutritionixAPITests.swift
//  VitalArcTests
//
//  Tests for NutritionixAPI client
//

import XCTest
@testable import VitalArc

final class NutritionixAPITests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var api: NutritionixAPI!

    override func setUp() {
        mockNetworkService = MockNetworkService()
        api = NutritionixAPI(
            networkService: mockNetworkService,
            appId: "test-app-id",
            appKey: "test-app-key"
        )
    }

    override func tearDown() {
        mockNetworkService = nil
        api = nil
    }

    // MARK: - Test Helpers

    private func makeBrandedFood(
        name: String = "Test Food",
        brand: String = "Test Brand",
        calories: Double = 150
    ) -> NutritionixBrandedFood {
        NutritionixBrandedFood(
            foodName: name,
            brandName: brand,
            servingQty: 1,
            servingUnit: "serving",
            nfCalories: calories,
            nfProtein: 10,
            nfTotalCarbohydrate: 20,
            nfTotalFat: 5,
            nfDietaryFiber: 2,
            nfSugars: 5,
            nixBrandId: nil,
            nixItemId: nil,
            upc: nil,
            photo: nil
        )
    }

    private func makeNutrientFood(
        name: String = "Chicken Breast",
        calories: Double = 165
    ) -> NutritionixNutrientFood {
        NutritionixNutrientFood(
            foodName: name,
            brandName: nil,
            servingQty: 100,
            servingUnit: "g",
            servingWeightGrams: 100,
            nfCalories: calories,
            nfProtein: 31,
            nfTotalCarbohydrate: 0,
            nfTotalFat: 3.6,
            nfDietaryFiber: 0,
            nfSugars: 0,
            upc: nil,
            photo: nil
        )
    }

    // MARK: - isConfigured Tests

    func testIsConfiguredWithValidCredentials() {
        // API initialized with valid credentials
        XCTAssertTrue(api.isConfigured)
    }

    func testIsConfiguredWithEmptyAppId() {
        let apiWithEmptyId = NutritionixAPI(
            networkService: mockNetworkService,
            appId: "",
            appKey: "test-key"
        )
        XCTAssertFalse(apiWithEmptyId.isConfigured)
    }

    func testIsConfiguredWithEmptyAppKey() {
        let apiWithEmptyKey = NutritionixAPI(
            networkService: mockNetworkService,
            appId: "test-id",
            appKey: ""
        )
        XCTAssertFalse(apiWithEmptyKey.isConfigured)
    }

    func testIsConfiguredWithBothEmpty() {
        let apiWithNoCredentials = NutritionixAPI(
            networkService: mockNetworkService,
            appId: "",
            appKey: ""
        )
        XCTAssertFalse(apiWithNoCredentials.isConfigured)
    }

    // MARK: - Search Tests

    func testSearchReturnsEmptyForEmptyQuery() async throws {
        // When
        let results = try await api.search(query: "")

        // Then
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(mockNetworkService.requestedURLs.isEmpty)
    }

    func testSearchReturnsEmptyForWhitespaceQuery() async throws {
        // When
        let results = try await api.search(query: "   ")

        // Then
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(mockNetworkService.requestedURLs.isEmpty)
    }

    func testSearchReturnsBrandedFoods() async throws {
        // Given
        let response = NutritionixSearchResponse(
            common: nil,
            branded: [makeBrandedFood(name: "Protein Bar", brand: "MyBrand", calories: 200)]
        )
        mockNetworkService.mockResponse = response

        // When
        let results = try await api.search(query: "protein bar")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Protein Bar")
        XCTAssertEqual(results.first?.brand, "MyBrand")
        XCTAssertEqual(results.first?.calories, 200)
        XCTAssertEqual(results.first?.source, .nutritionix)
    }

    func testSearchSendsCorrectHeaders() async throws {
        // Given
        let response = NutritionixSearchResponse(common: nil, branded: [])
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.search(query: "chicken")

        // Then
        XCTAssertEqual(mockNetworkService.lastRequestHeader("x-app-id"), "test-app-id")
        XCTAssertEqual(mockNetworkService.lastRequestHeader("x-app-key"), "test-app-key")
    }

    func testSearchBuildsCorrectURL() async throws {
        // Given
        let response = NutritionixSearchResponse(common: nil, branded: [])
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.search(query: "test food")

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("search/instant") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("query=test%20food") ?? false)
    }

    func testSearchThrowsOnNetworkError() async {
        // Given
        mockNetworkService.mockError = NetworkError.serverError(statusCode: 500)

        // When/Then
        do {
            _ = try await api.search(query: "chicken")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    func testSearchFiltersOutInvalidFoods() async throws {
        // Given - food with 0 calories should be filtered out
        let validFood = makeBrandedFood(name: "Valid Food", calories: 100)
        let invalidFood = NutritionixBrandedFood(
            foodName: "Invalid Food",
            brandName: nil,
            servingQty: 1,
            servingUnit: "serving",
            nfCalories: 0, // Invalid - 0 calories
            nfProtein: nil,
            nfTotalCarbohydrate: nil,
            nfTotalFat: nil,
            nfDietaryFiber: nil,
            nfSugars: nil,
            nixBrandId: nil,
            nixItemId: nil,
            upc: nil,
            photo: nil
        )
        let response = NutritionixSearchResponse(
            common: nil,
            branded: [validFood, invalidFood]
        )
        mockNetworkService.mockResponse = response

        // When
        let results = try await api.search(query: "food")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Valid Food")
    }

    // MARK: - getNutrients Tests

    func testGetNutrientsReturnsEmptyForEmptyQuery() async throws {
        // When
        let results = try await api.getNutrients(query: "")

        // Then
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(mockNetworkService.requestedURLs.isEmpty)
    }

    func testGetNutrientsReturnsFoods() async throws {
        // Given
        let response = NutritionixNutrientsResponse(
            foods: [makeNutrientFood(name: "Grilled Chicken", calories: 165)]
        )
        mockNetworkService.mockResponse = response

        // When
        let results = try await api.getNutrients(query: "1 chicken breast")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Grilled Chicken")
        XCTAssertEqual(results.first?.calories, 165)
    }

    func testGetNutrientsSendsPostRequest() async throws {
        // Given
        let response = NutritionixNutrientsResponse(foods: [])
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.getNutrients(query: "chicken")

        // Then
        let request = mockNetworkService.requestedRequests.first
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    // MARK: - getByUPC Tests

    func testGetByUPCThrowsForEmptyBarcode() async {
        // When/Then
        do {
            _ = try await api.getByUPC(barcode: "")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGetByUPCThrowsForWhitespaceBarcode() async {
        // When/Then
        do {
            _ = try await api.getByUPC(barcode: "   ")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGetByUPCReturnsFood() async throws {
        // Given
        let response = NutritionixUPCResponse(
            foods: [makeNutrientFood(name: "Protein Bar", calories: 200)]
        )
        mockNetworkService.mockResponse = response

        // When
        let food = try await api.getByUPC(barcode: "012345678905")

        // Then
        XCTAssertEqual(food.name, "Protein Bar")
        XCTAssertEqual(food.calories, 200)
    }

    func testGetByUPCThrowsWhenNoFoodFound() async {
        // Given
        let response = NutritionixUPCResponse(foods: [])
        mockNetworkService.mockResponse = response

        // When/Then
        do {
            _ = try await api.getByUPC(barcode: "000000000000")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGetByUPCIncludesBarcodeInQuery() async throws {
        // Given
        let response = NutritionixUPCResponse(foods: [makeNutrientFood()])
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.getByUPC(barcode: "012345678905")

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("upc=012345678905") ?? false)
    }
}

// MARK: - NetworkError Equatable for tests

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.decodingError, .decodingError),
             (.invalidResponse, .invalidResponse):
            return true
        case let (.serverError(lCode), .serverError(rCode)):
            return lCode == rCode
        case let (.unknown(lError), .unknown(rError)):
            return lError.localizedDescription == rError.localizedDescription
        default:
            return false
        }
    }
}
