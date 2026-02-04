//
//  FoodAPICoordinator.swift
//  VitalArc
//
//  Intelligent multi-source food search coordinator
//

import Foundation

protocol FoodAPICoordinatorProtocol {
    func search(query: String) async throws -> [Food]
    func searchByBarcode(barcode: String) async throws -> Food
}

/// Coordinates searches across multiple food APIs
/// Provides intelligent fallback and deduplication
@MainActor
final class FoodAPICoordinator: FoodAPICoordinatorProtocol {
    private let nutritionix: NutritionixAPIProtocol
    private let openFoodFacts: OpenFoodFactsAPIProtocol
    private let usda: USDAFoodAPIProtocol
    private let cache: FoodCacheProtocol

    init(
        nutritionix: NutritionixAPIProtocol = NutritionixAPI(),
        openFoodFacts: OpenFoodFactsAPIProtocol = OpenFoodFactsAPI(),
        usda: USDAFoodAPIProtocol = USDAFoodAPI(),
        cache: FoodCacheProtocol? = nil
    ) {
        self.nutritionix = nutritionix
        self.openFoodFacts = openFoodFacts
        self.usda = usda
        self.cache = cache ?? FoodCache.shared
    }

    /// Search across multiple food databases
    /// Returns combined, deduplicated results prioritized by quality
    func search(query: String) async throws -> [Food] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        // 1. Check cache first (includes legitimate empty results)
        if let cached = cache.search(query: trimmedQuery) {
            return cached
        }

        var allFoods: [Food] = []
        var atLeastOneSourceSucceeded = false

        // 2. Try all sources in parallel
        // Use protocol property directly (no type casting)
        let isNutritionixConfigured = nutritionix.isConfigured

        async let nutritionixResults: [Food]? = isNutritionixConfigured
            ? try? await nutritionix.search(query: trimmedQuery)
            : nil

        async let offResults: [Food]? = try? await openFoodFacts.search(query: trimmedQuery, page: 1)
        async let usdaResults: [Food]? = try? await usda.searchFoods(query: trimmedQuery)

        // 3. Combine results and track success
        let (nxFoods, offFoods, usdaFoods) = await (nutritionixResults, offResults, usdaResults)

        // Add Nutritionix foods first (highest quality for branded foods)
        if let nxFoods = nxFoods {
            atLeastOneSourceSucceeded = true
            allFoods.append(contentsOf: nxFoods)
        }

        // Add OpenFoodFacts foods (good for international products)
        if let offFoods = offFoods {
            atLeastOneSourceSucceeded = true
            allFoods.append(contentsOf: offFoods)
        }

        // Add USDA foods (basic but reliable)
        if let usdaFoods = usdaFoods {
            atLeastOneSourceSucceeded = true
            allFoods.append(contentsOf: usdaFoods)
        }

        // 4. Deduplicate and rank
        let deduplicated = deduplicateFoods(allFoods)

        // 5. Cache results only if at least one API succeeded
        // This caches legitimate "no results" but not transient failures
        if atLeastOneSourceSucceeded {
            cache.store(query: trimmedQuery, foods: deduplicated)
        }

        return deduplicated
    }

    /// Search by barcode (UPC/EAN)
    func searchByBarcode(barcode: String) async throws -> Food {
        let trimmedBarcode = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBarcode.isEmpty else {
            throw NetworkError.invalidResponse
        }

        // Check cache first
        if let cached = cache.getByBarcode(trimmedBarcode) {
            return cached
        }

        // Try Nutritionix first (if configured)
        if nutritionix.isConfigured {
            if let food = try? await nutritionix.getByUPC(barcode: trimmedBarcode) {
                cache.storeBarcode(trimmedBarcode, food: food)
                return food
            }
        }

        // Fallback to OpenFoodFacts (always available)
        let food = try await openFoodFacts.getByBarcode(barcode: trimmedBarcode)
        cache.storeBarcode(trimmedBarcode, food: food)
        return food
    }

    // MARK: - Private Helpers

    /// Deduplicate foods based on name and brand similarity
    private func deduplicateFoods(_ foods: [Food]) -> [Food] {
        var seen: Set<String> = []
        var unique: [Food] = []

        for food in foods {
            let key = foodKey(food)
            if !seen.contains(key) {
                seen.insert(key)
                unique.append(food)
            }
        }

        return unique
    }

    /// Generate unique key for food item
    private func foodKey(_ food: Food) -> String {
        let name = food.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let brand = food.brand?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return "\(name)-\(brand)"
    }
}
