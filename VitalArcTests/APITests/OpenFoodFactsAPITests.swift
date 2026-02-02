//
//  OpenFoodFactsAPITests.swift
//  VitalArcTests
//
//  Tests for OpenFoodFactsAPI client
//

import XCTest
@testable import VitalArc

final class OpenFoodFactsAPITests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var api: OpenFoodFactsAPI!

    override func setUp() {
        mockNetworkService = MockNetworkService()
        api = OpenFoodFactsAPI(networkService: mockNetworkService)
    }

    override func tearDown() {
        mockNetworkService = nil
        api = nil
    }

    // MARK: - Test Helpers

    private func makeOFFProduct(
        name: String = "Test Product",
        brand: String? = "Test Brand",
        barcode: String = "3017620422003",
        calories: Double = 150
    ) -> OFFProduct {
        OFFProduct(
            productName: name,
            productNameEn: name,
            brands: brand,
            quantity: "100g",
            servingSize: "100g",
            nutriments: OFFNutriments(
                energyKcal100g: calories,
                proteins100g: 10,
                carbohydrates100g: 20,
                fat100g: 5,
                fiber100g: 2,
                sugars100g: 5,
                salt100g: 0.5,
                sodium100g: 0.2,
                energyKcalServing: nil,
                proteinsServing: nil,
                carbohydratesServing: nil,
                fatServing: nil
            ),
            code: barcode,
            imageURL: nil,
            imageFrontURL: nil,
            imageFrontThumbURL: nil,
            categories: nil,
            categoriesTags: nil
        )
    }

    // MARK: - isConfigured Tests

    func testIsConfiguredAlwaysReturnsTrue() {
        // OpenFoodFacts requires no API key
        XCTAssertTrue(api.isConfigured)
    }

    // MARK: - Search Tests

    func testSearchReturnsEmptyForEmptyQuery() async throws {
        // When
        let results = try await api.search(query: "", page: 1)

        // Then
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(mockNetworkService.requestedURLs.isEmpty)
    }

    func testSearchReturnsEmptyForWhitespaceQuery() async throws {
        // When
        let results = try await api.search(query: "   ", page: 1)

        // Then
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(mockNetworkService.requestedURLs.isEmpty)
    }

    func testSearchReturnsProducts() async throws {
        // Given
        let response = OFFSearchResponse(
            count: 1,
            page: 1,
            pageSize: 25,
            products: [makeOFFProduct(name: "Nutella", brand: "Ferrero", calories: 539)]
        )
        mockNetworkService.mockResponse = response

        // When
        let results = try await api.search(query: "nutella", page: 1)

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Nutella")
        XCTAssertEqual(results.first?.brand, "Ferrero")
        XCTAssertEqual(results.first?.source, .openFoodFacts)
    }

    func testSearchBuildsCorrectURL() async throws {
        // Given
        let response = OFFSearchResponse(count: 0, page: 1, pageSize: 25, products: [])
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.search(query: "test food", page: 1)

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("search") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("search_terms=test%20food") ?? false)
    }

    func testSearchIncludesPageParameter() async throws {
        // Given
        let response = OFFSearchResponse(count: 0, page: 2, pageSize: 25, products: [])
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.search(query: "test", page: 2)

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertTrue(url?.absoluteString.contains("page=2") ?? false)
    }

    func testSearchIncludesPageSize() async throws {
        // Given
        let response = OFFSearchResponse(count: 0, page: 1, pageSize: 25, products: [])
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.search(query: "test", page: 1)

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertTrue(url?.absoluteString.contains("page_size=25") ?? false)
    }

    func testSearchThrowsOnNetworkError() async {
        // Given
        mockNetworkService.mockError = NetworkError.serverError(statusCode: 503)

        // When/Then
        do {
            _ = try await api.search(query: "test", page: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    func testSearchFiltersOutInvalidProducts() async throws {
        // Given - product without name and product without calories should be filtered
        let validProduct = makeOFFProduct(name: "Valid Product", calories: 100)
        let productWithoutName = OFFProduct(
            productName: nil,
            productNameEn: nil,
            brands: "Some Brand",
            quantity: nil,
            servingSize: nil,
            nutriments: OFFNutriments(
                energyKcal100g: 100,
                proteins100g: 10,
                carbohydrates100g: 20,
                fat100g: 5,
                fiber100g: nil,
                sugars100g: nil,
                salt100g: nil,
                sodium100g: nil,
                energyKcalServing: nil,
                proteinsServing: nil,
                carbohydratesServing: nil,
                fatServing: nil
            ),
            code: "123",
            imageURL: nil,
            imageFrontURL: nil,
            imageFrontThumbURL: nil,
            categories: nil,
            categoriesTags: nil
        )
        let productWithoutCalories = OFFProduct(
            productName: "No Calories",
            productNameEn: "No Calories",
            brands: nil,
            quantity: nil,
            servingSize: nil,
            nutriments: OFFNutriments(
                energyKcal100g: nil,
                proteins100g: 10,
                carbohydrates100g: 20,
                fat100g: 5,
                fiber100g: nil,
                sugars100g: nil,
                salt100g: nil,
                sodium100g: nil,
                energyKcalServing: nil,
                proteinsServing: nil,
                carbohydratesServing: nil,
                fatServing: nil
            ),
            code: "456",
            imageURL: nil,
            imageFrontURL: nil,
            imageFrontThumbURL: nil,
            categories: nil,
            categoriesTags: nil
        )
        let response = OFFSearchResponse(
            count: 3,
            page: 1,
            pageSize: 25,
            products: [validProduct, productWithoutName, productWithoutCalories]
        )
        mockNetworkService.mockResponse = response

        // When
        let results = try await api.search(query: "food", page: 1)

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Valid Product")
    }

    // MARK: - getByBarcode Tests

    func testGetByBarcodeThrowsForEmptyBarcode() async {
        // When/Then
        do {
            _ = try await api.getByBarcode(barcode: "")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGetByBarcodeThrowsForWhitespaceBarcode() async {
        // When/Then
        do {
            _ = try await api.getByBarcode(barcode: "   ")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGetByBarcodeReturnsFood() async throws {
        // Given
        let response = OFFProductResponse(
            status: 1,
            product: makeOFFProduct(name: "Chocolate Bar", barcode: "3017620422003", calories: 530)
        )
        mockNetworkService.mockResponse = response

        // When
        let food = try await api.getByBarcode(barcode: "3017620422003")

        // Then
        XCTAssertEqual(food.name, "Chocolate Bar")
        XCTAssertEqual(food.barcode, "3017620422003")
        XCTAssertEqual(food.source, .openFoodFacts)
    }

    func testGetByBarcodeBuildsCorrectURL() async throws {
        // Given
        let response = OFFProductResponse(
            status: 1,
            product: makeOFFProduct(barcode: "3017620422003")
        )
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.getByBarcode(barcode: "3017620422003")

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("product/3017620422003") ?? false)
    }

    func testGetByBarcodeThrowsWhenProductNotFound() async {
        // Given - status 0 means not found
        let response = OFFProductResponse(status: 0, product: nil)
        mockNetworkService.mockResponse = response

        // When/Then
        do {
            _ = try await api.getByBarcode(barcode: "0000000000000")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGetByBarcodeThrowsWhenProductHasNoName() async {
        // Given - product without name
        let invalidProduct = OFFProduct(
            productName: nil,
            productNameEn: nil,
            brands: "Brand",
            quantity: nil,
            servingSize: nil,
            nutriments: OFFNutriments(
                energyKcal100g: 100,
                proteins100g: 10,
                carbohydrates100g: 20,
                fat100g: 5,
                fiber100g: nil,
                sugars100g: nil,
                salt100g: nil,
                sodium100g: nil,
                energyKcalServing: nil,
                proteinsServing: nil,
                carbohydratesServing: nil,
                fatServing: nil
            ),
            code: "123",
            imageURL: nil,
            imageFrontURL: nil,
            imageFrontThumbURL: nil,
            categories: nil,
            categoriesTags: nil
        )
        let response = OFFProductResponse(status: 1, product: invalidProduct)
        mockNetworkService.mockResponse = response

        // When/Then
        do {
            _ = try await api.getByBarcode(barcode: "123")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - searchByCategory Tests

    func testSearchByCategoryReturnsProducts() async throws {
        // Given
        let response = OFFSearchResponse(
            count: 2,
            page: 1,
            pageSize: 25,
            products: [
                makeOFFProduct(name: "Organic Milk"),
                makeOFFProduct(name: "Whole Milk")
            ]
        )
        mockNetworkService.mockResponse = response

        // When
        let results = try await api.searchByCategory(category: "en:milks")

        // Then
        XCTAssertEqual(results.count, 2)
    }

    func testSearchByCategoryBuildsCorrectURL() async throws {
        // Given
        let response = OFFSearchResponse(count: 0, page: 1, pageSize: 25, products: [])
        mockNetworkService.mockResponse = response

        // When
        _ = try await api.searchByCategory(category: "en:chocolates")

        // Then
        let url = mockNetworkService.requestedURLs.first
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("categories_tags=en%3Achocolates") ?? false)
    }
}
