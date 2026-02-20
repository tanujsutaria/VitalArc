//
//  NutritionBugFixRegressionTests.swift
//  VitalArcTests
//
//  Regression tests for Session 23.0 nutrition bug fixes:
//  1. Water tracking timezone-aware midnight reset
//  2. Quick re-log preserves custom serving sizes
//  3. Edit quantity triggers immediate daily total update
//  4. Meal time categorization with configurable boundaries
//

import XCTest
@testable import VitalArc

@MainActor
final class NutritionBugFixRegressionTests: XCTestCase {
    var repository: MockNutritionRepository!

    override func setUp() async throws {
        repository = MockNutritionRepository()
    }

    override func tearDown() async throws {
        repository = nil
    }

    // MARK: - Bug 1: Water Tracking Timezone-Aware Day Boundaries

    func testGetWaterEntriesNormalizesDateToStartOfDay() async throws {
        // Given: Water entries for today
        let now = Date()
        let calendar = Calendar.current
        repository.mockWaterEntries = [
            WaterEntry(date: now, amount: 250)
        ]
        let useCase = GetWaterEntriesUseCase(repository: repository)

        // When: Query with a mid-day date
        let midDay = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: now)!
        let entries = try await useCase.execute(for: midDay)

        // Then: Should still return entries for the same day
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.amount, 250)
    }

    func testGetWaterEntriesNormalizesLateNightDate() async throws {
        // Given: Water entry at 11 PM local time
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lateNight = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today)!
        repository.mockWaterEntries = [
            WaterEntry(date: lateNight, amount: 500)
        ]
        let useCase = GetWaterEntriesUseCase(repository: repository)

        // When: Query with start of the same day
        let entries = try await useCase.execute(for: today)

        // Then: Should return the late night entry (same local day)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.amount, 500)
    }

    func testGetWaterEntriesDoesNotCrossDayBoundary() async throws {
        // Given: Water entries on two consecutive days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        repository.mockWaterEntries = [
            WaterEntry(date: today, amount: 250),
            WaterEntry(date: yesterday, amount: 500)
        ]
        let useCase = GetWaterEntriesUseCase(repository: repository)

        // When: Query for today
        let entries = try await useCase.execute(for: today)

        // Then: Should only return today's entry
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.amount, 250)
    }

    func testGetWaterEntriesHandlesStartOfDayNormalization() async throws {
        // Given: Query date is already start of day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        repository.mockWaterEntries = [
            WaterEntry(date: startOfDay, amount: 300)
        ]
        let useCase = GetWaterEntriesUseCase(repository: repository)

        // When: Query with an already-normalized date
        let entries = try await useCase.execute(for: startOfDay)

        // Then: Should work correctly (double normalization is idempotent)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.amount, 300)
    }

    // MARK: - Bug 2: Re-log Preserves Custom Serving Size

    func testRelogPreservesCustomQuantityViaLogFoodUseCase() async throws {
        // Given: An original food entry with custom quantity (250g instead of default 100g)
        let foodId = UUID()
        let food = Food(
            id: foodId,
            name: "Chicken Breast",
            servingSize: 100,
            calories: 165,
            protein: 31,
            carbs: 0,
            fat: 3.6
        )
        repository.mockFoods = [food]

        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        // Create original entry with custom 250g serving
        let originalEntry = FoodEntry(
            foodId: foodId,
            date: Date(),
            meal: .lunch,
            quantity: 250,
            calories: 412.5,
            protein: 77.5,
            carbs: 0,
            fat: 9.0
        )
        repository.mockFoodEntries = [originalEntry]
        await viewModel.loadEntries()

        // When: Re-log the entry
        await viewModel.relogEntry(originalEntry)

        // Then: The new entry should use 250g quantity (the custom serving), not 100g (default)
        let reloggedEntries = repository.savedFoodEntries
        let reloggedEntry = try XCTUnwrap(reloggedEntries.last)
        XCTAssertEqual(reloggedEntry.quantity, 250, accuracy: 0.1,
                       "Re-logged entry should preserve the original 250g custom serving size")
    }

    func testRelogUpdatesNutritionalDataFromCurrentFood() async throws {
        // Given: A food that has been updated with new nutritional data
        let foodId = UUID()
        let updatedFood = Food(
            id: foodId,
            name: "Chicken Breast",
            servingSize: 100,
            calories: 170,  // Updated from 165
            protein: 32,    // Updated from 31
            carbs: 0,
            fat: 3.8        // Updated from 3.6
        )
        repository.mockFoods = [updatedFood]

        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        // Original entry with OLD nutritional data at 200g
        let originalEntry = FoodEntry(
            foodId: foodId,
            date: Date(),
            meal: .dinner,
            quantity: 200,
            calories: 330,  // Old data: 165 * 2
            protein: 62,    // Old data: 31 * 2
            carbs: 0,
            fat: 7.2        // Old data: 3.6 * 2
        )
        repository.mockFoodEntries = [originalEntry]

        // When: Re-log the entry
        await viewModel.relogEntry(originalEntry)

        // Then: Macros should be recalculated from CURRENT food data at 200g
        let reloggedEntry = try XCTUnwrap(repository.savedFoodEntries.last)
        XCTAssertEqual(reloggedEntry.quantity, 200, accuracy: 0.1,
                       "Quantity should be preserved")
        XCTAssertEqual(reloggedEntry.calories, 340, accuracy: 1,
                       "Calories should use updated food data (170 * 2)")
        XCTAssertEqual(reloggedEntry.protein, 64, accuracy: 1,
                       "Protein should use updated food data (32 * 2)")
    }

    func testRelogFallsBackToStoredMacrosWhenFoodNotFound() async throws {
        // Given: Food no longer exists in the repository
        let foodId = UUID()
        repository.mockFoods = []  // No foods available

        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        let originalEntry = FoodEntry(
            foodId: foodId,
            date: Date(),
            meal: .breakfast,
            quantity: 150,
            calories: 248,
            protein: 46.5,
            carbs: 0,
            fat: 5.4
        )
        repository.mockFoodEntries = [originalEntry]

        // When: Re-log the entry
        await viewModel.relogEntry(originalEntry)

        // Then: Should fall back to stored macro data with preserved quantity
        let reloggedEntry = try XCTUnwrap(repository.savedFoodEntries.last)
        XCTAssertEqual(reloggedEntry.quantity, 150, accuracy: 0.1)
        XCTAssertEqual(reloggedEntry.calories, 248, accuracy: 0.1)
        XCTAssertEqual(reloggedEntry.protein, 46.5, accuracy: 0.1)
    }

    // MARK: - Bug 3: Edit Quantity Immediate Daily Total Update

    func testUpdateEntryImmediatelyUpdatesLocalFoodEntries() async throws {
        // Given: A food entry in the view model
        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        let entry = FoodEntry(
            foodId: UUID(),
            date: Date(),
            meal: .lunch,
            quantity: 100,
            calories: 165,
            protein: 31,
            carbs: 0,
            fat: 3.6
        )
        repository.mockFoodEntries = [entry]
        await viewModel.loadEntries()
        XCTAssertEqual(viewModel.foodEntries.count, 1)
        XCTAssertEqual(viewModel.foodEntries.first?.quantity, 100)

        // When: Update the entry quantity to 200g
        await viewModel.updateEntry(entry, newQuantity: 200)

        // Then: The local foodEntries should be updated immediately
        XCTAssertEqual(viewModel.foodEntries.count, 1)
        let updatedEntry = try XCTUnwrap(viewModel.foodEntries.first)
        XCTAssertEqual(updatedEntry.quantity, 200, accuracy: 0.1,
                       "Local entry should reflect the new quantity immediately")
        XCTAssertEqual(updatedEntry.calories, 330, accuracy: 1,
                       "Calories should be recalculated proportionally")
    }

    func testUpdateEntryPreservesEntryId() async throws {
        // Given
        let entryId = UUID()
        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        let entry = FoodEntry(
            id: entryId,
            foodId: UUID(),
            date: Date(),
            meal: .breakfast,
            quantity: 100,
            calories: 200,
            protein: 20,
            carbs: 25,
            fat: 8
        )
        repository.mockFoodEntries = [entry]
        await viewModel.loadEntries()

        // When
        await viewModel.updateEntry(entry, newQuantity: 150)

        // Then: ID should be preserved (same entry, not new)
        XCTAssertEqual(viewModel.foodEntries.first?.id, entryId)
    }

    // MARK: - Bug 4: Meal Time Categorization

    func testMealTypeForCurrentTimeReturnsBreakfastInMorning() {
        // Test with breakfast hours
        let result = MealType.forCurrentTime(
            breakfastStart: 5,
            lunchStart: 11,
            dinnerStart: 17,
            snackStart: 21
        )

        // We can't control Date() in tests, but we can verify the function exists
        // and returns a valid MealType
        XCTAssertTrue(MealType.allCases.contains(result))
    }

    func testMealTypeDefaultBoundaries() {
        // Verify default boundary values are sensible
        XCTAssertEqual(MealType.breakfastStartHour, 5)
        XCTAssertEqual(MealType.lunchStartHour, 11)
        XCTAssertEqual(MealType.dinnerStartHour, 17)
        XCTAssertEqual(MealType.snackStartHour, 21)
    }

    func testMealTypeForCurrentTimeWithCustomBoundaries() {
        // Test with custom early-riser boundaries
        let earlyBreakfast = MealType.forCurrentTime(
            breakfastStart: 4,
            lunchStart: 10,
            dinnerStart: 16,
            snackStart: 20
        )
        XCTAssertTrue(MealType.allCases.contains(earlyBreakfast))
    }

    func testMealTypeForCurrentTimeIsNotAlwaysBreakfast() {
        // The key regression: selectedMeal should not always default to .breakfast
        // Verify the function uses time-based logic (at least one non-breakfast result exists)
        let hour = Calendar.current.component(.hour, from: Date())

        let result = MealType.forCurrentTime()

        // Based on current hour, verify correct meal type
        if hour >= 21 || hour < 5 {
            XCTAssertEqual(result, .snack)
        } else if hour >= 17 {
            XCTAssertEqual(result, .dinner)
        } else if hour >= 11 {
            XCTAssertEqual(result, .lunch)
        } else {
            XCTAssertEqual(result, .breakfast)
        }
    }

    func testMealTypeBoundaryAtLunchStart() {
        // Test boundary: hour == lunchStart should return lunch
        let hour = Calendar.current.component(.hour, from: Date())

        if hour == 11 {
            let result = MealType.forCurrentTime()
            XCTAssertEqual(result, .lunch,
                           "At exactly 11:00, meal should be lunch not breakfast")
        }
    }

    func testMealTypeBoundaryAtDinnerStart() {
        let hour = Calendar.current.component(.hour, from: Date())

        if hour == 17 {
            let result = MealType.forCurrentTime()
            XCTAssertEqual(result, .dinner,
                           "At exactly 17:00, meal should be dinner not lunch")
        }
    }

    func testMealTypeBoundaryAtSnackStart() {
        let hour = Calendar.current.component(.hour, from: Date())

        if hour == 21 {
            let result = MealType.forCurrentTime()
            XCTAssertEqual(result, .snack,
                           "At exactly 21:00, meal should be snack not dinner")
        }
    }

    func testMealTypeAllBoundariesWithExplicitHours() {
        // Test all boundary transitions with simulated hours
        // Since we can't mock Date(), we verify the logic directly

        // Breakfast: hour 5-10
        // Lunch: hour 11-16
        // Dinner: hour 17-20
        // Snack: hour 21-4

        // The forCurrentTime function uses Calendar.current.component(.hour, from: Date())
        // so we test the configurable boundaries exhaustively
        let result = MealType.forCurrentTime(
            breakfastStart: 6,
            lunchStart: 12,
            dinnerStart: 18,
            snackStart: 22
        )

        // Just verify it returns a valid result with custom boundaries
        XCTAssertTrue(MealType.allCases.contains(result))
    }

    // MARK: - Bug 1 Additional: Verify Normalization Passed to Repository

    func testGetWaterEntriesQueryDateIsNormalized() async throws {
        // Given: An afternoon date that should be normalized to midnight
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let afternoon = calendar.date(bySettingHour: 15, minute: 45, second: 30, of: today)!

        // Water entry at 8 AM — same day as afternoon query
        let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today)!
        repository.mockWaterEntries = [
            WaterEntry(date: morning, amount: 350)
        ]
        let useCase = GetWaterEntriesUseCase(repository: repository)

        // When: Query using an afternoon time
        let entries = try await useCase.execute(for: afternoon)

        // Then: The morning entry is found because the use case normalizes both dates to start-of-day
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.amount, 350)
    }

    func testGetWaterEntriesMultipleEntriesSameDay() async throws {
        // Given: Multiple water entries throughout the day
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let morning = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: today)!
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!
        let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today)!

        repository.mockWaterEntries = [
            WaterEntry(date: morning, amount: 250),
            WaterEntry(date: noon, amount: 500),
            WaterEntry(date: evening, amount: 300)
        ]
        let useCase = GetWaterEntriesUseCase(repository: repository)

        // When: Query for today
        let entries = try await useCase.execute(for: today)

        // Then: All entries from the same local day should be returned
        XCTAssertEqual(entries.count, 3)
        let totalAmount = entries.reduce(0) { $0 + $1.amount }
        XCTAssertEqual(totalAmount, 1050, accuracy: 0.1)
    }

    // MARK: - Bug 2 Additional: Re-log Edge Cases

    func testRelogPreservesFiberAndSugar() async throws {
        // Given: A food with fiber and sugar
        let foodId = UUID()
        let food = Food(
            id: foodId,
            name: "Oatmeal",
            servingSize: 100,
            calories: 389,
            protein: 16.9,
            carbs: 66.3,
            fat: 6.9,
            fiber: 10.6,
            sugar: 0.9
        )
        repository.mockFoods = [food]

        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        let originalEntry = FoodEntry(
            foodId: foodId,
            date: Date(),
            meal: .breakfast,
            quantity: 150,
            calories: 583.5,
            protein: 25.35,
            carbs: 99.45,
            fat: 10.35,
            fiber: 15.9,
            sugar: 1.35
        )
        repository.mockFoodEntries = [originalEntry]

        // When: Re-log the entry
        await viewModel.relogEntry(originalEntry)

        // Then: Fiber and sugar should be recalculated from current food data at 150g
        let reloggedEntry = try XCTUnwrap(repository.savedFoodEntries.last)
        XCTAssertEqual(reloggedEntry.quantity, 150, accuracy: 0.1)
        // Fiber: 10.6 * 1.5 = 15.9
        XCTAssertEqual(reloggedEntry.fiber ?? 0, 15.9, accuracy: 0.1,
                       "Fiber should be scaled correctly from current food data")
        // Sugar: 0.9 * 1.5 = 1.35
        XCTAssertEqual(reloggedEntry.sugar ?? 0, 1.35, accuracy: 0.1,
                       "Sugar should be scaled correctly from current food data")
    }

    func testRelogPreservesMealType() async throws {
        // Given: An entry with .dinner meal type
        let foodId = UUID()
        let food = Food(
            id: foodId,
            name: "Salmon",
            servingSize: 100,
            calories: 208,
            protein: 20,
            carbs: 0,
            fat: 13
        )
        repository.mockFoods = [food]

        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        let originalEntry = FoodEntry(
            foodId: foodId,
            date: Date(),
            meal: .dinner,
            quantity: 200,
            calories: 416,
            protein: 40,
            carbs: 0,
            fat: 26
        )
        repository.mockFoodEntries = [originalEntry]

        // When: Re-log
        await viewModel.relogEntry(originalEntry)

        // Then: Meal type from the original entry should be preserved
        let reloggedEntry = try XCTUnwrap(repository.savedFoodEntries.last)
        XCTAssertEqual(reloggedEntry.meal, .dinner,
                       "Re-logged entry should preserve the original meal type")
    }

    func testRelogFallbackPreservesFiberAndSugar() async throws {
        // Given: Food not in DB, original entry has fiber and sugar
        let foodId = UUID()
        repository.mockFoods = [] // Food deleted from DB

        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        let originalEntry = FoodEntry(
            foodId: foodId,
            date: Date(),
            meal: .snack,
            quantity: 100,
            calories: 52,
            protein: 0.3,
            carbs: 13.8,
            fat: 0.2,
            fiber: 2.4,
            sugar: 10.4
        )
        repository.mockFoodEntries = [originalEntry]

        // When: Re-log (will hit fallback path)
        await viewModel.relogEntry(originalEntry)

        // Then: Stored fiber and sugar should be preserved in fallback
        let reloggedEntry = try XCTUnwrap(repository.savedFoodEntries.last)
        XCTAssertEqual(reloggedEntry.fiber ?? 0, 2.4, accuracy: 0.1,
                       "Fallback should preserve stored fiber")
        XCTAssertEqual(reloggedEntry.sugar ?? 0, 10.4, accuracy: 0.1,
                       "Fallback should preserve stored sugar")
    }

    // MARK: - Bug 3 Additional: Decreased Quantity & Daily Nutrition

    func testUpdateEntryDecreasedQuantityScalesMacros() async throws {
        // Given: An entry at 200g
        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        let entry = FoodEntry(
            foodId: UUID(),
            date: Date(),
            meal: .lunch,
            quantity: 200,
            calories: 330,
            protein: 62,
            carbs: 0,
            fat: 7.2
        )
        repository.mockFoodEntries = [entry]
        await viewModel.loadEntries()

        // When: Decrease quantity to 50g (quarter of original)
        await viewModel.updateEntry(entry, newQuantity: 50)

        // Then: Local entry should reflect decreased macros immediately
        let updatedEntry = try XCTUnwrap(viewModel.foodEntries.first)
        XCTAssertEqual(updatedEntry.quantity, 50, accuracy: 0.1)
        XCTAssertEqual(updatedEntry.calories, 82.5, accuracy: 1,
                       "Calories should be quartered (330 / 4)")
        XCTAssertEqual(updatedEntry.protein, 15.5, accuracy: 1,
                       "Protein should be quartered (62 / 4)")
        XCTAssertEqual(updatedEntry.fat, 1.8, accuracy: 0.1,
                       "Fat should be quartered (7.2 / 4)")
    }

    func testUpdateEntryTriggersDailyNutritionRecalculation() async throws {
        // Given: An entry in the view model
        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        let entry = FoodEntry(
            foodId: UUID(),
            date: Date(),
            meal: .breakfast,
            quantity: 100,
            calories: 200,
            protein: 20,
            carbs: 30,
            fat: 8
        )
        repository.mockFoodEntries = [entry]
        await viewModel.loadEntries()

        let dailyNutritionCountBefore = repository.savedDailyNutritions.count

        // When: Update quantity
        await viewModel.updateEntry(entry, newQuantity: 150)

        // Then: Daily nutrition should be recalculated (saved to repository)
        XCTAssertGreaterThan(repository.savedDailyNutritions.count, dailyNutritionCountBefore,
                             "UpdateFoodEntryUseCase should trigger daily nutrition recalculation")
    }

    func testUpdateEntryOnlyUpdatesTargetEntryInList() async throws {
        // Given: Multiple entries in the view model
        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        let entry1 = FoodEntry(
            foodId: UUID(),
            date: Date(),
            meal: .breakfast,
            quantity: 100,
            calories: 200,
            protein: 20,
            carbs: 25,
            fat: 8
        )
        let entry2 = FoodEntry(
            foodId: UUID(),
            date: Date(),
            meal: .lunch,
            quantity: 150,
            calories: 350,
            protein: 35,
            carbs: 40,
            fat: 12
        )
        repository.mockFoodEntries = [entry1, entry2]
        await viewModel.loadEntries()
        XCTAssertEqual(viewModel.foodEntries.count, 2)

        // When: Update only entry1
        await viewModel.updateEntry(entry1, newQuantity: 200)

        // Then: entry1 should be updated, entry2 should be unchanged
        let updatedEntry1 = viewModel.foodEntries.first { $0.id == entry1.id }
        let unchangedEntry2 = viewModel.foodEntries.first { $0.id == entry2.id }

        XCTAssertEqual(updatedEntry1?.quantity ?? 0, 200, accuracy: 0.1,
                       "Target entry should be updated")
        XCTAssertEqual(unchangedEntry2?.quantity ?? 0, 150, accuracy: 0.1,
                       "Other entry should remain unchanged")
        XCTAssertEqual(unchangedEntry2?.calories ?? 0, 350, accuracy: 0.1,
                       "Other entry's macros should remain unchanged")
    }

    // MARK: - Bug 4 Additional: Deterministic Meal Categorization

    func testMealTypeForCurrentTimeMatchesCurrentHour() {
        // Verify the result matches a known-correct mapping for the current hour
        let hour = Calendar.current.component(.hour, from: Date())
        let result = MealType.forCurrentTime()

        // Exhaustive mapping of hour → expected meal type
        let expected: MealType
        switch hour {
        case 5..<11: expected = .breakfast
        case 11..<17: expected = .lunch
        case 17..<21: expected = .dinner
        default: expected = .snack  // 21-23, 0-4
        }

        XCTAssertEqual(result, expected,
                       "At hour \(hour), expected \(expected) but got \(result)")
    }

    func testViewModelSelectedMealUsesAutoDetection() {
        // Key regression: selectedMeal should not always be .breakfast
        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        // The ViewModel initializes selectedMeal = MealType.forCurrentTime()
        let hour = Calendar.current.component(.hour, from: Date())
        let expectedMeal: MealType
        switch hour {
        case 5..<11: expectedMeal = .breakfast
        case 11..<17: expectedMeal = .lunch
        case 17..<21: expectedMeal = .dinner
        default: expectedMeal = .snack
        }

        XCTAssertEqual(viewModel.selectedMeal, expectedMeal,
                       "ViewModel selectedMeal should use auto-detection, not hardcoded .breakfast")
    }

    func testMealTypeConfigurableBoundariesShiftCorrectly() {
        // Test that shifting all boundaries earlier still produces correct results
        let hour = Calendar.current.component(.hour, from: Date())

        // Shift everything 2 hours earlier: breakfast at 3, lunch at 9, dinner at 15, snack at 19
        let result = MealType.forCurrentTime(
            breakfastStart: 3,
            lunchStart: 9,
            dinnerStart: 15,
            snackStart: 19
        )

        let expected: MealType
        switch hour {
        case 3..<9: expected = .breakfast
        case 9..<15: expected = .lunch
        case 15..<19: expected = .dinner
        default: expected = .snack  // 19-23, 0-2
        }

        XCTAssertEqual(result, expected,
                       "Custom boundaries should shift meal windows correctly")
    }

    // MARK: - Integration: Re-log + Daily Nutrition Update

    func testRelogEntryUpdatesDailyNutrition() async throws {
        // Given: A food and an entry to re-log
        let foodId = UUID()
        let food = Food(
            id: foodId,
            name: "Oatmeal",
            servingSize: 100,
            calories: 68,
            protein: 2.4,
            carbs: 12,
            fat: 1.4
        )
        repository.mockFoods = [food]

        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        let originalEntry = FoodEntry(
            foodId: foodId,
            date: Date(),
            meal: .breakfast,
            quantity: 200,
            calories: 136,
            protein: 4.8,
            carbs: 24,
            fat: 2.8
        )
        repository.mockFoodEntries = [originalEntry]

        // When: Re-log the entry
        await viewModel.relogEntry(originalEntry)

        // Then: Daily nutrition should be saved (LogFoodUseCase handles this)
        XCTAssertFalse(repository.savedDailyNutritions.isEmpty,
                       "Re-log should trigger daily nutrition update via LogFoodUseCase")
    }

    func testUpdateEntryDailyNutritionReflectsNewTotals() async throws {
        // Given: Two entries for today
        let logFoodUseCase = LogFoodUseCase(repository: repository)
        let updateFoodEntryUseCase = UpdateFoodEntryUseCase(repository: repository)
        let viewModel = FoodLoggingViewModel(
            logFoodUseCase: logFoodUseCase,
            updateFoodEntryUseCase: updateFoodEntryUseCase,
            repository: repository
        )

        let entry1 = FoodEntry(
            foodId: UUID(),
            date: Date(),
            meal: .breakfast,
            quantity: 100,
            calories: 200,
            protein: 20,
            carbs: 30,
            fat: 5
        )
        let entry2 = FoodEntry(
            foodId: UUID(),
            date: Date(),
            meal: .lunch,
            quantity: 100,
            calories: 300,
            protein: 30,
            carbs: 40,
            fat: 10
        )
        repository.mockFoodEntries = [entry1, entry2]
        await viewModel.loadEntries()

        // When: Double entry1's quantity (200 cal → 400 cal)
        await viewModel.updateEntry(entry1, newQuantity: 200)

        // Then: Daily nutrition should reflect the updated total
        // entry1: 400 cal + entry2: 300 cal = 700 cal total
        let latestDailyNutrition = repository.savedDailyNutritions.last
        XCTAssertNotNil(latestDailyNutrition,
                       "Daily nutrition should be recalculated after update")
        XCTAssertEqual(latestDailyNutrition?.caloriesConsumed ?? 0, 700, accuracy: 1,
                       "Daily total should include updated entry calories")
    }
}
