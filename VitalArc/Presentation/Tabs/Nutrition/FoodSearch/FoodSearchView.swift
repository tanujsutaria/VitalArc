//
//  FoodSearchView.swift
//  VitalArc
//
//  View for searching foods via USDA API
//

import SwiftUI

struct FoodSearchView: View {
    @State private var viewModel: FoodSearchViewModel
    @Environment(\.dismiss) private var dismiss

    let onFoodSelected: (Food) -> Void

    init(searchFoodUseCase: SearchFoodUseCaseProtocol, onFoodSelected: @escaping (Food) -> Void) {
        _viewModel = State(initialValue: FoodSearchViewModel(searchFoodUseCase: searchFoodUseCase))
        self.onFoodSelected = onFoodSelected
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search results
                if viewModel.isLoading {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                    EmptySearchView()
                } else if viewModel.searchResults.isEmpty {
                    InitialSearchView()
                } else {
                    SearchResultsListView(
                        results: viewModel.searchResults,
                        onSelect: { food in
                            onFoodSelected(food)
                            dismiss()
                        }
                    )
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search foods...")
            .onChange(of: viewModel.searchQuery) {
                viewModel.search()
            }
            .navigationTitle("Search Foods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Searching...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Error")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Results")
                .font(.headline)

            Text("Try searching with different keywords")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct InitialSearchView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Search for Foods")
                .font(.headline)

            Text("Enter a food name to search the USDA database")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SearchResultsListView: View {
    let results: [Food]
    let onSelect: (Food) -> Void

    var body: some View {
        List {
            ForEach(results) { food in
                FoodResultRowView(food: food, onSelect: onSelect)
            }
        }
        .listStyle(.plain)
    }
}
