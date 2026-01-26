//
//  UpdateMesocycleProgressUseCase.swift
//  VitalArc
//
//  Use Case: Update mesocycle progress and provide auto-regulation
//

import Foundation

final class UpdateMesocycleProgressUseCase {
    private let mesocycleRepository: MesocycleRepository
    private let workoutRepository: WorkoutRepository

    init(
        mesocycleRepository: MesocycleRepository,
        workoutRepository: WorkoutRepository
    ) {
        self.mesocycleRepository = mesocycleRepository
        self.workoutRepository = workoutRepository
    }

    /// Calculate auto-regulation advice based on recent performance
    func calculateAutoRegulation(
        exerciseId: UUID,
        mesocycleId: UUID,
        plannedRIR: Int
    ) async throws -> AutoRegulationAdvice {
        // Get workouts from the last 2 weeks
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -14, to: endDate) else {
            return AutoRegulationAdvice(
                recommendation: .maintain,
                reason: "Insufficient data",
                suggestedWeightChange: nil
            )
        }

        // Fetch recent workouts
        let workouts = try await workoutRepository.getWorkouts(from: startDate, to: endDate)

        // Filter sets for this exercise and mesocycle
        let relevantSets = workouts
            .flatMap { $0.sets }
            .filter { $0.exerciseId == exerciseId && $0.mesocycleId == mesocycleId && $0.completed }

        guard !relevantSets.isEmpty else {
            return AutoRegulationAdvice(
                recommendation: .maintain,
                reason: "No recent workout data",
                suggestedWeightChange: nil
            )
        }

        // Calculate average RIR
        let setsWithRIR = relevantSets.filter { $0.rir != nil }
        guard !setsWithRIR.isEmpty else {
            return AutoRegulationAdvice(
                recommendation: .maintain,
                reason: "No RIR data recorded",
                suggestedWeightChange: nil
            )
        }

        let averageRIR = Double(setsWithRIR.compactMap { $0.rir }.reduce(0, +)) / Double(setsWithRIR.count)
        let rirDifference = averageRIR - Double(plannedRIR)

        // Calculate average weight for progression suggestion
        let averageWeight = relevantSets.map { $0.weight }.reduce(0, +) / Double(relevantSets.count)

        // Determine recommendation based on RIR difference
        if rirDifference >= 2.0 {
            // Actual RIR is 2+ higher than planned (too easy)
            let suggestedIncrease = max(2.5, averageWeight * 0.05) // 5% or 2.5kg minimum
            return AutoRegulationAdvice(
                recommendation: .increaseWeight,
                reason: "Consistently leaving \(Int(averageRIR)) RIR vs target of \(plannedRIR). You can handle more weight.",
                suggestedWeightChange: suggestedIncrease
            )
        } else if rirDifference >= 1.0 {
            // Actual RIR is 1-2 higher than planned (slightly easy)
            let suggestedIncrease = max(2.5, averageWeight * 0.025) // 2.5% or 2.5kg minimum
            return AutoRegulationAdvice(
                recommendation: .increaseWeight,
                reason: "Leaving more reps in reserve than planned. Consider small weight increase.",
                suggestedWeightChange: suggestedIncrease
            )
        } else if rirDifference <= -2.0 {
            // Actual RIR is 2+ lower than planned (too hard, failing sets)
            return AutoRegulationAdvice(
                recommendation: .deload,
                reason: "Consistently unable to maintain \(plannedRIR) RIR. Recommend deload week.",
                suggestedWeightChange: -averageWeight * 0.1 // 10% reduction
            )
        } else if rirDifference <= -1.0 {
            // Actual RIR is 1-2 lower than planned (slightly hard)
            let suggestedDecrease = averageWeight * 0.05 // 5% reduction
            return AutoRegulationAdvice(
                recommendation: .decreaseWeight,
                reason: "Struggling to maintain target RIR. Consider reducing weight slightly.",
                suggestedWeightChange: -suggestedDecrease
            )
        } else {
            // RIR within ±1 of target (on track)
            return AutoRegulationAdvice(
                recommendation: .maintain,
                reason: "Performance on track. Maintain current progression.",
                suggestedWeightChange: nil
            )
        }
    }

    /// Get current training blocks for active mesocycle
    func getCurrentTrainingBlocks() async throws -> [TrainingBlock] {
        guard let activeMesocycle = try await mesocycleRepository.getActiveMesocycle() else {
            return []
        }

        return activeMesocycle.trainingBlocks
    }

    /// Get training block for specific day
    func getTrainingBlockForDay(_ dayOfWeek: Int) async throws -> TrainingBlock? {
        guard let activeMesocycle = try await mesocycleRepository.getActiveMesocycle() else {
            return nil
        }

        return activeMesocycle.trainingBlocks.first { $0.dayOfWeek == dayOfWeek }
    }

    /// Calculate recommended weight for next set based on progression scheme
    func calculateProgressionWeight(
        exercise: TrainingBlockExercise,
        currentWeight: Double,
        actualReps: Int,
        actualRIR: Int?
    ) -> Double {
        switch exercise.progressionScheme {
        case .linear:
            // Simple linear progression: add 2.5kg each week
            return currentWeight + 2.5

        case .doubleProgression:
            // Add reps until max reached, then add weight
            if actualReps >= exercise.targetRepsMax {
                // Hit top of rep range, increase weight and drop reps
                return currentWeight + 2.5
            } else {
                // Keep same weight, aim for more reps
                return currentWeight
            }

        case .wave:
            // Undulating: alternate between heavier and lighter weeks
            // This would need week context - simplified here
            let variation = currentWeight * 0.05
            return currentWeight + variation

        case .static:
            // Maintain current weight
            return currentWeight
        }
    }

    /// Update mesocycle status based on date
    func updateMesocycleStatus() async throws {
        let mesocycles = try await mesocycleRepository.getMesocycles()
        let today = Date()

        for mesocycle in mesocycles {
            var updated = mesocycle

            // Auto-activate if start date reached and currently planned
            if mesocycle.status == .planned && today >= mesocycle.startDate {
                updated.status = .active
                updated.updatedAt = Date()
                try await mesocycleRepository.updateMesocycle(updated)
            }

            // Auto-complete if end date passed and currently active
            if mesocycle.status == .active && today > mesocycle.endDate {
                updated.status = .completed
                updated.updatedAt = Date()
                try await mesocycleRepository.updateMesocycle(updated)
            }
        }
    }

    /// Get progress summary for mesocycle
    func getProgressSummary(mesocycleId: UUID) async throws -> MesocycleProgressSummary {
        guard let mesocycle = try await mesocycleRepository.getMesocycle(id: mesocycleId) else {
            throw MesocycleError.mesocycleNotFound
        }

        // Get all workouts for this mesocycle
        let workouts = try await workoutRepository.getWorkouts(
            from: mesocycle.startDate,
            to: Date()
        )

        // Filter sets linked to this mesocycle
        let mesocycleSets = workouts
            .flatMap { $0.sets }
            .filter { $0.mesocycleId == mesocycleId }

        // Calculate metrics
        let totalSets = mesocycleSets.count
        let completedSets = mesocycleSets.filter { $0.completed }.count
        let totalVolume = mesocycleSets.reduce(0.0) { $0 + $1.volume }
        let averageRIR = calculateAverageRIR(sets: mesocycleSets)

        // Calculate week-by-week progress
        let weeklyProgress = calculateWeeklyProgress(
            workouts: workouts,
            mesocycleId: mesocycleId,
            mesocycle: mesocycle
        )

        // Calculate per-exercise progress
        let exerciseProgress = try await calculateExerciseProgress(
            workouts: workouts,
            mesocycleId: mesocycleId,
            mesocycle: mesocycle
        )

        return MesocycleProgressSummary(
            mesocycleId: mesocycleId,
            currentWeek: mesocycle.currentWeek ?? 0,
            totalWeeks: mesocycle.durationWeeks,
            currentPhase: mesocycle.currentPhase,
            totalSets: totalSets,
            completedSets: completedSets,
            totalVolume: totalVolume,
            averageRIR: averageRIR,
            progressPercentage: mesocycle.progressPercentage,
            weeklyProgress: weeklyProgress,
            exerciseProgress: exerciseProgress
        )
    }

    /// Calculate week-by-week progress data
    private func calculateWeeklyProgress(
        workouts: [Workout],
        mesocycleId: UUID,
        mesocycle: Mesocycle
    ) -> [WeeklyProgress] {
        let calendar = Calendar.current
        var weeklyData: [Int: (volume: Double, sets: Int, completed: Int, rirs: [Int], workouts: Int)] = [:]

        for workout in workouts {
            // Determine which week this workout belongs to
            let daysSinceStart = calendar.dateComponents([.day], from: mesocycle.startDate, to: workout.date).day ?? 0
            let weekNumber = max(1, (daysSinceStart / 7) + 1)

            guard weekNumber <= mesocycle.durationWeeks else { continue }

            let sets = workout.sets.filter { $0.mesocycleId == mesocycleId }
            guard !sets.isEmpty else { continue }

            var data = weeklyData[weekNumber] ?? (volume: 0, sets: 0, completed: 0, rirs: [], workouts: 0)
            data.volume += sets.reduce(0.0) { $0 + $1.volume }
            data.sets += sets.count
            data.completed += sets.filter { $0.completed }.count
            data.rirs += sets.compactMap { $0.rir }
            data.workouts += 1
            weeklyData[weekNumber] = data
        }

        // Create WeeklyProgress for each week up to current
        let currentWeek = mesocycle.currentWeek ?? 1
        return (1...currentWeek).map { weekNum in
            let data = weeklyData[weekNum]
            let avgRIR: Double? = {
                guard let rirs = data?.rirs, !rirs.isEmpty else { return nil }
                return Double(rirs.reduce(0, +)) / Double(rirs.count)
            }()

            return WeeklyProgress(
                weekNumber: weekNum,
                totalVolume: data?.volume ?? 0,
                totalSets: data?.sets ?? 0,
                completedSets: data?.completed ?? 0,
                averageRIR: avgRIR,
                workoutCount: data?.workouts ?? 0
            )
        }
    }

    /// Calculate per-exercise progress across weeks
    private func calculateExerciseProgress(
        workouts: [Workout],
        mesocycleId: UUID,
        mesocycle: Mesocycle
    ) async throws -> [ExerciseWeeklyProgress] {
        let calendar = Calendar.current

        // Get all exercises for name lookup
        let exercises = try await workoutRepository.getExercises()
        let exerciseNames: [UUID: String] = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0.name) })

        // Group sets by exercise
        var exerciseData: [UUID: (name: String, weekData: [Int: (maxWeight: Double, totalReps: Int, sets: Int, bestSet: (weight: Double, reps: Int))])] = [:]

        for workout in workouts {
            let daysSinceStart = calendar.dateComponents([.day], from: mesocycle.startDate, to: workout.date).day ?? 0
            let weekNumber = max(1, (daysSinceStart / 7) + 1)

            guard weekNumber <= mesocycle.durationWeeks else { continue }

            for set in workout.sets where set.mesocycleId == mesocycleId && set.completed {
                let exerciseId = set.exerciseId

                // Get exercise name from lookup
                let exerciseName = exerciseNames[exerciseId] ?? "Unknown Exercise"

                var data = exerciseData[exerciseId] ?? (name: exerciseName, weekData: [:])
                var weekEntry = data.weekData[weekNumber] ?? (maxWeight: 0, totalReps: 0, sets: 0, bestSet: (weight: 0, reps: 0))

                weekEntry.maxWeight = max(weekEntry.maxWeight, set.weight)
                weekEntry.totalReps += set.reps
                weekEntry.sets += 1

                // Track best set (highest weight with most reps)
                if set.weight > weekEntry.bestSet.weight ||
                   (set.weight == weekEntry.bestSet.weight && set.reps > weekEntry.bestSet.reps) {
                    weekEntry.bestSet = (set.weight, set.reps)
                }

                data.weekData[weekNumber] = weekEntry
                exerciseData[exerciseId] = data
            }
        }

        // Convert to ExerciseWeeklyProgress
        return exerciseData.map { exerciseId, data in
            let weeklyData = data.weekData.map { weekNum, weekData in
                ExerciseWeekData(
                    weekNumber: weekNum,
                    maxWeight: weekData.maxWeight,
                    totalReps: weekData.totalReps,
                    totalSets: weekData.sets,
                    bestSet: "\(Int(weekData.bestSet.weight)) x \(weekData.bestSet.reps)"
                )
            }.sorted { $0.weekNumber < $1.weekNumber }

            return ExerciseWeeklyProgress(
                exerciseId: exerciseId,
                exerciseName: data.name,
                weeklyData: weeklyData
            )
        }.sorted { $0.exerciseName < $1.exerciseName }
    }

    private func calculateAverageRIR(sets: [WorkoutSet]) -> Double? {
        let setsWithRIR = sets.compactMap { $0.rir }
        guard !setsWithRIR.isEmpty else { return nil }
        return Double(setsWithRIR.reduce(0, +)) / Double(setsWithRIR.count)
    }
}

/// Progress summary for a mesocycle
struct MesocycleProgressSummary {
    let mesocycleId: UUID
    let currentWeek: Int
    let totalWeeks: Int
    let currentPhase: MesocyclePhase?
    let totalSets: Int
    let completedSets: Int
    let totalVolume: Double
    let averageRIR: Double?
    let progressPercentage: Double
    let weeklyProgress: [WeeklyProgress]
    let exerciseProgress: [ExerciseWeeklyProgress]
}

/// Weekly progress data for charts
struct WeeklyProgress: Identifiable {
    let id = UUID()
    let weekNumber: Int
    let totalVolume: Double // in lbs
    let totalSets: Int
    let completedSets: Int
    let averageRIR: Double?
    let workoutCount: Int
}

/// Per-exercise weekly progress for tracking specific lifts
struct ExerciseWeeklyProgress: Identifiable {
    let id = UUID()
    let exerciseId: UUID
    let exerciseName: String
    let weeklyData: [ExerciseWeekData]
}

struct ExerciseWeekData: Identifiable {
    let id = UUID()
    let weekNumber: Int
    let maxWeight: Double // in lbs
    let totalReps: Int
    let totalSets: Int
    let bestSet: String // e.g., "225 x 8"
}
