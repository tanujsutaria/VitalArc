//
//  GetWaterEntriesUseCase.swift
//  VitalArc
//
//  Use case for retrieving water intake entries
//

import Foundation

protocol GetWaterEntriesUseCaseProtocol {
    func execute(for date: Date) async throws -> [WaterEntry]
}

final class GetWaterEntriesUseCase: GetWaterEntriesUseCaseProtocol {
    private let repository: NutritionRepository

    init(repository: NutritionRepository) {
        self.repository = repository
    }

    func execute(for date: Date) async throws -> [WaterEntry] {
        try await repository.getWaterEntries(for: date)
    }
}
