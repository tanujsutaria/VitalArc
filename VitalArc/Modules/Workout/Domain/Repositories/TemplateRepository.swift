//
//  TemplateRepository.swift
//  VitalArc
//
//  Repository protocol for workout templates
//

import Foundation

/// Protocol for workout template persistence
protocol TemplateRepository {
    func getTemplates() async throws -> [WorkoutTemplate]
    func getTemplate(id: UUID) async throws -> WorkoutTemplate?
    func getTemplates(category: TemplateCategory) async throws -> [WorkoutTemplate]
    func saveTemplate(_ template: WorkoutTemplate) async throws
    func updateTemplate(_ template: WorkoutTemplate) async throws
    func deleteTemplate(id: UUID) async throws
    func incrementTemplateUsage(id: UUID) async throws
}
