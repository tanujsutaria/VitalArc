//
//  MockNotificationScheduler.swift
//  VitalArcTests
//
//  Mock implementation of NotificationScheduler for testing
//

import Foundation
import UserNotifications
@testable import VitalArc

/// Mock NotificationScheduler for unit testing NotificationSettingsViewModel
@MainActor
final class MockNotificationScheduler {
    // MARK: - Mock Data

    var mockAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    var mockAuthorizationResult = true
    var mockPendingNotificationCount = 0
    var mockPendingIdentifiers: [String] = []

    // MARK: - Call Tracking

    var requestAuthorizationCallCount = 0
    var checkAuthorizationStatusCallCount = 0
    var scheduleFromPreferencesCallCount = 0
    var scheduleRecoveryAlertCallCount = 0
    var cancelWorkoutRemindersCallCount = 0
    var cancelRecoveryAlertsCallCount = 0
    var cancelNutritionRemindersCallCount = 0
    var cancelAllScheduledNotificationsCallCount = 0
    var getPendingNotificationCountCallCount = 0
    var clearBadgeCallCount = 0
    var updateBadgeCountCallCount = 0

    // MARK: - Captured Parameters

    var lastScheduledPreferences: NotificationPreferences?
    var lastRecoveryScore: Double?
    var lastRecoveryThreshold: Int?
    var lastRecoveryEnabled: Bool?
    var lastBadgeCount: Int?

    // MARK: - Error Simulation

    var shouldThrowOnRequestAuthorization = false
    var shouldThrowOnScheduleFromPreferences = false
    var shouldThrowOnScheduleRecoveryAlert = false
    var shouldThrowOnClearBadge = false
    var shouldThrowOnUpdateBadgeCount = false
    var errorToThrow: Error?

    // MARK: - Authorization

    func requestAuthorization() async throws -> Bool {
        requestAuthorizationCallCount += 1
        if shouldThrowOnRequestAuthorization {
            throw errorToThrow ?? MockNotificationSchedulerError.authorizationFailed
        }
        if mockAuthorizationResult {
            mockAuthorizationStatus = .authorized
        } else {
            mockAuthorizationStatus = .denied
        }
        return mockAuthorizationResult
    }

    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        checkAuthorizationStatusCallCount += 1
        return mockAuthorizationStatus
    }

    // MARK: - Scheduling

    func scheduleFromPreferences(_ preferences: NotificationPreferences) async throws {
        scheduleFromPreferencesCallCount += 1
        lastScheduledPreferences = preferences
        if shouldThrowOnScheduleFromPreferences {
            throw errorToThrow ?? MockNotificationSchedulerError.schedulingFailed
        }
        // Simulate adding notifications
        mockPendingNotificationCount = countExpectedNotifications(from: preferences)
    }

    func scheduleRecoveryAlertIfNeeded(
        recoveryScore: Double,
        threshold: Int,
        enabled: Bool
    ) async throws {
        scheduleRecoveryAlertCallCount += 1
        lastRecoveryScore = recoveryScore
        lastRecoveryThreshold = threshold
        lastRecoveryEnabled = enabled
        if shouldThrowOnScheduleRecoveryAlert {
            throw errorToThrow ?? MockNotificationSchedulerError.schedulingFailed
        }
        // Simulate adding recovery alert if conditions met
        if enabled && recoveryScore < Double(threshold) {
            mockPendingNotificationCount += 1
        }
    }

    // MARK: - Cancellation

    func cancelWorkoutReminders() async {
        cancelWorkoutRemindersCallCount += 1
        // Simulate removing workout notifications
    }

    func cancelRecoveryAlerts() {
        cancelRecoveryAlertsCallCount += 1
        // Simulate removing recovery alerts
    }

    func cancelNutritionReminders() {
        cancelNutritionRemindersCallCount += 1
        // Simulate removing nutrition reminders
    }

    func cancelAllScheduledNotifications() async {
        cancelAllScheduledNotificationsCallCount += 1
        mockPendingNotificationCount = 0
        mockPendingIdentifiers = []
    }

    // MARK: - Badge Management

    func updateBadgeCount(_ count: Int) async throws {
        updateBadgeCountCallCount += 1
        lastBadgeCount = count
        if shouldThrowOnUpdateBadgeCount {
            throw errorToThrow ?? MockNotificationSchedulerError.badgeUpdateFailed
        }
    }

    func clearBadge() async throws {
        clearBadgeCallCount += 1
        if shouldThrowOnClearBadge {
            throw errorToThrow ?? MockNotificationSchedulerError.badgeUpdateFailed
        }
        lastBadgeCount = 0
    }

    // MARK: - Pending Notifications

    func getPendingNotificationCount() async -> Int {
        getPendingNotificationCountCallCount += 1
        return mockPendingNotificationCount
    }

    func getPendingNotificationIdentifiers() async -> [String] {
        return mockPendingIdentifiers
    }

    // MARK: - Helper Methods

    func reset() {
        mockAuthorizationStatus = .notDetermined
        mockAuthorizationResult = true
        mockPendingNotificationCount = 0
        mockPendingIdentifiers = []
        requestAuthorizationCallCount = 0
        checkAuthorizationStatusCallCount = 0
        scheduleFromPreferencesCallCount = 0
        scheduleRecoveryAlertCallCount = 0
        cancelWorkoutRemindersCallCount = 0
        cancelRecoveryAlertsCallCount = 0
        cancelNutritionRemindersCallCount = 0
        cancelAllScheduledNotificationsCallCount = 0
        getPendingNotificationCountCallCount = 0
        clearBadgeCallCount = 0
        updateBadgeCountCallCount = 0
        lastScheduledPreferences = nil
        lastRecoveryScore = nil
        lastRecoveryThreshold = nil
        lastRecoveryEnabled = nil
        lastBadgeCount = nil
        shouldThrowOnRequestAuthorization = false
        shouldThrowOnScheduleFromPreferences = false
        shouldThrowOnScheduleRecoveryAlert = false
        shouldThrowOnClearBadge = false
        shouldThrowOnUpdateBadgeCount = false
        errorToThrow = nil
    }

    private func countExpectedNotifications(from preferences: NotificationPreferences) -> Int {
        var count = 0
        if preferences.workoutRemindersEnabled {
            count += preferences.workoutReminderDays.count
        }
        if preferences.nutritionRemindersEnabled {
            count += 1
        }
        // Recovery alerts scheduled dynamically
        return count
    }
}

// MARK: - Mock Errors

enum MockNotificationSchedulerError: LocalizedError {
    case authorizationFailed
    case schedulingFailed
    case badgeUpdateFailed

    var errorDescription: String? {
        switch self {
        case .authorizationFailed: return "Mock: Notification authorization failed"
        case .schedulingFailed: return "Mock: Failed to schedule notification"
        case .badgeUpdateFailed: return "Mock: Failed to update badge"
        }
    }
}
