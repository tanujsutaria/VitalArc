//
//  UserProfileProviding.swift
//  VitalArc
//
//  Cross-domain protocol for read-only user profile access
//

import Foundation

/// Protocol for cross-domain read-only access to user profile data.
/// Used by domains that need user information (e.g., recovery/strain scoring
/// needs weight and activity level) without depending on the full UserRepository.
protocol UserProfileProviding {
    func getUserProfile() async throws -> UserProfile?
}
