//
//  MockAnalyticsUseCases.swift
//  VitalArcTests
//
//  Mock implementations of analytics use cases for testing
//

import Foundation
@testable import VitalArc

// MARK: - MockCalculateVolumeUseCase

/// Mock for CalculateVolumeUseCase
final class MockCalculateVolumeUseCase {
    var mockVolumeMetrics: VolumeMetrics?
    var mockWeeklyMetrics: [VolumeMetrics] = []
    var executeCallCount = 0
    var executeForWeeksCallCount = 0
    var shouldThrow = false
    var errorToThrow: Error?

    func execute(startDate: Date, endDate: Date) async throws -> VolumeMetrics {
        executeCallCount += 1
        if shouldThrow {
            throw errorToThrow ?? MockUseCaseError.executionFailed
        }
        return mockVolumeMetrics ?? VolumeMetrics(
            weekStartDate: startDate,
            weekEndDate: endDate,
            exerciseVolumes: [],
            totalVolume: 0,
            avgIntensity: 0,
            workoutCount: 0
        )
    }

    func executeForWeek(date: Date) async throws -> VolumeMetrics {
        return try await execute(startDate: date, endDate: date)
    }

    func executeForWeeks(_ weeks: Int) async throws -> [VolumeMetrics] {
        executeForWeeksCallCount += 1
        if shouldThrow {
            throw errorToThrow ?? MockUseCaseError.executionFailed
        }
        if !mockWeeklyMetrics.isEmpty {
            return mockWeeklyMetrics
        }
        // Generate sample metrics
        let calendar = Calendar.current
        return (0..<weeks).map { offset in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: Date()) ?? Date()
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
            return VolumeMetrics(
                weekStartDate: weekStart,
                weekEndDate: weekEnd,
                exerciseVolumes: [],
                totalVolume: Double(1000 * (weeks - offset)),
                avgIntensity: 70,
                workoutCount: 3
            )
        }.reversed()
    }
}

// MARK: - MockTrackProgressiveOverloadUseCase

/// Mock for TrackProgressiveOverloadUseCase
final class MockTrackProgressiveOverloadUseCase {
    var mockResult: ProgressiveOverloadData?
    var executeCallCount = 0
    var shouldThrow = false

    func execute(exerciseId: UUID, weeks: Int = 12) async throws -> ProgressiveOverloadData {
        executeCallCount += 1
        if shouldThrow {
            throw MockUseCaseError.executionFailed
        }
        return mockResult ?? ProgressiveOverloadData(
            isProgressing: true,
            weeklyVolumeChange: 5.0,
            recommendations: ["Keep up the good work"],
            needsDeload: false,
            volumeHistory: []
        )
    }
}

// MARK: - MockGenerateProgressReportUseCase

/// Mock for GenerateProgressReportUseCase
final class MockGenerateProgressReportUseCase {
    var mockReport: ProgressReport?
    var executeCallCount = 0
    var shouldThrow = false
    var lastStartDate: Date?
    var lastEndDate: Date?

    func execute(startDate: Date, endDate: Date) async throws -> ProgressReport {
        executeCallCount += 1
        lastStartDate = startDate
        lastEndDate = endDate
        if shouldThrow {
            throw MockUseCaseError.executionFailed
        }
        return mockReport ?? createDefaultReport(startDate: startDate, endDate: endDate)
    }

    private func createDefaultReport(startDate: Date, endDate: Date) -> ProgressReport {
        return ProgressReport(
            period: DateInterval(start: startDate, end: endDate),
            bodyWeightChange: 0.5,
            volumeChange: 10.0,
            recordsBroken: [],
            workoutConsistency: 75.0,
            avgCalorieAdherence: 85.0,
            avgSleepHours: 7.5,
            avgHRV: 65.0
        )
    }
}

// MARK: - MockCalculateRecoveryScoreUseCase

/// Mock for CalculateRecoveryScoreUseCase
@MainActor
final class MockCalculateRecoveryScoreUseCase {
    var mockResult: RecoveryScoreResult?
    var executeCallCount = 0
    var shouldThrow = false

    func execute() async throws -> RecoveryScoreResult {
        executeCallCount += 1
        if shouldThrow {
            throw MockUseCaseError.executionFailed
        }
        return mockResult ?? createDefaultResult()
    }

    private func createDefaultResult() -> RecoveryScoreResult {
        return RecoveryScoreResult(
            score: 75,
            hrvScore: 80.0,
            hrScore: 70.0,
            sleepScore: 75.0,
            readiness: .good,
            recommendation: "Good recovery. You can train normally.",
            breakdown: RecoveryScoreResult.RecoveryBreakdown(
                hrvContribution: 40,
                hrContribution: 21,
                sleepContribution: 15
            )
        )
    }
}

// MARK: - MockCalculateStrainScoreUseCase

/// Mock for CalculateStrainScoreUseCase
@MainActor
final class MockCalculateStrainScoreUseCase {
    var mockResult: StrainResult?
    var executeDailyStrainCallCount = 0
    var executeForDateCallCount = 0
    var shouldThrow = false
    var lastRequestedDate: Date?

    func executeDailyStrain() async throws -> Double {
        executeDailyStrainCallCount += 1
        if shouldThrow {
            throw MockUseCaseError.executionFailed
        }
        return mockResult?.strainScore ?? 12.5
    }

    func execute(for date: Date) async throws -> StrainResult? {
        executeForDateCallCount += 1
        lastRequestedDate = date
        if shouldThrow {
            throw MockUseCaseError.executionFailed
        }
        return mockResult ?? createDefaultResult(for: date)
    }

    func execute(for workouts: [WorkoutData], on date: Date) async throws -> StrainResult? {
        return try await execute(for: date)
    }

    func executeForDateRange(from startDate: Date, to endDate: Date) async throws -> [StrainResult] {
        if shouldThrow {
            throw MockUseCaseError.executionFailed
        }
        return []
    }

    private func createDefaultResult(for date: Date) -> StrainResult {
        return StrainResult(
            date: date,
            trimpScore: 150,
            strainScore: 12.5,
            duration: 3600,
            averageHeartRate: 140,
            maxHeartRate: 175,
            heartRateReserve: 65,
            workoutCount: 1,
            calculationMethod: .banister
        )
    }
}

// MARK: - Mock Error

enum MockUseCaseError: LocalizedError {
    case executionFailed

    var errorDescription: String? {
        return "Mock use case execution failed"
    }
}
