//
//  FoodLoggingView.swift
//  VitalArc
//
//  Main view for logging food entries
//

import SwiftUI

struct FoodLoggingView: View {
    @State private var viewModel: FoodLoggingViewModel
    @State private var showingQuantitySheet = false
    @State private var selectedFood: Food?

    init(logFoodUseCase: LogFoodUseCaseProtocol, repository: NutritionRepository) {
        _viewModel = State(initialValue: FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            repository: repository
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Date selector
                    DateSelectorView(
                        selectedDate: $viewModel.selectedDate,
                        onPrevious: viewModel.previousDay,
                        onNext: viewModel.nextDay,
                        onToday: viewModel.goToToday
                    )
                    .padding(.horizontal)

                    // Meals
                    ForEach(MealType.allCases, id: \.self) { meal in
                        let entries = viewModel.foodEntries.filter { $0.meal == meal }
                        let totals = viewModel.mealTotals(for: meal)

                        MealSectionView(
                            meal: meal,
                            entries: entries,
                            totals: totals,
                            onAddFood: {
                                viewModel.selectedMeal = meal
                                viewModel.showingFoodSearch = true
                            },
                            onDeleteEntry: { entry in
                                Task {
                                    await viewModel.deleteEntry(entry)
                                }
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle("Food Log")
            .task {
                await viewModel.loadEntries()
            }
            .onChange(of: viewModel.selectedDate) {
                Task {
                    await viewModel.loadEntries()
                }
            }
            .sheet(isPresented: $viewModel.showingFoodSearch) {
                FoodSearchView(
                    searchFoodUseCase: SearchFoodUseCase(
                        repository: viewModel.repository,
                        api: USDAFoodAPI()
                    ),
                    onFoodSelected: { food in
                        selectedFood = food
                        showingQuantitySheet = true
                    }
                )
            }
            .sheet(isPresented: $showingQuantitySheet) {
                if let food = selectedFood {
                    QuantityInputView(
                        food: food,
                        meal: viewModel.selectedMeal,
                        onLog: { quantity in
                            Task {
                                await viewModel.logFood(food, quantity: quantity, meal: viewModel.selectedMeal)
                            }
                            showingQuantitySheet = false
                            selectedFood = nil
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Date Selector

private struct DateSelectorView: View {
    @Binding var selectedDate: Date
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void

    private var dateText: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else if Calendar.current.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: selectedDate)
        }
    }

    var body: some View {
        HStack {
            Button {
                onPrevious()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            .buttonStyle(.bordered)

            Spacer()

            Button {
                onToday()
            } label: {
                Text(dateText)
                    .font(.vitalH3)
            }

            Spacer()

            Button {
                onNext()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, Spacing.sm)
    }
}

// MARK: - Quantity Input

private struct QuantityInputView: View {
    let food: Food
    let meal: MealType
    let onLog: (Double) -> Void

    @State private var quantity: String = "100"
    @Environment(\.dismiss) private var dismiss

    private var quantityValue: Double {
        Double(quantity) ?? 100
    }

    private var scaledFood: Food {
        food.scaled(to: quantityValue)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Food") {
                    Text(food.name)
                        .font(.vitalH3)

                    if let brand = food.brand {
                        Text(brand)
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }

                Section("Quantity") {
                    HStack {
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)

                        Text("grams")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Nutrition") {
                    NutritionRow(label: "Calories", value: "\(Int(scaledFood.calories))", color: .vitalPrimary)
                    NutritionRow(label: "Protein", value: "\(Int(scaledFood.protein))g", color: .vitalInfo)
                    NutritionRow(label: "Carbs", value: "\(Int(scaledFood.carbs))g", color: .vitalWarning)
                    NutritionRow(label: "Fat", value: "\(Int(scaledFood.fat))g", color: .vitalDanger)
                }
            }
            .navigationTitle("Log Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        onLog(quantityValue)
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct NutritionRow: View {
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
