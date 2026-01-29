//
//  FoodResultRowView.swift
//  VitalArc
//
//  Row view for displaying food search result
//

import SwiftUI

struct FoodResultRowView: View {
    let food: Food
    var onSelect: ((Food) -> Void)?

    var body: some View {
        Button {
            HapticFeedback.light()
            onSelect?(food)
        } label: {
            HStack(spacing: Spacing.md) {
                // Food image or icon
                if let imageURL = food.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 56, height: 56)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                        case .failure:
                            FoodIcon(source: food.source)
                        @unknown default:
                            FoodIcon(source: food.source)
                        }
                    }
                } else {
                    FoodIcon(source: food.source)
                }

                // Food info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // Name and source badge
                    HStack(spacing: Spacing.xs) {
                        Text(food.name)
                            .font(.vitalLabel)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            .lineLimit(2)

                        Spacer()

                        SourceBadge(source: food.source)
                    }

                    if let brand = food.brand {
                        Text(brand)
                            .font(.vitalBodySmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            .lineLimit(1)
                    }

                    // Macros per serving
                    HStack(spacing: Spacing.sm) {
                        MacroLabel(value: Int(food.calories), unit: "cal", color: .vitalWarning)
                        MacroLabel(value: Int(food.protein), unit: "P", color: .vitalDanger)
                        MacroLabel(value: Int(food.carbs), unit: "C", color: .vitalInfo)
                        MacroLabel(value: Int(food.fat), unit: "F", color: .vitalWarning)
                    }
                    .font(.vitalBodySmall)

                    // Serving size
                    Text("\(formatServingSize(food.servingSize))\(food.servingUnit) serving")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.vitalLabelSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
            .padding(Spacing.md)
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusMedium)
            .vitalCardShadow()
        }
        .buttonStyle(.plain)
    }

    private func formatServingSize(_ size: Double) -> String {
        if size.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(size))
        } else {
            return String(format: "%.1f", size)
        }
    }
}

private struct MacroLabel: View {
    let value: Int
    let unit: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Text("\(value)")
                .font(.vitalLabelSmall)
            Text(unit)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .foregroundStyle(color)
    }
}

private struct FoodIcon: View {
    let source: FoodSource

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                .fill(sourceColor.opacity(0.15))
                .frame(width: 56, height: 56)

            Image(systemName: source.iconName)
                .font(.vitalDisplaySmall)
                .foregroundStyle(sourceColor)
        }
    }

    private var sourceColor: Color {
        switch source {
        case .usda: return .vitalSuccess
        case .nutritionix: return .vitalWarning
        case .openFoodFacts: return .vitalInfo
        case .manual, .custom: return .vitalTextSecondary
        }
    }
}

private struct SourceBadge: View {
    let source: FoodSource

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: source.iconName)
                .font(.system(size: Spacing.iconTiny))
            Text(source.displayName)
                .font(.vitalCaptionSmall)
        }
        .foregroundStyle(badgeColor)
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(badgeColor.opacity(0.15))
        .cornerRadius(Spacing.xs)
    }

    private var badgeColor: Color {
        switch source {
        case .usda: return .vitalSuccess
        case .nutritionix: return .vitalWarning
        case .openFoodFacts: return .vitalInfo
        case .manual, .custom: return .vitalTextSecondary
        }
    }
}

#Preview {
    List {
        FoodResultRowView(
            food: Food(
                name: "Chicken Breast",
                brand: "Generic",
                servingSize: 100,
                servingUnit: "g",
                calories: 165,
                protein: 31,
                carbs: 0,
                fat: 3.6
            )
        )

        FoodResultRowView(
            food: Food(
                name: "Brown Rice",
                servingSize: 100,
                servingUnit: "g",
                calories: 370,
                protein: 7.9,
                carbs: 77.2,
                fat: 2.9
            )
        )
    }
}
