//
//  AnalyticsRepository.swift
//  VitalArc
//
//  Repository protocol for analytics data
//

import Foundation

/// Protocol for analytics data persistence
protocol AnalyticsRepository {
    // MARK: - Progress Snapshots
    func getProgressSnapshots(from startDate: Date, to endDate: Date) async throws -> [ProgressSnapshot]
    func getProgressSnapshot(id: UUID) async throws -> ProgressSnapshot?
    func getLatestProgressSnapshot() async throws -> ProgressSnapshot?
    func saveProgressSnapshot(_ snapshot: ProgressSnapshot) async throws
    func deleteProgressSnapshot(id: UUID) async throws

    // MARK: - Volume Metrics
    func getVolumeMetrics(from startDate: Date, to endDate: Date) async throws -> [VolumeMetrics]
    func getVolumeMetrics(for weekStartDate: Date) async throws -> VolumeMetrics?
    func saveVolumeMetrics(_ metrics: VolumeMetrics) async throws

    // MARK: - Personal Records
    func getPersonalRecords() async throws -> [PersonalRecord]
    func getPersonalRecords(for exerciseId: UUID) async throws -> [PersonalRecord]
    func getPersonalRecord(id: UUID) async throws -> PersonalRecord?
    func savePersonalRecord(_ record: PersonalRecord) async throws
    func deletePersonalRecord(id: UUID) async throws
}
