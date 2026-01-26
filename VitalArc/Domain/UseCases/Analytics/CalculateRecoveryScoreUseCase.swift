//
//  CalculateRecoveryScoreUseCase.swift
//  VitalArc
//
//  Calculates a recovery score based on HRV, resting heart rate, and sleep data
//  Uses a Whoop/Oura-style algorithm with weighted factors
//

import Foundation

/// Result containing recovery score and contributing factors
struct RecoveryScoreResult {
    let score: Int
    let hrvScore: Double?
    let hrScore: Double?
    let sleepScore: Double?
    let readiness: RecoveryReadiness
    let recommendation: String
    let breakdown: RecoveryBreakdown

    enum RecoveryReadiness: String {
        case optimal = "Optimal"
        case good = "Good"
        case moderate = "Moderate"
        case low = "Low"
        case veryLow = "Very Low"

        init(score: Int) {
            switch score {
            case 85...100: self = .optimal
            case 70..<85: self = .good
            case 50..<70: self = .moderate
            case 30..<50: self = .low
            default: self = .veryLow
            }
        }
    }

    struct RecoveryBreakdown {
        let hrvContribution: Double  // 0-50 points
        let hrContribution: Double   // 0-30 points
        let sleepContribution: Double // 0-20 points
    }
}

@MainActor
final class CalculateRecoveryScoreUseCase {
    private let healthRepository: HealthRepository

    /// Weights for each factor in the recovery score
    private let hrvWeight: Double = 0.50  // HRV is the primary indicator
    private let hrWeight: Double = 0.30   // Resting HR is secondary
    private let sleepWeight: Double = 0.20 // Sleep quality/duration

    /// Number of days to use for baseline calculation
    private let baselineDays: Int = 60

    init(healthRepository: HealthRepository) {
        self.healthRepository = healthRepository
    }

    /// Calculate recovery score for today based on recent health data
    func execute() async throws -> RecoveryScoreResult {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -baselineDays, to: today) ?? today

        // Fetch health metrics for baseline period
        let metrics = try await healthRepository.getHealthMetrics(from: startDate, to: today)

        guard !metrics.isEmpty else {
            return createDefaultResult(message: "Not enough health data available")
        }

        // Get today's metrics (or most recent)
        let todayMetrics = metrics.last

        // Calculate baselines from historical data
        let hrvBaseline = calculateHRVBaseline(metrics: metrics)
        let hrBaseline = calculateHRBaseline(metrics: metrics)
        let sleepBaseline = calculateSleepBaseline(metrics: metrics)

        // Calculate individual scores
        let hrvScore = calculateHRVScore(
            todayHRV: todayMetrics?.heartRateVariability,
            baseline: hrvBaseline
        )

        let hrScore = calculateHRScore(
            todayHR: todayMetrics?.restingHeartRate,
            baseline: hrBaseline
        )

        let sleepScore = calculateSleepScore(
            todaySleep: todayMetrics?.sleepHours,
            baseline: sleepBaseline
        )

        // Calculate weighted recovery score
        let (finalScore, breakdown) = calculateFinalScore(
            hrvScore: hrvScore,
            hrScore: hrScore,
            sleepScore: sleepScore
        )

        let readiness = RecoveryScoreResult.RecoveryReadiness(score: finalScore)
        let recommendation = generateRecommendation(readiness: readiness, breakdown: breakdown)

        return RecoveryScoreResult(
            score: finalScore,
            hrvScore: hrvScore,
            hrScore: hrScore,
            sleepScore: sleepScore,
            readiness: readiness,
            recommendation: recommendation,
            breakdown: breakdown
        )
    }

    // MARK: - Baseline Calculations

    private func calculateHRVBaseline(metrics: [HealthMetrics]) -> Double? {
        let hrvValues = metrics.compactMap { $0.heartRateVariability }
        guard !hrvValues.isEmpty else { return nil }

        // Use median for more robust baseline (less affected by outliers)
        let sorted = hrvValues.sorted()
        let middle = sorted.count / 2

        if sorted.count % 2 == 0 {
            return (sorted[middle - 1] + sorted[middle]) / 2
        } else {
            return sorted[middle]
        }
    }

    private func calculateHRBaseline(metrics: [HealthMetrics]) -> Double? {
        let hrValues = metrics.compactMap { $0.restingHeartRate }
        guard !hrValues.isEmpty else { return nil }

        // Use median for baseline
        let sorted = hrValues.sorted()
        let middle = sorted.count / 2

        if sorted.count % 2 == 0 {
            return (sorted[middle - 1] + sorted[middle]) / 2
        } else {
            return sorted[middle]
        }
    }

    private func calculateSleepBaseline(metrics: [HealthMetrics]) -> Double {
        let sleepValues = metrics.compactMap { $0.sleepHours }
        guard !sleepValues.isEmpty else { return 8.0 } // Default 8 hours

        return sleepValues.reduce(0, +) / Double(sleepValues.count)
    }

    // MARK: - Individual Score Calculations

    private func calculateHRVScore(todayHRV: Double?, baseline: Double?) -> Double? {
        guard let hrv = todayHRV, let base = baseline, base > 0 else {
            return nil
        }

        // HRV score is based on deviation from baseline
        // Higher HRV than baseline = better recovery
        let ratio = hrv / base

        // Score mapping:
        // ratio >= 1.1  = 100 (10%+ above baseline)
        // ratio == 1.0  = 70 (at baseline)
        // ratio == 0.9  = 50 (10% below baseline)
        // ratio <= 0.7  = 0 (30%+ below baseline)

        if ratio >= 1.1 {
            return 100
        } else if ratio >= 1.0 {
            // Linear interpolation from 70-100 for ratios 1.0-1.1
            return 70 + (ratio - 1.0) * 300
        } else if ratio >= 0.7 {
            // Linear interpolation from 0-70 for ratios 0.7-1.0
            return (ratio - 0.7) * (70 / 0.3)
        } else {
            return 0
        }
    }

    private func calculateHRScore(todayHR: Double?, baseline: Double?) -> Double? {
        guard let hr = todayHR, let base = baseline, base > 0 else {
            return nil
        }

        // Lower resting HR than baseline = better recovery
        // Inverse of HRV logic
        let ratio = base / hr  // Note: inverted

        // Score mapping:
        // ratio >= 1.05 = 100 (HR 5%+ below baseline)
        // ratio == 1.0  = 70 (at baseline)
        // ratio == 0.95 = 50 (HR 5% above baseline)
        // ratio <= 0.85 = 0 (HR 15%+ above baseline)

        if ratio >= 1.05 {
            return 100
        } else if ratio >= 1.0 {
            return 70 + (ratio - 1.0) * 600
        } else if ratio >= 0.85 {
            return (ratio - 0.85) * (70 / 0.15)
        } else {
            return 0
        }
    }

    private func calculateSleepScore(todaySleep: Double?, baseline: Double) -> Double? {
        guard let sleep = todaySleep else { return nil }

        // Score based on sleep duration vs target (8 hours or baseline)
        let target = max(baseline, 7.0) // Minimum 7 hours target
        let ratio = sleep / target

        // Score mapping:
        // ratio >= 1.0  = 100 (met or exceeded target)
        // ratio == 0.875 = 70 (7/8 hours = 87.5%)
        // ratio == 0.75  = 50 (6/8 hours)
        // ratio <= 0.5   = 0 (4/8 hours or less)

        if ratio >= 1.0 {
            return 100
        } else if ratio >= 0.5 {
            // Linear interpolation from 0-100 for ratios 0.5-1.0
            return (ratio - 0.5) * 200
        } else {
            return 0
        }
    }

    // MARK: - Final Score Calculation

    private func calculateFinalScore(
        hrvScore: Double?,
        hrScore: Double?,
        sleepScore: Double?
    ) -> (Int, RecoveryScoreResult.RecoveryBreakdown) {

        var totalWeight: Double = 0
        var weightedSum: Double = 0

        var hrvContribution: Double = 0
        var hrContribution: Double = 0
        var sleepContribution: Double = 0

        // HRV contribution (up to 50 points)
        if let hrv = hrvScore {
            let contribution = hrv * hrvWeight
            weightedSum += contribution
            totalWeight += hrvWeight
            hrvContribution = (hrv / 100) * 50 // Scale to max 50 points
        }

        // HR contribution (up to 30 points)
        if let hr = hrScore {
            let contribution = hr * hrWeight
            weightedSum += contribution
            totalWeight += hrWeight
            hrContribution = (hr / 100) * 30 // Scale to max 30 points
        }

        // Sleep contribution (up to 20 points)
        if let sleep = sleepScore {
            let contribution = sleep * sleepWeight
            weightedSum += contribution
            totalWeight += sleepWeight
            sleepContribution = (sleep / 100) * 20 // Scale to max 20 points
        }

        let breakdown = RecoveryScoreResult.RecoveryBreakdown(
            hrvContribution: hrvContribution,
            hrContribution: hrContribution,
            sleepContribution: sleepContribution
        )

        // If no data, return 0
        guard totalWeight > 0 else {
            return (0, breakdown)
        }

        // Normalize the score based on available weights
        let normalizedScore = weightedSum / totalWeight

        return (Int(normalizedScore.rounded()), breakdown)
    }

    // MARK: - Recommendations

    private func generateRecommendation(
        readiness: RecoveryScoreResult.RecoveryReadiness,
        breakdown: RecoveryScoreResult.RecoveryBreakdown
    ) -> String {
        switch readiness {
        case .optimal:
            return "Your body is fully recovered. Great day for high-intensity training or competition."
        case .good:
            return "Good recovery. You can train normally. Consider moderate to high intensity."
        case .moderate:
            if breakdown.sleepContribution < 10 {
                return "Recovery affected by sleep. Consider lighter training and prioritize rest tonight."
            } else if breakdown.hrvContribution < 25 {
                return "HRV below baseline suggests accumulated stress. Consider a moderate workout."
            }
            return "Moderate recovery. Listen to your body and adjust intensity as needed."
        case .low:
            return "Recovery is low. Consider active recovery, mobility work, or a rest day."
        case .veryLow:
            return "Your body needs rest. Take a recovery day and focus on sleep and nutrition."
        }
    }

    private func createDefaultResult(message: String) -> RecoveryScoreResult {
        return RecoveryScoreResult(
            score: 0,
            hrvScore: nil,
            hrScore: nil,
            sleepScore: nil,
            readiness: .veryLow,
            recommendation: message,
            breakdown: RecoveryScoreResult.RecoveryBreakdown(
                hrvContribution: 0,
                hrContribution: 0,
                sleepContribution: 0
            )
        )
    }
}
