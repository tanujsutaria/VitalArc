//
//  FoodSearchViewModel.swift
//  VitalArc
//
//  ViewModel for food search with debounced queries
//

import Foundation
import Observation

enum FavoriteSortOrder: String, CaseIterable {
    case alphabetical = "A-Z"
    case mostUsed = "Most Used"
}

@MainActor
@Observable
final class FoodSearchViewModel {
    var searchQuery = ""
    var searchResults: [Food] = []
    var favoriteFoods: [Food] = []
    var recentFoods: [Food] = []
    var favoriteSortOrder: FavoriteSortOrder = .alphabetical
    var isLoading = false
    var errorMessage: String?
    var isBarcodeScannerPresented = false
    var scannedBarcode: String?
    var showingCreateCustomFood = false

    private let searchFoodUseCase: SearchFoodUseCaseProtocol
    private let repository: NutritionRepository?
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
        multiSourceUseCase: SearchMultiSourceFoodUseCaseProtocol? = nil,
        repository: NutritionRepository? = nil
    ) {
        self.searchFoodUseCase = searchFoodUseCase
        self._multiSourceUseCase = multiSourceUseCase
        self.repository = repository
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

    /// Load favorites and recent foods for display when search is empty
    func loadSuggestions() async {
        guard let repository = repository else { return }
        do {
            let favorites = try await repository.getFavoriteFoods()
            favoriteFoods = sortedFavorites(favorites)
            recentFoods = try await repository.getRecentFoods(limit: 10)
        } catch {
            // Non-critical: don't surface errors for suggestions
        }
    }

    private func sortedFavorites(_ foods: [Food]) -> [Food] {
        switch favoriteSortOrder {
        case .alphabetical:
            return foods.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .mostUsed:
            return foods.sorted { $0.usageCount > $1.usageCount }
        }
    }

    /// Toggle favorite status for a food
    func toggleFavorite(for food: Food) async {
        guard let repository = repository else { return }
        do {
            try await repository.toggleFavorite(foodId: food.id)
            await loadSuggestions()
        } catch {
            // Non-critical
        }
    }

    /// Save a custom food
    func saveCustomFood(_ food: Food) async {
        guard let repository = repository else { return }
        do {
            try await repository.saveFood(food)
            await loadSuggestions()
        } catch {
            errorMessage = "Failed to save custom food"
        }
    }
}
