//
//  MockHealthRepository.swift
//  VitalArcTests
//
//  Mock implementation of HealthRepository for testing
//

import Foundation
@testable import VitalArc

/// Mock HealthRepository for unit testing
class MockHealthRepository: HealthRepository {
    // MARK: - Mock Data

    var mockTodayMetrics: HealthMetrics?
    var mockWeekMetrics: [HealthMetrics] = []
    var mockAuthorizationSuccess = false

    // MARK: - Call Tracking

    var getHealthMetricsForDateCallCount = 0
    var getHealthMetricsForRangeCallCount = 0
    var saveHealthMetricsCallCount = 0
    var syncFromHealthKitCallCount = 0
    var requestAuthorizationCallCount = 0
    var authorizationRequested = false
    var syncRequested = false

    // MARK: - Captured Parameters

    var lastSavedMetrics: HealthMetrics?
    var lastRequestedDate: Date?
    var lastRequestedStartDate: Date?
    var lastRequestedEndDate: Date?

    // MARK: - Error Simulation

    var shouldThrowOnGetMetrics = false
    var shouldThrowOnSave = false
    var shouldThrowOnSync = false
    var shouldThrowOnAuthorization = false
    var errorToThrow: Error?

    // MARK: - HealthRepository Protocol

    func getHealthMetrics(for date: Date) async throws -> HealthMetrics? {
        getHealthMetricsForDateCallCount += 1
        lastRequestedDate = date
        if shouldThrowOnGetMetrics {
            throw errorToThrow ?? MockHealthRepositoryError.fetchFailed
        }
        return mockTodayMetrics
    }

    func getHealthMetrics(from startDate: Date, to endDate: Date) async throws -> [HealthMetrics] {
        getHealthMetricsForRangeCallCount += 1
        lastRequestedStartDate = startDate
        lastRequestedEndDate = endDate
        if shouldThrowOnGetMetrics {
            throw errorToThrow ?? MockHealthRepositoryError.fetchFailed
        }
        return mockWeekMetrics
    }

    func saveHealthMetrics(_ metrics: HealthMetrics) async throws {
        saveHealthMetricsCallCount += 1
        lastSavedMetrics = metrics
        if shouldThrowOnSave {
            throw errorToThrow ?? MockHealthRepositoryError.saveFailed
        }
    }

    func syncFromHealthKit() async throws {
        syncFromHealthKitCallCount += 1
        syncRequested = true
        if shouldThrowOnSync {
            throw errorToThrow ?? MockHealthRepositoryError.syncFailed
        }
    }

    func requestHealthKitAuthorization() async throws -> Bool {
        requestAuthorizationCallCount += 1
        authorizationRequested = true
        if shouldThrowOnAuthorization {
            throw errorToThrow ?? MockHealthRepositoryError.authorizationFailed
        }
        return mockAuthorizationSuccess
    }

    // MARK: - Helper Methods

    func reset() {
        mockTodayMetrics = nil
        mockWeekMetrics = []
        mockAuthorizationSuccess = false
        getHealthMetricsForDateCallCount = 0
        getHealthMetricsForRangeCallCount = 0
        saveHealthMetricsCallCount = 0
        syncFromHealthKitCallCount = 0
        requestAuthorizationCallCount = 0
        authorizationRequested = false
        syncRequested = false
        lastSavedMetrics = nil
        lastRequestedDate = nil
        lastRequestedStartDate = nil
        lastRequestedEndDate = nil
        shouldThrowOnGetMetrics = false
        shouldThrowOnSave = false
        shouldThrowOnSync = false
        shouldThrowOnAuthorization = false
        errorToThrow = nil
    }

    /// Create sample metrics for testing
    static func createSampleMetrics(
        date: Date = Date(),
        hrv: Double = 75.0,
        rhr: Double = 65.0,
        energy: Double = 450.0,
        steps: Int = 10000,
        sleep: Double = 7.5,
        weight: Double = 75.0
    ) -> HealthMetrics {
        return HealthMetrics(
            date: date,
            heartRateVariability: hrv,
            restingHeartRate: rhr,
            activeEnergy: energy,
            steps: steps,
            sleepHours: sleep,
            weight: weight
        )
    }

    /// Generate a week of sample metrics
    static func createWeekMetrics(startingFrom date: Date = Date()) -> [HealthMetrics] {
        return (0..<7).map { day -> HealthMetrics in
            let metricsDate = Calendar.current.date(byAdding: .day, value: -day, to: date) ?? date
            let hrv = 70.0 + Double(day)
            let rhr = 60.0 + Double(day)
            let energy = 400.0 + Double(day) * 50.0
            let stepsCount = 8000 + day * 500
            let sleep = 7.0 + Double(day) * 0.1
            return HealthMetrics(
                date: metricsDate,
                heartRateVariability: hrv,
                restingHeartRate: rhr,
                activeEnergy: energy,
                steps: stepsCount,
                sleepHours: sleep,
                weight: 75.0
            )
        }
    }
}

// MARK: - Mock Errors

enum MockHealthRepositoryError: LocalizedError {
    case fetchFailed
    case saveFailed
    case syncFailed
    case authorizationFailed

    var errorDescription: String? {
        switch self {
        case .fetchFailed: return "Mock: Failed to fetch health metrics"
        case .saveFailed: return "Mock: Failed to save health metrics"
        case .syncFailed: return "Mock: Failed to sync from HealthKit"
        case .authorizationFailed: return "Mock: HealthKit authorization failed"
        }
    }
}
