//
//  UpdateFoodEntryUseCase.swift
//  VitalArc
//
//  Use case for updating a food entry's quantity with proportional macro recalculation
//

import Foundation

protocol UpdateFoodEntryUseCaseProtocol {
    func execute(entry: FoodEntry, newQuantity: Double) async throws -> FoodEntry
}

/// Use case for updating a food entry's quantity and recalculating macros proportionally
final class UpdateFoodEntryUseCase: UpdateFoodEntryUseCaseProtocol {
    private let repository: NutritionRepository

    init(repository: NutritionRepository) {
        self.repository = repository
    }

    /// Update a food entry's quantity and recalculate all macros proportionally
    /// - Parameters:
    ///   - entry: The existing food entry to update
    ///   - newQuantity: New quantity in grams (must be > 0)
    /// - Returns: Updated FoodEntry with recalculated macros
    func execute(entry: FoodEntry, newQuantity: Double) async throws -> FoodEntry {
        guard newQuantity > 0 else {
            throw UpdateFoodEntryError.invalidQuantity
        }

        guard entry.quantity > 0 else {
            throw UpdateFoodEntryError.invalidOriginalQuantity
        }

        let scale = newQuantity / entry.quantity

        let updatedEntry = FoodEntry(
            id: entry.id,
            foodId: entry.foodId,
            foodName: entry.foodName,
            date: entry.date,
            meal: entry.meal,
            quantity: newQuantity,
            calories: entry.calories * scale,
            protein: entry.protein * scale,
            carbs: entry.carbs * scale,
            fat: entry.fat * scale,
            fiber: entry.fiber.map { $0 * scale },
            sugar: entry.sugar.map { $0 * scale }
        )

        try await repository.saveFoodEntry(updatedEntry)

        // Update daily nutrition totals
        try? await updateDailyNutrition(for: entry.date)

        return updatedEntry
    }

    /// Update daily nutrition totals for a given date
    private func updateDailyNutrition(for date: Date) async throws {
        let entries = try await repository.getFoodEntries(for: date)

        let totalCalories = entries.reduce(0) { $0 + $1.calories }
        let totalProtein = entries.reduce(0) { $0 + $1.protein }
        let totalCarbs = entries.reduce(0) { $0 + $1.carbs }
        let totalFat = entries.reduce(0) { $0 + $1.fat }
        let totalFiber = entries.reduce(0) { $0 + ($1.fiber ?? 0) }
        let totalSugar = entries.reduce(0) { $0 + ($1.sugar ?? 0) }

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

enum UpdateFoodEntryError: Error, LocalizedError {
    case invalidQuantity
    case invalidOriginalQuantity

    var errorDescription: String? {
        switch self {
        case .invalidQuantity:
            return "Quantity must be greater than zero"
        case .invalidOriginalQuantity:
            return "Original entry has invalid quantity"
        }
    }
}
