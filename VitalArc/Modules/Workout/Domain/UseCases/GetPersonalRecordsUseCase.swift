//
//  GetPersonalRecordsUseCase.swift
//  VitalArc
//
//  Use Case: Retrieve personal records, optionally filtered by exercise
//

import Foundation

final class GetPersonalRecordsUseCase {
    private let analyticsRepository: AnalyticsRepository

    init(analyticsRepository: AnalyticsRepository) {
        self.analyticsRepository = analyticsRepository
    }

    /// Get all personal records, optionally filtered to a specific exercise
    func execute(exerciseId: UUID? = nil) async throws -> [PersonalRecord] {
        if let exerciseId = exerciseId {
            return try await analyticsRepository.getPersonalRecords(for: exerciseId)
        }
        return try await analyticsRepository.getPersonalRecords()
    }
}
