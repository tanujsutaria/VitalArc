//
//  DeleteFoodEntryUseCase.swift
//  VitalArc
//
//  Use case for deleting a food entry
//

import Foundation

protocol DeleteFoodEntryUseCaseProtocol {
    func execute(id: UUID) async throws
}

/// Use case for deleting a food entry by ID
final class DeleteFoodEntryUseCase: DeleteFoodEntryUseCaseProtocol {
    private let repository: NutritionRepository

    init(repository: NutritionRepository) {
        self.repository = repository
    }

    /// Delete a food entry by its ID
    /// - Parameter id: The UUID of the food entry to delete
    func execute(id: UUID) async throws {
        try await repository.deleteFoodEntry(id: id)
    }
}
