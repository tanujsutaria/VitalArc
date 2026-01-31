//
//  GetHealthMetricsUseCase.swift
//  VitalArc
//
//  Use case for fetching health metrics for a specific date
//

import Foundation

protocol GetHealthMetricsUseCaseProtocol {
    func execute(for date: Date) async throws -> HealthMetrics?
}

/// Use case for getting health metrics for a specific date
final class GetHealthMetricsUseCase: GetHealthMetricsUseCaseProtocol {
    private let repository: HealthRepository

    init(repository: HealthRepository) {
        self.repository = repository
    }

    /// Get health metrics for a specific date
    /// - Parameter date: The date to fetch metrics for
    /// - Returns: HealthMetrics for the given date, or nil if none exist
    func execute(for date: Date) async throws -> HealthMetrics? {
        try await repository.getHealthMetrics(for: date)
    }
}
