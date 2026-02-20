//
//  GetBodyCompositionEntriesUseCase.swift
//  VitalArc
//
//  Use case for retrieving body measurements
//

import Foundation

protocol GetBodyCompositionEntriesUseCaseProtocol {
    func execute(from startDate: Date, to endDate: Date) async throws -> [BodyCompositionEntry]
    func getLatest() async throws -> BodyCompositionEntry?
}

final class GetBodyCompositionEntriesUseCase: GetBodyCompositionEntriesUseCaseProtocol {
    private let repository: BodyCompositionEntryRepository

    init(repository: BodyCompositionEntryRepository) {
        self.repository = repository
    }

    func execute(from startDate: Date, to endDate: Date) async throws -> [BodyCompositionEntry] {
        try await repository.getMeasurements(from: startDate, to: endDate)
    }

    func getLatest() async throws -> BodyCompositionEntry? {
        try await repository.getLatestMeasurement()
    }
}
