//
//  HealthDashboardViewModel.swift
//  VitalArc
//
//  ViewModel for Health Dashboard
//

import Foundation
import SwiftUI

@Observable
final class HealthDashboardViewModel {

    // MARK: - Properties

    private let healthRepository: HealthRepository

    var todayMetrics: HealthMetrics?
    var weekMetrics: [HealthMetrics] = []
    var isLoading = false
    var error: Error?
    var showingPermissionAlert = false

    // MARK: - Initialization

    init(healthRepository: HealthRepository) {
        self.healthRepository = healthRepository
    }

    // MARK: - Data Loading

    /// Load today's health metrics
    @MainActor
    func loadTodayMetrics() async {
        isLoading = true
        error = nil

        do {
            let today = Calendar.current.startOfDay(for: Date())
            todayMetrics = try await healthRepository.getHealthMetrics(for: today)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Load health metrics for the past week
    @MainActor
    func loadWeekMetrics() async {
        isLoading = true
        error = nil

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

        isLoading = false
    }

    /// Load all metrics (today + week)
    @MainActor
    func loadAllMetrics() async {
        await loadTodayMetrics()
        await loadWeekMetrics()
    }

    /// Refresh all metrics
    @MainActor
    func refresh() async {
        await syncFromHealthKit()
        await loadAllMetrics()
    }

    // MARK: - HealthKit Integration

    /// Request HealthKit permissions
    @MainActor
    func requestHealthKitPermissions() async {
        do {
            let authorized = try await healthRepository.requestHealthKitAuthorization()
            if authorized {
                await syncFromHealthKit()
                await loadAllMetrics()
            }
        } catch {
            self.error = error
            showingPermissionAlert = true
        }
    }

    /// Sync data from HealthKit
    @MainActor
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
