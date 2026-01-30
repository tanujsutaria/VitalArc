//
//  FoodSearchViewModelTests.swift
//  VitalArcTests
//
//  Unit tests for FoodSearchViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class FoodSearchViewModelTests: XCTestCase {

    var searchFoodUseCase: MockSearchFoodUseCase!
    var multiSourceUseCase: MockSearchMultiSourceFoodUseCase!
    var viewModel: FoodSearchViewModel!

    override func setUp() {
        super.setUp()
        searchFoodUseCase = MockSearchFoodUseCase()
        multiSourceUseCase = MockSearchMultiSourceFoodUseCase()
        viewModel = FoodSearchViewModel(
            searchFoodUseCase: searchFoodUseCase,
            multiSourceUseCase: multiSourceUseCase
        )
    }

    override func tearDown() {
        searchFoodUseCase = nil
        multiSourceUseCase = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialSearchQueryIsEmpty() {
        XCTAssertEqual(viewModel.searchQuery, "")
    }

    func testInitialSearchResultsIsEmpty() {
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }

    func testInitialIsLoadingIsFalse() {
        XCTAssertFalse(viewModel.isLoading)
    }

    func testInitialErrorMessageIsNil() {
        XCTAssertNil(viewModel.errorMessage)
    }

    func testInitialBarcodeScannerNotPresented() {
        XCTAssertFalse(viewModel.isBarcodeScannerPresented)
    }

    // MARK: - Search - Basic Tests

    func testSearchWithEmptyQueryClearsResults() async throws {
        // Setup: add some results first
        viewModel.searchResults = MockSearchMultiSourceFoodUseCase.createSampleResults()
        viewModel.searchQuery = ""

        viewModel.search()

        // Wait briefly for the synchronous clear
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }

    func testSearchWithEmptyQueryClearsError() async throws {
        viewModel.errorMessage = "Previous error"
        viewModel.searchQuery = ""

        viewModel.search()

        try await Task.sleep(for: .milliseconds(50))

        XCTAssertNil(viewModel.errorMessage)
    }

    func testSearchReturnsResults() async throws {
        let sampleResults = MockSearchMultiSourceFoodUseCase.createSampleResults(count: 3)
        multiSourceUseCase.mockResults = sampleResults
        viewModel.searchQuery = "apple"

        viewModel.search()

        // Wait for debounce (500ms) + execution time
        try await Task.sleep(for: .milliseconds(700))

        XCTAssertEqual(viewModel.searchResults.count, 3)
        XCTAssertEqual(multiSourceUseCase.lastSearchQuery, "apple")
    }

    func testSearchHandlesError() async throws {
        multiSourceUseCase.shouldThrowOnSearch = true
        viewModel.searchQuery = "test"

        viewModel.search()

        // Wait for debounce + execution
        try await Task.sleep(for: .milliseconds(700))

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Search - Debouncing Tests

    func testSearchDebounces500ms() async throws {
        multiSourceUseCase.mockResults = MockSearchMultiSourceFoodUseCase.createSampleResults()
        viewModel.searchQuery = "banana"

        viewModel.search()

        // Check immediately - should not have executed yet
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertEqual(multiSourceUseCase.executeCallCount, 0)

        // Wait for debounce to complete
        try await Task.sleep(for: .milliseconds(500))
        XCTAssertEqual(multiSourceUseCase.executeCallCount, 1)
    }

    func testSearchCancelsPreviousTask() async throws {
        multiSourceUseCase.mockResults = MockSearchMultiSourceFoodUseCase.createSampleResults()

        // Start first search
        viewModel.searchQuery = "apple"
        viewModel.search()

        // Immediately start second search
        try await Task.sleep(for: .milliseconds(100))
        viewModel.searchQuery = "banana"
        viewModel.search()

        // Wait for debounce + execution
        try await Task.sleep(for: .milliseconds(700))

        // Only the second search should have completed
        XCTAssertEqual(multiSourceUseCase.lastSearchQuery, "banana")
    }

    func testMultipleSearchesOnlyLastExecutes() async throws {
        multiSourceUseCase.mockResults = MockSearchMultiSourceFoodUseCase.createSampleResults()

        // Rapid fire searches
        viewModel.searchQuery = "a"
        viewModel.search()
        try await Task.sleep(for: .milliseconds(100))

        viewModel.searchQuery = "ap"
        viewModel.search()
        try await Task.sleep(for: .milliseconds(100))

        viewModel.searchQuery = "app"
        viewModel.search()
        try await Task.sleep(for: .milliseconds(100))

        viewModel.searchQuery = "apple"
        viewModel.search()

        // Wait for final debounce + execution
        try await Task.sleep(for: .milliseconds(700))

        // Only the last query should be searched
        XCTAssertEqual(multiSourceUseCase.lastSearchQuery, "apple")
    }

    // MARK: - Barcode Search Tests

    func testSearchByBarcodeSuccess() async throws {
        let sampleFood = MockSearchMultiSourceFoodUseCase.createSampleFood(name: "Barcode Product")
        multiSourceUseCase.mockBarcodeResult = sampleFood

        viewModel.searchByBarcode("1234567890")

        // Wait for async execution
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.name, "Barcode Product")
    }

    func testSearchByBarcodeUpdatesSearchQuery() async throws {
        let sampleFood = MockSearchMultiSourceFoodUseCase.createSampleFood(name: "Scanned Item")
        multiSourceUseCase.mockBarcodeResult = sampleFood

        viewModel.searchByBarcode("1234567890")

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(viewModel.searchQuery, "Scanned Item")
    }

    func testSearchByBarcodeHandlesError() async throws {
        multiSourceUseCase.shouldThrowOnBarcode = true

        viewModel.searchByBarcode("invalid")

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }

    func testSearchByBarcodeSetsLoading() async throws {
        let sampleFood = MockSearchMultiSourceFoodUseCase.createSampleFood()
        multiSourceUseCase.mockBarcodeResult = sampleFood

        viewModel.searchByBarcode("1234567890")

        // After completion
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Barcode Scanner UI Tests

    func testPresentBarcodeScanner() {
        XCTAssertFalse(viewModel.isBarcodeScannerPresented)

        viewModel.presentBarcodeScanner()

        XCTAssertTrue(viewModel.isBarcodeScannerPresented)
    }

    // MARK: - Clear Search Tests

    func testClearSearchResetsQuery() {
        viewModel.searchQuery = "test"

        viewModel.clearSearch()

        XCTAssertEqual(viewModel.searchQuery, "")
    }

    func testClearSearchResetsResults() {
        viewModel.searchResults = MockSearchMultiSourceFoodUseCase.createSampleResults()

        viewModel.clearSearch()

        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }

    func testClearSearchResetsError() {
        viewModel.errorMessage = "Some error"

        viewModel.clearSearch()

        XCTAssertNil(viewModel.errorMessage)
    }

    func testClearSearchCancelsTask() async throws {
        multiSourceUseCase.mockResults = MockSearchMultiSourceFoodUseCase.createSampleResults()

        // Start a search
        viewModel.searchQuery = "apple"
        viewModel.search()

        // Clear before debounce completes
        try await Task.sleep(for: .milliseconds(100))
        viewModel.clearSearch()

        // Wait past the debounce time
        try await Task.sleep(for: .milliseconds(500))

        // Search should not have executed
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }
}
