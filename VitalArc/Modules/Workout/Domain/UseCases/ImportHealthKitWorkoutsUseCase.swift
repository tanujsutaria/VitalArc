//
//  ImportHealthKitWorkoutsUseCase.swift
//  VitalArc
//
//  Use Case: Import workouts from HealthKit into the workout repository
//

import Foundation
import HealthKit

@MainActor
final class ImportHealthKitWorkoutsUseCase {
    private let repository: WorkoutRepository
    private let healthKitManager: HealthKitManager

    init(repository: WorkoutRepository, healthKitManager: HealthKitManager) {
        self.repository = repository
        self.healthKitManager = healthKitManager
    }

    /// Import workouts from HealthKit for a date range.
    /// Returns the number of newly imported workouts (skips duplicates).
    func execute(from startDate: Date, to endDate: Date) async throws -> Int {
        let hkWorkouts = try await healthKitManager.fetchWorkouts(from: startDate, to: endDate)

        var importedCount = 0

        for hkWorkout in hkWorkouts {
            let healthKitId = hkWorkout.uuid.uuidString

            // Skip if already imported (deduplication)
            if let _ = try await repository.getWorkoutByHealthKitId(healthKitId) {
                continue
            }

            let workout = Workout(
                date: hkWorkout.startDate,
                name: hkWorkout.workoutActivityType.name,
                sets: [],
                notes: nil,
                duration: hkWorkout.duration,
                source: .healthKit,
                healthKitId: healthKitId
            )

            try await repository.saveWorkout(workout)
            importedCount += 1
        }

        return importedCount
    }
}
