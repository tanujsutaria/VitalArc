//
//  NetworkService.swift
//  VitalArc
//
//  Generic HTTP client with async/await
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case invalidResponse
    case serverError(statusCode: Int)
    case allSourcesFailed
    case notConfigured
    case unknown(Error)
}

protocol NetworkServiceProtocol {
    func get<T: Decodable>(url: URL) async throws -> T
    func post<T: Decodable, U: Encodable>(url: URL, body: U) async throws -> T
    func request<T: Decodable>(request: URLRequest) async throws -> T
}

/// Generic HTTP client using async/await
final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    /// Perform GET request
    func get<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw NetworkError.decodingError
        }
    }

    /// Perform POST request
    func post<T: Decodable, U: Encodable>(url: URL, body: U) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw NetworkError.decodingError
        }
    }

    /// Perform custom request (for APIs requiring custom headers, etc.)
    func request<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw NetworkError.decodingError
        }
    }
}
