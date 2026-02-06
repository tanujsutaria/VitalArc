//
//  MesocycleViewModel.swift
//  VitalArc
//
//  ViewModel for Mesocycle Management
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class MesocycleViewModel {
    private let mesocycleRepository: MesocycleRepository
    private let workoutRepository: WorkoutRepository
    private let createUseCase: CreateMesocycleUseCase
    private let progressUseCase: UpdateMesocycleProgressUseCase

    // State
    var mesocycles: [Mesocycle] = []
    var activeMesocycle: Mesocycle?
    var selectedMesocycle: Mesocycle?
    var progressSummary: MesocycleProgressSummary?
    var isLoading = false
    var error: Error?

    init(
        mesocycleRepository: MesocycleRepository,
        workoutRepository: WorkoutRepository
    ) {
        self.mesocycleRepository = mesocycleRepository
        self.workoutRepository = workoutRepository
        self.createUseCase = CreateMesocycleUseCase(repository: mesocycleRepository)
        self.progressUseCase = UpdateMesocycleProgressUseCase(
            mesocycleRepository: mesocycleRepository,
            workoutRepository: workoutRepository
        )
    }

    // MARK: - Data Loading

    func loadMesocycles() async {
        isLoading = true
        defer { isLoading = false }

        do {
            mesocycles = try await mesocycleRepository.getMesocycles()
            activeMesocycle = try await mesocycleRepository.getActiveMesocycle()

            // Update statuses based on dates
            try await progressUseCase.updateMesocycleStatus()

            // Reload after status update
            mesocycles = try await mesocycleRepository.getMesocycles()
            activeMesocycle = try await mesocycleRepository.getActiveMesocycle()
        } catch {
            self.error = error
        }
    }

    func loadProgressSummary(for mesocycleId: UUID) async {
        do {
            progressSummary = try await progressUseCase.getProgressSummary(mesocycleId: mesocycleId)
        } catch {
            self.error = error
        }
    }

    // MARK: - Mesocycle Operations

    func createMesocycle(
        name: String,
        startDate: Date,
        durationWeeks: Int,
        goal: TrainingGoal,
        phaseTemplate: PhaseTemplate,
        trainingBlocks: [TrainingBlock]
    ) async {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await createUseCase.execute(
                name: name,
                startDate: startDate,
                durationWeeks: durationWeeks,
                goal: goal,
                phaseTemplate: phaseTemplate,
                trainingBlocks: trainingBlocks
            )
            await loadMesocycles()
        } catch {
            self.error = error
        }
    }

    func activateMesocycle(_ mesocycle: Mesocycle) async {
        do {
            try await mesocycleRepository.activateMesocycle(id: mesocycle.id)
            await loadMesocycles()
        } catch {
            self.error = error
        }
    }

    func completeMesocycle(_ mesocycle: Mesocycle) async {
        do {
            try await mesocycleRepository.completeMesocycle(id: mesocycle.id)
            await loadMesocycles()
        } catch {
            self.error = error
        }
    }

    func deleteMesocycle(_ mesocycle: Mesocycle) async {
        do {
            try await mesocycleRepository.deleteMesocycle(id: mesocycle.id)
            await loadMesocycles()
        } catch {
            self.error = error
        }
    }

    func updateMesocycle(_ mesocycle: Mesocycle) async {
        do {
            try await mesocycleRepository.updateMesocycle(mesocycle)
            await loadMesocycles()
        } catch {
            self.error = error
        }
    }

    // MARK: - Auto-Regulation

    func getAutoRegulation(
        for exercise: TrainingBlockExercise,
        mesocycleId: UUID
    ) async -> AutoRegulationAdvice? {
        do {
            return try await progressUseCase.calculateAutoRegulation(
                exerciseId: exercise.exerciseId,
                mesocycleId: mesocycleId,
                plannedRIR: exercise.targetRIR
            )
        } catch {
            self.error = error
            return nil
        }
    }

    // MARK: - Training Blocks

    func getCurrentTrainingBlocks() async -> [TrainingBlock] {
        do {
            return try await progressUseCase.getCurrentTrainingBlocks()
        } catch {
            self.error = error
            return []
        }
    }

    func getTrainingBlockForToday() async -> TrainingBlock? {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: Date())

        do {
            return try await progressUseCase.getTrainingBlockForDay(dayOfWeek)
        } catch {
            self.error = error
            return nil
        }
    }

    // MARK: - Helper Methods

    func getMesocyclesByStatus(_ status: MesocycleStatus) -> [Mesocycle] {
        mesocycles.filter { $0.status == status }
    }

    func clearError() {
        error = nil
    }
}
