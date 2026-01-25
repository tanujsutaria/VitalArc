//
//  DependencyContainer.swift
//  VitalArc
//
//  Dependency Injection Container
//

import Foundation
import SwiftData
import HealthKit

/// Centralized dependency injection container
final class DependencyContainer {
    let modelContext: ModelContext

    // Repositories (initialized immediately)
    let workoutRepository: WorkoutRepository
    let nutritionRepository: NutritionRepository
    let healthRepository: HealthRepository
    let userRepository: UserRepository

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Initialize all repositories
        self.workoutRepository = SwiftDataWorkoutRepository(modelContext: modelContext)
        self.nutritionRepository = SwiftDataNutritionRepository(modelContext: modelContext)
        self.healthRepository = SwiftDataHealthRepository(modelContext: modelContext)
        self.userRepository = SwiftDataUserRepository(modelContext: modelContext)
    }
}

// MARK: - Repository Implementations (Placeholders for now)

/// SwiftData implementation of WorkoutRepository
final class SwiftDataWorkoutRepository: WorkoutRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getExercises() async throws -> [Exercise] {
        let descriptor = FetchDescriptor<ExerciseModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func getExercise(id: UUID) async throws -> Exercise? {
        var descriptor = FetchDescriptor<ExerciseModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        let models = try modelContext.fetch(descriptor)
        return models.first?.toDomain()
    }

    func searchExercises(query: String) async throws -> [Exercise] {
        let lowercaseQuery = query.lowercased()
        let descriptor = FetchDescriptor<ExerciseModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        let allModels = try modelContext.fetch(descriptor)
        let filtered = allModels.filter { $0.name.lowercased().contains(lowercaseQuery) }
        return filtered.map { $0.toDomain() }
    }

    func saveExercise(_ exercise: Exercise) async throws {
        let model = ExerciseModel.fromDomain(exercise)
        modelContext.insert(model)
        try modelContext.save()
    }

    func getWorkouts() async throws -> [Workout] {
        let descriptor = FetchDescriptor<WorkoutModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func getWorkout(id: UUID) async throws -> Workout? {
        var descriptor = FetchDescriptor<WorkoutModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        let models = try modelContext.fetch(descriptor)
        return models.first?.toDomain()
    }

    func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout] {
        let descriptor = FetchDescriptor<WorkoutModel>(
            predicate: #Predicate { workout in
                workout.date >= startDate && workout.date <= endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func saveWorkout(_ workout: Workout) async throws {
        // Create set models
        let setModels = workout.sets.map { WorkoutSetModel.fromDomain($0) }

        // Insert sets first
        for setModel in setModels {
            modelContext.insert(setModel)
        }

        // Create workout model with sets
        let workoutModel = WorkoutModel.fromDomain(workout, sets: setModels)
        modelContext.insert(workoutModel)

        try modelContext.save()
    }

    func deleteWorkout(id: UUID) async throws {
        var descriptor = FetchDescriptor<WorkoutModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        let models = try modelContext.fetch(descriptor)

        if let model = models.first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }

    func getLastWorkoutForExercise(_ exerciseId: UUID) async throws -> Workout? {
        // Get all workouts sorted by date descending
        let descriptor = FetchDescriptor<WorkoutModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)

        // Find first workout that contains this exercise
        for model in models {
            let workout = model.toDomain()
            if workout.sets.contains(where: { $0.exerciseId == exerciseId }) {
                return workout
            }
        }

        return nil
    }
}

/// SwiftData implementation of NutritionRepository
final class SwiftDataNutritionRepository: NutritionRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func searchFoods(query: String) async throws -> [Food] {
        let descriptor = FetchDescriptor<FoodModel>(
            predicate: #Predicate { food in
                food.name.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.name)]
        )

        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func getFood(id: UUID) async throws -> Food? {
        let descriptor = FetchDescriptor<FoodModel>(
            predicate: #Predicate { food in
                food.id == id
            }
        )

        guard let model = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return model.toDomain()
    }

    func saveFood(_ food: Food) async throws {
        // Check if food already exists
        let descriptor = FetchDescriptor<FoodModel>(
            predicate: #Predicate { foodModel in
                foodModel.id == food.id
            }
        )

        if let existing = try modelContext.fetch(descriptor).first {
            // Update existing
            existing.name = food.name
            existing.brand = food.brand
            existing.servingSize = food.servingSize
            existing.servingUnit = food.servingUnit
            existing.calories = food.calories
            existing.protein = food.protein
            existing.carbs = food.carbs
            existing.fat = food.fat
            existing.fiber = food.fiber
            existing.sugar = food.sugar
            existing.source = food.source.rawValue
        } else {
            // Insert new
            let model = FoodModel.fromDomain(food)
            modelContext.insert(model)
        }

        try modelContext.save()
    }

    func getFoodEntries(for date: Date) async throws -> [FoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<FoodEntryModel>(
            predicate: #Predicate { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            },
            sortBy: [SortDescriptor(\.date)]
        )

        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func getFoodEntries(from startDate: Date, to endDate: Date) async throws -> [FoodEntry] {
        let descriptor = FetchDescriptor<FoodEntryModel>(
            predicate: #Predicate { entry in
                entry.date >= startDate && entry.date <= endDate
            },
            sortBy: [SortDescriptor(\.date)]
        )

        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func saveFoodEntry(_ entry: FoodEntry) async throws {
        // Check if entry already exists
        let descriptor = FetchDescriptor<FoodEntryModel>(
            predicate: #Predicate { entryModel in
                entryModel.id == entry.id
            }
        )

        if let existing = try modelContext.fetch(descriptor).first {
            // Update existing
            existing.foodId = entry.foodId
            existing.date = entry.date
            existing.meal = entry.meal.rawValue
            existing.quantity = entry.quantity
            existing.calories = entry.calories
            existing.protein = entry.protein
            existing.carbs = entry.carbs
            existing.fat = entry.fat
        } else {
            // Insert new
            let model = FoodEntryModel.fromDomain(entry)
            modelContext.insert(model)
        }

        try modelContext.save()
    }

    func deleteFoodEntry(id: UUID) async throws {
        let descriptor = FetchDescriptor<FoodEntryModel>(
            predicate: #Predicate { entry in
                entry.id == id
            }
        )

        guard let model = try modelContext.fetch(descriptor).first else {
            return
        }

        modelContext.delete(model)
        try modelContext.save()
    }

    func getDailyNutrition(for date: Date) async throws -> DailyNutrition? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<DailyNutritionModel>(
            predicate: #Predicate { nutrition in
                nutrition.date >= startOfDay && nutrition.date < endOfDay
            }
        )

        guard let model = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return model.toDomain()
    }

    func saveDailyNutrition(_ nutrition: DailyNutrition) async throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: nutrition.date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<DailyNutritionModel>(
            predicate: #Predicate { nutritionModel in
                nutritionModel.date >= startOfDay && nutritionModel.date < endOfDay
            }
        )

        if let existing = try modelContext.fetch(descriptor).first {
            // Update existing
            existing.caloriesConsumed = nutrition.caloriesConsumed
            existing.proteinConsumed = nutrition.proteinConsumed
            existing.carbsConsumed = nutrition.carbsConsumed
            existing.fatConsumed = nutrition.fatConsumed
            existing.calorieGoal = nutrition.calorieGoal
            existing.proteinGoal = nutrition.proteinGoal
            existing.carbsGoal = nutrition.carbsGoal
            existing.fatGoal = nutrition.fatGoal
        } else {
            // Insert new
            let model = DailyNutritionModel.fromDomain(nutrition)
            modelContext.insert(model)
        }

        try modelContext.save()
    }
}

/// SwiftData implementation of HealthRepository
final class SwiftDataHealthRepository: HealthRepository {
    private let modelContext: ModelContext
    private let healthKitManager: HealthKitManager

    init(modelContext: ModelContext, healthKitManager: HealthKitManager = HealthKitManager()) {
        self.modelContext = modelContext
        self.healthKitManager = healthKitManager
    }

    func getHealthMetrics(for date: Date) async throws -> HealthMetrics? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<HealthMetricsModel>(
            predicate: #Predicate { metrics in
                metrics.date >= startOfDay && metrics.date < endOfDay
            }
        )

        let models = try modelContext.fetch(descriptor)
        return models.first?.toDomain()
    }

    func getHealthMetrics(from startDate: Date, to endDate: Date) async throws -> [HealthMetrics] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        let descriptor = FetchDescriptor<HealthMetricsModel>(
            predicate: #Predicate { metrics in
                metrics.date >= start && metrics.date <= end
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func saveHealthMetrics(_ metrics: HealthMetrics) async throws {
        // Check if metrics for this date already exist
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: metrics.date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<HealthMetricsModel>(
            predicate: #Predicate { model in
                model.date >= startOfDay && model.date < endOfDay
            }
        )

        let existingModels = try modelContext.fetch(descriptor)

        if let existingModel = existingModels.first {
            // Update existing model
            existingModel.heartRateVariability = metrics.heartRateVariability
            existingModel.restingHeartRate = metrics.restingHeartRate
            existingModel.activeEnergy = metrics.activeEnergy
            existingModel.steps = metrics.steps
            existingModel.sleepHours = metrics.sleepHours
            existingModel.weight = metrics.weight
        } else {
            // Create new model
            let model = HealthMetricsModel.fromDomain(metrics)
            modelContext.insert(model)
        }

        try modelContext.save()
    }

    func syncFromHealthKit() async throws {
        guard healthKitManager.isHealthKitAvailable() else {
            throw HealthKitError.notAvailable
        }

        // Sync last 7 days of data
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekAgo = calendar.date(byAdding: .day, value: -6, to: today) else {
            return
        }

        // Fetch metrics from HealthKit
        let metrics = try await healthKitManager.fetchHealthMetrics(from: weekAgo, to: today)

        // Save to SwiftData
        for metric in metrics {
            try await saveHealthMetrics(metric)
        }
    }

    func requestHealthKitAuthorization() async throws -> Bool {
        return try await healthKitManager.requestAuthorization()
    }
}

/// SwiftData implementation of UserRepository
final class SwiftDataUserRepository: UserRepository {
    private let modelContext: ModelContext

    // UserDefaults key for onboarding status
    private let onboardingKey = "hasCompletedOnboarding"

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getUserProfile() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfileModel>()
        let profiles = try modelContext.fetch(descriptor)

        // Return the first profile (singleton pattern - only one profile per app)
        return profiles.first?.toDomain()
    }

    func saveUserProfile(_ profile: UserProfile) async throws {
        // Check if a profile already exists (singleton)
        let descriptor = FetchDescriptor<UserProfileModel>()
        let existingProfiles = try modelContext.fetch(descriptor)

        // Delete existing profiles to maintain singleton
        for existingProfile in existingProfiles {
            modelContext.delete(existingProfile)
        }

        // Create and insert new profile
        let profileModel = UserProfileModel.fromDomain(profile)
        modelContext.insert(profileModel)

        try modelContext.save()
    }

    func updateUserProfile(_ profile: UserProfile) async throws {
        let descriptor = FetchDescriptor<UserProfileModel>(
            predicate: #Predicate { $0.id == profile.id }
        )

        guard let existingProfile = try modelContext.fetch(descriptor).first else {
            // If profile doesn't exist, create it
            try await saveUserProfile(profile)
            return
        }

        // Update existing profile
        existingProfile.name = profile.name
        existingProfile.birthDate = profile.birthDate
        existingProfile.biologicalSex = profile.biologicalSex.rawValue
        existingProfile.height = profile.height
        existingProfile.weight = profile.weight
        existingProfile.activityLevel = profile.activityLevel.rawValue
        existingProfile.weightGoal = profile.weightGoal.rawValue
        existingProfile.updatedAt = Date()

        try modelContext.save()
    }

    func deleteUserProfile() async throws {
        let descriptor = FetchDescriptor<UserProfileModel>()
        let profiles = try modelContext.fetch(descriptor)

        for profile in profiles {
            modelContext.delete(profile)
        }

        try modelContext.save()
    }

    func hasCompletedOnboarding() async -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingKey)
    }

    func setOnboardingCompleted(_ completed: Bool) async {
        UserDefaults.standard.set(completed, forKey: onboardingKey)
    }
}
