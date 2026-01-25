//
//  MealSectionView.swift
//  VitalArc
//
//  Section view for displaying a meal with food entries
//

import SwiftUI

struct MealSectionView: View {
    let meal: MealType
    let entries: [FoodEntry]
    let totals: (calories: Double, protein: Double, carbs: Double, fat: Double)
    let onAddFood: () -> Void
    let onDeleteEntry: (FoodEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Meal icon and name
                HStack(spacing: 8) {
                    Image(systemName: mealIcon)
                        .font(.title3)
                        .foregroundStyle(mealColor)

                    Text(meal.rawValue)
                        .font(.headline)
                }

                Spacer()

                // Totals
                if !entries.isEmpty {
                    Text("\(Int(totals.calories)) cal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Add button
                Button {
                    onAddFood()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(mealColor)
                }
            }

            // Entries
            if entries.isEmpty {
                EmptyMealView()
            } else {
                ForEach(entries) { entry in
                    FoodEntryRowView(entry: entry, onDelete: {
                        onDeleteEntry(entry)
                    })
                }

                // Meal totals
                MealTotalsView(totals: totals)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var mealIcon: String {
        switch meal {
        case .breakfast:
            return "sunrise.fill"
        case .lunch:
            return "sun.max.fill"
        case .dinner:
            return "moon.stars.fill"
        case .snack:
            return "leaf.fill"
        }
    }

    private var mealColor: Color {
        switch meal {
        case .breakfast:
            return .orange
        case .lunch:
            return .yellow
        case .dinner:
            return .purple
        case .snack:
            return .green
        }
    }
}

// MARK: - Subviews

private struct EmptyMealView: View {
    var body: some View {
        Text("No foods logged")
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            .padding(.vertical, 8)
    }
}

private struct FoodEntryRowView: View {
    let entry: FoodEntry
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(Int(entry.quantity))g")
                    .font(.subheadline)
                    .fontWeight(.medium)

                // Macros
                HStack(spacing: 8) {
                    MacroText(value: Int(entry.calories), unit: "cal", color: .orange)
                    MacroText(value: Int(entry.protein), unit: "P", color: .blue)
                    MacroText(value: Int(entry.carbs), unit: "C", color: .green)
                    MacroText(value: Int(entry.fat), unit: "F", color: .red)
                }
                .font(.caption)
            }

            Spacer()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

private struct MacroText: View {
    let value: Int
    let unit: String
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text("\(value)")
                .fontWeight(.semibold)
            Text(unit)
        }
        .foregroundStyle(color)
    }
}

private struct MealTotalsView: View {
    let totals: (calories: Double, protein: Double, carbs: Double, fat: Double)

    var body: some View {
        Divider()
            .padding(.vertical, 4)

        HStack {
            Text("Total")
                .font(.subheadline)
                .fontWeight(.semibold)

            Spacer()

            HStack(spacing: 12) {
                MacroText(value: Int(totals.calories), unit: "cal", color: .orange)
                MacroText(value: Int(totals.protein), unit: "P", color: .blue)
                MacroText(value: Int(totals.carbs), unit: "C", color: .green)
                MacroText(value: Int(totals.fat), unit: "F", color: .red)
            }
            .font(.subheadline)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            MealSectionView(
                meal: .breakfast,
                entries: [
                    FoodEntry(
                        foodId: UUID(),
                        meal: .breakfast,
                        quantity: 100,
                        calories: 165,
                        protein: 31,
                        carbs: 0,
                        fat: 3.6
                    )
                ],
                totals: (calories: 165, protein: 31, carbs: 0, fat: 3.6),
                onAddFood: {},
                onDeleteEntry: { _ in }
            )

            MealSectionView(
                meal: .lunch,
                entries: [],
                totals: (calories: 0, protein: 0, carbs: 0, fat: 0),
                onAddFood: {},
                onDeleteEntry: { _ in }
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
