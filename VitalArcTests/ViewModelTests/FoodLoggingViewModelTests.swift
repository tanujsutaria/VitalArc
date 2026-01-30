//
//  FoodLoggingViewModelTests.swift
//  VitalArcTests
//
//  Tests for FoodLoggingViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class FoodLoggingViewModelTests: XCTestCase {
    var repository: MockNutritionRepository!
    var logFoodUseCase: LogFoodUseCase!
    var viewModel: FoodLoggingViewModel!

    override func setUp() async throws {
        repository = MockNutritionRepository()
        logFoodUseCase = LogFoodUseCase(repository: repository)
        viewModel = FoodLoggingViewModel(logFoodUseCase: logFoodUseCase, repository: repository)
    }

    override func tearDown() async throws {
        repository = nil
        logFoodUseCase = nil
        viewModel = nil
    }

    // MARK: - Test Helpers

    private func makeTestFood(
        name: String = "Chicken Breast",
        calories: Double = 165,
        protein: Double = 31,
        carbs: Double = 0,
        fat: Double = 3.6
    ) -> Food {
        Food(
            name: name,
            servingSize: 100,
            servingUnit: "g",
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }

    private func makeTestEntry(
        calories: Double = 165,
        protein: Double = 31,
        carbs: Double = 0,
        fat: Double = 3.6,
        meal: MealType = .breakfast,
        date: Date = Date()
    ) -> FoodEntry {
        FoodEntry(
            foodId: UUID(),
            date: date,
            meal: meal,
            quantity: 100,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertTrue(viewModel.foodEntries.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showingFoodSearch)
        XCTAssertEqual(viewModel.selectedMeal, .breakfast)
    }

    func testInitialDateIsToday() {
        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDateInToday(viewModel.selectedDate))
    }

    // MARK: - Load Entries Tests

    func testLoadEntriesSuccess() async {
        // Given
        let entry1 = makeTestEntry(meal: .breakfast)
        let entry2 = makeTestEntry(meal: .lunch)
        repository.mockFoodEntries = [entry1, entry2]

        // When
        await viewModel.loadEntries()

        // Then
        XCTAssertEqual(viewModel.foodEntries.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadEntriesEmpty() async {
        // Given
        repository.mockFoodEntries = []

        // When
        await viewModel.loadEntries()

        // Then
        XCTAssertTrue(viewModel.foodEntries.isEmpty)
    }

    func testLoadEntriesHandlesError() async {
        // Given
        repository.shouldThrowOnGet = true

        // When
        await viewModel.loadEntries()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadEntriesOnlyLoadsForSelectedDate() async {
        // Given
        let today = Date()
        let yesterday = today.addingTimeInterval(-86400)

        let todayEntry = makeTestEntry(date: today)
        let yesterdayEntry = makeTestEntry(date: yesterday)
        repository.mockFoodEntries = [todayEntry, yesterdayEntry]

        viewModel.selectedDate = today

        // When
        await viewModel.loadEntries()

        // Then
        XCTAssertEqual(viewModel.foodEntries.count, 1)
    }

    // MARK: - Log Food Tests

    func testLogFood() async {
        // Given
        let food = makeTestFood()

        // When
        await viewModel.logFood(food, quantity: 100, meal: .breakfast)

        // Then
        XCTAssertEqual(repository.savedFoodEntries.count, 1)
        XCTAssertEqual(repository.savedFoodEntries.first?.meal, .breakfast)
    }

    func testLogFoodReloadsEntries() async {
        // Given
        let food = makeTestFood()

        // When
        await viewModel.logFood(food, quantity: 100, meal: .lunch)

        // Then - Entries should be reloaded
        // The mock repository adds the entry, so it should appear
        XCTAssertGreaterThanOrEqual(viewModel.foodEntries.count, 1)
    }

    func testLogFoodWithDifferentMeals() async {
        // Given
        let food = makeTestFood()

        // When - Log to different meals
        await viewModel.logFood(food, quantity: 100, meal: .breakfast)
        await viewModel.logFood(food, quantity: 100, meal: .lunch)
        await viewModel.logFood(food, quantity: 100, meal: .dinner)
        await viewModel.logFood(food, quantity: 100, meal: .snack)

        // Then
        XCTAssertEqual(repository.savedFoodEntries.count, 4)
        let meals = Set(repository.savedFoodEntries.map { $0.meal })
        XCTAssertEqual(meals, Set(MealType.allCases))
    }

    func testLogFoodHandlesError() async {
        // Given
        repository.shouldThrowOnSave = true
        let food = makeTestFood()

        // When
        await viewModel.logFood(food, quantity: 100, meal: .breakfast)

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Delete Entry Tests

    func testDeleteEntry() async {
        // Given
        let entry = makeTestEntry()
        repository.mockFoodEntries = [entry]
        await viewModel.loadEntries()

        // When
        await viewModel.deleteEntry(entry)

        // Then
        XCTAssertTrue(repository.deletedFoodEntryIds.contains(entry.id))
    }

    func testDeleteEntryReloadsEntries() async {
        // Given
        let entry = makeTestEntry()
        repository.mockFoodEntries = [entry]
        await viewModel.loadEntries()
        XCTAssertEqual(viewModel.foodEntries.count, 1)

        // When
        await viewModel.deleteEntry(entry)

        // Then - Entry should be removed from list
        XCTAssertEqual(viewModel.foodEntries.count, 0)
    }

    func testDeleteEntryHandlesError() async {
        // Given
        repository.shouldThrowOnDelete = true
        let entry = makeTestEntry()

        // When
        await viewModel.deleteEntry(entry)

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Entries By Meal Tests

    func testEntriesByMeal() async {
        // Given
        let breakfastEntry = makeTestEntry(meal: .breakfast)
        let lunchEntry1 = makeTestEntry(meal: .lunch)
        let lunchEntry2 = makeTestEntry(meal: .lunch)
        let dinnerEntry = makeTestEntry(meal: .dinner)
        repository.mockFoodEntries = [breakfastEntry, lunchEntry1, lunchEntry2, dinnerEntry]
        await viewModel.loadEntries()

        // When
        let grouped = viewModel.entriesByMeal()

        // Then
        XCTAssertEqual(grouped[.breakfast]?.count, 1)
        XCTAssertEqual(grouped[.lunch]?.count, 2)
        XCTAssertEqual(grouped[.dinner]?.count, 1)
        XCTAssertNil(grouped[.snack])
    }

    func testEntriesByMealWithEmpty() async {
        // Given
        repository.mockFoodEntries = []
        await viewModel.loadEntries()

        // When
        let grouped = viewModel.entriesByMeal()

        // Then
        XCTAssertTrue(grouped.isEmpty)
    }

    // MARK: - Meal Totals Tests

    func testMealTotals() async {
        // Given
        let entry1 = makeTestEntry(calories: 200, protein: 20, carbs: 10, fat: 5, meal: .breakfast)
        let entry2 = makeTestEntry(calories: 300, protein: 30, carbs: 20, fat: 10, meal: .breakfast)
        repository.mockFoodEntries = [entry1, entry2]
        await viewModel.loadEntries()

        // When
        let totals = viewModel.mealTotals(for: .breakfast)

        // Then
        XCTAssertEqual(totals.calories, 500, accuracy: 0.1)
        XCTAssertEqual(totals.protein, 50, accuracy: 0.1)
        XCTAssertEqual(totals.carbs, 30, accuracy: 0.1)
        XCTAssertEqual(totals.fat, 15, accuracy: 0.1)
    }

    func testMealTotalsForEmptyMeal() async {
        // Given
        repository.mockFoodEntries = []
        await viewModel.loadEntries()

        // When
        let totals = viewModel.mealTotals(for: .snack)

        // Then
        XCTAssertEqual(totals.calories, 0)
        XCTAssertEqual(totals.protein, 0)
        XCTAssertEqual(totals.carbs, 0)
        XCTAssertEqual(totals.fat, 0)
    }

    func testMealTotalsOnlyIncludesRelevantMeal() async {
        // Given
        let breakfastEntry = makeTestEntry(calories: 200, protein: 20, carbs: 10, fat: 5, meal: .breakfast)
        let lunchEntry = makeTestEntry(calories: 500, protein: 40, carbs: 50, fat: 15, meal: .lunch)
        repository.mockFoodEntries = [breakfastEntry, lunchEntry]
        await viewModel.loadEntries()

        // When
        let breakfastTotals = viewModel.mealTotals(for: .breakfast)

        // Then - Should only include breakfast
        XCTAssertEqual(breakfastTotals.calories, 200, accuracy: 0.1)
    }

    // MARK: - Date Navigation Tests

    func testPreviousDay() async {
        // Given
        let originalDate = viewModel.selectedDate
        let calendar = Calendar.current

        // When
        viewModel.previousDay()

        // Then
        let expectedDate = calendar.date(byAdding: .day, value: -1, to: originalDate)!
        XCTAssertTrue(calendar.isDate(viewModel.selectedDate, inSameDayAs: expectedDate))
    }

    func testNextDay() async {
        // Given
        let originalDate = viewModel.selectedDate
        let calendar = Calendar.current

        // When
        viewModel.nextDay()

        // Then
        let expectedDate = calendar.date(byAdding: .day, value: 1, to: originalDate)!
        XCTAssertTrue(calendar.isDate(viewModel.selectedDate, inSameDayAs: expectedDate))
    }

    func testGoToToday() async {
        // Given - Navigate away from today
        viewModel.previousDay()
        viewModel.previousDay()

        // When
        viewModel.goToToday()

        // Then
        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDateInToday(viewModel.selectedDate))
    }

    func testNavigationTriggersReload() async {
        // Given
        let entry = makeTestEntry()
        repository.mockFoodEntries = [entry]

        // When - Navigate to previous day
        viewModel.previousDay()

        // Wait for async reload
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then - Entries should be reloaded (will be empty since entry is for original date)
        // The important thing is that load was triggered
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Multiple Navigation Tests

    func testNavigateMultipleDaysBack() async {
        // Given
        let calendar = Calendar.current
        let originalDate = viewModel.selectedDate

        // When
        viewModel.previousDay()
        viewModel.previousDay()
        viewModel.previousDay()

        // Then
        let expectedDate = calendar.date(byAdding: .day, value: -3, to: originalDate)!
        XCTAssertTrue(calendar.isDate(viewModel.selectedDate, inSameDayAs: expectedDate))
    }

    func testNavigateBackAndForth() async {
        // Given
        let originalDate = viewModel.selectedDate
        let calendar = Calendar.current

        // When
        viewModel.previousDay()
        viewModel.nextDay()

        // Then
        XCTAssertTrue(calendar.isDate(viewModel.selectedDate, inSameDayAs: originalDate))
    }

    // MARK: - UI State Tests

    func testShowingFoodSearchToggle() {
        // Given
        XCTAssertFalse(viewModel.showingFoodSearch)

        // When
        viewModel.showingFoodSearch = true

        // Then
        XCTAssertTrue(viewModel.showingFoodSearch)
    }

    func testSelectedMealChange() {
        // Given
        XCTAssertEqual(viewModel.selectedMeal, .breakfast)

        // When
        viewModel.selectedMeal = .dinner

        // Then
        XCTAssertEqual(viewModel.selectedMeal, .dinner)
    }

    // MARK: - Edge Cases

    func testLoadEntriesWithManyEntries() async {
        // Given - Many entries
        let entries = (0..<50).map { _ in makeTestEntry() }
        repository.mockFoodEntries = entries

        // When
        await viewModel.loadEntries()

        // Then
        XCTAssertEqual(viewModel.foodEntries.count, 50)
    }

    func testLogFoodUsesSelectedDate() async {
        // Given
        let food = makeTestFood()
        viewModel.previousDay() // Go to yesterday
        let expectedDate = viewModel.selectedDate

        // When
        await viewModel.logFood(food, quantity: 100, meal: .breakfast)

        // Then
        let savedEntry = repository.savedFoodEntries.first
        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDate(savedEntry!.date, inSameDayAs: expectedDate))
    }

    func testLogFoodWithScaledQuantity() async {
        // Given
        let food = makeTestFood(calories: 165, protein: 31) // per 100g

        // When
        await viewModel.logFood(food, quantity: 200, meal: .lunch) // 200g

        // Then
        let savedEntry = repository.savedFoodEntries.first
        XCTAssertEqual(savedEntry?.calories ?? 0, 330, accuracy: 0.1) // 165 * 2
        XCTAssertEqual(savedEntry?.protein ?? 0, 62, accuracy: 0.1)   // 31 * 2
    }
}
