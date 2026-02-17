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
    let logWaterUseCase: LogWaterUseCase
    let getWaterEntriesUseCase: GetWaterEntriesUseCase
    let deleteWaterEntryUseCase: DeleteWaterEntryUseCase

    init(modelContext: ModelContext) {
        self.nutritionRepository = SwiftDataNutritionRepository(modelContext: modelContext)
        self.logWaterUseCase = LogWaterUseCase(repository: nutritionRepository)
        self.getWaterEntriesUseCase = GetWaterEntriesUseCase(repository: nutritionRepository)
        self.deleteWaterEntryUseCase = DeleteWaterEntryUseCase(repository: nutritionRepository)
    }
}

// MARK: - NutritionDataProviding Conformance

extension SwiftDataNutritionRepository: NutritionDataProviding {}
