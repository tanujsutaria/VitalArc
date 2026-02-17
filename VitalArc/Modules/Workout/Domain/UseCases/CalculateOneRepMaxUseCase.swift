//
//  CalculateOneRepMaxUseCase.swift
//  VitalArc
//
//  Use case for estimating one-rep max using the Epley formula
//

import Foundation

struct CalculateOneRepMaxUseCase {
    private let analyticsRepository: AnalyticsRepository

    init(analyticsRepository: AnalyticsRepository) {
        self.analyticsRepository = analyticsRepository
    }

    /// Estimates 1RM using the Epley formula: weight * (1 + reps / 30)
    /// Returns nil if weight <= 0 or reps <= 0. Returns weight directly if reps == 1.
    static func estimate(weight: Double, reps: Int) -> Double? {
        guard weight > 0, reps > 0 else { return nil }
        if reps == 1 { return weight }
        return weight * (1.0 + Double(reps) / 30.0)
    }

    /// Gets the historical best 1RM for a given exercise from personal records
    func getHistoricalBest(for exerciseId: UUID) async -> Double? {
        do {
            let records = try await analyticsRepository.getPersonalRecords(for: exerciseId)
            return records
                .filter { $0.recordType == .oneRepMax }
                .max(by: { $0.value < $1.value })?.value
        } catch {
            return nil
        }
    }
}
