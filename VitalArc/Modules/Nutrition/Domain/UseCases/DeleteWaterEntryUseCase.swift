//
//  DeleteWaterEntryUseCase.swift
//  VitalArc
//
//  Use case for deleting a water entry
//

import Foundation

protocol DeleteWaterEntryUseCaseProtocol {
    func execute(id: UUID) async throws
}

/// Use case for deleting a water entry by ID
final class DeleteWaterEntryUseCase: DeleteWaterEntryUseCaseProtocol {
    private let repository: NutritionRepository

    init(repository: NutritionRepository) {
        self.repository = repository
    }

    /// Delete a water entry by its ID
    /// - Parameter id: The UUID of the water entry to delete
    func execute(id: UUID) async throws {
        try await repository.deleteWaterEntry(id: id)
    }
}
