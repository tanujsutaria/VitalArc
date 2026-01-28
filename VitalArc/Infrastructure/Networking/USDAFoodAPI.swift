//
//  USDAFoodAPI.swift
//  VitalArc
//
//  USDA FoodData Central API integration
//

import Foundation

protocol USDAFoodAPIProtocol {
    func searchFoods(query: String) async throws -> [Food]
}

/// USDA FoodData Central API client
final class USDAFoodAPI: USDAFoodAPIProtocol {
    private let networkService: NetworkServiceProtocol
    private let apiKey: String
    private let baseURL: String

    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        apiKey: String? = nil,
        baseURL: String = "https://api.nal.usda.gov/fdc/v1"
    ) {
        self.networkService = networkService
        self.apiKey = apiKey ?? APISecrets.usdaApiKey
        self.baseURL = baseURL
    }

    /// Search for foods using USDA API
    /// - Parameter query: Search query string
    /// - Returns: Array of Food entities
    func searchFoods(query: String) async throws -> [Food] {
        // Trim and validate query
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        // Build URL
        guard var urlComponents = URLComponents(string: "\(baseURL)/foods/search") else {
            throw NetworkError.invalidURL
        }

        // Add query parameters
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: trimmedQuery),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "pageSize", value: "25"),
            URLQueryItem(name: "dataType", value: "Foundation,SR Legacy") // Focus on nutritionally complete foods
        ]

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }

        // Make request
        let response: USDASearchResponse = try await networkService.get(url: url)

        // Convert to domain entities
        let foods = response.foods.compactMap { $0.toDomain() }

        return foods
    }

    /// Get detailed food information by FDC ID
    /// - Parameter fdcId: USDA FoodData Central ID
    /// - Returns: Food entity
    func getFood(fdcId: Int) async throws -> Food? {
        guard let url = URL(string: "\(baseURL)/food/\(fdcId)?api_key=\(apiKey)") else {
            throw NetworkError.invalidURL
        }

        let response: USDAFoodDetail = try await networkService.get(url: url)
        return response.toDomain()
    }
}
