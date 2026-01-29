//
//  CalculateTDEEUseCase.swift
//  VitalArc
//
//  Calculates Total Daily Energy Expenditure (TDEE) using Mifflin-St Jeor formula
//  TDEE = BMR × Activity Multiplier, adjusted for weight goals
//

import Foundation

/// Result containing TDEE calculation breakdown
struct TDEEResult: Equatable {
    let bmr: Double                    // Basal Metabolic Rate
    let tdee: Double                   // Total Daily Energy Expenditure
    let adjustedCalories: Double       // TDEE adjusted for weight goal
    let activityMultiplier: Double     // Activity level multiplier used
    let proteinGoal: Double            // Recommended protein (g)
    let fatGoal: Double                // Recommended fat (g)
    let carbGoal: Double               // Recommended carbs (g)
    let deficit: Double                // Calorie deficit (negative) or surplus (positive)
    let formula: TDEEFormula

    /// TDEE calculation formula used
    enum TDEEFormula: String {
        case mifflinStJeor = "Mifflin-St Jeor"
    }

    /// Macro distribution percentages
    struct MacroDistribution {
        static let proteinCaloriesPerGram: Double = 4
        static let carbCaloriesPerGram: Double = 4
        static let fatCaloriesPerGram: Double = 9

        // Default distribution: 30% protein, 35% carbs, 35% fat
        static let proteinPercent: Double = 0.30
        static let carbPercent: Double = 0.35
        static let fatPercent: Double = 0.35
    }
}

/// Protocol for TDEE calculation
protocol CalculateTDEEUseCaseProtocol {
    func execute() async throws -> TDEEResult?
    func execute(for profile: UserProfile) -> TDEEResult
    func calculateBMR(weight: Double, height: Double, age: Int, biologicalSex: BiologicalSex) -> Double
}

@MainActor
final class CalculateTDEEUseCase: CalculateTDEEUseCaseProtocol {
    private let userRepository: UserRepository

    /// Activity level multipliers (Harris-Benedict activity factors)
    private let activityMultipliers: [ActivityLevel: Double] = [
        .sedentary: 1.2,       // Little or no exercise
        .light: 1.375,         // Light exercise 1-3 days/week
        .moderate: 1.55,       // Moderate exercise 3-5 days/week
        .very: 1.725,          // Hard exercise 6-7 days/week
        .extreme: 1.9          // Very hard exercise, physical job
    ]

    /// Calorie adjustment for weight goals
    private let goalAdjustment: Double = 500 // calories

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    // MARK: - Public Interface

    /// Calculate TDEE using stored user profile
    func execute() async throws -> TDEEResult? {
        guard let profile = try await userRepository.getUserProfile() else {
            return nil
        }

        return execute(for: profile)
    }

    /// Calculate TDEE for a given user profile
    func execute(for profile: UserProfile) -> TDEEResult {
        // Calculate BMR using Mifflin-St Jeor
        let bmr = calculateBMR(
            weight: profile.weight,
            height: profile.height,
            age: profile.age,
            biologicalSex: profile.biologicalSex
        )

        // Apply activity multiplier
        let multiplier = activityMultipliers[profile.activityLevel] ?? 1.55
        let tdee = bmr * multiplier

        // Adjust for weight goal
        let (adjustedCalories, deficit) = adjustForGoal(tdee: tdee, goal: profile.weightGoal)

        // Calculate macro goals based on adjusted calories
        let macros = calculateMacros(calories: adjustedCalories, weight: profile.weight)

        return TDEEResult(
            bmr: bmr.rounded(),
            tdee: tdee.rounded(),
            adjustedCalories: adjustedCalories.rounded(),
            activityMultiplier: multiplier,
            proteinGoal: macros.protein.rounded(),
            fatGoal: macros.fat.rounded(),
            carbGoal: macros.carbs.rounded(),
            deficit: deficit,
            formula: .mifflinStJeor
        )
    }

    // MARK: - BMR Calculation

    /// Calculate BMR using Mifflin-St Jeor equation (1990)
    /// Men:   BMR = 10 × weight(kg) + 6.25 × height(cm) − 5 × age(years) + 5
    /// Women: BMR = 10 × weight(kg) + 6.25 × height(cm) − 5 × age(years) − 161
    func calculateBMR(
        weight: Double,
        height: Double,
        age: Int,
        biologicalSex: BiologicalSex
    ) -> Double {
        let baseBMR = (10 * weight) + (6.25 * height) - (5 * Double(age))

        switch biologicalSex {
        case .male:
            return baseBMR + 5
        case .female:
            return baseBMR - 161
        case .other:
            // Use average of male/female formulas
            return baseBMR - 78 // (5 + (-161)) / 2 = -78
        }
    }

    // MARK: - Goal Adjustment

    private func adjustForGoal(tdee: Double, goal: WeightGoal) -> (calories: Double, deficit: Double) {
        switch goal {
        case .lose:
            return (tdee - goalAdjustment, -goalAdjustment)
        case .maintain:
            return (tdee, 0)
        case .gain:
            return (tdee + goalAdjustment, goalAdjustment)
        }
    }

    // MARK: - Macro Calculation

    private func calculateMacros(calories: Double, weight: Double) -> (protein: Double, fat: Double, carbs: Double) {
        // Protein: 1.6-2.2g per kg body weight for active individuals
        // Using 2.0g/kg as default for fitness-focused users
        let proteinGrams = weight * 2.0
        let proteinCalories = proteinGrams * TDEEResult.MacroDistribution.proteinCaloriesPerGram

        // Remaining calories split between fat and carbs
        let remainingCalories = calories - proteinCalories

        // Fat: 25-35% of total calories
        let fatCalories = calories * TDEEResult.MacroDistribution.fatPercent
        let fatGrams = fatCalories / TDEEResult.MacroDistribution.fatCaloriesPerGram

        // Carbs: remaining calories
        let carbCalories = remainingCalories - fatCalories
        let carbGrams = max(0, carbCalories / TDEEResult.MacroDistribution.carbCaloriesPerGram)

        return (proteinGrams, fatGrams, carbGrams)
    }
}
