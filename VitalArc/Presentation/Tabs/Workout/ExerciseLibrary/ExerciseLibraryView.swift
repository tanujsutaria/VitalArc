//
//  ExerciseLibraryView.swift
//  VitalArc
//
//  Exercise Library - Browse and search exercises grouped by body part
//  Supports custom categories and custom exercises
//

import SwiftUI

// MARK: - Body Part Categories

enum BodyPartCategory: String, CaseIterable, Identifiable, Codable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case quads = "Quads"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case calves = "Calves"
    case core = "Core"
    case forearms = "Forearms"
    case custom = "Custom"

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
        case .calves: return "shoeprints.fill"
        case .core: return "circle.grid.cross.fill"
        case .forearms: return "hand.raised.fill"
        case .custom: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .chest: return .red
        case .back: return .blue
        case .shoulders: return .orange
        case .biceps: return .purple
        case .triceps: return .pink
        case .quads: return .green
        case .hamstrings: return .teal
        case .glutes: return .indigo
        case .calves: return .mint
        case .core: return .yellow
        case .forearms: return .brown
        case .custom: return .gray
        }
    }

    /// Maps MuscleGroup to BodyPartCategory
    static func from(muscleGroup: MuscleGroup) -> BodyPartCategory {
        switch muscleGroup {
        case .chest: return .chest
        case .upperBack, .lowerBack, .lats, .traps, .back: return .back
        case .shoulders, .rearDelts: return .shoulders
        case .biceps: return .biceps
        case .triceps: return .triceps
        case .quadriceps: return .quads
        case .hamstrings, .hipFlexors, .adductors, .abductors: return .hamstrings
        case .glutes: return .glutes
        case .calves: return .calves
        case .abs, .obliques, .serratus: return .core
        case .forearms: return .forearms
        case .fullBody: return .custom
        }
    }
}

struct ExerciseLibraryView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var viewModel: ExerciseLibraryViewModel
    @State private var expandedSections: Set<BodyPartCategory> = Set(BodyPartCategory.allCases)
    @State private var showingAddExercise = false
    @State private var showingAddCategory = false
    @State private var customCategories: [String] = []

    let onSelectExercise: (Exercise) -> Void

    init(
        getExercisesUseCase: GetExercisesUseCase,
        onSelectExercise: @escaping (Exercise) -> Void
    ) {
        self.viewModel = ExerciseLibraryViewModel(getExercisesUseCase: getExercisesUseCase)
        self.onSelectExercise = onSelectExercise
    }

    var body: some View {
        VStack(spacing: 0) {
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
            } else if viewModel.exercises.isEmpty && viewModel.searchText.isEmpty {
                emptyStateView
            } else if viewModel.exercises.isEmpty {
                ContentUnavailableView.search
            } else {
                exerciseListGroupedByBodyPart
            }
        }
        .background(Color.vitalAdaptiveBackground)
        .searchable(text: $viewModel.searchText, prompt: "Search exercises")
        .onChange(of: viewModel.searchText) { _, newValue in
            Task {
                await viewModel.updateSearch(newValue)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingAddExercise = true
                    } label: {
                        Label("Add Custom Exercise", systemImage: "plus.circle")
                    }

                    Button {
                        showingAddCategory = true
                    } label: {
                        Label("Add Custom Category", systemImage: "folder.badge.plus")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddCustomExerciseView { exercise in
                // Handle adding custom exercise
                Task {
                    await viewModel.loadExercises()
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCustomCategoryView { categoryName in
                customCategories.append(categoryName)
            }
        }
        .task {
            await viewModel.loadExercises()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.vitalAdaptiveTextTertiary)

            Text("No Exercises")
                .font(.vitalH2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            Text("Add custom exercises to get started")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Button {
                showingAddExercise = true
            } label: {
                Label("Add Exercise", systemImage: "plus.circle.fill")
                    .font(.vitalLabel)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(Color.vitalPrimary)
                    .cornerRadius(Spacing.radiusMedium)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Grouped Exercise List

    private var exerciseListGroupedByBodyPart: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                // Standard body part categories
                ForEach(BodyPartCategory.allCases.filter { $0 != .custom }) { bodyPart in
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
                                .padding(.vertical, Spacing.sm)
                            }
                        } header: {
                            BodyPartSectionHeader(
                                title: bodyPart.rawValue,
                                icon: bodyPart.icon,
                                color: bodyPart.color,
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

                // Custom categories
                ForEach(customCategories, id: \.self) { categoryName in
                    Section {
                        Text("No exercises in this category")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            .padding(Spacing.md)
                    } header: {
                        HStack(spacing: Spacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 40, height: 40)

                                Image(systemName: "star.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.gray)
                            }

                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text(categoryName)
                                    .font(.vitalH3)
                                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                                Text("Custom category")
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, Spacing.screenPadding)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.vitalAdaptiveSurface)
                    }
                }
            }
        }
    }

    /// Groups exercises by their primary muscle group mapped to BodyPartCategory
    private func exercisesGrouped(by bodyPart: BodyPartCategory) -> [Exercise] {
        viewModel.exercises.filter { exercise in
            guard let primaryMuscle = exercise.primaryMuscles.first else {
                return bodyPart == .custom
            }
            return BodyPartCategory.from(muscleGroup: primaryMuscle) == bodyPart
        }
    }
}

// MARK: - Body Part Section Header

struct BodyPartSectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    let exerciseCount: Int
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Icon with background
                ZStack {
                    RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(color)
                }

                // Title and count
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
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

// MARK: - Add Custom Exercise View

struct AddCustomExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencyContainer) private var container

    @State private var name = ""
    @State private var selectedBodyPart: BodyPartCategory = .chest
    @State private var notes = ""
    @State private var isSaving = false
    @State private var saveError: String?

    let onSave: (Exercise) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Details") {
                    TextField("Exercise Name", text: $name)

                    Picker("Body Part", selection: $selectedBodyPart) {
                        ForEach(BodyPartCategory.allCases.filter { $0 != .custom }) { bodyPart in
                            HStack {
                                Image(systemName: bodyPart.icon)
                                    .foregroundStyle(bodyPart.color)
                                Text(bodyPart.rawValue)
                            }
                            .tag(bodyPart)
                        }
                    }
                }

                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .alert("Error Saving Exercise", isPresented: .init(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK") { saveError = nil }
            } message: {
                if let error = saveError {
                    Text(error)
                }
            }
        }
    }

    private func saveExercise() {
        isSaving = true

        let muscleGroup = muscleGroupFor(bodyPart: selectedBodyPart)

        let exercise = Exercise(
            name: name.trimmingCharacters(in: .whitespaces),
            category: .custom,
            primaryMuscles: [muscleGroup],
            secondaryMuscles: [],
            equipment: .bodyweight,
            instructions: notes.isEmpty ? nil : notes,
            isCustom: true
        )

        Task {
            do {
                if let container = container {
                    try await container.workoutRepository.saveExercise(exercise)
                }
                onSave(exercise)
                dismiss()
            } catch {
                print("[ExerciseLibrary] Failed to save exercise: \(error)")
                saveError = "Failed to save exercise. Please try again."
                isSaving = false
            }
        }
    }

    private func muscleGroupFor(bodyPart: BodyPartCategory) -> MuscleGroup {
        switch bodyPart {
        case .chest: return .chest
        case .back: return .back
        case .shoulders: return .shoulders
        case .biceps: return .biceps
        case .triceps: return .triceps
        case .quads: return .quadriceps
        case .hamstrings: return .hamstrings
        case .glutes: return .glutes
        case .calves: return .calves
        case .core: return .abs
        case .forearms: return .forearms
        case .custom: return .fullBody
        }
    }
}

// MARK: - Add Custom Category View

struct AddCustomCategoryView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var categoryName = ""

    let onSave: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    TextField("Category Name", text: $categoryName)
                }

                Section {
                    Text("Custom categories help you organize exercises your way. You can add exercises to this category after creating it.")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(categoryName.trimmingCharacters(in: .whitespaces))
                        dismiss()
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseLibraryView(
            getExercisesUseCase: GetExercisesUseCase(
                repository: PreviewWorkoutRepository()
            )
        ) { exercise in
            print("Selected: \(exercise.name)")
        }
    }
}
