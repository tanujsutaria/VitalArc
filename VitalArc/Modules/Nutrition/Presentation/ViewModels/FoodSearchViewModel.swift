//
//  FoodSearchViewModel.swift
//  VitalArc
//
//  ViewModel for food search with debounced queries
//

import Foundation
import Observation

@MainActor
@Observable
final class FoodSearchViewModel {
    var searchQuery = ""
    var searchResults: [Food] = []
    var isLoading = false
    var errorMessage: String?
    var isBarcodeScannerPresented = false
    var scannedBarcode: String?

    private let searchFoodUseCase: SearchFoodUseCaseProtocol
    private var _multiSourceUseCase: SearchMultiSourceFoodUseCaseProtocol?
    private var searchTask: Task<Void, Never>?

    private var multiSourceUseCase: SearchMultiSourceFoodUseCaseProtocol {
        if let useCase = _multiSourceUseCase {
            return useCase
        }
        let coordinator = FoodAPICoordinator()
        let useCase = SearchMultiSourceFoodUseCase(coordinator: coordinator)
        _multiSourceUseCase = useCase
        return useCase
    }

    init(
        searchFoodUseCase: SearchFoodUseCaseProtocol,
        multiSourceUseCase: SearchMultiSourceFoodUseCaseProtocol? = nil
    ) {
        self.searchFoodUseCase = searchFoodUseCase
        self._multiSourceUseCase = multiSourceUseCase
    }

    /// Perform debounced search using multi-source
    func search() {
        // Cancel existing search task
        searchTask?.cancel()

        // Clear results if query is empty
        guard !searchQuery.isEmpty else {
            searchResults = []
            errorMessage = nil
            return
        }

        // Debounce: wait 500ms before searching
        searchTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .milliseconds(500))

                // Check if task was cancelled
                guard !Task.isCancelled else { return }

                isLoading = true
                errorMessage = nil

                // Use multi-source search for better results
                let results = try await multiSourceUseCase.execute(query: searchQuery)

                // Check if task was cancelled
                guard !Task.isCancelled else { return }

                searchResults = results
                isLoading = false
            } catch {
                guard !Task.isCancelled else { return }

                errorMessage = UserFacingError.message(for: error, context: .searching)
                searchResults = []
                isLoading = false
            }
        }
    }

    /// Search by barcode
    func searchByBarcode(_ barcode: String) {
        Task { @MainActor in
            do {
                isLoading = true
                errorMessage = nil

                let food = try await multiSourceUseCase.searchByBarcode(barcode: barcode)

                searchResults = [food]
                searchQuery = food.name
                isLoading = false
            } catch {
                errorMessage = UserFacingError.message(for: error, context: .searching)
                searchResults = []
                isLoading = false
            }
        }
    }

    /// Present barcode scanner
    func presentBarcodeScanner() {
        isBarcodeScannerPresented = true
    }

    /// Clear search results
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        errorMessage = nil
        searchTask?.cancel()
    }
}
