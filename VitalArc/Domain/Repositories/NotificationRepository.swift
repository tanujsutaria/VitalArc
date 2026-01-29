//
//  NotificationRepository.swift
//  VitalArc
//
//  Repository protocol for notification preferences persistence
//

import Foundation

/// Repository protocol for managing notification preferences
protocol NotificationPreferencesRepository {
    /// Get the current notification preferences
    func getPreferences() async throws -> NotificationPreferences?

    /// Save notification preferences
    func savePreferences(_ preferences: NotificationPreferences) async throws

    /// Update notification preferences
    func updatePreferences(_ preferences: NotificationPreferences) async throws

    /// Reset preferences to defaults
    func resetToDefaults() async throws
}
