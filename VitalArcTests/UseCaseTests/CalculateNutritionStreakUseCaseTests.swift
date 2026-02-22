//
//  CalculateNutritionStreakUseCaseTests.swift
//  VitalArcTests
//
//  Unit tests for CalculateNutritionStreakUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class CalculateNutritionStreakUseCaseTests: XCTestCase {

    var mockRepository: MockNutritionRepository!
    var useCase: CalculateNutritionStreakUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockNutritionRepository()
        useCase = CalculateNutritionStreakUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeEntry(daysAgo: Int) -> FoodEntry {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: Date()))!
        return FoodEntry(
            foodId: UUID(),
            foodName: "Test Food",
            date: date,
            meal: .lunch,
            quantity: 100,
            calories: 200,
            protein: 20,
            carbs: 30,
            fat: 8
        )
    }

    // MARK: - No Entries

    func testNoEntriesReturnsZeroStreaks() async throws {
        mockRepository.mockFoodEntries = []

        let result = try await useCase.execute()

        XCTAssertEqual(result.currentStreak, 0)
        XCTAssertEqual(result.longestStreak, 0)
    }

    // MARK: - Consecutive Days from Today

    func testConsecutiveDaysFromToday() async throws {
        // Entries for today, yesterday, 2 days ago
        mockRepository.mockFoodEntries = [
            makeEntry(daysAgo: 0),
            makeEntry(daysAgo: 1),
            makeEntry(daysAgo: 2)
        ]

        let result = try await useCase.execute()

        XCTAssertEqual(result.currentStreak, 3)
        XCTAssertEqual(result.longestStreak, 3)
    }

    // MARK: - Gap Yesterday Breaks Streak

    func testGapYesterdayBreaksCurrentStreak() async throws {
        // Entry today and 2 days ago, but NOT yesterday
        mockRepository.mockFoodEntries = [
            makeEntry(daysAgo: 0),
            makeEntry(daysAgo: 2),
            makeEntry(daysAgo: 3)
        ]

        let result = try await useCase.execute()

        XCTAssertEqual(result.currentStreak, 1) // Only today
        XCTAssertEqual(result.longestStreak, 2) // 2+3 days ago
    }

    // MARK: - Today Has No Entries (starts from yesterday)

    func testTodayNoEntriesStartsFromYesterday() async throws {
        // No entry today, but entries yesterday and 2 days ago
        mockRepository.mockFoodEntries = [
            makeEntry(daysAgo: 1),
            makeEntry(daysAgo: 2),
            makeEntry(daysAgo: 3)
        ]

        let result = try await useCase.execute()

        XCTAssertEqual(result.currentStreak, 3)
        XCTAssertEqual(result.longestStreak, 3)
    }

    // MARK: - Longest Streak Different from Current

    func testLongestStreakDifferentFromCurrent() async throws {
        // Current streak: today only (1)
        // Longest streak: 5-9 days ago (5 consecutive)
        mockRepository.mockFoodEntries = [
            makeEntry(daysAgo: 0),
            // gap at 1-4 days ago
            makeEntry(daysAgo: 5),
            makeEntry(daysAgo: 6),
            makeEntry(daysAgo: 7),
            makeEntry(daysAgo: 8),
            makeEntry(daysAgo: 9)
        ]

        let result = try await useCase.execute()

        XCTAssertEqual(result.currentStreak, 1)
        XCTAssertEqual(result.longestStreak, 5)
    }

    // MARK: - Single Day Entry

    func testSingleDayEntryGivesStreakOfOne() async throws {
        mockRepository.mockFoodEntries = [makeEntry(daysAgo: 0)]

        let result = try await useCase.execute()

        XCTAssertEqual(result.currentStreak, 1)
        XCTAssertEqual(result.longestStreak, 1)
    }

    // MARK: - Multiple Entries Same Day

    func testMultipleEntriesSameDayCountsAsOne() async throws {
        // 3 entries today, 2 entries yesterday
        mockRepository.mockFoodEntries = [
            makeEntry(daysAgo: 0),
            makeEntry(daysAgo: 0),
            makeEntry(daysAgo: 0),
            makeEntry(daysAgo: 1),
            makeEntry(daysAgo: 1)
        ]

        let result = try await useCase.execute()

        XCTAssertEqual(result.currentStreak, 2)
        XCTAssertEqual(result.longestStreak, 2)
    }

    // MARK: - No Entry Today or Yesterday

    func testNoEntryTodayOrYesterdayReturnsZeroCurrent() async throws {
        // Entries only 3+ days ago
        mockRepository.mockFoodEntries = [
            makeEntry(daysAgo: 3),
            makeEntry(daysAgo: 4)
        ]

        let result = try await useCase.execute()

        XCTAssertEqual(result.currentStreak, 0)
        XCTAssertEqual(result.longestStreak, 2)
    }
}
