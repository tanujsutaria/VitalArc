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

    /// Convert to domain entity
    func toDomain() -> HealthMetrics {
        HealthMetrics(
            id: id,
            date: date,
            heartRateVariability: heartRateVariability,
            restingHeartRate: restingHeartRate,
            activeEnergy: activeEnergy,
            steps: steps,
            sleepHours: sleepHours,
            weight: weight
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
            weight: metrics.weight
        )
    }
}
