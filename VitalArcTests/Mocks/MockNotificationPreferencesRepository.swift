//
//  MockNotificationPreferencesRepository.swift
//  VitalArcTests
//
//  Mock implementation of NotificationPreferencesRepository for testing
//

import Foundation
@testable import VitalArc

/// Mock NotificationPreferencesRepository for unit testing
final class MockNotificationPreferencesRepository: NotificationPreferencesRepository {
    // MARK: - Mock Data

    var mockPreferences: NotificationPreferences?

    // MARK: - Call Tracking

    var getPreferencesCallCount = 0
    var savePreferencesCallCount = 0
    var updatePreferencesCallCount = 0
    var resetToDefaultsCallCount = 0

    // MARK: - Captured Parameters

    var lastSavedPreferences: NotificationPreferences?
    var lastUpdatedPreferences: NotificationPreferences?

    // MARK: - Error Simulation

    var shouldThrowOnGet = false
    var shouldThrowOnSave = false
    var shouldThrowOnUpdate = false
    var shouldThrowOnReset = false
    var errorToThrow: Error?

    // MARK: - NotificationPreferencesRepository Protocol

    func getPreferences() async throws -> NotificationPreferences? {
        getPreferencesCallCount += 1
        if shouldThrowOnGet {
            throw errorToThrow ?? MockNotificationPreferencesError.fetchFailed
        }
        return mockPreferences
    }

    func savePreferences(_ preferences: NotificationPreferences) async throws {
        savePreferencesCallCount += 1
        lastSavedPreferences = preferences
        if shouldThrowOnSave {
            throw errorToThrow ?? MockNotificationPreferencesError.saveFailed
        }
        mockPreferences = preferences
    }

    func updatePreferences(_ preferences: NotificationPreferences) async throws {
        updatePreferencesCallCount += 1
        lastUpdatedPreferences = preferences
        if shouldThrowOnUpdate {
            throw errorToThrow ?? MockNotificationPreferencesError.updateFailed
        }
        mockPreferences = preferences
    }

    func resetToDefaults() async throws {
        resetToDefaultsCallCount += 1
        if shouldThrowOnReset {
            throw errorToThrow ?? MockNotificationPreferencesError.resetFailed
        }
        mockPreferences = .default
    }

    // MARK: - Helper Methods

    func reset() {
        mockPreferences = nil
        getPreferencesCallCount = 0
        savePreferencesCallCount = 0
        updatePreferencesCallCount = 0
        resetToDefaultsCallCount = 0
        lastSavedPreferences = nil
        lastUpdatedPreferences = nil
        shouldThrowOnGet = false
        shouldThrowOnSave = false
        shouldThrowOnUpdate = false
        shouldThrowOnReset = false
        errorToThrow = nil
    }

    /// Create sample preferences for testing
    static func createSamplePreferences(
        workoutRemindersEnabled: Bool = true,
        recoveryAlertsEnabled: Bool = true,
        nutritionRemindersEnabled: Bool = false,
        recoveryThreshold: Int = 50,
        workoutDays: Set<Int> = [2, 4, 6] // Mon, Wed, Fri
    ) -> NotificationPreferences {
        var prefs = NotificationPreferences.default
        prefs.workoutRemindersEnabled = workoutRemindersEnabled
        prefs.recoveryAlertsEnabled = recoveryAlertsEnabled
        prefs.nutritionRemindersEnabled = nutritionRemindersEnabled
        prefs.recoveryThreshold = recoveryThreshold
        prefs.workoutReminderDays = workoutDays
        return prefs
    }
}

// MARK: - Mock Errors

enum MockNotificationPreferencesError: LocalizedError {
    case fetchFailed
    case saveFailed
    case updateFailed
    case resetFailed

    var errorDescription: String? {
        switch self {
        case .fetchFailed: return "Mock: Failed to fetch notification preferences"
        case .saveFailed: return "Mock: Failed to save notification preferences"
        case .updateFailed: return "Mock: Failed to update notification preferences"
        case .resetFailed: return "Mock: Failed to reset notification preferences"
        }
    }
}
