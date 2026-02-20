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
    let bodyMeasurementRepository: SwiftDataBodyCompositionEntryRepository
    let logWaterUseCase: LogWaterUseCase
    let getWaterEntriesUseCase: GetWaterEntriesUseCase
    let deleteWaterEntryUseCase: DeleteWaterEntryUseCase
    let updateFoodEntryUseCase: UpdateFoodEntryUseCase
    let saveBodyCompositionEntryUseCase: SaveBodyCompositionEntryUseCase
    let getBodyCompositionEntriesUseCase: GetBodyCompositionEntriesUseCase

    init(modelContext: ModelContext) {
        self.nutritionRepository = SwiftDataNutritionRepository(modelContext: modelContext)
        self.bodyMeasurementRepository = SwiftDataBodyCompositionEntryRepository(modelContext: modelContext)
        self.logWaterUseCase = LogWaterUseCase(repository: nutritionRepository)
        self.getWaterEntriesUseCase = GetWaterEntriesUseCase(repository: nutritionRepository)
        self.deleteWaterEntryUseCase = DeleteWaterEntryUseCase(repository: nutritionRepository)
        self.updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: nutritionRepository)
        self.saveBodyCompositionEntryUseCase = SaveBodyCompositionEntryUseCase(repository: bodyMeasurementRepository)
        self.getBodyCompositionEntriesUseCase = GetBodyCompositionEntriesUseCase(repository: bodyMeasurementRepository)
    }
}

// MARK: - NutritionDataProviding Conformance

extension SwiftDataNutritionRepository: NutritionDataProviding {}
