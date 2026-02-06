//
//  NutritionDataProviding.swift
//  VitalArc
//
//  Cross-domain protocol for read-only nutrition data access
//

import Foundation

/// Protocol for cross-domain read-only access to nutrition data.
/// Used by Analytics and other domains that need nutrition information
/// without depending on the full NutritionRepository.
protocol NutritionDataProviding {
    func getDailyNutrition(for date: Date) async throws -> DailyNutrition?
    func getFoodEntries(from startDate: Date, to endDate: Date) async throws -> [FoodEntry]
}
