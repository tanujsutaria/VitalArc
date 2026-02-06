//
//  NutritionSummaryView.swift
//  VitalArc
//
//  View for displaying daily nutrition summary and goals
//

import SwiftUI

struct NutritionSummaryView: View {
    let dailyNutrition: DailyNutrition?
    let nutritionRepository: NutritionRepository?
    @State private var selectedMacro: MacroType?

    init(dailyNutrition: DailyNutrition?, nutritionRepository: NutritionRepository? = nil) {
        self.dailyNutrition = dailyNutrition
        self.nutritionRepository = nutritionRepository
    }

    var body: some View {
        VitalCard {
            VStack(spacing: Spacing.lg) {
                if let nutrition = dailyNutrition {
                    // Tappable instructions hint
                    if nutritionRepository != nil {
                        Text("Tap a ring to view details")
                            .font(.vitalCaptionSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }

                    // Macro rings
                    HStack(spacing: Spacing.md) {
                        TappableMacroRing(
                            name: "Calories",
                            consumed: nutrition.caloriesConsumed,
                            goal: nutrition.calorieGoal,
                            color: .vitalWarning,
                            unit: "kcal",
                            isEnabled: nutritionRepository != nil
                        ) {
                            selectedMacro = .calories
                        }

                        TappableMacroRing(
                            name: "Protein",
                            consumed: nutrition.proteinConsumed,
                            goal: nutrition.proteinGoal,
                            color: .vitalDanger,
                            unit: "g",
                            isEnabled: nutritionRepository != nil
                        ) {
                            selectedMacro = .protein
                        }

                        TappableMacroRing(
                            name: "Carbs",
                            consumed: nutrition.carbsConsumed,
                            goal: nutrition.carbsGoal,
                            color: .vitalInfo,
                            unit: "g",
                            isEnabled: nutritionRepository != nil
                        ) {
                            selectedMacro = .carbs
                        }

                        TappableMacroRing(
                            name: "Fat",
                            consumed: nutrition.fatConsumed,
                            goal: nutrition.fatGoal,
                            color: .vitalWarning,
                            unit: "g",
                            isEnabled: nutritionRepository != nil
                        ) {
                            selectedMacro = .fat
                        }
                    }

                    // Calorie progress bar
                    if let calorieGoal = nutrition.calorieGoal {
                        CalorieProgressView(
                            consumed: nutrition.caloriesConsumed,
                            goal: calorieGoal,
                            remaining: nutrition.caloriesRemaining ?? 0
                        )
                    }
                } else {
                    EmptyNutritionView()
                }
            }
        }
        .sheet(item: $selectedMacro) { macro in
            if let nutrition = dailyNutrition, let repository = nutritionRepository {
                MacroDetailSheet(
                    macroType: macro,
                    currentValue: getCurrentValue(for: macro, nutrition: nutrition),
                    goalValue: getGoalValue(for: macro, nutrition: nutrition),
                    nutritionRepository: repository
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Helpers

    private func getCurrentValue(for macro: MacroType, nutrition: DailyNutrition) -> Double {
        switch macro {
        case .calories: return nutrition.caloriesConsumed
        case .protein: return nutrition.proteinConsumed
        case .carbs: return nutrition.carbsConsumed
        case .fat: return nutrition.fatConsumed
        }
    }

    private func getGoalValue(for macro: MacroType, nutrition: DailyNutrition) -> Double? {
        switch macro {
        case .calories: return nutrition.calorieGoal
        case .protein: return nutrition.proteinGoal
        case .carbs: return nutrition.carbsGoal
        case .fat: return nutrition.fatGoal
        }
    }
}

// MARK: - Tappable Macro Ring

private struct TappableMacroRing: View {
    let name: String
    let consumed: Double
    let goal: Double?
    let color: Color
    let unit: String
    let isEnabled: Bool
    let onTap: () -> Void

    var body: some View {
        if isEnabled {
            Button(action: {
                HapticFeedback.light()
                onTap()
            }) {
                MacroRingView(
                    name: name,
                    consumed: consumed,
                    goal: goal,
                    color: color,
                    unit: unit
                )
            }
            .buttonStyle(.plain)
        } else {
            MacroRingView(
                name: name,
                consumed: consumed,
                goal: goal,
                color: color,
                unit: unit
            )
        }
    }
}

// MARK: - Subviews

private struct CalorieProgressView: View {
    let consumed: Double
    let goal: Double
    let remaining: Double

    private var progress: Double {
        min(consumed / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Daily Goal")
                    .font(.vitalLabel)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Spacer()

                if remaining > 0 {
                    Text("\(Int(remaining)) left")
                        .font(.vitalBodySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                } else {
                    Text("\(Int(abs(remaining))) over")
                        .font(.vitalBodySmall)
                        .foregroundStyle(Color.vitalWarning)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                        .fill(Color.vitalWarning.opacity(0.2))
                        .frame(height: 10)

                    // Progress
                    RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                        .fill(
                            LinearGradient(
                                colors: remaining > 0
                                    ? [Color.vitalWarning, Color.vitalWarning.opacity(0.8)]
                                    : [Color.vitalDanger, Color.vitalDanger.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 10)
                        .animation(.vitalSpring, value: progress)
                }
            }
            .frame(height: 10)

            // Percentage
            Text("\(Int(progress * 100))% of goal")
                .font(.vitalBodySmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .padding(.top, Spacing.sm)
    }
}

private struct EmptyNutritionView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.vitalWarning.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "chart.pie")
                    .font(.vitalIcon2XLarge)
                    .foregroundStyle(Color.vitalWarning)
            }

            VStack(spacing: Spacing.xs) {
                Text("No nutrition data")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Text("Start logging foods to see your nutrition summary")
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, Spacing.xl)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            NutritionSummaryView(
                dailyNutrition: DailyNutrition(
                    date: Date(),
                    caloriesConsumed: 1500,
                    proteinConsumed: 120,
                    carbsConsumed: 150,
                    fatConsumed: 50,
                    calorieGoal: 2000,
                    proteinGoal: 150,
                    carbsGoal: 200,
                    fatGoal: 60
                )
            )

            NutritionSummaryView(dailyNutrition: nil)
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
