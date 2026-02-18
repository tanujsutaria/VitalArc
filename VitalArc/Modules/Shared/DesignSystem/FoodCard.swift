//
//  FoodCard.swift
//  VitalArc
//
//  Modern food card component with macro visualization
//

import SwiftUI

struct FoodCard: View {
    let foodName: String
    let servingSize: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let mealType: String?
    let onTap: (() -> Void)?
    let onDelete: (() -> Void)?

    init(
        foodName: String,
        servingSize: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        mealType: String? = nil,
        onTap: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.foodName = foodName
        self.servingSize = servingSize
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.mealType = mealType
        self.onTap = onTap
        self.onDelete = onDelete
    }

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            onTap?()
        }) {
            VitalCard(padding: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(foodName)
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                                .lineLimit(2)

                            Text(servingSize)
                                .font(.vitalBodySmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }

                        Spacer()

                        // Calories badge
                        VStack(spacing: Spacing.xxs) {
                            Text("\(calories)")
                                .font(.vitalNumberSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            Text("kcal")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.vitalWarning.opacity(0.15))
                        .cornerRadius(Spacing.sm)
                    }

                    // Macro bars
                    VStack(spacing: Spacing.xs) {
                        MacroBar(
                            label: "P",
                            value: protein,
                            color: .vitalDanger,
                            unit: "g"
                        )

                        MacroBar(
                            label: "C",
                            value: carbs,
                            color: .vitalInfo,
                            unit: "g"
                        )

                        MacroBar(
                            label: "F",
                            value: fat,
                            color: .vitalWarning,
                            unit: "g"
                        )
                    }

                    // Meal type and actions
                    HStack {
                        if let mealType = mealType {
                            Text(mealType)
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(.white)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xs)
                                .background(Color.vitalPrimary)
                                .cornerRadius(Spacing.radiusSmall)
                        }

                        Spacer()

                        if let onDelete = onDelete {
                            Button(action: {
                                HapticFeedback.medium()
                                onDelete()
                            }) {
                                Image(systemName: "trash")
                                    .font(.vitalIconSmallMedium)
                                    .foregroundStyle(Color.vitalDanger)
                            }
                            .vitalScaleButton()
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Macro Bar

struct MacroBar: View {
    let label: String
    let value: Double
    let color: Color
    let unit: String
    var maxValue: Double = 100

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text(label)
                .font(.vitalLabelSmall)
                .foregroundStyle(color)
                .frame(width: 12)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(color.opacity(0.15))
                        .cornerRadius(Spacing.xs)

                    // Progress
                    Rectangle()
                        .fill(color)
                        .frame(width: min(CGFloat(value / maxValue) * geometry.size.width, geometry.size.width))
                        .cornerRadius(Spacing.xs)
                        .animation(.vitalSpring, value: value)
                }
            }
            .frame(height: 8)

            Text("\(String(format: "%.0f", value))\(unit)")
                .font(.vitalBodySmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

// MARK: - Food Search Result Row

struct FoodSearchResultRow: View {
    let foodName: String
    let brandName: String?
    let calories: Int
    let servingSize: String
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            onTap()
        }) {
            HStack(spacing: Spacing.md) {
                // Food icon
                ZStack {
                    Circle()
                        .fill(Color.vitalWarning.opacity(0.15))
                        .frame(width: Spacing.avatarSmall, height: Spacing.avatarSmall)

                    Image(systemName: "fork.knife")
                        .font(.vitalIconMediumSemibold)
                        .foregroundStyle(Color.vitalWarning)
                }

                // Food info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(foodName)
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        .lineLimit(1)

                    HStack(spacing: Spacing.xs) {
                        if let brandName = brandName {
                            Text(brandName)
                                .font(.vitalBodySmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }

                        Text("•")
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                        Text(servingSize)
                            .font(.vitalBodySmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }

                Spacer()

                // Calories
                Text("\(calories) kcal")
                    .font(.vitalLabelSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                Image(systemName: "chevron.right")
                    .font(.vitalIconXSmallSemibold)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
            .padding(Spacing.md)
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusMedium)
            .vitalCardShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.md) {
            FoodCard(
                foodName: "Grilled Chicken Breast",
                servingSize: "150g",
                calories: 165,
                protein: 31,
                carbs: 0,
                fat: 3.6,
                mealType: "Lunch",
                onDelete: {}
            )

            FoodCard(
                foodName: "Brown Rice",
                servingSize: "1 cup (195g)",
                calories: 216,
                protein: 5,
                carbs: 45,
                fat: 1.8,
                mealType: "Dinner"
            )

            FoodSearchResultRow(
                foodName: "Oatmeal",
                brandName: "Quaker",
                calories: 150,
                servingSize: "1/2 cup (40g)",
                onTap: {}
            )
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
