//
//  FoodEntryModel.swift
//  VitalArc
//
//  SwiftData Model for Food Entry
//

import Foundation
import SwiftData

@Model
final class FoodEntryModel {
    @Attribute(.unique) var id: UUID
    var foodId: UUID
    var date: Date
    var meal: String
    var quantity: Double
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double

    init(
        id: UUID = UUID(),
        foodId: UUID,
        date: Date = Date(),
        meal: String,
        quantity: Double,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double
    ) {
        self.id = id
        self.foodId = foodId
        self.date = date
        self.meal = meal
        self.quantity = quantity
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }

    /// Convert to domain entity
    func toDomain() -> FoodEntry {
        FoodEntry(
            id: id,
            foodId: foodId,
            date: date,
            meal: MealType(rawValue: meal) ?? .snack,
            quantity: quantity,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }

    /// Create from domain entity
    static func fromDomain(_ entry: FoodEntry) -> FoodEntryModel {
        FoodEntryModel(
            id: entry.id,
            foodId: entry.foodId,
            date: entry.date,
            meal: entry.meal.rawValue,
            quantity: entry.quantity,
            calories: entry.calories,
            protein: entry.protein,
            carbs: entry.carbs,
            fat: entry.fat
        )
    }
}
