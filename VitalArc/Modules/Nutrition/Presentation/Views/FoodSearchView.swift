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

    init(
        searchFoodUseCase: SearchFoodUseCaseProtocol,
        repository: NutritionRepository? = nil,
        onFoodSelected: @escaping (Food) -> Void
    ) {
        _viewModel = State(initialValue: FoodSearchViewModel(
            searchFoodUseCase: searchFoodUseCase,
            repository: repository
        ))
        self.onFoodSelected = onFoodSelected
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search results
                if viewModel.isLoading {
                    VitalLoadingState(message: "Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    FoodSearchErrorView(message: errorMessage) {
                        viewModel.search()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, Spacing.screenPadding)
                } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                    VitalEmptyState(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "Try searching with different keywords"
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, Spacing.screenPadding)
                } else if viewModel.searchResults.isEmpty {
                    SuggestionsView(
                        viewModel: viewModel,
                        onSelect: { food in
                            onFoodSelected(food)
                            dismiss()
                        }
                    )
                } else {
                    SearchResultsListView(
                        results: viewModel.searchResults,
                        onSelect: { food in
                            onFoodSelected(food)
                            dismiss()
                        },
                        onToggleFavorite: { food in
                            Task { await viewModel.toggleFavorite(for: food) }
                        }
                    )
                }
            }
            .background(Color.vitalAdaptiveBackground)
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

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.presentBarcodeScanner()
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                            .font(.vitalBody)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isBarcodeScannerPresented) {
                BarcodeScannerView(scannedBarcode: $viewModel.scannedBarcode)
            }
            .onChange(of: viewModel.scannedBarcode) { _, newValue in
                if let barcode = newValue {
                    viewModel.searchByBarcode(barcode)
                    viewModel.scannedBarcode = nil
                }
            }
            .sheet(isPresented: $viewModel.showingCreateCustomFood) {
                CreateCustomFoodView { food in
                    Task {
                        await viewModel.saveCustomFood(food)
                        onFoodSelected(food)
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadSuggestions()
            }
        }
    }
}

// MARK: - Subviews

/// Error view that displays an error message with retry action
private struct FoodSearchErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.vitalWarning.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.vitalIconHuge)
                        .foregroundStyle(Color.vitalWarning)
                }

                // Text
                VStack(spacing: Spacing.sm) {
                    Text("Error")
                        .font(.vitalDisplaySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }

                // Retry button
                VitalButton(
                    title: "Try Again",
                    style: .primary,
                    icon: "arrow.clockwise",
                    fullWidth: true,
                    action: retryAction
                )
                .padding(.top, Spacing.sm)
            }
        }
        .transition(.vitalScale)
    }
}

/// Suggestions view shown when search is empty: favorites, recent foods, create custom
private struct SuggestionsView: View {
    let viewModel: FoodSearchViewModel
    let onSelect: (Food) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Create Custom Food button
                Button {
                    viewModel.showingCreateCustomFood = true
                } label: {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "plus.circle.fill")
                            .font(.vitalBody)
                        Text("Create Custom Food")
                            .font(.vitalLabel)
                    }
                    .foregroundStyle(Color.vitalPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Color.vitalPrimary.opacity(0.1))
                    .cornerRadius(Spacing.radiusMedium)
                }
                .buttonStyle(.plain)

                // Favorites section
                if !viewModel.favoriteFoods.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(Color.vitalDanger)
                            Text("Favorites")
                                .font(.vitalH3)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }

                        ForEach(viewModel.favoriteFoods) { food in
                            FoodResultRowView(
                                food: food,
                                onSelect: onSelect,
                                onToggleFavorite: { food in
                                    Task { await viewModel.toggleFavorite(for: food) }
                                }
                            )
                        }
                    }
                }

                // Recent section
                if !viewModel.recentFoods.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(Color.vitalInfo)
                            Text("Recent")
                                .font(.vitalH3)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }

                        ForEach(viewModel.recentFoods) { food in
                            FoodResultRowView(
                                food: food,
                                onSelect: onSelect,
                                onToggleFavorite: { food in
                                    Task { await viewModel.toggleFavorite(for: food) }
                                }
                            )
                        }
                    }
                }

                // Info card when no favorites/recent
                if viewModel.favoriteFoods.isEmpty && viewModel.recentFoods.isEmpty {
                    InitialSearchInfoView()
                }
            }
            .padding(Spacing.screenPadding)
        }
    }
}

/// Info card shown when no favorites or recent foods exist
private struct InitialSearchInfoView: View {
    var body: some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(Color.vitalPrimary.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "magnifyingglass")
                        .font(.vitalIconHuge)
                        .foregroundStyle(Color.vitalPrimary)
                }

                VStack(spacing: Spacing.sm) {
                    Text("Search for Foods")
                        .font(.vitalDisplaySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        .multilineTextAlignment(.center)

                    Text("Search across multiple databases:")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: Spacing.itemSpacing) {
                    DatabaseBadge(name: "USDA", icon: "leaf.fill", color: .vitalSuccess)
                    DatabaseBadge(name: "Nutritionix", icon: "fork.knife", color: .vitalWarning)
                    DatabaseBadge(name: "OpenFoodFacts", icon: "globe", color: .vitalInfo)
                }

                Text("Or tap the barcode icon to scan a product")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalTextTertiary)
            }
        }
        .transition(.vitalScale)
    }
}

/// Badge showing a data source
private struct DatabaseBadge: View {
    let name: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.vitalCaption)
                .foregroundStyle(color)
            Text(name)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(color.opacity(0.1))
        .cornerRadius(Spacing.radiusSmall)
    }
}

/// List view showing search results
private struct SearchResultsListView: View {
    let results: [Food]
    let onSelect: (Food) -> Void
    var onToggleFavorite: ((Food) -> Void)?

    var body: some View {
        List {
            ForEach(results) { food in
                FoodResultRowView(
                    food: food,
                    onSelect: onSelect,
                    onToggleFavorite: onToggleFavorite
                )
            }
        }
        .listStyle(.plain)
    }
}
