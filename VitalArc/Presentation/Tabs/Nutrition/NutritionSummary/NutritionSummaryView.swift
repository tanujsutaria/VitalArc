//
//  NutritionSummaryView.swift
//  VitalArc
//
//  View for displaying daily nutrition summary and goals
//

import SwiftUI

struct NutritionSummaryView: View {
    let dailyNutrition: DailyNutrition?

    var body: some View {
        VitalCard {
            VStack(spacing: Spacing.lg) {
                if let nutrition = dailyNutrition {
                    // Macro rings
                    HStack(spacing: Spacing.md) {
                        MacroRingView(
                            name: "Calories",
                            consumed: nutrition.caloriesConsumed,
                            goal: nutrition.calorieGoal,
                            color: .vitalWarning,
                            unit: "kcal"
                        )

                        MacroRingView(
                            name: "Protein",
                            consumed: nutrition.proteinConsumed,
                            goal: nutrition.proteinGoal,
                            color: .vitalDanger,
                            unit: "g"
                        )

                        MacroRingView(
                            name: "Carbs",
                            consumed: nutrition.carbsConsumed,
                            goal: nutrition.carbsGoal,
                            color: .vitalInfo,
                            unit: "g"
                        )

                        MacroRingView(
                            name: "Fat",
                            consumed: nutrition.fatConsumed,
                            goal: nutrition.fatGoal,
                            color: .vitalWarning,
                            unit: "g"
                        )
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
                    .font(.system(size: 40))
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
