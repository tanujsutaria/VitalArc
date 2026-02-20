//
//  FoodLoggingViewModel.swift
//  VitalArc
//
//  ViewModel for managing food logging
//

import Foundation
import Observation

@MainActor
@Observable
final class FoodLoggingViewModel {
    var selectedDate = Date()
    var foodEntries: [FoodEntry] = []
    var isLoading = false
    var errorMessage: String?
    var showingFoodSearch = false
    var selectedMeal: MealType = MealType.forCurrentTime()
    var isLoggingFood = false
    var isDeletingEntry = false
    var isUpdatingEntry = false

    private let logFoodUseCase: LogFoodUseCaseProtocol
    private let updateFoodEntryUseCase: UpdateFoodEntryUseCaseProtocol
    let repository: NutritionRepository

    init(
        logFoodUseCase: LogFoodUseCaseProtocol,
        updateFoodEntryUseCase: UpdateFoodEntryUseCaseProtocol,
        repository: NutritionRepository
    ) {
        self.logFoodUseCase = logFoodUseCase
        self.updateFoodEntryUseCase = updateFoodEntryUseCase
        self.repository = repository
    }

    /// Load food entries for selected date
    func loadEntries() async {
        isLoading = true
        errorMessage = nil

        do {
            foodEntries = try await repository.getFoodEntries(for: selectedDate)
            isLoading = false
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .loading)
            isLoading = false
        }
    }

    /// Log a food entry
    func logFood(_ food: Food, quantity: Double, meal: MealType) async {
        // Prevent duplicate submissions
        guard !isLoggingFood else { return }
        isLoggingFood = true

        do {
            _ = try await logFoodUseCase.execute(
                food: food,
                quantity: quantity,
                meal: meal,
                date: selectedDate
            )
            await loadEntries()
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .saving)
        }

        isLoggingFood = false
    }

    /// Delete a food entry
    func deleteEntry(_ entry: FoodEntry) async {
        // Prevent duplicate deletions
        guard !isDeletingEntry else { return }
        isDeletingEntry = true

        do {
            try await repository.deleteFoodEntry(id: entry.id)
            await loadEntries()
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .deleting)
        }

        isDeletingEntry = false
    }

    /// Update a food entry's quantity with proportional macro recalculation
    func updateEntry(_ entry: FoodEntry, newQuantity: Double) async {
        guard !isUpdatingEntry else { return }
        isUpdatingEntry = true

        do {
            let updatedEntry = try await updateFoodEntryUseCase.execute(entry: entry, newQuantity: newQuantity)

            // Immediately update the local entry for instant UI feedback
            if let index = foodEntries.firstIndex(where: { $0.id == entry.id }) {
                foodEntries[index] = updatedEntry
            }
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .saving)
        }

        isUpdatingEntry = false
    }

    /// Re-log an existing food entry with the selected date, preserving original serving size
    func relogEntry(_ entry: FoodEntry) async {
        guard !isLoggingFood else { return }
        isLoggingFood = true

        do {
            // Look up the food to get current nutritional data, preserving original quantity
            if let food = try await repository.getFood(id: entry.foodId) {
                // Use logFoodUseCase to properly scale macros from current food data,
                // update daily nutrition totals, and track food usage
                _ = try await logFoodUseCase.execute(
                    food: food,
                    quantity: entry.quantity,
                    meal: entry.meal,
                    date: selectedDate
                )
            } else {
                // Food no longer in DB; fall back to stored macro data
                let newEntry = FoodEntry(
                    foodId: entry.foodId,
                    date: selectedDate,
                    meal: entry.meal,
                    quantity: entry.quantity,
                    calories: entry.calories,
                    protein: entry.protein,
                    carbs: entry.carbs,
                    fat: entry.fat,
                    fiber: entry.fiber,
                    sugar: entry.sugar
                )
                try await repository.saveFoodEntry(newEntry)
            }
            await loadEntries()
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .saving)
        }

        isLoggingFood = false
    }

    /// Get entries grouped by meal
    func entriesByMeal() -> [MealType: [FoodEntry]] {
        Dictionary(grouping: foodEntries) { $0.meal }
    }

    /// Calculate totals for a meal
    func mealTotals(for meal: MealType) -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        let entries = foodEntries.filter { $0.meal == meal }
        return (
            calories: entries.reduce(0) { $0 + $1.calories },
            protein: entries.reduce(0) { $0 + $1.protein },
            carbs: entries.reduce(0) { $0 + $1.carbs },
            fat: entries.reduce(0) { $0 + $1.fat }
        )
    }

    /// Navigate to previous day
    func previousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        Task { await loadEntries() }
    }

    /// Navigate to next day
    func nextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        Task { await loadEntries() }
    }

    /// Go to today
    func goToToday() {
        selectedDate = Date()
        Task { await loadEntries() }
    }
}
