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

    init(modelContext: ModelContext) {
        self.healthRepository = SwiftDataHealthRepository(modelContext: modelContext)
    }
}

// MARK: - HealthDataProviding Conformance

extension SwiftDataHealthRepository: HealthDataProviding {}
