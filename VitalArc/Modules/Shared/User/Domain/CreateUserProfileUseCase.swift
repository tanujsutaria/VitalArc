//
//  CreateUserProfileUseCase.swift
//  VitalArc
//
//  Use Case for creating a new user profile
//

import Foundation

/// Use case for creating and saving a new user profile
final class CreateUserProfileUseCase {
    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    /// Creates and saves a new user profile
    /// - Parameter profile: The user profile to create
    /// - Throws: Repository errors if save fails
    func execute(profile: UserProfile) async throws {
        try await repository.saveUserProfile(profile)
    }
}
