//
//  HealthDataProviding.swift
//  VitalArc
//
//  Cross-domain protocol for read-only health data access
//

import Foundation

/// Protocol for cross-domain read-only access to health data.
/// Used by Analytics and other domains that need health metrics
/// without depending on the full HealthRepository.
protocol HealthDataProviding {
    func getHealthMetrics(for date: Date) async throws -> HealthMetrics?
    func getHealthMetrics(from startDate: Date, to endDate: Date) async throws -> [HealthMetrics]
}
