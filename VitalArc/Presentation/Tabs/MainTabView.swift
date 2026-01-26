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

            // Training Tab
            if let mesocycleRepository = container?.mesocycleRepository,
               let workoutRepository = container?.workoutRepository {
                MesocycleListView(
                    mesocycleRepository: mesocycleRepository,
                    workoutRepository: workoutRepository
                )
                .tabItem {
                    Label("Training", systemImage: "calendar")
                }
                .tag(2)
            }

            // Nutrition Tab
            NutritionTabView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }
                .tag(3)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(.accentColor)
    }
}

struct WorkoutTabView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var showingWorkoutLogger = false
    @State private var selectedView: WorkoutView = .history

    enum WorkoutView {
        case history
        case exercises
    }

    var body: some View {
        if let container = container {
            NavigationStack {
                VStack(spacing: 0) {
                    // View Selector
                    Picker("View", selection: $selectedView) {
                        Text("History").tag(WorkoutView.history)
                        Text("Exercises").tag(WorkoutView.exercises)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    // Content
                    if selectedView == .history {
                        WorkoutHistoryView(repository: container.workoutRepository)
                    } else {
                        ExerciseLibraryView(
                            getExercisesUseCase: GetExercisesUseCase(
                                repository: container.workoutRepository
                            )
                        ) { exercise in
                            // Exercise selected from library
                        }
                    }
                }
                .navigationTitle("Workout")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingWorkoutLogger = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
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
                    // Seed exercises on first launch
                    try? await ExerciseSeeds.seedIfNeeded(repository: container.workoutRepository)
                }
            }
        } else {
            ProgressView()
        }
    }
}

struct NutritionTabView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var selectedView: NutritionView = .logging
    @State private var dailyNutrition: DailyNutrition?

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
                            VStack(spacing: 16) {
                                NutritionSummaryView(dailyNutrition: dailyNutrition)
                            }
                            .padding()
                        }
                        .background(Color(.systemGroupedBackground))
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
        dailyNutrition = try? await calculateUseCase.execute(for: Date())
    }
}

// ProfileView is now implemented in Profile/ProfileView.swift

#Preview {
    MainTabView()
}
