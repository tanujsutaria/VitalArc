//
//  FoodEntry.swift
//  VitalArc
//
//  Domain Entity for Food Entry
//

import Foundation

/// Domain entity representing a logged food entry
struct FoodEntry: Identifiable, Equatable {
    let id: UUID
    let foodId: UUID
    let date: Date
    let meal: MealType
    let quantity: Double // in grams
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double

    init(
        id: UUID = UUID(),
        foodId: UUID,
        date: Date = Date(),
        meal: MealType,
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
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}
