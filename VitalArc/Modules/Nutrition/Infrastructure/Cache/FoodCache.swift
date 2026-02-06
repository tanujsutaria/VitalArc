//
//  FoodCache.swift
//  VitalArc
//
//  In-memory cache for food search results
//

import Foundation

/// Protocol for food caching to enable testing
@MainActor
protocol FoodCacheProtocol {
    func search(query: String) -> [Food]?
    func store(query: String, foods: [Food])
    func getByBarcode(_ barcode: String) -> Food?
    func storeBarcode(_ barcode: String, food: Food)
}

/// In-memory cache for food search results
/// Reduces API calls and improves performance
@MainActor
final class FoodCache: FoodCacheProtocol {
    static let shared = FoodCache()

    // MARK: - Cache Storage

    private var searchCache: [String: CachedSearchResult] = [:]
    private var barcodeCache: [String: CachedFood] = [:]

    // MARK: - Configuration

    private let maxCacheSize = 1000
    private let cacheExpiration: TimeInterval = 3600 * 24 // 24 hours

    // MARK: - Search Cache

    struct CachedSearchResult {
        let query: String
        let foods: [Food]
        let timestamp: Date
    }

    /// Search cached results for query
    func search(query: String) -> [Food]? {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard let cached = searchCache[normalizedQuery] else {
            return nil
        }

        // Check if expired
        if Date().timeIntervalSince(cached.timestamp) > cacheExpiration {
            searchCache.removeValue(forKey: normalizedQuery)
            return nil
        }

        return cached.foods
    }

    /// Store search results in cache
    func store(query: String, foods: [Food]) {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Enforce cache size limit
        if searchCache.count >= maxCacheSize {
            clearOldest()
        }

        searchCache[normalizedQuery] = CachedSearchResult(
            query: normalizedQuery,
            foods: foods,
            timestamp: Date()
        )
    }

    // MARK: - Barcode Cache

    struct CachedFood {
        let barcode: String
        let food: Food
        let timestamp: Date
    }

    /// Get cached food by barcode
    func getByBarcode(_ barcode: String) -> Food? {
        guard let cached = barcodeCache[barcode] else {
            return nil
        }

        // Check if expired
        if Date().timeIntervalSince(cached.timestamp) > cacheExpiration {
            barcodeCache.removeValue(forKey: barcode)
            return nil
        }

        return cached.food
    }

    /// Store food in barcode cache
    func storeBarcode(_ barcode: String, food: Food) {
        // Enforce cache size limit
        if barcodeCache.count >= maxCacheSize {
            clearOldestBarcodes()
        }

        barcodeCache[barcode] = CachedFood(
            barcode: barcode,
            food: food,
            timestamp: Date()
        )
    }

    // MARK: - Cache Management

    /// Clear expired cache entries
    func clearExpired() {
        let now = Date()

        // Clear expired search results
        searchCache = searchCache.filter { _, cached in
            now.timeIntervalSince(cached.timestamp) <= cacheExpiration
        }

        // Clear expired barcode results
        barcodeCache = barcodeCache.filter { _, cached in
            now.timeIntervalSince(cached.timestamp) <= cacheExpiration
        }
    }

    /// Clear oldest cache entries when limit is reached
    private func clearOldest() {
        guard searchCache.count >= maxCacheSize else { return }

        // Sort by timestamp and remove oldest 20%
        let sorted = searchCache.sorted { $0.value.timestamp < $1.value.timestamp }
        let removeCount = max(1, maxCacheSize / 5)

        for i in 0..<removeCount {
            searchCache.removeValue(forKey: sorted[i].key)
        }
    }

    /// Clear oldest barcode entries when limit is reached
    private func clearOldestBarcodes() {
        guard barcodeCache.count >= maxCacheSize else { return }

        // Sort by timestamp and remove oldest 20%
        let sorted = barcodeCache.sorted { $0.value.timestamp < $1.value.timestamp }
        let removeCount = max(1, maxCacheSize / 5)

        for i in 0..<removeCount {
            barcodeCache.removeValue(forKey: sorted[i].key)
        }
    }

    /// Clear all cached data
    func clearAll() {
        searchCache.removeAll()
        barcodeCache.removeAll()
    }

    // MARK: - Statistics

    var cacheStatistics: (searchEntries: Int, barcodeEntries: Int) {
        (searchCache.count, barcodeCache.count)
    }
}
