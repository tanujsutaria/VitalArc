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
        do {
            let schema = Schema([
                // Workout Domain Models
                WorkoutModel.self,
                ExerciseModel.self,
                WorkoutSetModel.self,

                // Nutrition Domain Models
                FoodModel.self,
                FoodEntryModel.self,
                DailyNutritionModel.self,

                // Health Domain Models
                HealthMetricsModel.self,

                // User Domain Models
                UserProfileModel.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic // Enable iCloud sync
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
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
            print("Failed to seed exercises: \(error)")
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
