//
//  ExerciseLibraryView.swift
//  VitalArc
//
//  Exercise Library - Browse and search exercises grouped by body part
//

import SwiftUI

// MARK: - Exercise Body Part Definition (for grouping exercises in the library)

enum ExerciseBodyPart: String, CaseIterable, Identifiable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case quads = "Quads"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case core = "Core"
    case fullBody = "Full Body"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .chest: return "heart.fill"
        case .back: return "figure.strengthtraining.traditional"
        case .shoulders: return "figure.arms.open"
        case .biceps: return "figure.mixed.cardio"
        case .triceps: return "figure.cooldown"
        case .quads: return "figure.walk"
        case .hamstrings: return "figure.run"
        case .glutes: return "figure.climbing"
        case .core: return "circle.grid.cross.fill"
        case .fullBody: return "figure.flexibility"
        }
    }

    var color: Color {
        switch self {
        case .chest: return .vitalDanger
        case .back: return .vitalInfo
        case .shoulders: return .vitalWarning
        case .biceps: return .vitalSecondary
        case .triceps: return .vitalAccent
        case .quads: return .vitalSuccess
        case .hamstrings: return .vitalPrimary
        case .glutes: return .vitalAccent
        case .core: return .vitalWarning
        case .fullBody: return .vitalInfo
        }
    }

    /// Maps MuscleGroup to ExerciseBodyPart for grouping
    static func from(muscleGroup: MuscleGroup) -> ExerciseBodyPart {
        switch muscleGroup {
        case .chest:
            return .chest
        case .upperBack, .lowerBack, .lats, .traps, .back:
            return .back
        case .shoulders, .rearDelts:
            return .shoulders
        case .biceps, .forearms:
            return .biceps
        case .triceps:
            return .triceps
        case .quadriceps:
            return .quads
        case .hamstrings, .hipFlexors, .adductors, .abductors:
            return .hamstrings
        case .glutes, .calves:
            return .glutes
        case .abs, .obliques, .serratus:
            return .core
        case .fullBody:
            return .fullBody
        }
    }
}

struct ExerciseLibraryView: View {
    @State private var viewModel: ExerciseLibraryViewModel
    @State private var expandedSections: Set<ExerciseBodyPart> = Set(ExerciseBodyPart.allCases)
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
                // Body Part Filter
                bodyPartFilterScrollView

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
                    exerciseListGroupedByBodyPart
                }
            }
            .background(Color.vitalAdaptiveBackground)
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

    // MARK: - Grouped Exercise List

    private var exerciseListGroupedByBodyPart: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md, pinnedViews: [.sectionHeaders]) {
                ForEach(ExerciseBodyPart.allCases) { bodyPart in
                    let exercisesForBodyPart = exercisesGrouped(by: bodyPart)

                    if !exercisesForBodyPart.isEmpty {
                        Section {
                            if expandedSections.contains(bodyPart) {
                                VStack(spacing: Spacing.sm) {
                                    ForEach(exercisesForBodyPart) { exercise in
                                        Button {
                                            onSelectExercise(exercise)
                                        } label: {
                                            ExerciseRowView(exercise: exercise)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, Spacing.screenPadding)
                                .padding(.bottom, Spacing.md)
                            }
                        } header: {
                            BodyPartSectionHeader(
                                bodyPart: bodyPart,
                                exerciseCount: exercisesForBodyPart.count,
                                isExpanded: expandedSections.contains(bodyPart)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if expandedSections.contains(bodyPart) {
                                        expandedSections.remove(bodyPart)
                                    } else {
                                        expandedSections.insert(bodyPart)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, Spacing.sm)
        }
    }

    /// Groups exercises by their primary muscle group mapped to ExerciseBodyPart
    private func exercisesGrouped(by bodyPart: ExerciseBodyPart) -> [Exercise] {
        viewModel.exercises.filter { exercise in
            guard let primaryMuscle = exercise.primaryMuscles.first else {
                return bodyPart == .fullBody
            }
            return ExerciseBodyPart.from(muscleGroup: primaryMuscle) == bodyPart
        }
    }

    // MARK: - Body Part Filter

    private var bodyPartFilterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.itemSpacing) {
                BodyPartFilterChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    color: .vitalPrimary,
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    Task {
                        await viewModel.selectCategory(nil)
                    }
                }

                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    BodyPartFilterChip(
                        title: category.rawValue,
                        icon: iconForCategory(category),
                        color: colorForCategory(category),
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        Task {
                            await viewModel.selectCategory(category)
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.screenPadding)
        }
        .padding(.vertical, Spacing.sm)
        .background(Color.vitalAdaptiveSurface)
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

    private func colorForCategory(_ category: ExerciseCategory) -> Color {
        switch category {
        case .push: return .vitalDanger
        case .pull: return .vitalInfo
        case .legs: return .vitalSuccess
        case .core: return .vitalWarning
        case .cardio: return .vitalSecondary
        case .olympic: return .vitalAccent
        case .strongman: return .vitalPrimary
        case .calisthenics: return .vitalInfo
        case .plyometrics: return .vitalWarning
        case .mobility: return .vitalSuccess
        }
    }
}

// MARK: - Body Part Section Header

struct BodyPartSectionHeader: View {
    let bodyPart: ExerciseBodyPart
    let exerciseCount: Int
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Icon with background
                ZStack {
                    RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                        .fill(bodyPart.color.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: bodyPart.icon)
                        .font(.system(size: Spacing.iconMedium, weight: .semibold))
                        .foregroundStyle(bodyPart.color)
                }

                // Title and count
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(bodyPart.rawValue)
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text("\(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                Spacer()

                // Expand/Collapse indicator
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    .rotationEffect(.degrees(isExpanded ? 0 : -90))
            }
            .padding(.horizontal, Spacing.screenPadding)
            .padding(.vertical, Spacing.sm)
            .background(Color.vitalAdaptiveSurface)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Body Part Filter Chip

struct BodyPartFilterChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(title)
                    .font(.vitalLabelSmall)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? color : Color.vitalAdaptiveBorder.opacity(0.5))
            .foregroundStyle(isSelected ? .white : Color.vitalAdaptiveTextPrimary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
