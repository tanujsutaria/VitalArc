//
//  CalculateVolumeUseCase.swift
//  VitalArc
//
//  Use case for calculating training volume metrics
//

import Foundation

/// Calculates training volume metrics for a given time period
class CalculateVolumeUseCase {
    private let workoutDataProvider: WorkoutDataProviding

    init(workoutDataProvider: WorkoutDataProviding) {
        self.workoutDataProvider = workoutDataProvider
    }

    /// Execute volume calculation for a date range
    func execute(startDate: Date, endDate: Date) async throws -> VolumeMetrics {
        // Fetch all workouts in date range
        let workouts = try await workoutDataProvider.getWorkouts(from: startDate, to: endDate)

        // Group sets by exercise
        var exerciseData: [UUID: ExerciseVolumeData] = [:]

        for workout in workouts {
            for set in workout.sets {
                if exerciseData[set.exerciseId] == nil {
                    exerciseData[set.exerciseId] = ExerciseVolumeData(
                        exerciseId: set.exerciseId,
                        sets: 0,
                        totalReps: 0,
                        totalWeight: 0,
                        weights: [],
                        rirs: []
                    )
                }

                exerciseData[set.exerciseId]?.sets += 1
                exerciseData[set.exerciseId]?.totalReps += set.reps

                let reps = Double(set.reps)
                let weight = set.weight
                let volume = reps * weight

                exerciseData[set.exerciseId]?.totalWeight += volume
                exerciseData[set.exerciseId]?.weights.append(weight)

                if let rir = set.rir {
                    exerciseData[set.exerciseId]?.rirs.append(Double(rir))
                }
            }
        }

        // Convert to ExerciseVolume array
        let exerciseVolumes = try await convertToExerciseVolumes(exerciseData)


        // Calculate total volume
        let totalVolume = exerciseVolumes.reduce(0) { $0 + $1.totalWeight }

        // Calculate average intensity (simplified)
        let avgIntensity = exerciseVolumes.isEmpty ? 0 :
            exerciseVolumes.reduce(0.0) { $0 + $1.intensity } / Double(exerciseVolumes.count)

        return VolumeMetrics(
            weekStartDate: startDate,
            weekEndDate: endDate,
            exerciseVolumes: exerciseVolumes.sorted { $0.totalWeight > $1.totalWeight },
            totalVolume: totalVolume,
            avgIntensity: avgIntensity,
            workoutCount: workouts.count
        )
    }

    /// Calculate volume for a specific week
    func executeForWeek(date: Date) async throws -> VolumeMetrics {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start else {
            throw VolumeCalculationError.invalidDate
        }

        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? date

        return try await execute(startDate: weekStart, endDate: weekEnd)
    }

    /// Calculate volume for last N weeks
    func executeForWeeks(_ weeks: Int) async throws -> [VolumeMetrics] {
        let calendar = Calendar.current
        let today = Date()
        var metrics: [VolumeMetrics] = []

        for weekOffset in 0..<weeks {
            guard let weekDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today),
                  let weekStart = calendar.dateInterval(of: .weekOfYear, for: weekDate)?.start else {
                continue
            }

            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekDate
            let weekMetrics = try await execute(startDate: weekStart, endDate: weekEnd)
            metrics.append(weekMetrics)
        }

        return metrics.reversed() // Return in chronological order
    }

    // MARK: - Private Helpers

    private func convertToExerciseVolumes(_ exerciseData: [UUID: ExerciseVolumeData]) async throws -> [ExerciseVolume] {
        var volumes: [ExerciseVolume] = []

        for (exerciseId, data) in exerciseData {
            // Fetch exercise name
            let exercise = try await workoutDataProvider.getExercise(id: exerciseId)
            let exerciseName = exercise?.name ?? Strings.Fallback.unknownExercise

            let avgWeight = data.weights.isEmpty ? 0 : data.weights.reduce(0, +) / Double(data.weights.count)
            let avgRIR = data.rirs.isEmpty ? nil : data.rirs.reduce(0, +) / Double(data.rirs.count)

            let volume = ExerciseVolume(
                exerciseId: data.exerciseId,
                exerciseName: exerciseName,
                sets: data.sets,
                totalReps: data.totalReps,
                totalWeight: data.totalWeight,
                avgWeight: avgWeight,
                avgRIR: avgRIR
            )
            volumes.append(volume)
        }

        return volumes
    }
}

// MARK: - Helper Types

private struct ExerciseVolumeData {
    let exerciseId: UUID
    var sets: Int
    var totalReps: Int
    var totalWeight: Double
    var weights: [Double]
    var rirs: [Double]
}

enum VolumeCalculationError: Error {
    case invalidDate
    case noWorkoutsFound
}
