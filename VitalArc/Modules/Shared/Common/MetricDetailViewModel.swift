//
//  MetricDetailViewModel.swift
//  VitalArc
//
//  ViewModel for loading metric history data for drill-down sheets
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class MetricDetailViewModel {

    // MARK: - Types

    enum DateRange: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
        case threeMonths = "90 Days"

        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            }
        }
    }

    // MARK: - Dependencies

    private let healthRepository: HealthRepository

    // MARK: - State

    var historyData: [ChartDataPoint] = []
    var isLoading = false
    var error: Error?

    // Summary statistics
    var average: Double?
    var minimum: Double?
    var maximum: Double?
    var trend: TrendDirection?

    // MARK: - Initialization

    init(healthRepository: HealthRepository) {
        self.healthRepository = healthRepository
    }

    // MARK: - Data Loading

    func loadHistory(for type: HealthMetricType, range: DateRange) async {
        isLoading = true
        error = nil

        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            guard let startDate = calendar.date(byAdding: .day, value: -(range.days - 1), to: today) else {
                isLoading = false
                return
            }

            let metrics = try await healthRepository.getHealthMetrics(from: startDate, to: today)

            // Extract the relevant metric values
            let dataPoints: [ChartDataPoint] = metrics.compactMap { metric in
                guard let value = extractValue(from: metric, for: type) else { return nil }
                return ChartDataPoint(date: metric.date, value: value)
            }

            historyData = dataPoints.sorted { $0.date < $1.date }

            // Calculate statistics
            let values = historyData.map { $0.value }
            if !values.isEmpty {
                average = values.reduce(0, +) / Double(values.count)
                minimum = values.min()
                maximum = values.max()
                trend = calculateTrend(values)
            } else {
                average = nil
                minimum = nil
                maximum = nil
                trend = nil
            }

        } catch {
            self.error = error
        }

        isLoading = false
    }

    // MARK: - Helpers

    private func extractValue(from metrics: HealthMetrics, for type: HealthMetricType) -> Double? {
        switch type {
        case .hrv:
            return metrics.heartRateVariability
        case .restingHR:
            return metrics.restingHeartRate
        case .steps:
            return metrics.steps.map { Double($0) }
        case .activeEnergy:
            return metrics.activeEnergy
        case .sleep:
            return metrics.sleepHours
        case .weight:
            return metrics.weight.map { UnitConversion.kgToLbs($0) }
        case .bodyFat:
            return metrics.bodyFatPercentage
        case .leanBodyMass:
            return metrics.leanBodyMass.map { UnitConversion.kgToLbs($0) }
        case .respiratoryRate:
            return metrics.respiratoryRate
        case .spo2:
            return metrics.oxygenSaturation
        case .vo2Max:
            return metrics.vo2Max
        }
    }

    private func calculateTrend(_ values: [Double]) -> TrendDirection? {
        guard values.count >= 2 else { return nil }

        // Compare first half average to second half average
        let midpoint = values.count / 2
        let firstHalf = Array(values.prefix(midpoint))
        let secondHalf = Array(values.suffix(values.count - midpoint))

        guard !firstHalf.isEmpty, !secondHalf.isEmpty else { return nil }

        let firstAvg = firstHalf.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0, +) / Double(secondHalf.count)

        // Guard against divide-by-zero when firstAvg is 0
        guard firstAvg.isFinite, firstAvg != 0 else {
            // If first half is zero but second half has values, trending up
            if secondAvg > 0 { return .up }
            return .stable
        }

        let percentChange = (secondAvg - firstAvg) / firstAvg * 100

        guard percentChange.isFinite else { return .stable }

        if percentChange > 5 {
            return .up
        } else if percentChange < -5 {
            return .down
        } else {
            return .stable
        }
    }
}
