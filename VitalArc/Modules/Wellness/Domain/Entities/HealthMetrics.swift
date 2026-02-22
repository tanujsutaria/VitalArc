//
//  HealthMetrics.swift
//  VitalArc
//
//  Domain Entity for Health Metrics
//

import Foundation

/// Sleep stage breakdown from HealthKit
struct SleepStages: Equatable {
    let deepSleep: Double // hours
    let remSleep: Double // hours
    let coreSleep: Double // hours (light sleep)
    let awake: Double // hours

    /// Total actual sleep time (excludes awake periods)
    /// Use this for sleep quality calculations
    var total: Double {
        deepSleep + remSleep + coreSleep
    }

    /// Total time in bed (includes awake periods)
    /// Use this when comparing to HealthKit's sleepHours which may include awake time
    var totalWithAwake: Double {
        deepSleep + remSleep + coreSleep + awake
    }

    var deepPercent: Double {
        guard total > 0 else { return 0 }
        return (deepSleep / total) * 100
    }

    var remPercent: Double {
        guard total > 0 else { return 0 }
        return (remSleep / total) * 100
    }

    var corePercent: Double {
        guard total > 0 else { return 0 }
        return (coreSleep / total) * 100
    }

    /// Sleep quality score based on stage composition (0-100)
    var qualityScore: Double {
        guard total > 0 else { return 0 }

        // Ideal targets: 20-25% deep, 20-25% REM, rest core/light
        // Score based on hitting these targets
        let deepScore: Double = {
            let idealDeep = 0.225 // 22.5% target
            let actual = deepSleep / total
            return max(0, 1 - abs(actual - idealDeep) / idealDeep) * 40
        }()

        let remScore: Double = {
            let idealRem = 0.225 // 22.5% target
            let actual = remSleep / total
            return max(0, 1 - abs(actual - idealRem) / idealRem) * 40
        }()

        // Duration bonus (7-9 hours optimal)
        let durationScore: Double = {
            if total >= 7 && total <= 9 {
                return 20
            } else if total >= 6 && total < 7 {
                return 15
            } else if total > 9 && total <= 10 {
                return 15
            } else {
                return max(0, 20 - abs(total - 8) * 5)
            }
        }()

        return min(100, deepScore + remScore + durationScore)
    }

    static let zero = SleepStages(deepSleep: 0, remSleep: 0, coreSleep: 0, awake: 0)
}

/// Sleep consistency score based on 7-day bedtime/wake time analysis
struct SleepConsistencyScore: Equatable {
    let bedtimeVariance: Double // standard deviation of bedtimes in minutes
    let wakeVariance: Double // standard deviation of wake times in minutes
    let consistencyScore: Int // 0-100, higher is more consistent
}

/// Domain entity representing health metrics from HealthKit
struct HealthMetrics: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let heartRateVariability: Double? // in ms (SDNN)
    let restingHeartRate: Double? // in BPM
    let activeEnergy: Double? // in kcal
    let steps: Int?
    let sleepHours: Double? // total sleep in hours
    let sleepStages: SleepStages? // detailed sleep breakdown
    let weight: Double? // in kg
    let bodyFatPercentage: Double? // percentage (0-100)
    let leanBodyMass: Double? // in kg
    let respiratoryRate: Double? // breaths per minute
    let oxygenSaturation: Double? // percentage (0-100)
    let vo2Max: Double? // mL/kg/min
    let waterIntake: Double? // in mL (from HealthKit dietaryWater)

    init(
        id: UUID = UUID(),
        date: Date,
        heartRateVariability: Double? = nil,
        restingHeartRate: Double? = nil,
        activeEnergy: Double? = nil,
        steps: Int? = nil,
        sleepHours: Double? = nil,
        sleepStages: SleepStages? = nil,
        weight: Double? = nil,
        bodyFatPercentage: Double? = nil,
        leanBodyMass: Double? = nil,
        respiratoryRate: Double? = nil,
        oxygenSaturation: Double? = nil,
        vo2Max: Double? = nil,
        waterIntake: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.heartRateVariability = heartRateVariability
        self.restingHeartRate = restingHeartRate
        self.activeEnergy = activeEnergy
        self.steps = steps
        self.sleepHours = sleepHours
        self.sleepStages = sleepStages
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.leanBodyMass = leanBodyMass
        self.respiratoryRate = respiratoryRate
        self.oxygenSaturation = oxygenSaturation
        self.vo2Max = vo2Max
        self.waterIntake = waterIntake
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
