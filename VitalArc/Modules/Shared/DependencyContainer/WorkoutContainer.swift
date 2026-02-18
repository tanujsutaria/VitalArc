//
//  WorkoutContainer.swift
//  VitalArc
//
//  Dependency container for the Workout domain
//

import Foundation
import SwiftData

/// Container for all workout-related dependencies
@MainActor
final class WorkoutContainer {
    let workoutRepository: SwiftDataWorkoutRepository
    let mesocycleRepository: SwiftDataMesocycleRepository
    let templateRepository: SwiftDataTemplateRepository
    let importHealthKitWorkoutsUseCase: ImportHealthKitWorkoutsUseCase

    init(modelContext: ModelContext, healthKitManager: HealthKitManager) {
        self.workoutRepository = SwiftDataWorkoutRepository(modelContext: modelContext)
        self.mesocycleRepository = SwiftDataMesocycleRepository(modelContext: modelContext)
        self.templateRepository = SwiftDataTemplateRepository(modelContext: modelContext)
        let importSource = HealthKitWorkoutImportSource(healthKitManager: healthKitManager)
        self.importHealthKitWorkoutsUseCase = ImportHealthKitWorkoutsUseCase(
            repository: workoutRepository,
            importSource: importSource
        )
    }
}

// MARK: - WorkoutDataProviding Conformance

extension SwiftDataWorkoutRepository: WorkoutDataProviding {
    func getTodayWorkouts() async throws -> [Workout] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay.addingTimeInterval(86400)
        return try await getWorkouts(from: startOfDay, to: endOfDay)
    }
}
