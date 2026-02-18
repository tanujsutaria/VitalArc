//
//  VitalArcApp.swift
//  VitalArc
//
//  Created by Claude on 2026-01-25.
//

import SwiftUI
import SwiftData

@main
struct VitalArcApp: App {
    // SwiftData container for persistence
    let modelContainer: ModelContainer

    // Dependency injection container
    let container: DependencyContainer

    init() {
        // Initialize SwiftData model container with all models
        let schema = Schema([
            // Workout Domain Models
            WorkoutModel.self,
            ExerciseModel.self,
            WorkoutSetModel.self,

            // Training Domain Models
            MesocycleModel.self,

            // Nutrition Domain Models
            FoodModel.self,
            FoodEntryModel.self,
            DailyNutritionModel.self,
            WaterEntryModel.self,

            // Health Domain Models
            HealthMetricsModel.self,

            // User Domain Models
            UserProfileModel.self,

            // Custom Category Model
            CustomCategoryModel.self,

            // Analytics Domain Models
            ProgressSnapshotModel.self,
            VolumeMetricsModel.self,
            PersonalRecordModel.self,
            WorkoutTemplateModel.self,

            // Notification Domain Models
            NotificationPreferencesModel.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none // Disable CloudKit during development to avoid migration issues
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            // During development, if migration fails, try deleting the store and recreating
            Log.error("SwiftData migration failed, attempting to recreate database", error: error, category: .data)

            // Delete existing store
            let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: storeURL)

            // Also try removing with different extensions SwiftData might use
            let walURL = storeURL.deletingPathExtension().appendingPathExtension("store-wal")
            let shmURL = storeURL.deletingPathExtension().appendingPathExtension("store-shm")
            try? FileManager.default.removeItem(at: walURL)
            try? FileManager.default.removeItem(at: shmURL)

            do {
                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
                Log.info("Database recreated successfully", category: .data)
            } catch {
                fatalError("Could not initialize ModelContainer even after reset: \(error)")
            }
        }

        // Initialize dependency injection container
        // Note: DependencyContainer is @MainActor, but init is called from main thread
        let modelContext = modelContainer.mainContext
        container = MainActor.assumeIsolated {
            DependencyContainer(modelContext: modelContext)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
                .environment(\.dependencyContainer, container)
        }
    }
}

/// Root view that decides whether to show onboarding or main app
struct RootView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var hasCompletedOnboarding = false
    @State private var isCheckingOnboarding = true

    var body: some View {
        Group {
            if isCheckingOnboarding {
                ProgressView("Loading...")
            } else if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingCoordinator(isOnboardingComplete: $hasCompletedOnboarding)
            }
        }
        .task {
            await initializeApp()
        }
    }

    private func initializeApp() async {
        guard let container = container else {
            isCheckingOnboarding = false
            return
        }

        // Seed exercise database if needed
        do {
            try await ExerciseSeeds.seedIfNeeded(repository: container.workoutRepository)
        } catch {
            Log.error("Failed to seed exercises", error: error, category: .data)
        }

        // Check onboarding status
        hasCompletedOnboarding = await container.userRepository.hasCompletedOnboarding()
        isCheckingOnboarding = false
    }
}

// Environment key for dependency injection
private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: DependencyContainer? = nil
}

extension EnvironmentValues {
    var dependencyContainer: DependencyContainer? {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

// Environment key for tab selection (shared between MainTabView and child views)
private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var selectedTab: Binding<Int> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}
