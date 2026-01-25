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
        VStack(spacing: 24) {
            if let nutrition = dailyNutrition {
                // Macro rings
                HStack(spacing: 16) {
                    MacroRingView(
                        name: "Calories",
                        consumed: nutrition.caloriesConsumed,
                        goal: nutrition.calorieGoal,
                        color: .orange,
                        unit: "kcal"
                    )

                    MacroRingView(
                        name: "Protein",
                        consumed: nutrition.proteinConsumed,
                        goal: nutrition.proteinGoal,
                        color: .blue,
                        unit: "g"
                    )

                    MacroRingView(
                        name: "Carbs",
                        consumed: nutrition.carbsConsumed,
                        goal: nutrition.carbsGoal,
                        color: .green,
                        unit: "g"
                    )

                    MacroRingView(
                        name: "Fat",
                        consumed: nutrition.fatConsumed,
                        goal: nutrition.fatGoal,
                        color: .red,
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
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Daily Goal")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                if remaining > 0 {
                    Text("\(Int(remaining)) left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(Int(abs(remaining))) over")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.orange.opacity(0.2))
                        .frame(height: 8)

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(remaining > 0 ? Color.orange : Color.orange.opacity(0.7))
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)

            // Percentage
            Text("\(Int(progress * 100))% of goal")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}

private struct EmptyNutritionView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No nutrition data")
                .font(.headline)

            Text("Start logging foods to see your nutrition summary")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 32)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
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
    .background(Color(.systemGroupedBackground))
}
