//
//  DailyNutritionModel.swift
//  VitalArc
//
//  SwiftData Model for Daily Nutrition
//

import Foundation
import SwiftData

@Model
final class DailyNutritionModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var caloriesConsumed: Double
    var proteinConsumed: Double
    var carbsConsumed: Double
    var fatConsumed: Double
    var calorieGoal: Double?
    var proteinGoal: Double?
    var carbsGoal: Double?
    var fatGoal: Double?

    init(
        id: UUID = UUID(),
        date: Date,
        caloriesConsumed: Double,
        proteinConsumed: Double,
        carbsConsumed: Double,
        fatConsumed: Double,
        calorieGoal: Double? = nil,
        proteinGoal: Double? = nil,
        carbsGoal: Double? = nil,
        fatGoal: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.caloriesConsumed = caloriesConsumed
        self.proteinConsumed = proteinConsumed
        self.carbsConsumed = carbsConsumed
        self.fatConsumed = fatConsumed
        self.calorieGoal = calorieGoal
        self.proteinGoal = proteinGoal
        self.carbsGoal = carbsGoal
        self.fatGoal = fatGoal
    }

    /// Convert to domain entity
    func toDomain() -> DailyNutrition {
        DailyNutrition(
            id: id,
            date: date,
            caloriesConsumed: caloriesConsumed,
            proteinConsumed: proteinConsumed,
            carbsConsumed: carbsConsumed,
            fatConsumed: fatConsumed,
            calorieGoal: calorieGoal,
            proteinGoal: proteinGoal,
            carbsGoal: carbsGoal,
            fatGoal: fatGoal
        )
    }

    /// Create from domain entity
    static func fromDomain(_ nutrition: DailyNutrition) -> DailyNutritionModel {
        DailyNutritionModel(
            id: nutrition.id,
            date: nutrition.date,
            caloriesConsumed: nutrition.caloriesConsumed,
            proteinConsumed: nutrition.proteinConsumed,
            carbsConsumed: nutrition.carbsConsumed,
            fatConsumed: nutrition.fatConsumed,
            calorieGoal: nutrition.calorieGoal,
            proteinGoal: nutrition.proteinGoal,
            carbsGoal: nutrition.carbsGoal,
            fatGoal: nutrition.fatGoal
        )
    }
}
