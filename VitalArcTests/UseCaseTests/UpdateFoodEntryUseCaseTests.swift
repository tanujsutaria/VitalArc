//
//  UpdateFoodEntryUseCaseTests.swift
//  VitalArcTests
//
//  Tests for UpdateFoodEntryUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class UpdateFoodEntryUseCaseTests: XCTestCase {
    var repository: MockNutritionRepository!
    var useCase: UpdateFoodEntryUseCase!

    override func setUp() async throws {
        repository = MockNutritionRepository()
        useCase = UpdateFoodEntryUseCase(repository: repository)
    }

    override func tearDown() async throws {
        repository = nil
        useCase = nil
    }

    // MARK: - Test Helpers

    private func makeTestEntry(
        id: UUID = UUID(),
        quantity: Double = 100,
        calories: Double = 165,
        protein: Double = 31,
        carbs: Double = 0,
        fat: Double = 3.6,
        fiber: Double? = nil,
        sugar: Double? = nil,
        meal: MealType = .breakfast,
        date: Date = Date()
    ) -> FoodEntry {
        FoodEntry(
            id: id,
            foodId: UUID(),
            date: date,
            meal: meal,
            quantity: quantity,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar
        )
    }

    // MARK: - Macro Recalculation Tests

    func testDoubleQuantityDoublesMacros() async throws {
        // Given
        let entry = makeTestEntry(quantity: 100, calories: 165, protein: 31, carbs: 0, fat: 3.6)
        repository.mockFoodEntries = [entry]

        // When
        let updated = try await useCase.execute(entry: entry, newQuantity: 200)

        // Then
        XCTAssertEqual(updated.quantity, 200)
        XCTAssertEqual(updated.calories, 330, accuracy: 0.1)
        XCTAssertEqual(updated.protein, 62, accuracy: 0.1)
        XCTAssertEqual(updated.carbs, 0, accuracy: 0.1)
        XCTAssertEqual(updated.fat, 7.2, accuracy: 0.1)
    }

    func testHalveQuantityHalvesMacros() async throws {
        // Given
        let entry = makeTestEntry(quantity: 200, calories: 400, protein: 50, carbs: 30, fat: 10)
        repository.mockFoodEntries = [entry]

        // When
        let updated = try await useCase.execute(entry: entry, newQuantity: 100)

        // Then
        XCTAssertEqual(updated.quantity, 100)
        XCTAssertEqual(updated.calories, 200, accuracy: 0.1)
        XCTAssertEqual(updated.protein, 25, accuracy: 0.1)
        XCTAssertEqual(updated.carbs, 15, accuracy: 0.1)
        XCTAssertEqual(updated.fat, 5, accuracy: 0.1)
    }

    func testFiberAndSugarScale() async throws {
        // Given
        let entry = makeTestEntry(quantity: 100, calories: 300, protein: 10, carbs: 50, fat: 5, fiber: 8.0, sugar: 12.0)
        repository.mockFoodEntries = [entry]

        // When
        let updated = try await useCase.execute(entry: entry, newQuantity: 150)

        // Then
        XCTAssertEqual(updated.fiber ?? 0, 12.0, accuracy: 0.1)
        XCTAssertEqual(updated.sugar ?? 0, 18.0, accuracy: 0.1)
    }

    func testNilFiberAndSugarRemainNil() async throws {
        // Given
        let entry = makeTestEntry(quantity: 100, calories: 200, protein: 20, carbs: 10, fat: 5, fiber: nil, sugar: nil)
        repository.mockFoodEntries = [entry]

        // When
        let updated = try await useCase.execute(entry: entry, newQuantity: 200)

        // Then
        XCTAssertNil(updated.fiber)
        XCTAssertNil(updated.sugar)
    }

    func testFractionalScaling() async throws {
        // Given
        let entry = makeTestEntry(quantity: 100, calories: 100, protein: 10, carbs: 20, fat: 5)
        repository.mockFoodEntries = [entry]

        // When
        let updated = try await useCase.execute(entry: entry, newQuantity: 75)

        // Then
        XCTAssertEqual(updated.quantity, 75)
        XCTAssertEqual(updated.calories, 75, accuracy: 0.1)
        XCTAssertEqual(updated.protein, 7.5, accuracy: 0.1)
        XCTAssertEqual(updated.carbs, 15, accuracy: 0.1)
        XCTAssertEqual(updated.fat, 3.75, accuracy: 0.1)
    }

    // MARK: - ID Preservation Tests

    func testPreservesEntryId() async throws {
        // Given
        let entryId = UUID()
        let entry = makeTestEntry(id: entryId)
        repository.mockFoodEntries = [entry]

        // When
        let updated = try await useCase.execute(entry: entry, newQuantity: 150)

        // Then
        XCTAssertEqual(updated.id, entryId)
    }

    func testPreservesFoodId() async throws {
        // Given
        let foodId = UUID()
        let entry = FoodEntry(
            foodId: foodId,
            date: Date(),
            meal: .lunch,
            quantity: 100,
            calories: 200,
            protein: 20,
            carbs: 25,
            fat: 8
        )
        repository.mockFoodEntries = [entry]

        // When
        let updated = try await useCase.execute(entry: entry, newQuantity: 200)

        // Then
        XCTAssertEqual(updated.foodId, foodId)
    }

    func testPreservesDateAndMeal() async throws {
        // Given
        let date = Date().addingTimeInterval(-86400)
        let entry = FoodEntry(
            foodId: UUID(),
            date: date,
            meal: .dinner,
            quantity: 100,
            calories: 300,
            protein: 30,
            carbs: 20,
            fat: 10
        )
        repository.mockFoodEntries = [entry]

        // When
        let updated = try await useCase.execute(entry: entry, newQuantity: 150)

        // Then
        XCTAssertEqual(updated.date, date)
        XCTAssertEqual(updated.meal, .dinner)
    }

    // MARK: - Validation Tests

    func testZeroQuantityThrows() async {
        // Given
        let entry = makeTestEntry()

        // When/Then
        do {
            _ = try await useCase.execute(entry: entry, newQuantity: 0)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is UpdateFoodEntryError)
        }
    }

    func testNegativeQuantityThrows() async {
        // Given
        let entry = makeTestEntry()

        // When/Then
        do {
            _ = try await useCase.execute(entry: entry, newQuantity: -50)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is UpdateFoodEntryError)
        }
    }

    func testZeroOriginalQuantityThrows() async {
        // Given
        let entry = makeTestEntry(quantity: 0)

        // When/Then
        do {
            _ = try await useCase.execute(entry: entry, newQuantity: 100)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is UpdateFoodEntryError)
        }
    }

    // MARK: - Repository Interaction Tests

    func testSavesUpdatedEntryToRepository() async throws {
        // Given
        let entry = makeTestEntry()
        repository.mockFoodEntries = [entry]

        // When
        _ = try await useCase.execute(entry: entry, newQuantity: 200)

        // Then
        XCTAssertEqual(repository.savedFoodEntries.count, 1)
        XCTAssertEqual(repository.savedFoodEntries.first?.quantity ?? 0, 200, accuracy: 0.1)
    }

    func testSaveFailureThrows() async {
        // Given
        let entry = makeTestEntry()
        repository.shouldThrowOnSave = true

        // When/Then
        do {
            _ = try await useCase.execute(entry: entry, newQuantity: 200)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNutritionRepository.MockError)
        }
    }

    func testSameQuantityNoChange() async throws {
        // Given
        let entry = makeTestEntry(quantity: 100, calories: 165, protein: 31, carbs: 0, fat: 3.6)
        repository.mockFoodEntries = [entry]

        // When
        let updated = try await useCase.execute(entry: entry, newQuantity: 100)

        // Then - Values should be the same
        XCTAssertEqual(updated.quantity, 100)
        XCTAssertEqual(updated.calories, 165, accuracy: 0.1)
        XCTAssertEqual(updated.protein, 31, accuracy: 0.1)
        XCTAssertEqual(updated.fat, 3.6, accuracy: 0.1)
    }

    func testVerySmallQuantity() async throws {
        // Given
        let entry = makeTestEntry(quantity: 100, calories: 200, protein: 20, carbs: 30, fat: 10)
        repository.mockFoodEntries = [entry]

        // When
        let updated = try await useCase.execute(entry: entry, newQuantity: 1)

        // Then
        XCTAssertEqual(updated.quantity, 1)
        XCTAssertEqual(updated.calories, 2, accuracy: 0.1)
        XCTAssertEqual(updated.protein, 0.2, accuracy: 0.1)
    }

    func testVeryLargeQuantity() async throws {
        // Given
        let entry = makeTestEntry(quantity: 100, calories: 100, protein: 10, carbs: 10, fat: 5)
        repository.mockFoodEntries = [entry]

        // When
        let updated = try await useCase.execute(entry: entry, newQuantity: 10000)

        // Then
        XCTAssertEqual(updated.quantity, 10000)
        XCTAssertEqual(updated.calories, 10000, accuracy: 0.1)
        XCTAssertEqual(updated.protein, 1000, accuracy: 0.1)
    }
}
