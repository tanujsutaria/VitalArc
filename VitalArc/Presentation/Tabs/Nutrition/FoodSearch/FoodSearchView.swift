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
                    InitialSearchView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, Spacing.screenPadding)
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
                        .font(.system(size: Spacing.iconHuge))
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

/// Initial search view shown when no query has been entered
private struct InitialSearchView: View {
    var body: some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.vitalPrimary.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: Spacing.iconHuge))
                        .foregroundStyle(Color.vitalPrimary)
                }

                // Text
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

                // Database badges
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

    var body: some View {
        List {
            ForEach(results) { food in
                FoodResultRowView(food: food, onSelect: onSelect)
            }
        }
        .listStyle(.plain)
    }
}
