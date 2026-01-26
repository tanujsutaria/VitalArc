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

        return MesocycleProgressSummary(
            mesocycleId: mesocycleId,
            currentWeek: mesocycle.currentWeek ?? 0,
            totalWeeks: mesocycle.durationWeeks,
            currentPhase: mesocycle.currentPhase,
            totalSets: totalSets,
            completedSets: completedSets,
            totalVolume: totalVolume,
            averageRIR: averageRIR,
            progressPercentage: mesocycle.progressPercentage
        )
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
}
