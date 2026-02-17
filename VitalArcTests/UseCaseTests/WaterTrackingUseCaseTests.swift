//
//  WaterTrackingUseCaseTests.swift
//  VitalArcTests
//
//  Tests for LogWaterUseCase, GetWaterEntriesUseCase, and DeleteWaterEntryUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class WaterTrackingUseCaseTests: XCTestCase {
    var repository: MockNutritionRepository!
    var logWaterUseCase: LogWaterUseCase!
    var getWaterEntriesUseCase: GetWaterEntriesUseCase!
    var deleteWaterEntryUseCase: DeleteWaterEntryUseCase!

    override func setUp() async throws {
        repository = MockNutritionRepository()
        logWaterUseCase = LogWaterUseCase(repository: repository)
        getWaterEntriesUseCase = GetWaterEntriesUseCase(repository: repository)
        deleteWaterEntryUseCase = DeleteWaterEntryUseCase(repository: repository)
    }

    override func tearDown() async throws {
        repository = nil
        logWaterUseCase = nil
        getWaterEntriesUseCase = nil
        deleteWaterEntryUseCase = nil
    }

    // MARK: - LogWaterUseCase Tests

    func testLogWaterCreatesEntry() async throws {
        let date = Date()

        let entry = try await logWaterUseCase.execute(amount: 250, date: date)

        XCTAssertEqual(entry.amount, 250)
        XCTAssertEqual(repository.savedWaterEntries.count, 1)
    }

    func testLogWaterCorrectAmountAndDate() async throws {
        let date = Date()

        let entry = try await logWaterUseCase.execute(amount: 500, date: date)

        XCTAssertEqual(entry.amount, 500)
        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDate(entry.date, inSameDayAs: date))
    }

    func testLogWaterThrowsOnError() async throws {
        repository.shouldThrowOnSave = true

        do {
            _ = try await logWaterUseCase.execute(amount: 250, date: Date())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNutritionRepository.MockError)
        }
    }

    func testLogWaterZeroAmount() async throws {
        let entry = try await logWaterUseCase.execute(amount: 0, date: Date())

        XCTAssertEqual(entry.amount, 0)
        XCTAssertEqual(repository.savedWaterEntries.count, 1)
    }

    func testLogWaterDecimalAmount() async throws {
        let entry = try await logWaterUseCase.execute(amount: 333.5, date: Date())

        XCTAssertEqual(entry.amount, 333.5, accuracy: 0.01)
        XCTAssertEqual(repository.savedWaterEntries.count, 1)
    }

    // MARK: - GetWaterEntriesUseCase Tests

    func testGetWaterEntriesReturnsEntries() async throws {
        let today = Date()
        let calendar = Calendar.current
        repository.mockWaterEntries = [
            WaterEntry(date: today, amount: 250),
            WaterEntry(date: today, amount: 500)
        ]

        let entries = try await getWaterEntriesUseCase.execute(for: today)

        XCTAssertEqual(entries.count, 2)
        // Verify entries are for the correct date
        for entry in entries {
            XCTAssertTrue(calendar.isDate(entry.date, inSameDayAs: today))
        }
    }

    func testGetWaterEntriesFiltersByDate() async throws {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        repository.mockWaterEntries = [
            WaterEntry(date: today, amount: 250),
            WaterEntry(date: yesterday, amount: 500)
        ]

        let entries = try await getWaterEntriesUseCase.execute(for: today)

        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.amount, 250)
    }

    func testGetWaterEntriesReturnsEmptyArray() async throws {
        repository.mockWaterEntries = []

        let entries = try await getWaterEntriesUseCase.execute(for: Date())

        XCTAssertTrue(entries.isEmpty)
    }

    func testGetWaterEntriesThrowsOnError() async throws {
        repository.shouldThrowOnGet = true

        do {
            _ = try await getWaterEntriesUseCase.execute(for: Date())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNutritionRepository.MockError)
        }
    }

    // MARK: - DeleteWaterEntryUseCase Tests

    func testDeleteWaterEntryCallsRepository() async throws {
        let entryId = UUID()
        repository.mockWaterEntries = [
            WaterEntry(id: entryId, date: Date(), amount: 250)
        ]

        try await deleteWaterEntryUseCase.execute(id: entryId)

        XCTAssertEqual(repository.deletedWaterEntryIds.count, 1)
        XCTAssertEqual(repository.deletedWaterEntryIds.first, entryId)
        XCTAssertTrue(repository.mockWaterEntries.isEmpty)
    }

    func testDeleteWaterEntryThrowsOnError() async throws {
        repository.shouldThrowOnDelete = true

        do {
            try await deleteWaterEntryUseCase.execute(id: UUID())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNutritionRepository.MockError)
        }
    }
}
