//
//  DetectPersonalRecordUseCase.swift
//  VitalArc
//
//  Use Case: Detect personal records from a completed workout
//

import Foundation

final class DetectPersonalRecordUseCase {
    private let workoutRepository: WorkoutRepository
    private let analyticsRepository: AnalyticsRepository

    init(workoutRepository: WorkoutRepository, analyticsRepository: AnalyticsRepository) {
        self.workoutRepository = workoutRepository
        self.analyticsRepository = analyticsRepository
    }

    /// Detect and save any new personal records from the given workout sets.
    /// Returns the list of new PRs detected.
    func execute(sets: [WorkoutSet]) async throws -> [PersonalRecord] {
        var newRecords: [PersonalRecord] = []

        // Group sets by exercise
        let setsByExercise = Dictionary(grouping: sets) { $0.exerciseId }

        for (exerciseId, exerciseSets) in setsByExercise {
            let completedSets = exerciseSets.filter { $0.completed && $0.weight > 0 && $0.reps > 0 }
            guard !completedSets.isEmpty else { continue }

            // Get exercise name
            let exercise = try await workoutRepository.getExercise(id: exerciseId)
            let exerciseName = exercise?.name ?? "Unknown Exercise"

            // Get existing PRs for this exercise
            let existingPRs = try await analyticsRepository.getPersonalRecords(for: exerciseId)

            // Check max weight (heaviest single set)
            if let heaviestSet = completedSets.max(by: { $0.weight < $1.weight }) {
                let existingMaxWeight = existingPRs
                    .filter { $0.recordType == .oneRepMax }
                    .map { $0.value }
                    .max() ?? 0

                // Estimated 1RM using Epley formula: weight * (1 + reps/30)
                let estimated1RM = heaviestSet.weight * (1.0 + Double(heaviestSet.reps) / 30.0)

                if estimated1RM > existingMaxWeight {
                    let record = PersonalRecord(
                        exerciseId: exerciseId,
                        exerciseName: exerciseName,
                        recordType: .oneRepMax,
                        value: estimated1RM,
                        reps: heaviestSet.reps,
                        date: Date()
                    )
                    try await analyticsRepository.savePersonalRecord(record)
                    newRecords.append(record)
                }
            }

            // Check max volume (total weight * reps for this exercise)
            let totalVolume = completedSets.reduce(0.0) { $0 + $1.volume }
            let existingMaxVolume = existingPRs
                .filter { $0.recordType == .maxVolume }
                .map { $0.value }
                .max() ?? 0

            if totalVolume > existingMaxVolume {
                let record = PersonalRecord(
                    exerciseId: exerciseId,
                    exerciseName: exerciseName,
                    recordType: .maxVolume,
                    value: totalVolume,
                    date: Date()
                )
                try await analyticsRepository.savePersonalRecord(record)
                newRecords.append(record)
            }

            // Check max reps (most reps in a single set at any weight)
            if let maxRepSet = completedSets.max(by: { $0.reps < $1.reps }) {
                let existingMaxReps = existingPRs
                    .filter { $0.recordType == .maxReps }
                    .map { $0.reps ?? 0 }
                    .max() ?? 0

                if maxRepSet.reps > existingMaxReps {
                    let record = PersonalRecord(
                        exerciseId: exerciseId,
                        exerciseName: exerciseName,
                        recordType: .maxReps,
                        value: maxRepSet.weight,
                        reps: maxRepSet.reps,
                        date: Date()
                    )
                    try await analyticsRepository.savePersonalRecord(record)
                    newRecords.append(record)
                }
            }
        }

        return newRecords
    }
}
