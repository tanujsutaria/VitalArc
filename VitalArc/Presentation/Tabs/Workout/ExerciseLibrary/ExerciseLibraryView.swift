//
//  ExerciseLibraryView.swift
//  VitalArc
//
//  Exercise Library - Browse and search exercises
//

import SwiftUI

struct ExerciseLibraryView: View {
    @State private var viewModel: ExerciseLibraryViewModel
    let onSelectExercise: (Exercise) -> Void

    init(
        getExercisesUseCase: GetExercisesUseCase,
        onSelectExercise: @escaping (Exercise) -> Void
    ) {
        self.viewModel = ExerciseLibraryViewModel(getExercisesUseCase: getExercisesUseCase)
        self.onSelectExercise = onSelectExercise
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter
                categoryFilterScrollView

                // Exercise List
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if viewModel.exercises.isEmpty {
                    ContentUnavailableView.search
                } else {
                    List(viewModel.exercises) { exercise in
                        Button {
                            onSelectExercise(exercise)
                        } label: {
                            ExerciseRowView(exercise: exercise)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Exercise Library")
            .searchable(text: $viewModel.searchText, prompt: "Search exercises")
            .onChange(of: viewModel.searchText) { _, newValue in
                Task {
                    await viewModel.updateSearch(newValue)
                }
            }
            .task {
                await viewModel.loadExercises()
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    Task {
                        await viewModel.selectCategory(nil)
                    }
                }

                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    CategoryFilterChip(
                        title: category.rawValue,
                        icon: iconForCategory(category),
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        Task {
                            await viewModel.selectCategory(category)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(.background)
    }

    private func iconForCategory(_ category: ExerciseCategory) -> String {
        switch category {
        case .push: return "arrow.up.circle.fill"
        case .pull: return "arrow.down.circle.fill"
        case .legs: return "figure.walk"
        case .core: return "circle.grid.cross.fill"
        case .cardio: return "heart.fill"
        case .olympic: return "figure.strengthtraining.traditional"
        case .strongman: return "figure.strengthtraining.functional"
        case .calisthenics: return "figure.gymnastics"
        case .plyometrics: return "figure.jumprope"
        case .mobility: return "figure.flexibility"
        }
    }
}

// MARK: - Category Filter Chip

struct CategoryFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
