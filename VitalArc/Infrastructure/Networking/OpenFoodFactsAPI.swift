//
//  OpenFoodFactsAPI.swift
//  VitalArc
//
//  OpenFoodFacts API integration for international foods
//

import Foundation

protocol OpenFoodFactsAPIProtocol {
    func search(query: String, page: Int) async throws -> [Food]
    func getByBarcode(barcode: String) async throws -> Food
}

/// OpenFoodFacts API client
/// Free and open: Unlimited requests
/// Best for: International foods, barcodes, product images
final class OpenFoodFactsAPI: OpenFoodFactsAPIProtocol {
    private let networkService: NetworkServiceProtocol
    private let baseURL: String

    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        baseURL: String = "https://world.openfoodfacts.org/api/v2"
    ) {
        self.networkService = networkService
        self.baseURL = baseURL
    }

    /// Search for foods by name
    func search(query: String, page: Int = 1) async throws -> [Food] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        // Build URL
        guard var urlComponents = URLComponents(string: "\(baseURL)/search") else {
            throw NetworkError.invalidURL
        }

        // OpenFoodFacts search parameters
        urlComponents.queryItems = [
            URLQueryItem(name: "search_terms", value: trimmedQuery),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: "25"),
            URLQueryItem(name: "fields", value: "product_name,product_name_en,brands,quantity,serving_size,nutriments,code,image_url,image_front_url,image_front_thumb_url,categories,categories_tags"),
            URLQueryItem(name: "json", value: "true")
        ]

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }

        // Make request
        let response: OFFSearchResponse = try await networkService.get(url: url)

        // Convert to domain entities
        let foods = response.products.compactMap { $0.toDomain() }

        return foods
    }

    /// Get food by barcode
    func getByBarcode(barcode: String) async throws -> Food {
        let trimmedBarcode = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBarcode.isEmpty else {
            throw NetworkError.invalidResponse
        }

        // Build URL - OpenFoodFacts uses /product/{barcode}.json
        guard let url = URL(string: "\(baseURL)/product/\(trimmedBarcode)") else {
            throw NetworkError.invalidURL
        }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "fields", value: "product_name,product_name_en,brands,quantity,serving_size,nutriments,code,image_url,image_front_url,image_front_thumb_url,categories,categories_tags")
        ]

        guard let finalURL = urlComponents?.url else {
            throw NetworkError.invalidURL
        }

        // Make request
        let response: OFFProductResponse = try await networkService.get(url: finalURL)

        // Check if product was found
        guard response.status == 1, let product = response.product else {
            throw NetworkError.invalidResponse
        }

        guard let food = product.toDomain() else {
            throw NetworkError.invalidResponse
        }

        return food
    }

    /// Search by category (optional feature)
    func searchByCategory(category: String) async throws -> [Food] {
        guard var urlComponents = URLComponents(string: "\(baseURL)/search") else {
            throw NetworkError.invalidURL
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "categories_tags", value: category),
            URLQueryItem(name: "page_size", value: "25"),
            URLQueryItem(name: "fields", value: "product_name,product_name_en,brands,quantity,serving_size,nutriments,code,image_url,image_front_url,image_front_thumb_url,categories,categories_tags"),
            URLQueryItem(name: "json", value: "true")
        ]

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }

        let response: OFFSearchResponse = try await networkService.get(url: url)
        let foods = response.products.compactMap { $0.toDomain() }

        return foods
    }

    /// Always available (no API key required)
    var isConfigured: Bool {
        return true
    }
}
