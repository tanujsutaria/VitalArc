//
//  MockUserRepository.swift
//  VitalArcTests
//
//  Mock implementation of UserRepository for testing
//

import Foundation
@testable import VitalArc

/// Mock UserRepository for unit testing
class MockUserRepository: UserRepository {
    // MARK: - Stored State

    var savedProfile: UserProfile?
    var onboardingCompleted: Bool = false

    // MARK: - Call Tracking

    var getUserProfileCallCount = 0
    var saveUserProfileCallCount = 0
    var updateUserProfileCallCount = 0
    var deleteUserProfileCallCount = 0
    var hasCompletedOnboardingCallCount = 0
    var setOnboardingCompletedCallCount = 0

    // MARK: - Error Simulation

    var shouldThrowOnSave = false
    var shouldThrowOnUpdate = false
    var shouldThrowOnDelete = false
    var errorToThrow: Error?

    // MARK: - UserRepository Protocol

    func getUserProfile() async throws -> UserProfile? {
        getUserProfileCallCount += 1
        return savedProfile
    }

    func saveUserProfile(_ profile: UserProfile) async throws {
        saveUserProfileCallCount += 1
        if shouldThrowOnSave {
            throw errorToThrow ?? MockRepositoryError.saveFailed
        }
        savedProfile = profile
    }

    func updateUserProfile(_ profile: UserProfile) async throws {
        updateUserProfileCallCount += 1
        if shouldThrowOnUpdate {
            throw errorToThrow ?? MockRepositoryError.updateFailed
        }
        savedProfile = profile
    }

    func deleteUserProfile() async throws {
        deleteUserProfileCallCount += 1
        if shouldThrowOnDelete {
            throw errorToThrow ?? MockRepositoryError.deleteFailed
        }
        savedProfile = nil
    }

    func hasCompletedOnboarding() async -> Bool {
        hasCompletedOnboardingCallCount += 1
        return onboardingCompleted
    }

    func setOnboardingCompleted(_ completed: Bool) async {
        setOnboardingCompletedCallCount += 1
        onboardingCompleted = completed
    }

    // MARK: - Helper Methods

    func reset() {
        savedProfile = nil
        onboardingCompleted = false
        getUserProfileCallCount = 0
        saveUserProfileCallCount = 0
        updateUserProfileCallCount = 0
        deleteUserProfileCallCount = 0
        hasCompletedOnboardingCallCount = 0
        setOnboardingCompletedCallCount = 0
        shouldThrowOnSave = false
        shouldThrowOnUpdate = false
        shouldThrowOnDelete = false
        errorToThrow = nil
    }
}

// MARK: - Mock Errors

enum MockRepositoryError: LocalizedError {
    case saveFailed
    case updateFailed
    case deleteFailed
    case notFound

    var errorDescription: String? {
        switch self {
        case .saveFailed: return "Mock: Save operation failed"
        case .updateFailed: return "Mock: Update operation failed"
        case .deleteFailed: return "Mock: Delete operation failed"
        case .notFound: return "Mock: Item not found"
        }
    }
}
