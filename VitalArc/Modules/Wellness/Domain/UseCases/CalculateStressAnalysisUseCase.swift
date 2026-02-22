//
//  CalculateStressAnalysisUseCase.swift
//  VitalArc
//
//  Analyzes HRV readings to determine stress levels and provide insights.
//  Separates daytime vs sleep HRV for more accurate stress detection.
//

import Foundation

struct CalculateStressAnalysisUseCase {

    /// Analyze HRV readings to produce a stress analysis for a given date.
    ///
    /// - Parameters:
    ///   - readings: All HRV readings for the day, tagged with context (daytime/sleep)
    ///   - baseline: 30-day average HRV for comparison
    ///   - date: The date being analyzed
    func execute(readings: [HRVReading], baseline: Double?, date: Date) -> StressAnalysis {
        let daytimeReadings = readings.filter { $0.context == .daytime }
        let sleepReadings = readings.filter { $0.context == .sleep }

        let daytimeHRV = average(daytimeReadings.map(\.value))
        let sleepHRV = average(sleepReadings.map(\.value))
        let overallHRV = average(readings.map(\.value))

        let cv = coefficientOfVariation(readings.map(\.value))

        let stressLevel = determineStressLevel(
            daytimeHRV: daytimeHRV,
            sleepHRV: sleepHRV,
            overallHRV: overallHRV,
            baseline: baseline,
            cv: cv
        )

        let insight = generateInsight(
            stressLevel: stressLevel,
            daytimeHRV: daytimeHRV,
            sleepHRV: sleepHRV,
            baseline: baseline,
            cv: cv
        )

        return StressAnalysis(
            date: date,
            daytimeHRV: daytimeHRV,
            sleepHRV: sleepHRV,
            overallHRV: overallHRV,
            stressLevel: stressLevel,
            hrvCoefficientOfVariation: cv,
            daytimeReadingCount: daytimeReadings.count,
            sleepReadingCount: sleepReadings.count,
            insight: insight
        )
    }

    // MARK: - Private Helpers

    private func average(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private func coefficientOfVariation(_ values: [Double]) -> Double? {
        guard values.count >= 2 else { return nil }
        let mean = values.reduce(0, +) / Double(values.count)
        guard mean > 0 else { return nil }
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        let stdDev = sqrt(variance)
        return (stdDev / mean) * 100
    }

    private func determineStressLevel(
        daytimeHRV: Double?,
        sleepHRV: Double?,
        overallHRV: Double?,
        baseline: Double?,
        cv: Double?
    ) -> StressLevel {
        guard let overall = overallHRV else { return .low }

        var stressScore: Double = 0

        // Factor 1: Overall HRV vs baseline (lower = more stress)
        if let baseline = baseline, baseline > 0 {
            let ratio = overall / baseline
            if ratio < 0.7 { stressScore += 3 }
            else if ratio < 0.85 { stressScore += 2 }
            else if ratio < 1.0 { stressScore += 1 }
        }

        // Factor 2: Daytime vs sleep HRV gap (large gap = daytime stress)
        if let day = daytimeHRV, let sleep = sleepHRV, sleep > 0 {
            let ratio = day / sleep
            if ratio < 0.6 { stressScore += 3 }
            else if ratio < 0.75 { stressScore += 2 }
            else if ratio < 0.9 { stressScore += 1 }
        }

        // Factor 3: HRV variability (high CV = more erratic = stress)
        if let cv = cv {
            if cv > 40 { stressScore += 2 }
            else if cv > 25 { stressScore += 1 }
        }

        // Factor 4: Absolute HRV thresholds
        if overall < 20 { stressScore += 2 }
        else if overall < 40 { stressScore += 1 }

        switch stressScore {
        case 0...1: return .low
        case 2...3: return .moderate
        case 4...5: return .elevated
        default: return .high
        }
    }

    private func generateInsight(
        stressLevel: StressLevel,
        daytimeHRV: Double?,
        sleepHRV: Double?,
        baseline: Double?,
        cv: Double?
    ) -> String {
        switch stressLevel {
        case .low:
            return "Your autonomic nervous system is well balanced. Great recovery state."
        case .moderate:
            if let day = daytimeHRV, let sleep = sleepHRV, sleep > 0, day / sleep < 0.85 {
                return "Moderate daytime stress detected. Your sleep HRV is recovering well — consider stress management during the day."
            }
            return "Moderate stress levels. Your body is coping but could benefit from relaxation."
        case .elevated:
            if let baseline = baseline, let day = daytimeHRV, baseline > 0, day / baseline < 0.7 {
                return "Daytime HRV is significantly below your baseline. Consider reducing intense activity and prioritizing recovery."
            }
            return "Elevated stress. Your nervous system is under load — prioritize rest, hydration, and sleep."
        case .high:
            return "High stress detected. Your HRV indicates significant autonomic strain. Focus on deep breathing, sleep, and reducing stressors."
        }
    }
}
