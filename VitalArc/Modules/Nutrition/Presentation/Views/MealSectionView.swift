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
    var onEditEntry: ((FoodEntry) -> Void)?
    var onRelogEntry: ((FoodEntry) -> Void)?

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
                .accessibilityLabel("Add food to \(meal.rawValue)")
                .accessibilityHint("Double tap to search for food")
            }

            // Entries
            if entries.isEmpty {
                EmptyMealView()
            } else {
                ForEach(entries) { entry in
                    FoodEntryRowView(
                        entry: entry,
                        onDelete: { onDeleteEntry(entry) },
                        onEdit: onEditEntry != nil ? { onEditEntry?(entry) } : nil,
                        onRelog: onRelogEntry != nil ? { onRelogEntry?(entry) } : nil
                    )
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
    var onEdit: (() -> Void)?
    var onRelog: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                if !entry.foodName.isEmpty {
                    Text(entry.foodName)
                        .font(.vitalBody)
                        .fontWeight(.medium)
                }

                Text("\(Int(entry.quantity))g")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

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

            HStack(spacing: Spacing.sm) {
                if onRelog != nil {
                    Button {
                        onRelog?()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalSuccess)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Re-log this food entry")
                }

                if onEdit != nil {
                    Button {
                        onEdit?()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalPrimary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Edit quantity")
                }

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalDanger)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete food entry")
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

private struct MacroText: View {
    let value: Int
    let unit: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.xxs) {
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Meal total")
        .accessibilityValue("\(Int(totals.calories)) calories, \(Int(totals.protein))g protein, \(Int(totals.carbs))g carbs, \(Int(totals.fat))g fat")
    }
}

// MARK: - Edit Quantity Sheet

struct EditQuantitySheet: View {
    let entry: FoodEntry
    let onSave: (Double) -> Void

    @State private var quantity: String
    @Environment(\.dismiss) private var dismiss

    init(entry: FoodEntry, onSave: @escaping (Double) -> Void) {
        self.entry = entry
        self.onSave = onSave
        _quantity = State(initialValue: "\(Int(entry.quantity))")
    }

    private var quantityValue: Double {
        LocaleAwareParsing.parsePositiveDouble(from: quantity) ?? entry.quantity
    }

    private var scale: Double {
        guard entry.quantity > 0 else { return 1.0 }
        return quantityValue / entry.quantity
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Quantity") {
                    HStack {
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)

                        Text("grams")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Updated Nutrition") {
                    NutritionPreviewRow(label: "Calories", value: "\(Int(entry.calories * scale))", color: .vitalPrimary)
                    NutritionPreviewRow(label: "Protein", value: "\(Int(entry.protein * scale))g", color: .vitalInfo)
                    NutritionPreviewRow(label: "Carbs", value: "\(Int(entry.carbs * scale))g", color: .vitalWarning)
                    NutritionPreviewRow(label: "Fat", value: "\(Int(entry.fat * scale))g", color: .vitalDanger)
                }
            }
            .navigationTitle("Edit Quantity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(quantityValue)
                        dismiss()
                    }
                    .disabled(quantityValue <= 0)
                }
            }
        }
    }
}

private struct NutritionPreviewRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(color)
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
                        foodName: "Chicken Breast",
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
                onDeleteEntry: { _ in },
                onEditEntry: { _ in },
                onRelogEntry: { _ in }
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
