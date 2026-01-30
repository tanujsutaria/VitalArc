//
//  MockNutritionRepository.swift
//  VitalArcTests
//
//  Mock implementation of NutritionRepository for testing
//

import Foundation
@testable import VitalArc

final class MockNutritionRepository: NutritionRepository {
    // MARK: - Mock Data

    var mockFoods: [Food] = []
    var mockFoodEntries: [FoodEntry] = []
    var mockDailyNutrition: [Date: DailyNutrition] = [:]

    // MARK: - Call Tracking

    var savedFoods: [Food] = []
    var savedFoodEntries: [FoodEntry] = []
    var savedDailyNutritions: [DailyNutrition] = []
    var deletedFoodEntryIds: [UUID] = []
    var searchQueries: [String] = []

    // MARK: - Error Simulation

    var shouldThrowOnSearch = false
    var shouldThrowOnSave = false
    var shouldThrowOnDelete = false
    var shouldThrowOnGet = false

    // MARK: - Food Operations

    func searchFoods(query: String) async throws -> [Food] {
        searchQueries.append(query)
        if shouldThrowOnSearch {
            throw MockError.searchFailed
        }
        return mockFoods.filter { $0.name.lowercased().contains(query.lowercased()) }
    }

    func getFood(id: UUID) async throws -> Food? {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        return mockFoods.first { $0.id == id }
    }

    func saveFood(_ food: Food) async throws {
        if shouldThrowOnSave {
            throw MockError.saveFailed
        }
        savedFoods.append(food)
        if !mockFoods.contains(where: { $0.id == food.id }) {
            mockFoods.append(food)
        }
    }

    // MARK: - Food Entry Operations

    func getFoodEntries(for date: Date) async throws -> [FoodEntry] {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        let calendar = Calendar.current
        return mockFoodEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func getFoodEntries(from startDate: Date, to endDate: Date) async throws -> [FoodEntry] {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        return mockFoodEntries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }
    }

    func saveFoodEntry(_ entry: FoodEntry) async throws {
        if shouldThrowOnSave {
            throw MockError.saveFailed
        }
        savedFoodEntries.append(entry)
        // Update mock data as well
        if let existingIndex = mockFoodEntries.firstIndex(where: { $0.id == entry.id }) {
            mockFoodEntries[existingIndex] = entry
        } else {
            mockFoodEntries.append(entry)
        }
    }

    func deleteFoodEntry(id: UUID) async throws {
        if shouldThrowOnDelete {
            throw MockError.deleteFailed
        }
        deletedFoodEntryIds.append(id)
        mockFoodEntries.removeAll { $0.id == id }
    }

    // MARK: - Daily Nutrition Operations

    func getDailyNutrition(for date: Date) async throws -> DailyNutrition? {
        if shouldThrowOnGet {
            throw MockError.getFailed
        }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return mockDailyNutrition[startOfDay]
    }

    func saveDailyNutrition(_ nutrition: DailyNutrition) async throws {
        if shouldThrowOnSave {
            throw MockError.saveFailed
        }
        savedDailyNutritions.append(nutrition)
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: nutrition.date)
        mockDailyNutrition[startOfDay] = nutrition
    }

    // MARK: - Test Helpers

    func reset() {
        mockFoods = []
        mockFoodEntries = []
        mockDailyNutrition = [:]
        savedFoods = []
        savedFoodEntries = []
        savedDailyNutritions = []
        deletedFoodEntryIds = []
        searchQueries = []
        shouldThrowOnSearch = false
        shouldThrowOnSave = false
        shouldThrowOnDelete = false
        shouldThrowOnGet = false
    }

    // MARK: - Mock Error

    enum MockError: Error, LocalizedError {
        case searchFailed
        case saveFailed
        case deleteFailed
        case getFailed

        var errorDescription: String? {
            switch self {
            case .searchFailed: return "Search failed"
            case .saveFailed: return "Save failed"
            case .deleteFailed: return "Delete failed"
            case .getFailed: return "Get failed"
            }
        }
    }
}

// MARK: - Mock FoodAPICoordinator

final class MockFoodAPICoordinator: FoodAPICoordinatorProtocol {
    var mockSearchResults: [Food] = []
    var mockBarcodeResult: Food?
    var shouldThrowOnSearch = false
    var shouldThrowOnBarcode = false
    var searchQueries: [String] = []
    var barcodeQueries: [String] = []

    func search(query: String) async throws -> [Food] {
        searchQueries.append(query)
        if shouldThrowOnSearch {
            throw MockError.searchFailed
        }
        return mockSearchResults
    }

    func searchByBarcode(barcode: String) async throws -> Food {
        barcodeQueries.append(barcode)
        if shouldThrowOnBarcode {
            throw MockError.barcodeFailed
        }
        guard let result = mockBarcodeResult else {
            throw MockError.notFound
        }
        return result
    }

    enum MockError: Error {
        case searchFailed
        case barcodeFailed
        case notFound
    }
}
