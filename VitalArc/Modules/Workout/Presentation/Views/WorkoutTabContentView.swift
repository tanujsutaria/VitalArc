//
//  WorkoutTabContentView.swift
//  VitalArc
//
//  Main content view for the Workout tab - Section-based layout
//

import SwiftUI

struct WorkoutTabContentView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var showingWorkoutLogger = false
    @State private var showingExerciseLibrary = false
    @State private var recentWorkouts: [Workout] = []
    @State private var templates: [WorkoutTemplate] = []
    @State private var isLoading = true
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        if let container = container {
            NavigationStack {
                ScrollView {
                    VStack(spacing: Spacing.sectionSpacing) {
                        // Start Workout Button
                        startWorkoutSection

                        // Templates Section
                        if !templates.isEmpty {
                            templatesSection(container: container)
                        }

                        // Exercise Library Section
                        exerciseLibrarySection(container: container)

                        // Recent Workouts Section
                        if !recentWorkouts.isEmpty {
                            recentWorkoutsSection(container: container)
                        }
                    }
                    .padding(Spacing.screenPadding)
                }
                .background(Color.vitalAdaptiveBackground)
                .navigationTitle("Workout")
                .sheet(isPresented: $showingWorkoutLogger) {
                    WorkoutLoggingView(
                        createWorkoutUseCase: CreateWorkoutUseCase(
                            repository: container.workoutRepository
                        ),
                        calculateProgressionUseCase: CalculateProgressionUseCase(
                            repository: container.workoutRepository
                        ),
                        getExercisesUseCase: GetExercisesUseCase(
                            repository: container.workoutRepository
                        ),
                        detectPersonalRecordUseCase: DetectPersonalRecordUseCase(
                            workoutRepository: container.workoutRepository,
                            analyticsRepository: container.analyticsRepository
                        ),
                        calculateOneRepMaxUseCase: CalculateOneRepMaxUseCase(
                            analyticsRepository: container.analyticsRepository
                        )
                    )
                }
                .sheet(isPresented: $showingExerciseLibrary) {
                    NavigationStack {
                        ExerciseLibraryView(
                            getExercisesUseCase: GetExercisesUseCase(
                                repository: container.workoutRepository
                            ),
                            getExerciseHistoryUseCase: container.workout.getExerciseHistoryUseCase
                        ) { _ in
                            // Exercise selected from library
                        }
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") {
                                    showingExerciseLibrary = false
                                }
                            }
                        }
                    }
                }
                .task {
                    // Cancel any previous load task to prevent race conditions on rapid navigation
                    loadTask?.cancel()
                    loadTask = Task {
                        try? await ExerciseSeeds.seedIfNeeded(repository: container.workoutRepository)
                        guard !Task.isCancelled else { return }
                        await loadData(container: container)
                    }
                    await loadTask?.value
                }
                .onDisappear {
                    loadTask?.cancel()
                }
            }
        } else {
            ProgressView()
        }
    }

    // MARK: - Start Workout Section

    private var startWorkoutSection: some View {
        VitalCard {
            VStack(spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Ready to train?")
                            .font(.vitalH2)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        Text("Log your workout and track progress")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                    Spacer()
                }

                VitalButton(
                    title: "Start Workout",
                    style: .primary,
                    icon: "play.fill"
                ) {
                    showingWorkoutLogger = true
                }
            }
        }
    }

    // MARK: - Templates Section

    @ViewBuilder
    private func templatesSection(container: DependencyContainer) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Templates")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Spacer()

                NavigationLink {
                    WorkoutTemplatesContentView(container: container)
                } label: {
                    Text("See All")
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalPrimary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(templates.prefix(5)) { template in
                        NavigationLink {
                            TemplateDetailView(
                                template: template,
                                onUseTemplate: { _ in },
                                onDeleteTemplate: { _ in }
                            )
                        } label: {
                            TemplatePreviewCard(template: template)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Exercise Library Section

    @ViewBuilder
    private func exerciseLibrarySection(container: DependencyContainer) -> some View {
        VitalCard {
            VStack(spacing: Spacing.md) {
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .font(.vitalH2)
                        .foregroundStyle(Color.vitalPrimary)

                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Exercise Library")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        Text("Browse 200+ exercises")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
        .onTapGesture {
            showingExerciseLibrary = true
        }
    }

    // MARK: - Recent Workouts Section

    @ViewBuilder
    private func recentWorkoutsSection(container: DependencyContainer) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Recent Workouts")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Spacer()

                NavigationLink {
                    WorkoutHistoryContentView(container: container)
                } label: {
                    Text("See All")
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalPrimary)
                }
            }

            ForEach(recentWorkouts.prefix(3)) { workout in
                NavigationLink {
                    WorkoutDetailView(
                        workout: workout,
                        repository: container.workoutRepository
                    )
                } label: {
                    WorkoutSummaryCard(workout: workout)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Data Loading

    @MainActor
    private func loadData(container: DependencyContainer) async {
        isLoading = true
        defer { isLoading = false }

        // Load recent workouts
        do {
            let allWorkouts = try await container.workoutRepository.getWorkouts()
            // Check for cancellation before updating state
            guard !Task.isCancelled else { return }
            recentWorkouts = allWorkouts
                .sorted { $0.date > $1.date }
                .prefix(5)
                .map { $0 }
        } catch {
            guard !Task.isCancelled else { return }
            Log.error("Failed to load workouts", error: error, category: .workout)
        }

        // Load templates
        do {
            let loadedTemplates = try await container.templateRepository.getTemplates()
            // Check for cancellation before updating state
            guard !Task.isCancelled else { return }
            templates = loadedTemplates
        } catch {
            guard !Task.isCancelled else { return }
            Log.error("Failed to load templates", error: error, category: .workout)
        }
    }
}

// MARK: - Template Preview Card

private struct TemplatePreviewCard: View {
    let template: WorkoutTemplate

    var body: some View {
        VitalCard(padding: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(template.name)
                    .font(.vitalLabel)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    .lineLimit(1)

                Text("\(template.exercises.count) exercises")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                HStack(spacing: Spacing.xs) {
                    Image(systemName: template.category.icon)
                        .font(.vitalCaptionSmall)
                    Text(template.category.displayName)
                        .font(.vitalCaptionSmall)
                }
                .foregroundStyle(Color.vitalPrimary)
            }
            .frame(width: Spacing.pieChartSize)
        }
    }
}

// MARK: - Workout Summary Card

private struct WorkoutSummaryCard: View {
    let workout: Workout

    var body: some View {
        VitalCard {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(workout.name ?? "Workout")
                        .font(.vitalLabel)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text(formatDate(workout.date))
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("\(workout.sets.count) sets")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    if let duration = workout.duration {
                        Text(formatDuration(duration))
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Templates Content View

struct WorkoutTemplatesContentView: View {
    let container: DependencyContainer
    @State private var viewModel: WorkoutTemplatesViewModel?
    @State private var showingCreateTemplate = false
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var searchText = ""

    var filteredTemplates: [WorkoutTemplate] {
        guard let viewModel = viewModel else { return [] }
        if searchText.isEmpty {
            return viewModel.templates
        } else {
            return viewModel.templates.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    var templatesByCategory: [TemplateCategory: [WorkoutTemplate]] {
        Dictionary(grouping: filteredTemplates) { $0.category }
    }

    var body: some View {
        Group {
            if let viewModel = viewModel {
                if viewModel.templates.isEmpty {
                    ContentUnavailableView(
                        "No Templates",
                        systemImage: "list.clipboard",
                        description: Text("Create your first workout template")
                    )
                } else {
                    List {
                        // Recently Used
                        if !viewModel.recentTemplates.isEmpty {
                            Section("Recently Used") {
                                ForEach(viewModel.recentTemplates) { template in
                                    NavigationLink {
                                        TemplateDetailView(
                                            template: template,
                                            onUseTemplate: { selectedTemplate = $0 },
                                            onDeleteTemplate: { templateToDelete in
                                                Task {
                                                    await viewModel.deleteTemplate(templateToDelete)
                                                }
                                            }
                                        )
                                    } label: {
                                        TemplateRow(template: template) {
                                            selectedTemplate = template
                                        }
                                    }
                                }
                            }
                        }

                        // All by category
                        ForEach(TemplateCategory.allCases, id: \.self) { category in
                            if let templates = templatesByCategory[category], !templates.isEmpty {
                                Section(category.displayName) {
                                    ForEach(templates) { template in
                                        NavigationLink {
                                            TemplateDetailView(
                                                template: template,
                                                onUseTemplate: { selectedTemplate = $0 },
                                                onDeleteTemplate: { templateToDelete in
                                                    Task {
                                                        await viewModel.deleteTemplate(templateToDelete)
                                                    }
                                                }
                                            )
                                        } label: {
                                            TemplateRow(template: template) {
                                                selectedTemplate = template
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search templates")
                }
            } else {
                ProgressView()
            }
        }
        .task {
            let loadUseCase = LoadWorkoutTemplateUseCase(
                templateRepository: container.templateRepository,
                workoutRepository: container.workoutRepository
            )
            let saveUseCase = SaveWorkoutTemplateUseCase(
                templateRepository: container.templateRepository,
                workoutRepository: container.workoutRepository
            )
            viewModel = WorkoutTemplatesViewModel(
                loadTemplateUseCase: loadUseCase,
                saveTemplateUseCase: saveUseCase,
                templateRepository: container.templateRepository
            )
            await viewModel?.loadTemplates()
        }
        .sheet(isPresented: $showingCreateTemplate) {
            if let viewModel = viewModel {
                TemplateEditorView(viewModel: viewModel)
            }
        }
        .sheet(item: $selectedTemplate) { template in
            StartWorkoutFromTemplateSheet(
                template: template,
                onStart: { _ in
                    Task {
                        await viewModel?.startWorkout(from: template)
                    }
                }
            )
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingCreateTemplate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    WorkoutTabContentView()
}
