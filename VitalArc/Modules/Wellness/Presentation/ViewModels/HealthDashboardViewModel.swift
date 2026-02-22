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
    private let calculateSleepConsistency: CalculateSleepConsistencyUseCase
    private let calculateHealthScores: CalculateHealthScoresUseCase
    private let importHealthKitWorkoutsUseCase: ImportHealthKitWorkoutsUseCase?

    var todayMetrics: HealthMetrics?
    var weekMetrics: [HealthMetrics] = []
    var readinessScore: ReadinessScore?
    var readinessResult: ReadinessResult?
    var sleepConsistency: SleepConsistencyScore?
    var readinessConfiguration: ReadinessConfiguration = .default
    var isLoading = false
    var error: Error?
    var showingPermissionAlert = false
    var authorizationDenied = false

    // MARK: - HRV Tracking Properties

    var hrvBaseline: Double?
    var hrvDeviationSignificant = false
    var hrvTrendData7Day: [ChartDataPoint] = []
    var hrvTrendData30Day: [ChartDataPoint] = []
    var monthMetrics: [HealthMetrics] = []

    // MARK: - Initialization

    init(
        healthRepository: HealthRepository,
        calculateReadinessScore: CalculateReadinessScoreUseCaseProtocol = CalculateReadinessScoreUseCase(),
        calculateSleepConsistency: CalculateSleepConsistencyUseCase = CalculateSleepConsistencyUseCase(),
        calculateHealthScores: CalculateHealthScoresUseCase = CalculateHealthScoresUseCase(),
        importHealthKitWorkoutsUseCase: ImportHealthKitWorkoutsUseCase? = nil
    ) {
        self.healthRepository = healthRepository
        self.calculateReadinessScore = calculateReadinessScore
        self.calculateSleepConsistency = calculateSleepConsistency
        self.calculateHealthScores = calculateHealthScores
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

    /// Load health metrics for the past 30 days (for HRV baseline)
    func loadMonthMetrics() async {
        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            guard let monthAgo = calendar.date(byAdding: .day, value: -29, to: today) else { return }
            monthMetrics = try await healthRepository.getHealthMetrics(from: monthAgo, to: today)
        } catch {
            // Non-critical - don't set error
        }
    }

    /// Load all metrics (today + week + month) and compute readiness score + HRV data
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

            if let monthAgo = calendar.date(byAdding: .day, value: -29, to: today) {
                monthMetrics = try await healthRepository.getHealthMetrics(from: monthAgo, to: today)
            }
        } catch {
            self.error = error
        }

        updateReadinessScore()
        updateSleepConsistency()
        updateHRVData()
    }

    /// Compute readiness score from today's metrics and weekly baselines
    private func updateReadinessScore() {
        guard let today = todayMetrics else {
            readinessScore = nil
            readinessResult = nil
            return
        }

        // Legacy score (backward compatible)
        readinessScore = calculateReadinessScore.execute(todayMetrics: today, weekMetrics: weekMetrics)

        // V2 structured result with trend detection
        let historicalScores = weekMetrics.compactMap { metrics -> Double? in
            let score = calculateReadinessScore.execute(todayMetrics: metrics, weekMetrics: weekMetrics)
            return score.overallScore
        }
        readinessResult = calculateReadinessScore.executeV2(
            todayMetrics: today,
            weekMetrics: weekMetrics,
            historicalScores: historicalScores,
            configuration: readinessConfiguration
        )
    }

    /// Compute sleep consistency from week metrics
    private func updateSleepConsistency() {
        sleepConsistency = calculateSleepConsistency.execute(weekMetrics: weekMetrics)
    }

    /// Update HRV baseline and trend data
    private func updateHRVData() {
        // 30-day baseline
        let allHRVValues = monthMetrics.compactMap { $0.heartRateVariability }
        if !allHRVValues.isEmpty {
            hrvBaseline = allHRVValues.reduce(0, +) / Double(allHRVValues.count)
        } else {
            hrvBaseline = nil
        }

        // Deviation detection (>15% from baseline)
        if let baseline = hrvBaseline, let todayHRV = todayMetrics?.heartRateVariability, baseline > 0 {
            let deviationPercent = abs(todayHRV - baseline) / baseline * 100
            hrvDeviationSignificant = deviationPercent > 15
        } else {
            hrvDeviationSignificant = false
        }

        // 7-day trend chart data
        hrvTrendData7Day = weekMetrics.compactMap { metrics in
            guard let hrv = metrics.heartRateVariability else { return nil }
            return ChartDataPoint(date: metrics.date, value: hrv)
        }.sorted { $0.date < $1.date }

        // 30-day trend chart data
        hrvTrendData30Day = monthMetrics.compactMap { metrics in
            guard let hrv = metrics.heartRateVariability else { return nil }
            return ChartDataPoint(date: metrics.date, value: hrv)
        }.sorted { $0.date < $1.date }
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
                authorizationDenied = false
                await syncFromHealthKit()
                await importWorkoutsFromHealthKit()
                await loadAllMetrics()

                // If sync returned no data, the user may have denied access
                if todayMetrics == nil && weekMetrics.isEmpty {
                    authorizationDenied = true
                    showingPermissionAlert = true
                }
            }
        } catch {
            self.error = error
            authorizationDenied = true
            showingPermissionAlert = true
        }
    }

    /// Guide user to Settings to re-enable HealthKit access after denial
    func openHealthSettings() {
        if let url = URL(string: "x-apple-health://") {
            UIApplication.shared.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
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

    // MARK: - SpO2 Thresholds

    /// SpO2 below this threshold is considered abnormally low and warrants attention
    static let spo2WarningThreshold: Double = 95
    /// SpO2 below this threshold is critically low and needs immediate medical attention
    static let spo2CriticalThreshold: Double = 90

    /// Returns true if today's SpO2 reading is below the warning threshold
    var isSpO2Low: Bool {
        guard let spo2 = todayMetrics?.oxygenSaturation else { return false }
        return spo2 < Self.spo2WarningThreshold
    }

    /// Returns true if today's SpO2 reading is critically low
    var isSpO2Critical: Bool {
        guard let spo2 = todayMetrics?.oxygenSaturation else { return false }
        return spo2 < Self.spo2CriticalThreshold
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

    // MARK: - HRV Computed Properties

    /// Whether today's HRV is above baseline
    var isHRVAboveBaseline: Bool {
        guard let baseline = hrvBaseline, let todayHRV = todayMetrics?.heartRateVariability else { return false }
        return todayHRV > baseline
    }

    /// HRV status description
    var hrvStatusText: String {
        guard let baseline = hrvBaseline, let todayHRV = todayMetrics?.heartRateVariability else {
            return "No data"
        }
        let diff = todayHRV - baseline
        let percent = abs(diff / baseline * 100)
        if percent < 5 {
            return "At baseline"
        } else if diff > 0 {
            return String(format: "%.0f%% above baseline", percent)
        } else {
            return String(format: "%.0f%% below baseline", percent)
        }
    }

    // MARK: - Health Scores

    /// Sleep score computed from today's metrics via domain use case
    var sleepScore: HealthScore? {
        guard let today = todayMetrics else { return nil }
        return calculateHealthScores.calculateSleepScore(today)
    }

    /// Activity score computed from today's metrics via domain use case
    var activityScore: HealthScore? {
        guard let today = todayMetrics else { return nil }
        return calculateHealthScores.calculateActivityScore(today)
    }

    /// Correlation hint between HRV and sleep
    var hrvSleepCorrelationHint: String? {
        guard weekMetrics.count >= 3 else { return nil }
        let paired = weekMetrics.compactMap { m -> (Double, Double)? in
            guard let hrv = m.heartRateVariability, let sleep = m.sleepHours else { return nil }
            return (hrv, sleep)
        }
        guard paired.count >= 3 else { return nil }

        // Simple correlation direction check
        let highSleepHRV = paired.filter { $0.1 >= 7 }.map { $0.0 }
        let lowSleepHRV = paired.filter { $0.1 < 7 }.map { $0.0 }

        guard !highSleepHRV.isEmpty, !lowSleepHRV.isEmpty else { return nil }

        let avgHighSleep = highSleepHRV.reduce(0, +) / Double(highSleepHRV.count)
        let avgLowSleep = lowSleepHRV.reduce(0, +) / Double(lowSleepHRV.count)

        if avgHighSleep > avgLowSleep * 1.1 {
            return "Your HRV tends to be higher on nights with 7+ hours of sleep."
        }
        return nil
    }
}
