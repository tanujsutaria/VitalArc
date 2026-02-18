//
//  LogFoodUseCaseTests.swift
//  VitalArcTests
//
//  Tests for LogFoodUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class LogFoodUseCaseTests: XCTestCase {
    var repository: MockNutritionRepository!
    var useCase: LogFoodUseCase!

    override func setUp() async throws {
        repository = MockNutritionRepository()
        useCase = LogFoodUseCase(repository: repository)
    }

    override func tearDown() async throws {
        repository = nil
        useCase = nil
    }

    // MARK: - Test Helpers

    private func makeTestFood(
        name: String = "Chicken Breast",
        servingSize: Double = 100,
        calories: Double = 165,
        protein: Double = 31,
        carbs: Double = 0,
        fat: Double = 3.6
    ) -> Food {
        Food(
            name: name,
            servingSize: servingSize,
            servingUnit: "g",
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }

    // MARK: - Happy Path Tests

    func testLogFoodCreatesEntry() async throws {
        // Given
        let food = makeTestFood()
        let date = Date()

        // When
        let entry = try await useCase.execute(
            food: food,
            quantity: 100,
            meal: .breakfast,
            date: date
        )

        // Then
        XCTAssertEqual(entry.foodId, food.id)
        XCTAssertEqual(entry.meal, .breakfast)
        XCTAssertEqual(entry.quantity, 100)
        XCTAssertEqual(repository.savedFoodEntries.count, 1)
    }

    func testLogFoodScalesQuantityCorrectly() async throws {
        // Given - Food per 100g
        let food = makeTestFood(
            calories: 165,
            protein: 31,
            carbs: 0,
            fat: 3.6
        )

        // When - Log 200g (double the serving)
        let entry = try await useCase.execute(
            food: food,
            quantity: 200,
            meal: .lunch,
            date: Date()
        )

        // Then - Macros should be doubled
        XCTAssertEqual(entry.calories, 330, accuracy: 0.1)
        XCTAssertEqual(entry.protein, 62, accuracy: 0.1)
        XCTAssertEqual(entry.carbs, 0, accuracy: 0.1)
        XCTAssertEqual(entry.fat, 7.2, accuracy: 0.1)
    }

    func testLogFoodScalesToSmallerQuantity() async throws {
        // Given - Food per 100g
        let food = makeTestFood(
            calories: 400,
            protein: 20,
            carbs: 40,
            fat: 10
        )

        // When - Log 50g (half the serving)
        let entry = try await useCase.execute(
            food: food,
            quantity: 50,
            meal: .snack,
            date: Date()
        )

        // Then - Macros should be halved
        XCTAssertEqual(entry.calories, 200, accuracy: 0.1)
        XCTAssertEqual(entry.protein, 10, accuracy: 0.1)
        XCTAssertEqual(entry.carbs, 20, accuracy: 0.1)
        XCTAssertEqual(entry.fat, 5, accuracy: 0.1)
    }

    // MARK: - Meal Type Tests

    func testLogFoodForBreakfast() async throws {
        let food = makeTestFood()

        let entry = try await useCase.execute(
            food: food,
            quantity: 100,
            meal: .breakfast,
            date: Date()
        )

        XCTAssertEqual(entry.meal, .breakfast)
    }

    func testLogFoodForLunch() async throws {
        let food = makeTestFood()

        let entry = try await useCase.execute(
            food: food,
            quantity: 100,
            meal: .lunch,
            date: Date()
        )

        XCTAssertEqual(entry.meal, .lunch)
    }

    func testLogFoodForDinner() async throws {
        let food = makeTestFood()

        let entry = try await useCase.execute(
            food: food,
            quantity: 100,
            meal: .dinner,
            date: Date()
        )

        XCTAssertEqual(entry.meal, .dinner)
    }

    func testLogFoodForSnack() async throws {
        let food = makeTestFood()

        let entry = try await useCase.execute(
            food: food,
            quantity: 100,
            meal: .snack,
            date: Date()
        )

        XCTAssertEqual(entry.meal, .snack)
    }

    // MARK: - Daily Nutrition Update Tests

    func testLogFoodUpdatesDailyNutritionTotals() async throws {
        // Given
        let food = makeTestFood(calories: 200, protein: 20, carbs: 10, fat: 5)
        let date = Date()

        // When
        _ = try await useCase.execute(
            food: food,
            quantity: 100,
            meal: .breakfast,
            date: date
        )

        // Then - Daily nutrition should be updated
        XCTAssertEqual(repository.savedDailyNutritions.count, 1)
        let dailyNutrition = repository.savedDailyNutritions.first
        XCTAssertEqual(dailyNutrition?.caloriesConsumed ?? 0, 200, accuracy: 0.1)
        XCTAssertEqual(dailyNutrition?.proteinConsumed ?? 0, 20, accuracy: 0.1)
    }

    func testLogMultipleFoodsAggregatesDaily() async throws {
        // Given
        let food1 = makeTestFood(name: "Eggs", calories: 150, protein: 12, carbs: 1, fat: 10)
        let food2 = makeTestFood(name: "Toast", calories: 100, protein: 3, carbs: 20, fat: 1)
        let date = Date()

        // When - Log both foods
        _ = try await useCase.execute(food: food1, quantity: 100, meal: .breakfast, date: date)
        _ = try await useCase.execute(food: food2, quantity: 100, meal: .breakfast, date: date)

        // Then - Totals should be aggregated
        let dailyNutrition = repository.savedDailyNutritions.last
        XCTAssertEqual(dailyNutrition?.caloriesConsumed ?? 0, 250, accuracy: 0.1)
        XCTAssertEqual(dailyNutrition?.proteinConsumed ?? 0, 15, accuracy: 0.1)
        XCTAssertEqual(dailyNutrition?.carbsConsumed ?? 0, 21, accuracy: 0.1)
        XCTAssertEqual(dailyNutrition?.fatConsumed ?? 0, 11, accuracy: 0.1)
    }

    func testLogFoodPreservesExistingGoals() async throws {
        // Given - Existing daily nutrition with goals
        let date = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        let existingNutrition = DailyNutrition(
            date: startOfDay,
            caloriesConsumed: 0,
            proteinConsumed: 0,
            carbsConsumed: 0,
            fatConsumed: 0,
            calorieGoal: 2000,
            proteinGoal: 150,
            carbsGoal: 200,
            fatGoal: 70
        )
        repository.mockDailyNutrition[startOfDay] = existingNutrition

        let food = makeTestFood(calories: 300, protein: 30, carbs: 10, fat: 8)

        // When
        _ = try await useCase.execute(food: food, quantity: 100, meal: .lunch, date: date)

        // Then - Goals should be preserved
        let updated = repository.savedDailyNutritions.last
        XCTAssertEqual(updated?.calorieGoal, 2000)
        XCTAssertEqual(updated?.proteinGoal, 150)
        XCTAssertEqual(updated?.carbsGoal, 200)
        XCTAssertEqual(updated?.fatGoal, 70)
    }

    // MARK: - Date Handling Tests

    func testLogFoodWithSpecificDate() async throws {
        // Given
        let food = makeTestFood()
        let yesterday = Date().addingTimeInterval(-86400)

        // When
        let entry = try await useCase.execute(
            food: food,
            quantity: 100,
            meal: .dinner,
            date: yesterday
        )

        // Then
        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDate(entry.date, inSameDayAs: yesterday))
    }

    func testLogFoodForDifferentDaysDoesNotMix() async throws {
        // Given
        let food = makeTestFood(calories: 200, protein: 20, carbs: 10, fat: 5)
        let today = Date()
        let yesterday = today.addingTimeInterval(-86400)

        // When - Log food for two different days
        _ = try await useCase.execute(food: food, quantity: 100, meal: .breakfast, date: today)
        _ = try await useCase.execute(food: food, quantity: 100, meal: .breakfast, date: yesterday)

        // Then - Should have separate daily nutrition records
        XCTAssertEqual(repository.mockDailyNutrition.count, 2)
    }

    // MARK: - Edge Cases

    func testLogFoodWithZeroQuantity() async throws {
        // Given
        let food = makeTestFood()

        // When
        let entry = try await useCase.execute(
            food: food,
            quantity: 0,
            meal: .snack,
            date: Date()
        )

        // Then
        XCTAssertEqual(entry.calories, 0)
        XCTAssertEqual(entry.protein, 0)
    }

    func testLogFoodWithVeryLargeQuantity() async throws {
        // Given - Food per 100g
        let food = makeTestFood(calories: 165, protein: 31, carbs: 0, fat: 3.6)

        // When - Log 1kg
        let entry = try await useCase.execute(
            food: food,
            quantity: 1000,
            meal: .dinner,
            date: Date()
        )

        // Then
        XCTAssertEqual(entry.calories, 1650, accuracy: 0.1)
        XCTAssertEqual(entry.protein, 310, accuracy: 0.1)
    }

    func testLogFoodWithDecimalQuantity() async throws {
        // Given
        let food = makeTestFood(calories: 100, protein: 10, carbs: 10, fat: 5)

        // When
        let entry = try await useCase.execute(
            food: food,
            quantity: 75.5,
            meal: .snack,
            date: Date()
        )

        // Then
        XCTAssertEqual(entry.calories, 75.5, accuracy: 0.1)
        XCTAssertEqual(entry.protein, 7.55, accuracy: 0.1)
    }

    // MARK: - Error Handling

    func testLogFoodThrowsOnSaveError() async throws {
        // Given
        repository.shouldThrowOnSave = true
        let food = makeTestFood()

        // When/Then
        do {
            _ = try await useCase.execute(food: food, quantity: 100, meal: .breakfast, date: Date())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNutritionRepository.MockError)
        }
    }

    // MARK: - Entry Properties Tests

    func testLogFoodEntryHasCorrectFoodId() async throws {
        // Given
        let food = makeTestFood()

        // When
        let entry = try await useCase.execute(
            food: food,
            quantity: 100,
            meal: .breakfast,
            date: Date()
        )

        // Then
        XCTAssertEqual(entry.foodId, food.id)
    }

    func testLogFoodEntryHasUniqueId() async throws {
        // Given
        let food = makeTestFood()

        // When
        let entry1 = try await useCase.execute(food: food, quantity: 100, meal: .breakfast, date: Date())
        let entry2 = try await useCase.execute(food: food, quantity: 100, meal: .lunch, date: Date())

        // Then
        XCTAssertNotEqual(entry1.id, entry2.id)
    }

    // MARK: - Usage Tracking Tests

    func testLogFoodUpdatesUsageTracking() async throws {
        // Given
        let food = makeTestFood()

        // When
        _ = try await useCase.execute(food: food, quantity: 100, meal: .breakfast, date: Date())

        // Then - saveFood should be called (usage tracking updates recentlyUsed/usageCount)
        XCTAssertEqual(repository.savedFoods.count, 1)
        XCTAssertEqual(repository.savedFoods.first?.id, food.id)
    }

    func testLogFoodIncrementsExistingUsageCount() async throws {
        // Given - Food with existing usage count
        var food = makeTestFood()
        food.usageCount = 5
        food.recentlyUsed = Date().addingTimeInterval(-3600)

        // When
        _ = try await useCase.execute(food: food, quantity: 100, meal: .lunch, date: Date())

        // Then - Usage count should be incremented
        let savedFood = repository.savedFoods.first
        XCTAssertNotNil(savedFood)
        XCTAssertEqual(savedFood?.usageCount, 6)
    }

    // MARK: - Fiber/Sugar Propagation Tests

    func testLogFoodPropagatesFiberAndSugar() async throws {
        // Given - Food with fiber and sugar per 100g
        let food = Food(
            name: "Oatmeal",
            servingSize: 100,
            servingUnit: "g",
            calories: 389,
            protein: 16.9,
            carbs: 66.3,
            fat: 6.9,
            fiber: 10.6,
            sugar: 0.9
        )

        // When - Log 200g
        let entry = try await useCase.execute(
            food: food,
            quantity: 200,
            meal: .breakfast,
            date: Date()
        )

        // Then - Fiber and sugar should be scaled and propagated
        XCTAssertEqual(entry.fiber ?? 0, 21.2, accuracy: 0.1)
        XCTAssertEqual(entry.sugar ?? 0, 1.8, accuracy: 0.1)
    }

    func testLogFoodWithNilFiberAndSugar() async throws {
        // Given - Food without fiber/sugar
        let food = makeTestFood() // no fiber/sugar

        // When
        let entry = try await useCase.execute(
            food: food,
            quantity: 100,
            meal: .breakfast,
            date: Date()
        )

        // Then - Fiber and sugar should be nil
        XCTAssertNil(entry.fiber)
        XCTAssertNil(entry.sugar)
    }

    func testLogFoodDailyNutritionIncludesFiberAndSugar() async throws {
        // Given
        let food = Food(
            name: "Apple",
            servingSize: 100,
            servingUnit: "g",
            calories: 52,
            protein: 0.3,
            carbs: 13.8,
            fat: 0.2,
            fiber: 2.4,
            sugar: 10.4
        )
        let date = Date()

        // When
        _ = try await useCase.execute(food: food, quantity: 100, meal: .snack, date: date)

        // Then - Daily nutrition should include fiber/sugar totals
        let dailyNutrition = repository.savedDailyNutritions.last
        XCTAssertNotNil(dailyNutrition)
        XCTAssertEqual(dailyNutrition?.fiberConsumed ?? 0, 2.4, accuracy: 0.1)
        XCTAssertEqual(dailyNutrition?.sugarConsumed ?? 0, 10.4, accuracy: 0.1)
    }
}
