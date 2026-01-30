//
//  CalculateNutritionUseCaseTests.swift
//  VitalArcTests
//
//  Tests for CalculateNutritionUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class CalculateNutritionUseCaseTests: XCTestCase {
    var repository: MockNutritionRepository!
    var useCase: CalculateNutritionUseCase!

    override func setUp() async throws {
        repository = MockNutritionRepository()
        useCase = CalculateNutritionUseCase(repository: repository)
    }

    override func tearDown() async throws {
        repository = nil
        useCase = nil
    }

    // MARK: - Test Helpers

    private func makeTestEntry(
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
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

    // MARK: - Calorie Goal Calculation Tests

    func testCalculateMaintenanceCalories() {
        // Given
        let weight = 75.0 // kg

        // When
        let calories = useCase.calculateCalorieGoal(weight: weight, goal: .maintenance)

        // Then - weight × 33
        XCTAssertEqual(calories, 2475, accuracy: 1)
    }

    func testCalculateDeficitCalories() {
        // Given
        let weight = 80.0 // kg

        // When
        let calories = useCase.calculateCalorieGoal(weight: weight, goal: .deficit)

        // Then - (weight × 33) - 500
        XCTAssertEqual(calories, 2140, accuracy: 1)
    }

    func testCalculateSurplusCalories() {
        // Given
        let weight = 70.0 // kg

        // When
        let calories = useCase.calculateCalorieGoal(weight: weight, goal: .surplus)

        // Then - (weight × 33) + 500
        XCTAssertEqual(calories, 2810, accuracy: 1)
    }

    func testCalculateCaloriesWithLowWeight() {
        // Given
        let weight = 50.0 // kg (light person)

        // When
        let maintenance = useCase.calculateCalorieGoal(weight: weight, goal: .maintenance)
        let deficit = useCase.calculateCalorieGoal(weight: weight, goal: .deficit)
        let surplus = useCase.calculateCalorieGoal(weight: weight, goal: .surplus)

        // Then
        XCTAssertEqual(maintenance, 1650, accuracy: 1) // 50 × 33
        XCTAssertEqual(deficit, 1150, accuracy: 1)     // 1650 - 500
        XCTAssertEqual(surplus, 2150, accuracy: 1)     // 1650 + 500
    }

    func testCalculateCaloriesWithHighWeight() {
        // Given
        let weight = 100.0 // kg (heavy person)

        // When
        let maintenance = useCase.calculateCalorieGoal(weight: weight, goal: .maintenance)
        let deficit = useCase.calculateCalorieGoal(weight: weight, goal: .deficit)
        let surplus = useCase.calculateCalorieGoal(weight: weight, goal: .surplus)

        // Then
        XCTAssertEqual(maintenance, 3300, accuracy: 1) // 100 × 33
        XCTAssertEqual(deficit, 2800, accuracy: 1)     // 3300 - 500
        XCTAssertEqual(surplus, 3800, accuracy: 1)     // 3300 + 500
    }

    // MARK: - Daily Nutrition Aggregation Tests

    func testExecuteWithNoEntries() async throws {
        // Given - Empty repository
        let date = Date()

        // When
        let nutrition = try await useCase.execute(for: date)

        // Then
        XCTAssertEqual(nutrition.caloriesConsumed, 0)
        XCTAssertEqual(nutrition.proteinConsumed, 0)
        XCTAssertEqual(nutrition.carbsConsumed, 0)
        XCTAssertEqual(nutrition.fatConsumed, 0)
    }

    func testExecuteWithSingleEntry() async throws {
        // Given
        let date = Date()
        let entry = makeTestEntry(calories: 500, protein: 40, carbs: 50, fat: 15, date: date)
        repository.mockFoodEntries = [entry]

        // When
        let nutrition = try await useCase.execute(for: date)

        // Then
        XCTAssertEqual(nutrition.caloriesConsumed, 500, accuracy: 0.1)
        XCTAssertEqual(nutrition.proteinConsumed, 40, accuracy: 0.1)
        XCTAssertEqual(nutrition.carbsConsumed, 50, accuracy: 0.1)
        XCTAssertEqual(nutrition.fatConsumed, 15, accuracy: 0.1)
    }

    func testExecuteAggregatesMultipleEntries() async throws {
        // Given
        let date = Date()
        let entries = [
            makeTestEntry(calories: 300, protein: 20, carbs: 30, fat: 10, meal: .breakfast, date: date),
            makeTestEntry(calories: 500, protein: 40, carbs: 50, fat: 15, meal: .lunch, date: date),
            makeTestEntry(calories: 600, protein: 45, carbs: 60, fat: 20, meal: .dinner, date: date),
            makeTestEntry(calories: 150, protein: 5, carbs: 20, fat: 5, meal: .snack, date: date)
        ]
        repository.mockFoodEntries = entries

        // When
        let nutrition = try await useCase.execute(for: date)

        // Then
        XCTAssertEqual(nutrition.caloriesConsumed, 1550, accuracy: 0.1)
        XCTAssertEqual(nutrition.proteinConsumed, 110, accuracy: 0.1)
        XCTAssertEqual(nutrition.carbsConsumed, 160, accuracy: 0.1)
        XCTAssertEqual(nutrition.fatConsumed, 50, accuracy: 0.1)
    }

    func testExecuteOnlyIncludesEntriesForRequestedDate() async throws {
        // Given
        let today = Date()
        let yesterday = today.addingTimeInterval(-86400)

        let todayEntry = makeTestEntry(calories: 500, protein: 40, carbs: 50, fat: 15, date: today)
        let yesterdayEntry = makeTestEntry(calories: 300, protein: 20, carbs: 30, fat: 10, date: yesterday)
        repository.mockFoodEntries = [todayEntry, yesterdayEntry]

        // When
        let nutrition = try await useCase.execute(for: today)

        // Then - Only today's entry
        XCTAssertEqual(nutrition.caloriesConsumed, 500, accuracy: 0.1)
    }

    // MARK: - Goal Preservation Tests

    func testExecutePreservesExistingGoals() async throws {
        // Given
        let date = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        let existingNutrition = DailyNutrition(
            date: startOfDay,
            caloriesConsumed: 1000,
            proteinConsumed: 80,
            carbsConsumed: 100,
            fatConsumed: 40,
            calorieGoal: 2000,
            proteinGoal: 150,
            carbsGoal: 200,
            fatGoal: 70
        )
        repository.mockDailyNutrition[startOfDay] = existingNutrition

        let newEntry = makeTestEntry(calories: 500, protein: 40, carbs: 50, fat: 15, date: date)
        repository.mockFoodEntries = [newEntry]

        // When
        let nutrition = try await useCase.execute(for: date)

        // Then - Goals should be preserved
        XCTAssertEqual(nutrition.calorieGoal, 2000)
        XCTAssertEqual(nutrition.proteinGoal, 150)
        XCTAssertEqual(nutrition.carbsGoal, 200)
        XCTAssertEqual(nutrition.fatGoal, 70)
    }

    func testExecuteUpdatesConsumedWhilePreservingGoals() async throws {
        // Given
        let date = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        let existingNutrition = DailyNutrition(
            date: startOfDay,
            caloriesConsumed: 500,
            proteinConsumed: 40,
            carbsConsumed: 50,
            fatConsumed: 15,
            calorieGoal: 2500
        )
        repository.mockDailyNutrition[startOfDay] = existingNutrition

        let newEntry = makeTestEntry(calories: 800, protein: 60, carbs: 80, fat: 25, date: date)
        repository.mockFoodEntries = [newEntry]

        // When
        let nutrition = try await useCase.execute(for: date)

        // Then
        XCTAssertEqual(nutrition.caloriesConsumed, 800, accuracy: 0.1)
        XCTAssertEqual(nutrition.calorieGoal, 2500)
    }

    func testExecuteWithNoExistingGoals() async throws {
        // Given
        let date = Date()
        let entry = makeTestEntry(calories: 500, protein: 40, carbs: 50, fat: 15, date: date)
        repository.mockFoodEntries = [entry]

        // When
        let nutrition = try await useCase.execute(for: date)

        // Then - Goals should be nil
        XCTAssertNil(nutrition.calorieGoal)
        XCTAssertNil(nutrition.proteinGoal)
        XCTAssertNil(nutrition.carbsGoal)
        XCTAssertNil(nutrition.fatGoal)
    }

    // MARK: - Update Goals Tests

    func testUpdateGoalsCreatesNewRecord() async throws {
        // Given
        let date = Date()

        // When
        try await useCase.updateGoals(
            for: date,
            calorieGoal: 2000,
            proteinGoal: 150,
            carbsGoal: 200,
            fatGoal: 70
        )

        // Then
        XCTAssertEqual(repository.savedDailyNutritions.count, 1)
        let saved = repository.savedDailyNutritions.first
        XCTAssertEqual(saved?.calorieGoal, 2000)
        XCTAssertEqual(saved?.proteinGoal, 150)
        XCTAssertEqual(saved?.carbsGoal, 200)
        XCTAssertEqual(saved?.fatGoal, 70)
    }

    func testUpdateGoalsPreservesConsumed() async throws {
        // Given
        let date = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        let existingNutrition = DailyNutrition(
            date: startOfDay,
            caloriesConsumed: 1500,
            proteinConsumed: 120,
            carbsConsumed: 150,
            fatConsumed: 50
        )
        repository.mockDailyNutrition[startOfDay] = existingNutrition

        // When
        try await useCase.updateGoals(for: date, calorieGoal: 2500)

        // Then - Consumed values should be preserved
        let saved = repository.savedDailyNutritions.last
        XCTAssertEqual(saved?.caloriesConsumed ?? 0, 1500, accuracy: 0.1)
        XCTAssertEqual(saved?.proteinConsumed ?? 0, 120, accuracy: 0.1)
        XCTAssertEqual(saved?.calorieGoal, 2500)
    }

    func testUpdatePartialGoals() async throws {
        // Given
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

        // When - Only update calorie goal
        try await useCase.updateGoals(for: date, calorieGoal: 2500)

        // Then - Other goals should be preserved
        let saved = repository.savedDailyNutritions.last
        XCTAssertEqual(saved?.calorieGoal, 2500)
        XCTAssertEqual(saved?.proteinGoal, 150) // preserved
        XCTAssertEqual(saved?.carbsGoal, 200)   // preserved
        XCTAssertEqual(saved?.fatGoal, 70)      // preserved
    }

    // MARK: - Persistence Tests

    func testExecuteSavesDailyNutrition() async throws {
        // Given
        let date = Date()
        let entry = makeTestEntry(calories: 500, protein: 40, carbs: 50, fat: 15, date: date)
        repository.mockFoodEntries = [entry]

        // When
        _ = try await useCase.execute(for: date)

        // Then
        XCTAssertEqual(repository.savedDailyNutritions.count, 1)
    }

    func testExecutePreservesExistingId() async throws {
        // Given
        let date = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let existingId = UUID()

        let existingNutrition = DailyNutrition(
            id: existingId,
            date: startOfDay,
            caloriesConsumed: 500,
            proteinConsumed: 40,
            carbsConsumed: 50,
            fatConsumed: 15
        )
        repository.mockDailyNutrition[startOfDay] = existingNutrition

        let newEntry = makeTestEntry(calories: 300, protein: 20, carbs: 30, fat: 10, date: date)
        repository.mockFoodEntries = [newEntry]

        // When
        let nutrition = try await useCase.execute(for: date)

        // Then
        XCTAssertEqual(nutrition.id, existingId)
    }

    // MARK: - Edge Cases

    func testExecuteWithZeroValues() async throws {
        // Given
        let date = Date()
        let entry = makeTestEntry(calories: 0, protein: 0, carbs: 0, fat: 0, date: date)
        repository.mockFoodEntries = [entry]

        // When
        let nutrition = try await useCase.execute(for: date)

        // Then
        XCTAssertEqual(nutrition.caloriesConsumed, 0)
        XCTAssertEqual(nutrition.proteinConsumed, 0)
        XCTAssertEqual(nutrition.carbsConsumed, 0)
        XCTAssertEqual(nutrition.fatConsumed, 0)
    }

    func testCalculateCaloriesWithZeroWeight() {
        // Given
        let weight = 0.0

        // When
        let calories = useCase.calculateCalorieGoal(weight: weight, goal: .maintenance)

        // Then
        XCTAssertEqual(calories, 0)
    }

    // MARK: - Error Handling

    func testExecuteThrowsOnGetError() async throws {
        // Given
        repository.shouldThrowOnGet = true
        let date = Date()

        // When/Then
        do {
            _ = try await useCase.execute(for: date)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNutritionRepository.MockError)
        }
    }
}
