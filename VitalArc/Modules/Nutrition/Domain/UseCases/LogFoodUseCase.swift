//
//  LogFoodUseCase.swift
//  VitalArc
//
//  Use case for logging food entries to specific meals
//

import Foundation

protocol LogFoodUseCaseProtocol {
    func execute(food: Food, quantity: Double, meal: MealType, date: Date) async throws -> FoodEntry
}

/// Use case for logging food entries
final class LogFoodUseCase: LogFoodUseCaseProtocol {
    private let repository: NutritionRepository

    init(repository: NutritionRepository) {
        self.repository = repository
    }

    /// Log a food entry for a specific meal
    /// - Parameters:
    ///   - food: The food to log
    ///   - quantity: Quantity in grams
    ///   - meal: Meal type (breakfast, lunch, dinner, snack)
    ///   - date: Date of the entry
    /// - Returns: Created FoodEntry
    func execute(food: Food, quantity: Double, meal: MealType, date: Date = Date()) async throws -> FoodEntry {
        // Scale the food to the desired quantity
        let scaledFood = food.scaled(to: quantity)

        // Create food entry
        let entry = FoodEntry(
            foodId: food.id,
            foodName: food.name,
            date: date,
            meal: meal,
            quantity: quantity,
            calories: scaledFood.calories,
            protein: scaledFood.protein,
            carbs: scaledFood.carbs,
            fat: scaledFood.fat,
            fiber: scaledFood.fiber,
            sugar: scaledFood.sugar
        )

        // Save to repository
        try await repository.saveFoodEntry(entry)

        // Update food usage tracking for recent/frequent foods
        var updatedFood = food
        updatedFood.recentlyUsed = Date()
        updatedFood.usageCount = food.usageCount + 1
        do {
            try await repository.saveFood(updatedFood)
        } catch {
            // Usage tracking failure is non-critical — log but don't block food logging
            print("[LogFoodUseCase] Warning: Failed to update food usage tracking: \(error.localizedDescription)")
        }

        // Update daily nutrition totals
        try? await updateDailyNutrition(for: date)

        return entry
    }

    /// Update daily nutrition totals for a given date
    private func updateDailyNutrition(for date: Date) async throws {
        // Get all entries for the date
        let entries = try await repository.getFoodEntries(for: date)

        // Calculate totals
        let totalCalories = entries.reduce(0) { $0 + $1.calories }
        let totalProtein = entries.reduce(0) { $0 + $1.protein }
        let totalCarbs = entries.reduce(0) { $0 + $1.carbs }
        let totalFat = entries.reduce(0) { $0 + $1.fat }
        let totalFiber = entries.reduce(0) { $0 + ($1.fiber ?? 0) }
        let totalSugar = entries.reduce(0) { $0 + ($1.sugar ?? 0) }

        // Get existing daily nutrition or create new
        let existing = try? await repository.getDailyNutrition(for: date)

        let dailyNutrition = DailyNutrition(
            id: existing?.id ?? UUID(),
            date: date,
            caloriesConsumed: totalCalories,
            proteinConsumed: totalProtein,
            carbsConsumed: totalCarbs,
            fatConsumed: totalFat,
            fiberConsumed: totalFiber,
            sugarConsumed: totalSugar,
            calorieGoal: existing?.calorieGoal,
            proteinGoal: existing?.proteinGoal,
            carbsGoal: existing?.carbsGoal,
            fatGoal: existing?.fatGoal,
            fiberGoal: existing?.fiberGoal,
            sugarGoal: existing?.sugarGoal
        )

        try await repository.saveDailyNutrition(dailyNutrition)
    }
}
