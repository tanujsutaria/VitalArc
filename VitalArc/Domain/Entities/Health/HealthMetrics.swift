//
//  HealthMetrics.swift
//  VitalArc
//
//  Domain Entity for Health Metrics
//

import Foundation

/// Domain entity representing health metrics from HealthKit
struct HealthMetrics: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let heartRateVariability: Double? // in ms (SDNN)
    let restingHeartRate: Double? // in BPM
    let activeEnergy: Double? // in kcal
    let steps: Int?
    let sleepHours: Double? // total sleep in hours
    let weight: Double? // in kg

    init(
        id: UUID = UUID(),
        date: Date,
        heartRateVariability: Double? = nil,
        restingHeartRate: Double? = nil,
        activeEnergy: Double? = nil,
        steps: Int? = nil,
        sleepHours: Double? = nil,
        weight: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.heartRateVariability = heartRateVariability
        self.restingHeartRate = restingHeartRate
        self.activeEnergy = activeEnergy
        self.steps = steps
        self.sleepHours = sleepHours
        self.weight = weight
    }

    /// Simple recovery indicator based on HRV (higher is better)
    var recoveryIndicator: RecoveryLevel? {
        guard let hrv = heartRateVariability else { return nil }

        // Simplified HRV ranges (SDNN in ms)
        // Note: These are rough guidelines, actual ranges vary by individual
        switch hrv {
        case 0..<20:
            return .poor
        case 20..<50:
            return .fair
        case 50..<100:
            return .good
        default:
            return .excellent
        }
    }
}

enum RecoveryLevel: String, Codable {
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case excellent = "Excellent"
}
