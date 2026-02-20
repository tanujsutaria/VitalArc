//
//  SaveBodyCompositionEntryUseCase.swift
//  VitalArc
//
//  Use case for saving a body measurement
//

import Foundation

protocol SaveBodyCompositionEntryUseCaseProtocol {
    func execute(_ measurement: BodyCompositionEntry) async throws
}

final class SaveBodyCompositionEntryUseCase: SaveBodyCompositionEntryUseCaseProtocol {
    private let repository: BodyCompositionEntryRepository

    init(repository: BodyCompositionEntryRepository) {
        self.repository = repository
    }

    func execute(_ measurement: BodyCompositionEntry) async throws {
        try await repository.saveMeasurement(measurement)
    }
}
