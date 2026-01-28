//
//  NutritionRepository.swift
//  VitalArc
//
//  Repository Protocol for Nutrition Domain
//

import Foundation

protocol NutritionRepository {
    // Food operations
    func searchFoods(query: String) async throws -> [Food]
    func getFood(id: UUID) async throws -> Food?
    func saveFood(_ food: Food) async throws

    // Food entry operations
    func getFoodEntries(for date: Date) async throws -> [FoodEntry]
    func getFoodEntries(from startDate: Date, to endDate: Date) async throws -> [FoodEntry]
    func saveFoodEntry(_ entry: FoodEntry) async throws
    func deleteFoodEntry(id: UUID) async throws

    // Daily nutrition operations
    func getDailyNutrition(for date: Date) async throws -> DailyNutrition?
    func saveDailyNutrition(_ nutrition: DailyNutrition) async throws
}
