//
//  WellnessContainer.swift
//  VitalArc
//
//  Dependency container for the Wellness/Health domain
//

import Foundation
import SwiftData

/// Container for all health/wellness-related dependencies
@MainActor
final class WellnessContainer {
    let healthRepository: SwiftDataHealthRepository
    let healthKitManager: HealthKitManager
    let calculateReadinessScoreUseCase: CalculateReadinessScoreUseCase
    let calculateRecoveryScoreUseCase: CalculateRecoveryScoreUseCase
    let calculateSleepConsistencyUseCase: CalculateSleepConsistencyUseCase

    init(modelContext: ModelContext, healthKitManager: HealthKitManager = HealthKitManager()) {
        self.healthKitManager = healthKitManager
        self.healthRepository = SwiftDataHealthRepository(modelContext: modelContext, healthKitManager: healthKitManager)
        self.calculateReadinessScoreUseCase = CalculateReadinessScoreUseCase()
        self.calculateRecoveryScoreUseCase = CalculateRecoveryScoreUseCase(healthDataProvider: healthRepository)
        self.calculateSleepConsistencyUseCase = CalculateSleepConsistencyUseCase()
    }
}

// HealthDataProviding conformance inherited from HealthRepository
