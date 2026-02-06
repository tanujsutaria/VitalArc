//
//  DailyNutrition.swift
//  VitalArc
//
//  Domain Entity for Daily Nutrition Summary
//

import Foundation

/// Domain entity representing daily nutrition totals
struct DailyNutrition: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let caloriesConsumed: Double
    let proteinConsumed: Double
    let carbsConsumed: Double
    let fatConsumed: Double
    let calorieGoal: Double?
    let proteinGoal: Double?
    let carbsGoal: Double?
    let fatGoal: Double?

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

    /// Percentage of calorie goal consumed
    var calorieProgress: Double? {
        guard let goal = calorieGoal, goal > 0 else { return nil }
        return (caloriesConsumed / goal) * 100
    }

    /// Remaining calories to goal
    var caloriesRemaining: Double? {
        guard let goal = calorieGoal else { return nil }
        return goal - caloriesConsumed
    }
}
