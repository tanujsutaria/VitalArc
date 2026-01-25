//
//  FoodSearchViewModel.swift
//  VitalArc
//
//  ViewModel for food search with debounced queries
//

import Foundation
import Observation

@Observable
final class FoodSearchViewModel {
    var searchQuery = ""
    var searchResults: [Food] = []
    var isLoading = false
    var errorMessage: String?

    private let searchFoodUseCase: SearchFoodUseCaseProtocol
    private var searchTask: Task<Void, Never>?

    init(searchFoodUseCase: SearchFoodUseCaseProtocol) {
        self.searchFoodUseCase = searchFoodUseCase
    }

    /// Perform debounced search
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

                let results = try await searchFoodUseCase.execute(query: searchQuery)

                // Check if task was cancelled
                guard !Task.isCancelled else { return }

                searchResults = results
                isLoading = false
            } catch {
                guard !Task.isCancelled else { return }

                errorMessage = "Failed to search foods: \(error.localizedDescription)"
                searchResults = []
                isLoading = false
            }
        }
    }

    /// Clear search results
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        errorMessage = nil
        searchTask?.cancel()
    }
}
