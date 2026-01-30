//
//  MockMesocycleRepository.swift
//  VitalArcTests
//
//  Mock implementation of MesocycleRepository for testing
//

import Foundation
@testable import VitalArc

/// Mock MesocycleRepository for unit testing
final class MockMesocycleRepository: MesocycleRepository {
    // MARK: - Mock Data

    var mockMesocycles: [Mesocycle] = []
    var mockActiveMesocycle: Mesocycle?

    // MARK: - Call Tracking

    var getMesocyclesCallCount = 0
    var getMesocycleByIdCallCount = 0
    var getActiveMesocycleCallCount = 0
    var saveMesocycleCallCount = 0
    var updateMesocycleCallCount = 0
    var deleteMesocycleCallCount = 0
    var activateMesocycleCallCount = 0
    var completeMesocycleCallCount = 0
    var getMesocyclesByStatusCallCount = 0
    var getMesocycleForDateCallCount = 0

    // MARK: - Captured Parameters

    var savedMesocycles: [Mesocycle] = []
    var updatedMesocycles: [Mesocycle] = []
    var deletedMesocycleIds: [UUID] = []
    var activatedMesocycleIds: [UUID] = []
    var completedMesocycleIds: [UUID] = []
    var lastRequestedId: UUID?
    var lastRequestedStatus: MesocycleStatus?
    var lastRequestedDate: Date?

    // MARK: - Error Simulation

    var shouldThrowOnGet = false
    var shouldThrowOnSave = false
    var shouldThrowOnUpdate = false
    var shouldThrowOnDelete = false
    var shouldThrowOnActivate = false
    var shouldThrowOnComplete = false
    var errorToThrow: Error?

    // MARK: - MesocycleRepository Protocol

    func getMesocycles() async throws -> [Mesocycle] {
        getMesocyclesCallCount += 1
        if shouldThrowOnGet {
            throw errorToThrow ?? MockMesocycleRepositoryError.fetchFailed
        }
        return mockMesocycles
    }

    func getMesocycle(id: UUID) async throws -> Mesocycle? {
        getMesocycleByIdCallCount += 1
        lastRequestedId = id
        if shouldThrowOnGet {
            throw errorToThrow ?? MockMesocycleRepositoryError.fetchFailed
        }
        return mockMesocycles.first { $0.id == id }
    }

    func getActiveMesocycle() async throws -> Mesocycle? {
        getActiveMesocycleCallCount += 1
        if shouldThrowOnGet {
            throw errorToThrow ?? MockMesocycleRepositoryError.fetchFailed
        }
        return mockActiveMesocycle
    }

    func saveMesocycle(_ mesocycle: Mesocycle) async throws {
        saveMesocycleCallCount += 1
        if shouldThrowOnSave {
            throw errorToThrow ?? MockMesocycleRepositoryError.saveFailed
        }
        savedMesocycles.append(mesocycle)
        mockMesocycles.append(mesocycle)
    }

    func updateMesocycle(_ mesocycle: Mesocycle) async throws {
        updateMesocycleCallCount += 1
        if shouldThrowOnUpdate {
            throw errorToThrow ?? MockMesocycleRepositoryError.updateFailed
        }
        updatedMesocycles.append(mesocycle)
        if let index = mockMesocycles.firstIndex(where: { $0.id == mesocycle.id }) {
            mockMesocycles[index] = mesocycle
        }
    }

    func deleteMesocycle(id: UUID) async throws {
        deleteMesocycleCallCount += 1
        if shouldThrowOnDelete {
            throw errorToThrow ?? MockMesocycleRepositoryError.deleteFailed
        }
        deletedMesocycleIds.append(id)
        mockMesocycles.removeAll { $0.id == id }
    }

    func activateMesocycle(id: UUID) async throws {
        activateMesocycleCallCount += 1
        if shouldThrowOnActivate {
            throw errorToThrow ?? MockMesocycleRepositoryError.activationFailed
        }
        activatedMesocycleIds.append(id)
        if let index = mockMesocycles.firstIndex(where: { $0.id == id }) {
            var updated = mockMesocycles[index]
            updated = Mesocycle(
                id: updated.id,
                name: updated.name,
                startDate: updated.startDate,
                endDate: updated.endDate,
                durationWeeks: updated.durationWeeks,
                goal: updated.goal,
                status: .active,
                phaseTemplate: updated.phaseTemplate,
                currentWeek: updated.currentWeek,
                trainingBlocks: updated.trainingBlocks,
                notes: updated.notes,
                createdAt: updated.createdAt,
                updatedAt: Date()
            )
            mockMesocycles[index] = updated
            mockActiveMesocycle = updated
        }
    }

    func completeMesocycle(id: UUID) async throws {
        completeMesocycleCallCount += 1
        if shouldThrowOnComplete {
            throw errorToThrow ?? MockMesocycleRepositoryError.completionFailed
        }
        completedMesocycleIds.append(id)
        if let index = mockMesocycles.firstIndex(where: { $0.id == id }) {
            var updated = mockMesocycles[index]
            updated = Mesocycle(
                id: updated.id,
                name: updated.name,
                startDate: updated.startDate,
                endDate: updated.endDate,
                durationWeeks: updated.durationWeeks,
                goal: updated.goal,
                status: .completed,
                phaseTemplate: updated.phaseTemplate,
                currentWeek: updated.currentWeek,
                trainingBlocks: updated.trainingBlocks,
                notes: updated.notes,
                createdAt: updated.createdAt,
                updatedAt: Date()
            )
            mockMesocycles[index] = updated
            if mockActiveMesocycle?.id == id {
                mockActiveMesocycle = nil
            }
        }
    }

    func getMesocyclesByStatus(_ status: MesocycleStatus) async throws -> [Mesocycle] {
        getMesocyclesByStatusCallCount += 1
        lastRequestedStatus = status
        if shouldThrowOnGet {
            throw errorToThrow ?? MockMesocycleRepositoryError.fetchFailed
        }
        return mockMesocycles.filter { $0.status == status }
    }

    func getMesocycleForDate(_ date: Date) async throws -> Mesocycle? {
        getMesocycleForDateCallCount += 1
        lastRequestedDate = date
        if shouldThrowOnGet {
            throw errorToThrow ?? MockMesocycleRepositoryError.fetchFailed
        }
        return mockMesocycles.first { mesocycle in
            date >= mesocycle.startDate && date <= mesocycle.endDate
        }
    }

    // MARK: - Helper Methods

    func reset() {
        mockMesocycles = []
        mockActiveMesocycle = nil
        getMesocyclesCallCount = 0
        getMesocycleByIdCallCount = 0
        getActiveMesocycleCallCount = 0
        saveMesocycleCallCount = 0
        updateMesocycleCallCount = 0
        deleteMesocycleCallCount = 0
        activateMesocycleCallCount = 0
        completeMesocycleCallCount = 0
        getMesocyclesByStatusCallCount = 0
        getMesocycleForDateCallCount = 0
        savedMesocycles = []
        updatedMesocycles = []
        deletedMesocycleIds = []
        activatedMesocycleIds = []
        completedMesocycleIds = []
        lastRequestedId = nil
        lastRequestedStatus = nil
        lastRequestedDate = nil
        shouldThrowOnGet = false
        shouldThrowOnSave = false
        shouldThrowOnUpdate = false
        shouldThrowOnDelete = false
        shouldThrowOnActivate = false
        shouldThrowOnComplete = false
        errorToThrow = nil
    }

    // MARK: - Sample Data Generators

    static func createSampleMesocycle(
        id: UUID = UUID(),
        name: String = "Test Mesocycle",
        startDate: Date = Date(),
        durationWeeks: Int = 4,
        goal: TrainingGoal = .hypertrophy,
        status: MesocycleStatus = .planned
    ) -> Mesocycle {
        let endDate = Calendar.current.date(byAdding: .weekOfYear, value: durationWeeks, to: startDate) ?? startDate
        return Mesocycle(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
            durationWeeks: durationWeeks,
            goal: goal,
            status: status,
            phaseTemplate: .linear,
            currentWeek: 1,
            trainingBlocks: [],
            notes: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static func createSampleTrainingBlock(
        dayOfWeek: Int = 1,
        name: String = "Push Day"
    ) -> TrainingBlock {
        TrainingBlock(
            dayOfWeek: dayOfWeek,
            name: name,
            exercises: [],
            notes: nil
        )
    }
}

// MARK: - Mock Errors

enum MockMesocycleRepositoryError: LocalizedError {
    case fetchFailed
    case saveFailed
    case updateFailed
    case deleteFailed
    case activationFailed
    case completionFailed

    var errorDescription: String? {
        switch self {
        case .fetchFailed: return "Mock: Failed to fetch mesocycle"
        case .saveFailed: return "Mock: Failed to save mesocycle"
        case .updateFailed: return "Mock: Failed to update mesocycle"
        case .deleteFailed: return "Mock: Failed to delete mesocycle"
        case .activationFailed: return "Mock: Failed to activate mesocycle"
        case .completionFailed: return "Mock: Failed to complete mesocycle"
        }
    }
}
