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
    var selectedMeal: MealType = .breakfast
    var isLoggingFood = false
    var isDeletingEntry = false

    private let logFoodUseCase: LogFoodUseCaseProtocol
    let repository: NutritionRepository

    init(logFoodUseCase: LogFoodUseCaseProtocol, repository: NutritionRepository) {
        self.logFoodUseCase = logFoodUseCase
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
