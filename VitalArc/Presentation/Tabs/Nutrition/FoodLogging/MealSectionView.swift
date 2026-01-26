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
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                // Meal icon and name
                HStack(spacing: Spacing.sm) {
                    Image(systemName: mealIcon)
                        .font(.vitalH2)
                        .foregroundStyle(mealColor)

                    Text(meal.rawValue)
                        .font(.vitalH3)
                }

                Spacer()

                // Totals
                if !entries.isEmpty {
                    Text("\(Int(totals.calories)) cal")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                // Add button
                Button {
                    onAddFood()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.vitalH2)
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
        .background(Color.vitalAdaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
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
            return .vitalWarning
        case .lunch:
            return .vitalPrimary
        case .dinner:
            return .vitalInfo
        case .snack:
            return .vitalSuccess
        }
    }
}

// MARK: - Subviews

private struct EmptyMealView: View {
    var body: some View {
        Text("No foods logged")
            .font(.vitalBody)
            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            .padding(.vertical, Spacing.sm)
    }
}

private struct FoodEntryRowView: View {
    let entry: FoodEntry
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("\(Int(entry.quantity))g")
                    .font(.vitalBody)
                    .fontWeight(.medium)

                // Macros
                HStack(spacing: Spacing.sm) {
                    MacroText(value: Int(entry.calories), unit: "cal", color: .vitalPrimary)
                    MacroText(value: Int(entry.protein), unit: "P", color: .vitalInfo)
                    MacroText(value: Int(entry.carbs), unit: "C", color: .vitalWarning)
                    MacroText(value: Int(entry.fat), unit: "F", color: .vitalDanger)
                }
                .font(.vitalCaption)
            }

            Spacer()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalDanger)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Spacing.xs)
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
            .padding(.vertical, Spacing.xs)

        HStack {
            Text("Total")
                .font(.vitalBody)
                .fontWeight(.semibold)

            Spacer()

            HStack(spacing: Spacing.md) {
                MacroText(value: Int(totals.calories), unit: "cal", color: .vitalPrimary)
                MacroText(value: Int(totals.protein), unit: "P", color: .vitalInfo)
                MacroText(value: Int(totals.carbs), unit: "C", color: .vitalWarning)
                MacroText(value: Int(totals.fat), unit: "F", color: .vitalDanger)
            }
            .font(.vitalBody)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
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
    .background(Color.vitalAdaptiveBackground)
}
