//
//  MacroGoalEditSheet.swift
//  VitalArc
//
//  Sheet for editing macro nutrient goals
//

import SwiftUI

struct MacroGoalEditSheet: View {
    @Environment(\.dismiss) private var dismiss

    let currentCalories: Double?
    let currentProtein: Double?
    let currentCarbs: Double?
    let currentFat: Double?
    let tdeeResult: TDEEResult?
    let onSave: (Double, Double, Double, Double) async -> Void

    @State private var calorieGoal: String = ""
    @State private var proteinGoal: String = ""
    @State private var carbsGoal: String = ""
    @State private var fatGoal: String = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Customize your daily nutrition targets. These goals help track your progress toward your fitness objectives.")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                        if let tdee = tdeeResult {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.vitalIconSmall)
                                    .foregroundStyle(Color.vitalWarning)
                                Text("Based on your profile, we recommend \(Int(tdee.adjustedCalories)) kcal/day.")
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                            .padding(.top, Spacing.xs)
                        }
                    }
                } header: {
                    Text("About Goals")
                }

                Section {
                    goalRow(
                        label: "Calories",
                        icon: "flame.fill",
                        color: .vitalWarning,
                        value: $calorieGoal,
                        unit: "kcal",
                        suggestion: tdeeResult?.adjustedCalories
                    )
                } header: {
                    Text("Energy")
                }

                Section {
                    goalRow(
                        label: "Protein",
                        icon: "p.circle.fill",
                        color: .vitalDanger,
                        value: $proteinGoal,
                        unit: "g",
                        suggestion: tdeeResult?.proteinGoal
                    )

                    goalRow(
                        label: "Carbohydrates",
                        icon: "c.circle.fill",
                        color: .vitalInfo,
                        value: $carbsGoal,
                        unit: "g",
                        suggestion: tdeeResult?.carbGoal
                    )

                    goalRow(
                        label: "Fat",
                        icon: "f.circle.fill",
                        color: .vitalWarning,
                        value: $fatGoal,
                        unit: "g",
                        suggestion: tdeeResult?.fatGoal
                    )
                } header: {
                    Text("Macronutrients")
                }

                if tdeeResult != nil {
                    Section {
                        Button {
                            applyTDEERecommendations()
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Use Recommended Goals")
                            }
                            .foregroundStyle(Color.vitalPrimary)
                        }
                    }
                }
            }
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveGoals()
                        }
                    }
                    .disabled(isSaving || !isValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                populateCurrentGoals()
            }
        }
    }

    // MARK: - Goal Row

    private func goalRow(
        label: String,
        icon: String,
        color: Color,
        value: Binding<String>,
        unit: String,
        suggestion: Double?
    ) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.vitalIconMedium)
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                if let suggestion = suggestion {
                    Text("Suggested: \(Int(suggestion)) \(unit)")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }

            Spacer()

            HStack(spacing: Spacing.xs) {
                TextField("0", text: value)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .font(.vitalBody).fontWeight(.semibold)

                Text(unit)
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    .frame(width: 30, alignment: .leading)
            }
        }
    }

    // MARK: - Helpers

    private var isValid: Bool {
        LocaleAwareParsing.parsePositiveDouble(from: calorieGoal) != nil &&
        LocaleAwareParsing.parsePositiveDouble(from: proteinGoal) != nil &&
        LocaleAwareParsing.parsePositiveDouble(from: carbsGoal) != nil &&
        LocaleAwareParsing.parsePositiveDouble(from: fatGoal) != nil
    }

    private func populateCurrentGoals() {
        calorieGoal = currentCalories.map { String(Int($0)) } ?? ""
        proteinGoal = currentProtein.map { String(Int($0)) } ?? ""
        carbsGoal = currentCarbs.map { String(Int($0)) } ?? ""
        fatGoal = currentFat.map { String(Int($0)) } ?? ""
    }

    private func applyTDEERecommendations() {
        guard let tdee = tdeeResult else { return }
        calorieGoal = String(Int(tdee.adjustedCalories))
        proteinGoal = String(Int(tdee.proteinGoal))
        carbsGoal = String(Int(tdee.carbGoal))
        fatGoal = String(Int(tdee.fatGoal))
    }

    private func saveGoals() async {
        guard let calories = LocaleAwareParsing.parsePositiveDouble(from: calorieGoal),
              let protein = LocaleAwareParsing.parsePositiveDouble(from: proteinGoal),
              let carbs = LocaleAwareParsing.parsePositiveDouble(from: carbsGoal),
              let fat = LocaleAwareParsing.parsePositiveDouble(from: fatGoal) else { return }

        isSaving = true
        await onSave(calories, protein, carbs, fat)
        isSaving = false
        dismiss()
    }
}

#Preview {
    MacroGoalEditSheet(
        currentCalories: 2000,
        currentProtein: 150,
        currentCarbs: 200,
        currentFat: 65,
        tdeeResult: TDEEResult(
            bmr: 1800,
            tdee: 2500,
            adjustedCalories: 2000,
            activityMultiplier: 1.55,
            proteinGoal: 160,
            fatGoal: 67,
            carbGoal: 200,
            deficit: -500,
            formula: .mifflinStJeor
        )
    ) { _, _, _, _ in
        // Preview save action
    }
}
