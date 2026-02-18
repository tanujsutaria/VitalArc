//
//  CalculateNutritionUseCase.swift
//  VitalArc
//
//  Use case for calculating daily nutrition totals and goals
//

import Foundation

protocol CalculateNutritionUseCaseProtocol {
    func execute(for date: Date) async throws -> DailyNutrition
    func calculateCalorieGoal(weight: Double, goal: CalorieGoal) -> Double
}

enum CalorieGoal {
    case maintenance
    case deficit
    case surplus
}

/// Use case for calculating daily nutrition
final class CalculateNutritionUseCase: CalculateNutritionUseCaseProtocol {
    private let repository: NutritionRepository

    init(repository: NutritionRepository) {
        self.repository = repository
    }

    /// Calculate daily nutrition totals for a specific date
    /// - Parameter date: Date to calculate nutrition for
    /// - Returns: DailyNutrition entity
    func execute(for date: Date) async throws -> DailyNutrition {
        // Get all food entries for the date
        let entries = try await repository.getFoodEntries(for: date)

        // Calculate totals
        let totalCalories = entries.reduce(0) { $0 + $1.calories }
        let totalProtein = entries.reduce(0) { $0 + $1.protein }
        let totalCarbs = entries.reduce(0) { $0 + $1.carbs }
        let totalFat = entries.reduce(0) { $0 + $1.fat }
        let totalFiber = entries.reduce(0) { $0 + ($1.fiber ?? 0) }
        let totalSugar = entries.reduce(0) { $0 + ($1.sugar ?? 0) }

        // Get existing daily nutrition to preserve goals
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

        // Save updated totals
        try await repository.saveDailyNutrition(dailyNutrition)

        return dailyNutrition
    }

    /// Calculate calorie goal based on weight and goal type
    /// - Parameters:
    ///   - weight: Body weight in kg
    ///   - goal: Calorie goal type (maintenance, deficit, surplus)
    /// - Returns: Daily calorie goal
    func calculateCalorieGoal(weight: Double, goal: CalorieGoal) -> Double {
        // Maintenance: weight (kg) × 33
        let maintenance = weight * 33

        switch goal {
        case .maintenance:
            return maintenance
        case .deficit:
            return maintenance - 500
        case .surplus:
            return maintenance + 500
        }
    }

    /// Update nutrition goals for a specific date
    /// - Parameters:
    ///   - date: Date to update goals for
    ///   - calorieGoal: Calorie goal
    ///   - proteinGoal: Protein goal in grams
    ///   - carbsGoal: Carbs goal in grams
    ///   - fatGoal: Fat goal in grams
    func updateGoals(
        for date: Date,
        calorieGoal: Double? = nil,
        proteinGoal: Double? = nil,
        carbsGoal: Double? = nil,
        fatGoal: Double? = nil
    ) async throws {
        // Get existing daily nutrition or create new
        let existing = try? await repository.getDailyNutrition(for: date)

        let dailyNutrition = DailyNutrition(
            id: existing?.id ?? UUID(),
            date: date,
            caloriesConsumed: existing?.caloriesConsumed ?? 0,
            proteinConsumed: existing?.proteinConsumed ?? 0,
            carbsConsumed: existing?.carbsConsumed ?? 0,
            fatConsumed: existing?.fatConsumed ?? 0,
            fiberConsumed: existing?.fiberConsumed ?? 0,
            sugarConsumed: existing?.sugarConsumed ?? 0,
            calorieGoal: calorieGoal ?? existing?.calorieGoal,
            proteinGoal: proteinGoal ?? existing?.proteinGoal,
            carbsGoal: carbsGoal ?? existing?.carbsGoal,
            fatGoal: fatGoal ?? existing?.fatGoal,
            fiberGoal: existing?.fiberGoal,
            sugarGoal: existing?.sugarGoal
        )

        try await repository.saveDailyNutrition(dailyNutrition)
    }
}
