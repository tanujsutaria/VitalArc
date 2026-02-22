//
//  StressAnalysis.swift
//  VitalArc
//
//  Domain entity for stress and HRV variability analysis
//

import Foundation

/// Stress level derived from HRV analysis
enum StressLevel: String, CaseIterable {
    case low = "Low"
    case moderate = "Moderate"
    case elevated = "Elevated"
    case high = "High"
}

/// A single HRV reading with timestamp and context
struct HRVReading: Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let value: Double // ms (SDNN)
    let context: HRVContext

    init(id: UUID = UUID(), timestamp: Date, value: Double, context: HRVContext) {
        self.id = id
        self.timestamp = timestamp
        self.value = value
        self.context = context
    }
}

/// Context of an HRV reading (daytime vs sleep)
enum HRVContext: String, CaseIterable {
    case daytime = "Daytime"
    case sleep = "Sleep"
}

/// Result of stress / HRV variability analysis for a given day
struct StressAnalysis: Equatable {
    let date: Date
    let daytimeHRV: Double? // Average daytime HRV (ms)
    let sleepHRV: Double? // Average sleep HRV (ms)
    let overallHRV: Double? // Combined average
    let stressLevel: StressLevel
    let hrvCoeffientOfVariation: Double? // CV% — higher means more variable
    let daytimeReadingCount: Int
    let sleepReadingCount: Int
    let insight: String

    /// Ratio of daytime to sleep HRV. <1.0 means daytime stress is suppressing HRV.
    var daytimeToSleepRatio: Double? {
        guard let day = daytimeHRV, let sleep = sleepHRV, sleep > 0 else { return nil }
        return day / sleep
    }
}
