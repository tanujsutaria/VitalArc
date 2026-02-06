//
//  LogWaterUseCase.swift
//  VitalArc
//
//  Use case for logging water intake
//

import Foundation

protocol LogWaterUseCaseProtocol {
    func execute(amount: Double, date: Date) async throws -> WaterEntry
}

final class LogWaterUseCase: LogWaterUseCaseProtocol {
    private let repository: NutritionRepository

    init(repository: NutritionRepository) {
        self.repository = repository
    }

    func execute(amount: Double, date: Date = Date()) async throws -> WaterEntry {
        let entry = WaterEntry(date: date, amount: amount)
        try await repository.saveWaterEntry(entry)
        return entry
    }
}
