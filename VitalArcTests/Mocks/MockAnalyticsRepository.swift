//
//  MockAnalyticsRepository.swift
//  VitalArcTests
//
//  Mock implementation of AnalyticsRepository for testing
//

import Foundation
@testable import VitalArc

/// Mock AnalyticsRepository for unit testing
final class MockAnalyticsRepository: AnalyticsRepository {
    // MARK: - Mock Data

    var mockProgressSnapshots: [ProgressSnapshot] = []
    var mockVolumeMetrics: [VolumeMetrics] = []
    var mockPersonalRecords: [PersonalRecord] = []

    // MARK: - Call Tracking

    var getProgressSnapshotsCallCount = 0
    var getVolumeMetricsCallCount = 0
    var getPersonalRecordsCallCount = 0
    var saveProgressSnapshotCallCount = 0
    var saveVolumeMetricsCallCount = 0
    var savePersonalRecordCallCount = 0

    // MARK: - Captured Parameters

    var lastStartDate: Date?
    var lastEndDate: Date?
    var savedSnapshots: [ProgressSnapshot] = []
    var savedVolumeMetrics: [VolumeMetrics] = []
    var savedPersonalRecords: [PersonalRecord] = []

    // MARK: - Error Simulation

    var shouldThrowOnGet = false
    var shouldThrowOnSave = false
    var errorToThrow: Error?

    // MARK: - Progress Snapshots

    func getProgressSnapshots(from startDate: Date, to endDate: Date) async throws -> [ProgressSnapshot] {
        getProgressSnapshotsCallCount += 1
        lastStartDate = startDate
        lastEndDate = endDate
        if shouldThrowOnGet {
            throw errorToThrow ?? MockAnalyticsRepositoryError.fetchFailed
        }
        return mockProgressSnapshots.filter { $0.date >= startDate && $0.date <= endDate }
    }

    func getProgressSnapshot(id: UUID) async throws -> ProgressSnapshot? {
        if shouldThrowOnGet {
            throw errorToThrow ?? MockAnalyticsRepositoryError.fetchFailed
        }
        return mockProgressSnapshots.first { $0.id == id }
    }

    func getLatestProgressSnapshot() async throws -> ProgressSnapshot? {
        if shouldThrowOnGet {
            throw errorToThrow ?? MockAnalyticsRepositoryError.fetchFailed
        }
        return mockProgressSnapshots.sorted { $0.date > $1.date }.first
    }

    func saveProgressSnapshot(_ snapshot: ProgressSnapshot) async throws {
        saveProgressSnapshotCallCount += 1
        if shouldThrowOnSave {
            throw errorToThrow ?? MockAnalyticsRepositoryError.saveFailed
        }
        savedSnapshots.append(snapshot)
        mockProgressSnapshots.append(snapshot)
    }

    func deleteProgressSnapshot(id: UUID) async throws {
        if shouldThrowOnSave {
            throw errorToThrow ?? MockAnalyticsRepositoryError.deleteFailed
        }
        mockProgressSnapshots.removeAll { $0.id == id }
    }

    // MARK: - Volume Metrics

    func getVolumeMetrics(from startDate: Date, to endDate: Date) async throws -> [VolumeMetrics] {
        getVolumeMetricsCallCount += 1
        if shouldThrowOnGet {
            throw errorToThrow ?? MockAnalyticsRepositoryError.fetchFailed
        }
        return mockVolumeMetrics.filter { $0.weekStartDate >= startDate && $0.weekEndDate <= endDate }
    }

    func getVolumeMetrics(for weekStartDate: Date) async throws -> VolumeMetrics? {
        if shouldThrowOnGet {
            throw errorToThrow ?? MockAnalyticsRepositoryError.fetchFailed
        }
        let calendar = Calendar.current
        return mockVolumeMetrics.first { calendar.isDate($0.weekStartDate, inSameDayAs: weekStartDate) }
    }

    func saveVolumeMetrics(_ metrics: VolumeMetrics) async throws {
        saveVolumeMetricsCallCount += 1
        if shouldThrowOnSave {
            throw errorToThrow ?? MockAnalyticsRepositoryError.saveFailed
        }
        savedVolumeMetrics.append(metrics)
        mockVolumeMetrics.append(metrics)
    }

    // MARK: - Personal Records

    func getPersonalRecords() async throws -> [PersonalRecord] {
        getPersonalRecordsCallCount += 1
        if shouldThrowOnGet {
            throw errorToThrow ?? MockAnalyticsRepositoryError.fetchFailed
        }
        return mockPersonalRecords
    }

    func getPersonalRecords(for exerciseId: UUID) async throws -> [PersonalRecord] {
        if shouldThrowOnGet {
            throw errorToThrow ?? MockAnalyticsRepositoryError.fetchFailed
        }
        return mockPersonalRecords.filter { $0.exerciseId == exerciseId }
    }

    func getPersonalRecord(id: UUID) async throws -> PersonalRecord? {
        if shouldThrowOnGet {
            throw errorToThrow ?? MockAnalyticsRepositoryError.fetchFailed
        }
        return mockPersonalRecords.first { $0.id == id }
    }

    func savePersonalRecord(_ record: PersonalRecord) async throws {
        savePersonalRecordCallCount += 1
        if shouldThrowOnSave {
            throw errorToThrow ?? MockAnalyticsRepositoryError.saveFailed
        }
        savedPersonalRecords.append(record)
        mockPersonalRecords.append(record)
    }

    func deletePersonalRecord(id: UUID) async throws {
        if shouldThrowOnSave {
            throw errorToThrow ?? MockAnalyticsRepositoryError.deleteFailed
        }
        mockPersonalRecords.removeAll { $0.id == id }
    }

    // MARK: - Helper Methods

    func reset() {
        mockProgressSnapshots = []
        mockVolumeMetrics = []
        mockPersonalRecords = []
        getProgressSnapshotsCallCount = 0
        getVolumeMetricsCallCount = 0
        getPersonalRecordsCallCount = 0
        saveProgressSnapshotCallCount = 0
        saveVolumeMetricsCallCount = 0
        savePersonalRecordCallCount = 0
        lastStartDate = nil
        lastEndDate = nil
        savedSnapshots = []
        savedVolumeMetrics = []
        savedPersonalRecords = []
        shouldThrowOnGet = false
        shouldThrowOnSave = false
        errorToThrow = nil
    }

    // MARK: - Sample Data Generators

    static func createSampleProgressSnapshot(
        date: Date = Date(),
        bodyWeight: Double? = 75.0
    ) -> ProgressSnapshot {
        return ProgressSnapshot(
            id: UUID(),
            date: date,
            bodyWeight: bodyWeight,
            measurements: nil,
            photos: nil,
            notes: nil
        )
    }

    static func createSampleVolumeMetrics(
        weekStartDate: Date = Date(),
        totalVolume: Double = 10000,
        workoutCount: Int = 3
    ) -> VolumeMetrics {
        let calendar = Calendar.current
        let weekEndDate = calendar.date(byAdding: .day, value: 7, to: weekStartDate) ?? weekStartDate
        return VolumeMetrics(
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
            exerciseVolumes: [],
            totalVolume: totalVolume,
            avgIntensity: 70,
            workoutCount: workoutCount
        )
    }

    static func createSamplePersonalRecord(
        exerciseName: String = "Bench Press",
        value: Double = 100,
        recordType: PersonalRecordType = .oneRepMax
    ) -> PersonalRecord {
        return PersonalRecord(
            id: UUID(),
            exerciseId: UUID(),
            exerciseName: exerciseName,
            value: value,
            recordType: recordType,
            date: Date(),
            workoutId: UUID()
        )
    }
}

// MARK: - Mock Errors

enum MockAnalyticsRepositoryError: LocalizedError {
    case fetchFailed
    case saveFailed
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .fetchFailed: return "Mock: Failed to fetch analytics data"
        case .saveFailed: return "Mock: Failed to save analytics data"
        case .deleteFailed: return "Mock: Failed to delete analytics data"
        }
    }
}
