//
//  HealthDashboardViewModel.swift
//  VitalArc
//
//  ViewModel for Health Dashboard
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class HealthDashboardViewModel {

    // MARK: - Properties

    private let healthRepository: HealthRepository
    private let calculateReadinessScore: CalculateReadinessScoreUseCaseProtocol
    private let importHealthKitWorkoutsUseCase: ImportHealthKitWorkoutsUseCase?

    var todayMetrics: HealthMetrics?
    var weekMetrics: [HealthMetrics] = []
    var readinessScore: ReadinessScore?
    var isLoading = false
    var error: Error?
    var showingPermissionAlert = false

    // MARK: - Initialization

    init(
        healthRepository: HealthRepository,
        calculateReadinessScore: CalculateReadinessScoreUseCaseProtocol = CalculateReadinessScoreUseCase(),
        importHealthKitWorkoutsUseCase: ImportHealthKitWorkoutsUseCase? = nil
    ) {
        self.healthRepository = healthRepository
        self.calculateReadinessScore = calculateReadinessScore
        self.importHealthKitWorkoutsUseCase = importHealthKitWorkoutsUseCase
    }

    // MARK: - Data Loading

    /// Load today's health metrics
    func loadTodayMetrics() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let today = Calendar.current.startOfDay(for: Date())
            todayMetrics = try await healthRepository.getHealthMetrics(for: today)
        } catch {
            self.error = error
        }
    }

    /// Load health metrics for the past week
    func loadWeekMetrics() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            guard let weekAgo = calendar.date(byAdding: .day, value: -6, to: today) else {
                return
            }

            weekMetrics = try await healthRepository.getHealthMetrics(from: weekAgo, to: today)
        } catch {
            self.error = error
        }
    }

    /// Load all metrics (today + week) and compute readiness score
    func loadAllMetrics() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            todayMetrics = try await healthRepository.getHealthMetrics(for: today)

            if let weekAgo = calendar.date(byAdding: .day, value: -6, to: today) {
                weekMetrics = try await healthRepository.getHealthMetrics(from: weekAgo, to: today)
            }
        } catch {
            self.error = error
        }

        updateReadinessScore()
    }

    /// Compute readiness score from today's metrics and weekly baselines
    private func updateReadinessScore() {
        guard let today = todayMetrics else {
            readinessScore = nil
            return
        }
        readinessScore = calculateReadinessScore.execute(todayMetrics: today, weekMetrics: weekMetrics)
    }

    /// Refresh all metrics and import new workouts
    func refresh() async {
        await syncFromHealthKit()
        await importWorkoutsFromHealthKit()
        await loadAllMetrics()
    }

    // MARK: - HealthKit Integration

    /// Request HealthKit permissions
    func requestHealthKitPermissions() async {
        do {
            let authorized = try await healthRepository.requestHealthKitAuthorization()
            if authorized {
                await syncFromHealthKit()
                await importWorkoutsFromHealthKit()
                await loadAllMetrics()
            }
        } catch {
            self.error = error
            showingPermissionAlert = true
        }
    }

    /// Import historical workouts from HealthKit (last 3 months)
    private func importWorkoutsFromHealthKit() async {
        guard let importUseCase = importHealthKitWorkoutsUseCase else { return }
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now.addingTimeInterval(-90 * 86400)
        do {
            _ = try await importUseCase.execute(from: startDate, to: now)
        } catch {
            Log.error("Failed to import workouts from HealthKit", error: error, category: .data)
        }
    }

    /// Sync data from HealthKit
    func syncFromHealthKit() async {
        isLoading = true
        error = nil

        do {
            try await healthRepository.syncFromHealthKit()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    // MARK: - Computed Properties

    /// Average HRV for the week
    var averageHRV: Double? {
        let values = weekMetrics.compactMap { $0.heartRateVariability }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    /// Average resting heart rate for the week
    var averageHeartRate: Double? {
        let values = weekMetrics.compactMap { $0.restingHeartRate }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    /// Total steps for the week
    var totalSteps: Int {
        weekMetrics.compactMap { $0.steps }.reduce(0, +)
    }

    /// Average daily steps
    var averageSteps: Int? {
        let values = weekMetrics.compactMap { $0.steps }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / values.count
    }

    /// Total active energy for the week
    var totalActiveEnergy: Double {
        weekMetrics.compactMap { $0.activeEnergy }.reduce(0, +)
    }

    /// Average sleep hours
    var averageSleepHours: Double? {
        let values = weekMetrics.compactMap { $0.sleepHours }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }
}
