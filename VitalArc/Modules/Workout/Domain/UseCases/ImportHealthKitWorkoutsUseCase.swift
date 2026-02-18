//
//  ImportHealthKitWorkoutsUseCase.swift
//  VitalArc
//
//  Use Case: Import workouts from an external source into the workout repository
//

import Foundation

@MainActor
final class ImportHealthKitWorkoutsUseCase {
    private let repository: WorkoutRepository
    private let importSource: WorkoutImportSource
    private var isImporting = false

    init(repository: WorkoutRepository, importSource: WorkoutImportSource) {
        self.repository = repository
        self.importSource = importSource
    }

    /// Import workouts from the configured source for a date range.
    /// Returns the number of newly imported workouts (skips duplicates).
    /// Serialized: concurrent calls return 0 immediately to prevent duplicates.
    func execute(from startDate: Date, to endDate: Date) async throws -> Int {
        guard !isImporting else { return 0 }
        isImporting = true
        defer { isImporting = false }

        let importedWorkouts = try await importSource.fetchWorkouts(from: startDate, to: endDate)

        var importedCount = 0

        for workoutData in importedWorkouts {
            // Skip if already imported (deduplication)
            if let _ = try await repository.getWorkoutByHealthKitId(workoutData.healthKitId) {
                continue
            }

            let workout = Workout(
                date: workoutData.startDate,
                name: workoutData.activityName,
                sets: [],
                notes: nil,
                duration: workoutData.duration,
                source: .healthKit,
                healthKitId: workoutData.healthKitId
            )

            try await repository.saveWorkout(workout)
            importedCount += 1
        }

        return importedCount
    }
}
