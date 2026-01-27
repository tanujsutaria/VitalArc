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
@MainActor
final class DependencyContainer {
    let modelContext: ModelContext

    // Repositories (initialized immediately)
    let workoutRepository: WorkoutRepository
    let nutritionRepository: NutritionRepository
    let healthRepository: HealthRepository
    let userRepository: UserRepository
    let mesocycleRepository: MesocycleRepository
    let analyticsRepository: AnalyticsRepository
    let templateRepository: TemplateRepository

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Initialize all repositories
        self.workoutRepository = SwiftDataWorkoutRepository(modelContext: modelContext)
        self.nutritionRepository = SwiftDataNutritionRepository(modelContext: modelContext)
        self.healthRepository = SwiftDataHealthRepository(modelContext: modelContext)
        self.userRepository = SwiftDataUserRepository(modelContext: modelContext)
        self.mesocycleRepository = SwiftDataMesocycleRepository(modelContext: modelContext)
        self.analyticsRepository = SwiftDataAnalyticsRepository(modelContext: modelContext)
        self.templateRepository = SwiftDataTemplateRepository(modelContext: modelContext)
    }
}

// MARK: - Repository Implementations (Placeholders for now)

/// SwiftData implementation of WorkoutRepository
@MainActor
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
@MainActor
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
        let foodId = food.id
        let descriptor = FetchDescriptor<FoodModel>(
            predicate: #Predicate { foodModel in
                foodModel.id == foodId
            }
        )

        if let existing = try modelContext.fetch(descriptor).first {
            // Update existing - all fields
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
            existing.barcode = food.barcode
            existing.imageURL = food.imageURL
            existing.isFavorite = food.isFavorite
            existing.isCustom = food.isCustom
            existing.recentlyUsed = food.recentlyUsed
            existing.usageCount = food.usageCount
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
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay.addingTimeInterval(86400)

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
        let entryId = entry.id
        let descriptor = FetchDescriptor<FoodEntryModel>(
            predicate: #Predicate { entryModel in
                entryModel.id == entryId
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
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay.addingTimeInterval(86400)

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
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay.addingTimeInterval(86400)

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
@MainActor
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
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay.addingTimeInterval(86400)

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
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay.addingTimeInterval(86400)

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
            struct HealthKitNotAvailableError: Error {}
            throw HealthKitNotAvailableError()
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

/// SwiftData implementation of MesocycleRepository
@MainActor
final class SwiftDataMesocycleRepository: MesocycleRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getMesocycles() async throws -> [Mesocycle] {
        let descriptor = FetchDescriptor<MesocycleModel>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func getMesocycle(id: UUID) async throws -> Mesocycle? {
        var descriptor = FetchDescriptor<MesocycleModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        let models = try modelContext.fetch(descriptor)
        return models.first?.toDomain()
    }

    func getActiveMesocycle() async throws -> Mesocycle? {
        let activeStatus = MesocycleStatus.active.rawValue
        let descriptor = FetchDescriptor<MesocycleModel>(
            predicate: #Predicate { $0.status == activeStatus }
        )
        let models = try modelContext.fetch(descriptor)
        return models.first?.toDomain()
    }

    func saveMesocycle(_ mesocycle: Mesocycle) async throws {
        let model = MesocycleModel.fromDomain(mesocycle)
        modelContext.insert(model)
        try modelContext.save()
    }

    func updateMesocycle(_ mesocycle: Mesocycle) async throws {
        let mesocycleId = mesocycle.id
        let descriptor = FetchDescriptor<MesocycleModel>(
            predicate: #Predicate { $0.id == mesocycleId }
        )

        guard let existingModel = try modelContext.fetch(descriptor).first else {
            try await saveMesocycle(mesocycle)
            return
        }

        // Update all fields
        existingModel.name = mesocycle.name
        existingModel.startDate = mesocycle.startDate
        existingModel.endDate = mesocycle.endDate
        existingModel.goal = mesocycle.goal.rawValue
        existingModel.status = mesocycle.status.rawValue
        existingModel.updatedAt = mesocycle.updatedAt

        // Re-encode phases and blocks
        let encoder = JSONEncoder()
        existingModel.phasesData = try? encoder.encode(mesocycle.phases)
        existingModel.trainingBlocksData = try? encoder.encode(mesocycle.trainingBlocks)

        try modelContext.save()
    }

    func deleteMesocycle(id: UUID) async throws {
        var descriptor = FetchDescriptor<MesocycleModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        let models = try modelContext.fetch(descriptor)

        if let model = models.first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }

    func activateMesocycle(id: UUID) async throws {
        // First, deactivate any currently active mesocycles
        let activeStatus = MesocycleStatus.active.rawValue
        let activeDescriptor = FetchDescriptor<MesocycleModel>(
            predicate: #Predicate { $0.status == activeStatus }
        )
        let activeModels = try modelContext.fetch(activeDescriptor)

        for activeModel in activeModels {
            activeModel.status = MesocycleStatus.planned.rawValue
            activeModel.updatedAt = Date()
        }

        // Activate the specified mesocycle
        var descriptor = FetchDescriptor<MesocycleModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        let models = try modelContext.fetch(descriptor)

        guard let model = models.first else {
            throw MesocycleError.mesocycleNotFound
        }

        model.status = MesocycleStatus.active.rawValue
        model.updatedAt = Date()

        try modelContext.save()
    }

    func completeMesocycle(id: UUID) async throws {
        var descriptor = FetchDescriptor<MesocycleModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        let models = try modelContext.fetch(descriptor)

        guard let model = models.first else {
            throw MesocycleError.mesocycleNotFound
        }

        model.status = MesocycleStatus.completed.rawValue
        model.updatedAt = Date()

        try modelContext.save()
    }

    func getMesocyclesByStatus(_ status: MesocycleStatus) async throws -> [Mesocycle] {
        let statusValue = status.rawValue
        let descriptor = FetchDescriptor<MesocycleModel>(
            predicate: #Predicate { $0.status == statusValue },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func getMesocycleForDate(_ date: Date) async throws -> Mesocycle? {
        let descriptor = FetchDescriptor<MesocycleModel>(
            predicate: #Predicate { model in
                model.startDate <= date && model.endDate >= date
            }
        )
        let models = try modelContext.fetch(descriptor)
        return models.first?.toDomain()
    }
}

/// SwiftData implementation of UserRepository
@MainActor
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
        let profileId = profile.id
        let descriptor = FetchDescriptor<UserProfileModel>(
            predicate: #Predicate { $0.id == profileId }
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

/// SwiftData implementation of AnalyticsRepository
@MainActor
final class SwiftDataAnalyticsRepository: AnalyticsRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Progress Snapshots

    func getProgressSnapshots(from startDate: Date, to endDate: Date) async throws -> [ProgressSnapshot] {
        let descriptor = FetchDescriptor<ProgressSnapshotModel>(
            predicate: #Predicate { snapshot in
                snapshot.date >= startDate && snapshot.date <= endDate
            },
            sortBy: [SortDescriptor(\.date)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func getProgressSnapshot(id: UUID) async throws -> ProgressSnapshot? {
        let descriptor = FetchDescriptor<ProgressSnapshotModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    func getLatestProgressSnapshot() async throws -> ProgressSnapshot? {
        let descriptor = FetchDescriptor<ProgressSnapshotModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    func saveProgressSnapshot(_ snapshot: ProgressSnapshot) async throws {
        let model = ProgressSnapshotModel.fromDomain(snapshot)
        modelContext.insert(model)
        try modelContext.save()
    }

    func deleteProgressSnapshot(id: UUID) async throws {
        let descriptor = FetchDescriptor<ProgressSnapshotModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }

    // MARK: - Volume Metrics

    func getVolumeMetrics(from startDate: Date, to endDate: Date) async throws -> [VolumeMetrics] {
        let descriptor = FetchDescriptor<VolumeMetricsModel>(
            predicate: #Predicate { metrics in
                metrics.weekStartDate >= startDate && metrics.weekEndDate <= endDate
            },
            sortBy: [SortDescriptor(\.weekStartDate)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func getVolumeMetrics(for weekStartDate: Date) async throws -> VolumeMetrics? {
        let calendar = Calendar.current
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStartDate) ?? weekStartDate

        let descriptor = FetchDescriptor<VolumeMetricsModel>(
            predicate: #Predicate { metrics in
                metrics.weekStartDate >= weekStartDate && metrics.weekStartDate < weekEnd
            }
        )
        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    func saveVolumeMetrics(_ metrics: VolumeMetrics) async throws {
        let model = VolumeMetricsModel.fromDomain(metrics)
        modelContext.insert(model)
        try modelContext.save()
    }

    // MARK: - Personal Records

    func getPersonalRecords() async throws -> [PersonalRecord] {
        let descriptor = FetchDescriptor<PersonalRecordModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func getPersonalRecords(for exerciseId: UUID) async throws -> [PersonalRecord] {
        let descriptor = FetchDescriptor<PersonalRecordModel>(
            predicate: #Predicate { $0.exerciseId == exerciseId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func getPersonalRecord(id: UUID) async throws -> PersonalRecord? {
        let descriptor = FetchDescriptor<PersonalRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    func savePersonalRecord(_ record: PersonalRecord) async throws {
        let model = PersonalRecordModel.fromDomain(record)
        modelContext.insert(model)
        try modelContext.save()
    }

    func deletePersonalRecord(id: UUID) async throws {
        let descriptor = FetchDescriptor<PersonalRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }
}

/// SwiftData implementation of TemplateRepository
@MainActor
final class SwiftDataTemplateRepository: TemplateRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getTemplates() async throws -> [WorkoutTemplate] {
        let descriptor = FetchDescriptor<WorkoutTemplateModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func getTemplate(id: UUID) async throws -> WorkoutTemplate? {
        let descriptor = FetchDescriptor<WorkoutTemplateModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    func getTemplates(category: TemplateCategory) async throws -> [WorkoutTemplate] {
        let categoryString = category.rawValue
        let descriptor = FetchDescriptor<WorkoutTemplateModel>(
            predicate: #Predicate { $0.category == categoryString },
            sortBy: [SortDescriptor(\.name)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func saveTemplate(_ template: WorkoutTemplate) async throws {
        let model = WorkoutTemplateModel.fromDomain(template)
        modelContext.insert(model)
        try modelContext.save()
    }

    func updateTemplate(_ template: WorkoutTemplate) async throws {
        let templateId = template.id
        let descriptor = FetchDescriptor<WorkoutTemplateModel>(
            predicate: #Predicate { $0.id == templateId }
        )

        if let existing = try modelContext.fetch(descriptor).first {
            existing.name = template.name
            existing.templateDescription = template.description
            existing.exercisesData = WorkoutTemplateModel.encodeExercises(template.exercises)
            existing.category = template.category.rawValue
            existing.estimatedDuration = template.estimatedDuration
            existing.lastUsed = template.lastUsed
            existing.useCount = template.useCount

            try modelContext.save()
        } else {
            try await saveTemplate(template)
        }
    }

    func deleteTemplate(id: UUID) async throws {
        let descriptor = FetchDescriptor<WorkoutTemplateModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }

    func incrementTemplateUsage(id: UUID) async throws {
        let descriptor = FetchDescriptor<WorkoutTemplateModel>(
            predicate: #Predicate { $0.id == id }
        )

        if let model = try modelContext.fetch(descriptor).first {
            model.useCount += 1
            model.lastUsed = Date()
            try modelContext.save()
        }
    }
}

