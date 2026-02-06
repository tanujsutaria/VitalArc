//
//  UpdateUserPreferencesUseCase.swift
//  VitalArc
//
//  Use Case for updating user preferences
//

import Foundation

/// Use case for updating user profile preferences
final class UpdateUserPreferencesUseCase {
    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    /// Updates an existing user profile
    /// - Parameter profile: The updated user profile
    /// - Throws: Repository errors if update fails
    func execute(profile: UserProfile) async throws {
        try await repository.updateUserProfile(profile)
    }
}
