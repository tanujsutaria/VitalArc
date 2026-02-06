//
//  CreateCustomFoodView.swift
//  VitalArc
//
//  View for creating custom food items with nutrition info
//

import SwiftUI

struct CreateCustomFoodView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var brand = ""
    @State private var servingSize = ""
    @State private var servingUnit = "g"
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var fiber = ""
    @State private var sugar = ""

    let onSave: (Food) -> Void

    private var isValid: Bool {
        !name.isEmpty &&
        !servingSize.isEmpty &&
        Double(servingSize) != nil &&
        !calories.isEmpty &&
        Double(calories) != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Basic Info
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Basic Info")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        VitalTextField(
                            title: "Food Name",
                            text: $name,
                            placeholder: "e.g. Homemade Granola",
                            icon: "fork.knife"
                        )

                        VitalTextField(
                            title: "Brand (optional)",
                            text: $brand,
                            placeholder: "e.g. Homemade",
                            icon: "tag"
                        )
                    }

                    // Serving Info
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Serving")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        HStack(spacing: Spacing.sm) {
                            VitalTextField(
                                title: "Serving Size",
                                text: $servingSize,
                                placeholder: "100",
                                keyboardType: .decimalPad
                            )

                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Unit")
                                    .font(.vitalLabelSmall)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                                Picker("Unit", selection: $servingUnit) {
                                    Text("g").tag("g")
                                    Text("ml").tag("ml")
                                    Text("oz").tag("oz")
                                    Text("cup").tag("cup")
                                    Text("tbsp").tag("tbsp")
                                    Text("tsp").tag("tsp")
                                    Text("piece").tag("piece")
                                }
                                .pickerStyle(.menu)
                                .padding(Spacing.sm)
                                .background(Color.vitalAdaptiveSurface)
                                .cornerRadius(Spacing.radiusMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                                        .stroke(Color.vitalAdaptiveBorder, lineWidth: Spacing.borderThin)
                                )
                            }
                            .frame(width: 100)
                        }
                    }

                    // Nutrition Info
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Nutrition (per serving)")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        VitalTextField(
                            title: "Calories",
                            text: $calories,
                            placeholder: "0",
                            icon: "flame.fill",
                            keyboardType: .decimalPad
                        )

                        HStack(spacing: Spacing.sm) {
                            VitalTextField(
                                title: "Protein (g)",
                                text: $protein,
                                placeholder: "0",
                                keyboardType: .decimalPad
                            )

                            VitalTextField(
                                title: "Carbs (g)",
                                text: $carbs,
                                placeholder: "0",
                                keyboardType: .decimalPad
                            )

                            VitalTextField(
                                title: "Fat (g)",
                                text: $fat,
                                placeholder: "0",
                                keyboardType: .decimalPad
                            )
                        }

                        HStack(spacing: Spacing.sm) {
                            VitalTextField(
                                title: "Fiber (g)",
                                text: $fiber,
                                placeholder: "0",
                                keyboardType: .decimalPad
                            )

                            VitalTextField(
                                title: "Sugar (g)",
                                text: $sugar,
                                placeholder: "0",
                                keyboardType: .decimalPad
                            )
                        }
                    }

                    // Save button
                    VitalButton(
                        title: "Save Custom Food",
                        style: .primary,
                        icon: "checkmark",
                        fullWidth: true,
                        isDisabled: !isValid,
                        action: saveFood
                    )
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle("Create Custom Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveFood() {
        let food = Food(
            name: name,
            brand: brand.isEmpty ? nil : brand,
            servingSize: Double(servingSize) ?? 100,
            servingUnit: servingUnit,
            calories: Double(calories) ?? 0,
            protein: Double(protein) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0,
            fiber: Double(fiber),
            sugar: Double(sugar),
            source: .custom,
            isCustom: true
        )
        HapticFeedback.success()
        onSave(food)
        dismiss()
    }
}
