//
//  CalculateHealthScoresUseCase.swift
//  VitalArc
//
//  Calculates sleep and activity scores from health metrics.
//  Extracted from HealthDashboardView for testability and reuse.
//

import Foundation

struct HealthScore {
    let value: Double // 0-100
    let label: String
}

struct CalculateHealthScoresUseCase {

    // MARK: - Sleep Score

    func calculateSleepScore(_ metrics: HealthMetrics) -> HealthScore {
        let score = sleepScoreValue(metrics)
        return HealthScore(value: score, label: sleepLabel(score))
    }

    // MARK: - Activity Score

    func calculateActivityScore(_ metrics: HealthMetrics) -> HealthScore {
        let score = activityScoreValue(metrics)
        return HealthScore(value: score, label: activityLabel(score))
    }

    // MARK: - Private Calculations

    private func sleepScoreValue(_ metrics: HealthMetrics) -> Double {
        guard let sleepHours = metrics.sleepHours else { return 0 }
        if sleepHours >= 7 && sleepHours <= 9 {
            return min(100, 80 + (sleepHours - 7) * 10)
        } else if sleepHours < 7 {
            return max(0, (sleepHours / 7) * 80)
        } else {
            return max(70, 90 - (sleepHours - 9) * 10)
        }
    }

    private func activityScoreValue(_ metrics: HealthMetrics) -> Double {
        var score: Double = 0

        if let steps = metrics.steps {
            score += min(Double(steps) / 10000 * 50, 50)
        }

        if let energy = metrics.activeEnergy {
            score += min(energy / 500 * 50, 50)
        }

        return min(score, 100)
    }

    private func sleepLabel(_ score: Double) -> String {
        switch score {
        case 0..<50: return "Poor"
        case 50..<70: return "Fair"
        case 70..<85: return "Good"
        default: return "Excellent"
        }
    }

    private func activityLabel(_ score: Double) -> String {
        switch score {
        case 0..<30: return "Low"
        case 30..<50: return "Light"
        case 50..<70: return "Moderate"
        case 70..<85: return "Active"
        default: return "High"
        }
    }
}
