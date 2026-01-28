//
//  HealthRepository.swift
//  VitalArc
//
//  Repository Protocol for Health Domain
//

import Foundation

protocol HealthRepository {
    // Health metrics operations
    func getHealthMetrics(for date: Date) async throws -> HealthMetrics?
    func getHealthMetrics(from startDate: Date, to endDate: Date) async throws -> [HealthMetrics]
    func saveHealthMetrics(_ metrics: HealthMetrics) async throws

    // HealthKit sync
    func syncFromHealthKit() async throws
    func requestHealthKitAuthorization() async throws -> Bool
}
