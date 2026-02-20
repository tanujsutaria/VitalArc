//
//  MockTemplateRepository.swift
//  VitalArcTests
//
//  Mock implementation of TemplateRepository for testing
//

import Foundation
@testable import VitalArc

final class MockTemplateRepository: TemplateRepository {
    // MARK: - Mock Data

    var mockTemplates: [WorkoutTemplate] = []

    // MARK: - Call Tracking

    var savedTemplates: [WorkoutTemplate] = []
    var updatedTemplates: [WorkoutTemplate] = []
    var deletedTemplateIds: [UUID] = []
    var incrementedUsageIds: [UUID] = []

    // MARK: - Error Simulation

    var shouldThrowOnGet = false
    var shouldThrowOnSave = false
    var shouldThrowOnDelete = false

    // MARK: - TemplateRepository Protocol

    func getTemplates() async throws -> [WorkoutTemplate] {
        if shouldThrowOnGet { throw MockTemplateRepositoryError.getFailed }
        return mockTemplates
    }

    func getTemplate(id: UUID) async throws -> WorkoutTemplate? {
        if shouldThrowOnGet { throw MockTemplateRepositoryError.getFailed }
        return mockTemplates.first { $0.id == id }
    }

    func getTemplates(category: TemplateCategory) async throws -> [WorkoutTemplate] {
        if shouldThrowOnGet { throw MockTemplateRepositoryError.getFailed }
        return mockTemplates.filter { $0.category == category }
    }

    func saveTemplate(_ template: WorkoutTemplate) async throws {
        if shouldThrowOnSave { throw MockTemplateRepositoryError.saveFailed }
        savedTemplates.append(template)
        mockTemplates.append(template)
    }

    func updateTemplate(_ template: WorkoutTemplate) async throws {
        if shouldThrowOnSave { throw MockTemplateRepositoryError.saveFailed }
        updatedTemplates.append(template)
        if let idx = mockTemplates.firstIndex(where: { $0.id == template.id }) {
            mockTemplates[idx] = template
        }
    }

    func deleteTemplate(id: UUID) async throws {
        if shouldThrowOnDelete { throw MockTemplateRepositoryError.deleteFailed }
        deletedTemplateIds.append(id)
        mockTemplates.removeAll { $0.id == id }
    }

    func incrementTemplateUsage(id: UUID) async throws {
        incrementedUsageIds.append(id)
        if let idx = mockTemplates.firstIndex(where: { $0.id == id }) {
            mockTemplates[idx].markAsUsed()
        }
    }

    // MARK: - Mock Error

    enum MockTemplateRepositoryError: Error, LocalizedError {
        case getFailed
        case saveFailed
        case deleteFailed

        var errorDescription: String? {
            switch self {
            case .getFailed: return "Get failed"
            case .saveFailed: return "Save failed"
            case .deleteFailed: return "Delete failed"
            }
        }
    }
}
