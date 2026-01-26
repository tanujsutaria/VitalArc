//
//  MesocycleRepository.swift
//  VitalArc
//
//  Repository Protocol for Mesocycle Domain
//

import Foundation

protocol MesocycleRepository {
    // Mesocycle operations
    func getMesocycles() async throws -> [Mesocycle]
    func getMesocycle(id: UUID) async throws -> Mesocycle?
    func getActiveMesocycle() async throws -> Mesocycle?
    func saveMesocycle(_ mesocycle: Mesocycle) async throws
    func updateMesocycle(_ mesocycle: Mesocycle) async throws
    func deleteMesocycle(id: UUID) async throws

    // Status operations
    func activateMesocycle(id: UUID) async throws
    func completeMesocycle(id: UUID) async throws

    // Query operations
    func getMesocyclesByStatus(_ status: MesocycleStatus) async throws -> [Mesocycle]
    func getMesocycleForDate(_ date: Date) async throws -> Mesocycle?
}
