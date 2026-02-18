//
//  GetExerciseHistoryUseCase.swift
//  VitalArc
//
//  Use case for retrieving exercise progression history
//

import Foundation

/// Retrieves progression history for a specific exercise
@MainActor
class GetExerciseHistoryUseCase {
    private let workoutRepository: WorkoutRepository

    init(workoutRepository: WorkoutRepository) {
        self.workoutRepository = workoutRepository
    }

    /// Get exercise history points sorted by date
    func execute(exerciseId: UUID) async throws -> [ExerciseHistoryPoint] {
        let workouts = try await workoutRepository.getWorkouts()

        // Group sets by workout date for this exercise
        var pointsByDate: [Date: (maxWeight: Double, totalVolume: Double, bestSet: (weight: Double, reps: Int))] = [:]

        for workout in workouts {
            let exerciseSets = workout.sets.filter { $0.exerciseId == exerciseId && $0.completed }
            guard !exerciseSets.isEmpty else { continue }

            let workoutDate = Calendar.current.startOfDay(for: workout.date)

            let maxWeight = exerciseSets.max(by: { $0.weight < $1.weight })?.weight ?? 0
            let totalVolume = exerciseSets.reduce(0.0) { $0 + $1.volume }

            // Find best set for estimated 1RM (highest estimated 1RM)
            let bestSet = exerciseSets.map { (weight: $0.weight, reps: $0.reps) }
                .max(by: { estimated1RM(weight: $0.weight, reps: $0.reps) < estimated1RM(weight: $1.weight, reps: $1.reps) })
                ?? (weight: 0, reps: 0)

            // Merge if multiple workouts on same day
            if let existing = pointsByDate[workoutDate] {
                pointsByDate[workoutDate] = (
                    maxWeight: max(existing.maxWeight, maxWeight),
                    totalVolume: existing.totalVolume + totalVolume,
                    bestSet: estimated1RM(weight: existing.bestSet.weight, reps: existing.bestSet.reps)
                        > estimated1RM(weight: bestSet.weight, reps: bestSet.reps)
                        ? existing.bestSet : bestSet
                )
            } else {
                pointsByDate[workoutDate] = (maxWeight: maxWeight, totalVolume: totalVolume, bestSet: bestSet)
            }
        }

        return pointsByDate.map { date, data in
            ExerciseHistoryPoint(
                date: date,
                maxWeight: data.maxWeight,
                totalVolume: data.totalVolume,
                estimated1RM: estimated1RM(weight: data.bestSet.weight, reps: data.bestSet.reps)
            )
        }
        .sorted { $0.date < $1.date }
    }

    /// Epley formula for estimated 1RM
    private func estimated1RM(weight: Double, reps: Int) -> Double {
        guard reps > 0, weight > 0 else { return 0 }
        if reps == 1 { return weight }
        return weight * (1 + Double(reps) / 30.0)
    }
}
