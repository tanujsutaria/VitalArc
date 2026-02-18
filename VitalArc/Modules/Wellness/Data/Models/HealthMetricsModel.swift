//
//  HealthMetricsModel.swift
//  VitalArc
//
//  SwiftData Model for Health Metrics
//

import Foundation
import SwiftData

@Model
final class HealthMetricsModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var heartRateVariability: Double?
    var restingHeartRate: Double?
    var activeEnergy: Double?
    var steps: Int?
    var sleepHours: Double?
    var weight: Double?

    // Sleep stage breakdown
    var deepSleepHours: Double?
    var remSleepHours: Double?
    var coreSleepHours: Double?
    var awakeHours: Double?

    // Body composition
    var bodyFatPercentage: Double?
    var leanBodyMass: Double?

    // Respiratory
    var respiratoryRate: Double?

    // Blood oxygen & cardio fitness
    var oxygenSaturation: Double?
    var vo2Max: Double?

    init(
        id: UUID = UUID(),
        date: Date,
        heartRateVariability: Double? = nil,
        restingHeartRate: Double? = nil,
        activeEnergy: Double? = nil,
        steps: Int? = nil,
        sleepHours: Double? = nil,
        weight: Double? = nil,
        deepSleepHours: Double? = nil,
        remSleepHours: Double? = nil,
        coreSleepHours: Double? = nil,
        awakeHours: Double? = nil,
        bodyFatPercentage: Double? = nil,
        leanBodyMass: Double? = nil,
        respiratoryRate: Double? = nil,
        oxygenSaturation: Double? = nil,
        vo2Max: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.heartRateVariability = heartRateVariability
        self.restingHeartRate = restingHeartRate
        self.activeEnergy = activeEnergy
        self.steps = steps
        self.sleepHours = sleepHours
        self.weight = weight
        self.deepSleepHours = deepSleepHours
        self.remSleepHours = remSleepHours
        self.coreSleepHours = coreSleepHours
        self.awakeHours = awakeHours
        self.bodyFatPercentage = bodyFatPercentage
        self.leanBodyMass = leanBodyMass
        self.respiratoryRate = respiratoryRate
        self.oxygenSaturation = oxygenSaturation
        self.vo2Max = vo2Max
    }

    /// Convert to domain entity
    func toDomain() -> HealthMetrics {
        // Build sleep stages if we have any stage data (including awake-only)
        let sleepStages: SleepStages? = {
            guard deepSleepHours != nil || remSleepHours != nil || coreSleepHours != nil || awakeHours != nil else {
                return nil
            }
            return SleepStages(
                deepSleep: deepSleepHours ?? 0,
                remSleep: remSleepHours ?? 0,
                coreSleep: coreSleepHours ?? 0,
                awake: awakeHours ?? 0
            )
        }()

        return HealthMetrics(
            id: id,
            date: date,
            heartRateVariability: heartRateVariability,
            restingHeartRate: restingHeartRate,
            activeEnergy: activeEnergy,
            steps: steps,
            sleepHours: sleepHours,
            sleepStages: sleepStages,
            weight: weight,
            bodyFatPercentage: bodyFatPercentage,
            leanBodyMass: leanBodyMass,
            respiratoryRate: respiratoryRate,
            oxygenSaturation: oxygenSaturation,
            vo2Max: vo2Max
        )
    }

    /// Create from domain entity
    static func fromDomain(_ metrics: HealthMetrics) -> HealthMetricsModel {
        HealthMetricsModel(
            id: metrics.id,
            date: metrics.date,
            heartRateVariability: metrics.heartRateVariability,
            restingHeartRate: metrics.restingHeartRate,
            activeEnergy: metrics.activeEnergy,
            steps: metrics.steps,
            sleepHours: metrics.sleepHours,
            weight: metrics.weight,
            deepSleepHours: metrics.sleepStages?.deepSleep,
            remSleepHours: metrics.sleepStages?.remSleep,
            coreSleepHours: metrics.sleepStages?.coreSleep,
            awakeHours: metrics.sleepStages?.awake,
            bodyFatPercentage: metrics.bodyFatPercentage,
            leanBodyMass: metrics.leanBodyMass,
            respiratoryRate: metrics.respiratoryRate,
            oxygenSaturation: metrics.oxygenSaturation,
            vo2Max: metrics.vo2Max
        )
    }
}
