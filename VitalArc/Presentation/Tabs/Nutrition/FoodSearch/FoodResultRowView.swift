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
            onSelect?(food)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Food icon
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(width: 40, height: 40)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                // Food info
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if let brand = food.brand {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Macros per serving
                    HStack(spacing: 12) {
                        MacroLabel(value: Int(food.calories), unit: "cal", color: .orange)
                        MacroLabel(value: Int(food.protein), unit: "P", color: .blue)
                        MacroLabel(value: Int(food.carbs), unit: "C", color: .green)
                        MacroLabel(value: Int(food.fat), unit: "F", color: .red)
                    }
                    .font(.caption)

                    // Serving size
                    Text("\(Int(food.servingSize))\(food.servingUnit) serving")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

private struct MacroLabel: View {
    let value: Int
    let unit: String
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text("\(value)")
                .fontWeight(.semibold)
            Text(unit)
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(color)
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
