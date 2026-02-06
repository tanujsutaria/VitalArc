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
    let calculateReadinessScoreUseCase: CalculateReadinessScoreUseCase
    let calculateRecoveryScoreUseCase: CalculateRecoveryScoreUseCase

    init(modelContext: ModelContext) {
        self.healthRepository = SwiftDataHealthRepository(modelContext: modelContext)
        self.calculateReadinessScoreUseCase = CalculateReadinessScoreUseCase()
        self.calculateRecoveryScoreUseCase = CalculateRecoveryScoreUseCase(healthRepository: healthRepository)
    }
}

// MARK: - HealthDataProviding Conformance

extension SwiftDataHealthRepository: HealthDataProviding {}
