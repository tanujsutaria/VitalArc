//
//  MainTabView.swift
//  VitalArc
//
//  Created by Claude on 2026-01-25.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Health Tab
            if let healthRepository = container?.healthRepository {
                HealthDashboardView(healthRepository: healthRepository)
                    .tabItem {
                        Label("Health", systemImage: "heart.fill")
                    }
                    .tag(0)
            }

            // Workout Tab
            WorkoutTabView()
                .tabItem {
                    Label("Workout", systemImage: "dumbbell.fill")
                }
                .tag(1)

            // Nutrition Tab
            NutritionTabView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }
                .tag(2)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.accentColor)
    }
}

struct WorkoutTabView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var showingWorkoutLogger = false
    @State private var selectedView: WorkoutView = .exercises

    enum WorkoutView: String, CaseIterable {
        case exercises = "Exercises"
        case templates = "Templates"
        case mesocycles = "Mesocycles"
        case history = "History"
    }

    var body: some View {
        if let container = container {
            NavigationStack {
                VStack(spacing: 0) {
                    // View Selector
                    Picker("View", selection: $selectedView) {
                        ForEach(WorkoutView.allCases, id: \.self) { view in
                            Text(view.rawValue).tag(view)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    // Content
                    switch selectedView {
                    case .exercises:
                        ExerciseLibraryView(
                            getExercisesUseCase: GetExercisesUseCase(
                                repository: container.workoutRepository
                            )
                        ) { exercise in
                            // Exercise selected from library
                        }
                    case .templates:
                        WorkoutTemplatesContentView(container: container)
                    case .mesocycles:
                        MesocycleContentView(container: container)
                    case .history:
                        WorkoutHistoryContentView(container: container)
                    }
                }
                .navigationTitle("Workout")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingWorkoutLogger = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.vitalH2)
                        }
                    }
                }
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
                        )
                    )
                }
                .task {
                    // Silent failure acceptable - exercise seeding is non-critical initialization
                    // that will retry on next launch if it fails
                    try? await ExerciseSeeds.seedIfNeeded(repository: container.workoutRepository)
                }
            }
        } else {
            ProgressView()
        }
    }
}

// MARK: - Templates Content View (embedded without NavigationStack)

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
            let saveUseCase = SaveWorkoutTemplateUseCase(templateRepository: container.templateRepository, workoutRepository: container.workoutRepository)
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

// MARK: - Mesocycle/Programs Content View (embedded without NavigationStack)

struct MesocycleContentView: View {
    let container: DependencyContainer
    @State private var viewModel: MesocycleViewModel?
    @State private var showingCreateSheet = false
    @State private var selectedStatus: MesocycleStatus = .active

    var body: some View {
        Group {
            if let viewModel = viewModel {
                VStack(spacing: 0) {
                    // Status Filter
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(MesocycleStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.sm)

                    // Mesocycle List
                    if viewModel.isLoading {
                        VitalLoadingState(message: "Loading programs...")
                            .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: Spacing.itemSpacing) {
                                let filteredMesocycles = viewModel.getMesocyclesByStatus(selectedStatus)

                                if filteredMesocycles.isEmpty {
                                    emptyStateView(viewModel: viewModel)
                                } else {
                                    ForEach(filteredMesocycles) { mesocycle in
                                        NavigationLink(destination: MesocycleDetailView(
                                            mesocycle: mesocycle,
                                            viewModel: viewModel
                                        )) {
                                            MesocycleCardView(mesocycle: mesocycle, viewModel: viewModel)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(Spacing.md)
                        }
                        .background(Color.vitalAdaptiveBackground)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            viewModel = MesocycleViewModel(
                mesocycleRepository: container.mesocycleRepository,
                workoutRepository: container.workoutRepository
            )
            await viewModel?.loadMesocycles()
        }
        .sheet(isPresented: $showingCreateSheet) {
            if let viewModel = viewModel {
                CreateMesocycleView(viewModel: viewModel)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingCreateSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.vitalH2)
                        .foregroundStyle(Color.vitalPrimary)
                }
            }
        }
    }

    private func emptyStateView(viewModel: MesocycleViewModel) -> some View {
        VitalEmptyState(
            icon: selectedStatus == .active ? "calendar.badge.exclamationmark" : "calendar",
            title: "No \(selectedStatus.rawValue) Programs",
            message: emptyStateMessage,
            actionTitle: (selectedStatus == .planned || selectedStatus == .active) ? "Create Program" : nil,
            action: (selectedStatus == .planned || selectedStatus == .active) ? {
                showingCreateSheet = true
            } : nil
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateMessage: String {
        switch selectedStatus {
        case .planned:
            return "Create a new training program to get started"
        case .active:
            return "No active training program. Activate a planned program or create a new one."
        case .completed:
            return "No completed programs yet. Complete your first mesocycle to see it here."
        }
    }
}

struct NutritionTabView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var selectedView: NutritionView = .logging
    @State private var dailyNutrition: DailyNutrition?
    @State private var nutritionLoadError: String?

    enum NutritionView {
        case logging
        case summary
    }

    var body: some View {
        if let container = container {
            NavigationStack {
                VStack(spacing: 0) {
                    // View Selector
                    Picker("View", selection: $selectedView) {
                        Text("Food Log").tag(NutritionView.logging)
                        Text("Summary").tag(NutritionView.summary)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    // Content
                    if selectedView == .logging {
                        FoodLoggingView(
                            logFoodUseCase: LogFoodUseCase(repository: container.nutritionRepository),
                            repository: container.nutritionRepository
                        )
                    } else {
                        ScrollView {
                            VStack(spacing: Spacing.lg) {
                                if let error = nutritionLoadError {
                                    VStack(spacing: Spacing.sm) {
                                        Image(systemName: "exclamationmark.triangle")
                                            .font(.vitalDisplayLarge)
                                            .foregroundStyle(Color.vitalWarning)
                                        Text(error)
                                            .font(.vitalBody)
                                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                    }
                                    .padding()
                                }
                                NutritionSummaryView(
                                    dailyNutrition: dailyNutrition,
                                    nutritionRepository: container.nutritionRepository
                                )
                            }
                            .padding()
                        }
                        .background(Color.vitalAdaptiveBackground)
                        .task {
                            await loadDailyNutrition()
                        }
                    }
                }
                .navigationTitle("Nutrition")
            }
        } else {
            ProgressView()
        }
    }

    @MainActor
    private func loadDailyNutrition() async {
        guard let container = container else { return }

        let calculateUseCase = CalculateNutritionUseCase(repository: container.nutritionRepository)
        do {
            dailyNutrition = try await calculateUseCase.execute(for: Date())
            nutritionLoadError = nil
        } catch {
            Log.error("Failed to load daily nutrition", error: error, category: .nutrition)
            nutritionLoadError = "Unable to load nutrition data"
        }
    }
}

// ProfileView is now implemented in Profile/ProfileView.swift

// MARK: - Analytics Tab View

// MARK: - Analytics Tab View (Deprecated - analytics now in-context)
// This view is no longer used but kept for reference
// Analytics are now integrated directly into Health, Workout, and Nutrition tabs

struct AnalyticsTabView: View {
    let container: DependencyContainer
    @State private var viewModel: AnalyticsDashboardViewModel?

    var body: some View {
        Group {
            if let viewModel = viewModel {
                AnalyticsDashboardView(viewModel: viewModel)
            } else {
                ProgressView("Loading Analytics...")
            }
        }
        .task {
            let calculateVolumeUseCase = CalculateVolumeUseCase(
                workoutRepository: container.workoutRepository
            )

            viewModel = AnalyticsDashboardViewModel(
                calculateVolumeUseCase: calculateVolumeUseCase,
                trackProgressiveOverloadUseCase: TrackProgressiveOverloadUseCase(
                    workoutRepository: container.workoutRepository
                ),
                generateProgressReportUseCase: GenerateProgressReportUseCase(
                    workoutRepository: container.workoutRepository,
                    healthRepository: container.healthRepository,
                    nutritionRepository: container.nutritionRepository,
                    analyticsRepository: container.analyticsRepository,
                    calculateVolumeUseCase: calculateVolumeUseCase
                ),
                calculateRecoveryScoreUseCase: CalculateRecoveryScoreUseCase(
                    healthRepository: container.healthRepository
                ),
                calculateStrainScoreUseCase: CalculateStrainScoreUseCase(
                    healthRepository: container.healthRepository,
                    userRepository: container.userRepository
                ),
                analyticsRepository: container.analyticsRepository,
                healthRepository: container.healthRepository,
                nutritionRepository: container.nutritionRepository
            )
        }
    }
}

#Preview {
    MainTabView()
}
