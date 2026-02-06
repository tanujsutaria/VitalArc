//
//  NutritionContainer.swift
//  VitalArc
//
//  Dependency container for the Nutrition domain
//

import Foundation
import SwiftData

/// Container for all nutrition-related dependencies
@MainActor
final class NutritionContainer {
    let nutritionRepository: SwiftDataNutritionRepository

    init(modelContext: ModelContext) {
        self.nutritionRepository = SwiftDataNutritionRepository(modelContext: modelContext)
    }
}

// MARK: - NutritionDataProviding Conformance

extension SwiftDataNutritionRepository: NutritionDataProviding {}
