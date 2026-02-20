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
    let fiber: Double?
    let sugar: Double?

    init(
        id: UUID = UUID(),
        foodId: UUID,
        date: Date = Date(),
        meal: MealType,
        quantity: Double,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double? = nil,
        sugar: Double? = nil
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
        self.fiber = fiber
        self.sugar = sugar
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var displayName: String {
        rawValue
    }

    // MARK: - Time-Based Meal Selection

    /// Default meal time boundaries (hour of day, 0-23)
    static let breakfastStartHour = 5   // 5 AM
    static let lunchStartHour = 11      // 11 AM
    static let dinnerStartHour = 17     // 5 PM
    static let snackStartHour = 21      // 9 PM

    /// Returns the appropriate meal type for the current time of day
    static func forCurrentTime(
        breakfastStart: Int = breakfastStartHour,
        lunchStart: Int = lunchStartHour,
        dinnerStart: Int = dinnerStartHour,
        snackStart: Int = snackStartHour
    ) -> MealType {
        let hour = Calendar.current.component(.hour, from: Date())

        if hour >= snackStart || hour < breakfastStart {
            return .snack
        } else if hour >= dinnerStart {
            return .dinner
        } else if hour >= lunchStart {
            return .lunch
        } else {
            return .breakfast
        }
    }

    /// Returns the appropriate meal type using a MealTimeConfiguration
    static func forCurrentTime(config: MealTimeConfiguration) -> MealType {
        return forCurrentTime(
            breakfastStart: config.breakfastStart,
            lunchStart: config.lunchStart,
            dinnerStart: config.dinnerStart,
            snackStart: config.snackStart
        )
    }

    /// Returns the meal type for a specific hour using a configuration
    static func forHour(_ hour: Int, config: MealTimeConfiguration = MealTimeConfiguration()) -> MealType {
        if hour >= config.snackStart || hour < config.breakfastStart {
            return .snack
        } else if hour >= config.dinnerStart {
            return .dinner
        } else if hour >= config.lunchStart {
            return .lunch
        } else {
            return .breakfast
        }
    }
}
