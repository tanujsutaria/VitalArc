//
//  MockNetworkService.swift
//  VitalArcTests
//
//  Mock implementation of NetworkService for testing API clients
//

import Foundation
@testable import VitalArc

final class MockNetworkService: NetworkServiceProtocol {
    // MARK: - Mock Configuration

    var mockResponse: Any?
    var mockError: Error?
    var requestedURLs: [URL] = []
    var requestedRequests: [URLRequest] = []

    // MARK: - NetworkServiceProtocol

    func get<T: Decodable>(url: URL) async throws -> T {
        requestedURLs.append(url)

        if let error = mockError {
            throw error
        }

        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError
        }

        return response
    }

    func post<T: Decodable, U: Encodable>(url: URL, body: U) async throws -> T {
        requestedURLs.append(url)

        if let error = mockError {
            throw error
        }

        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError
        }

        return response
    }

    func request<T: Decodable>(request: URLRequest) async throws -> T {
        requestedRequests.append(request)
        if let url = request.url {
            requestedURLs.append(url)
        }

        if let error = mockError {
            throw error
        }

        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError
        }

        return response
    }

    // MARK: - Test Helpers

    func reset() {
        mockResponse = nil
        mockError = nil
        requestedURLs = []
        requestedRequests = []
    }

    /// Helper to verify request headers
    func lastRequestHeader(_ headerField: String) -> String? {
        requestedRequests.last?.value(forHTTPHeaderField: headerField)
    }

    /// Helper to verify URL query parameters
    func lastURLQueryItems() -> [URLQueryItem]? {
        guard let url = requestedURLs.last else { return nil }
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
    }
}
