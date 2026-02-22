//
//  UserRepository.swift
//  VitalArc
//
//  Repository Protocol for User Domain
//

import Foundation

protocol UserRepository: UserProfileProviding {
    // User profile operations
    func getUserProfile() async throws -> UserProfile?
    func saveUserProfile(_ profile: UserProfile) async throws
    func updateUserProfile(_ profile: UserProfile) async throws
    func deleteUserProfile() async throws

    // Preferences
    func hasCompletedOnboarding() async -> Bool
    func setOnboardingCompleted(_ completed: Bool) async
}
