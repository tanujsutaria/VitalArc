//
//  NotificationPreferences.swift
//  VitalArc
//
//  Domain Entity for Notification Preferences
//

import Foundation

/// User preferences for all notification types
struct NotificationPreferences: Equatable, Codable {
    var workoutRemindersEnabled: Bool
    var recoveryAlertsEnabled: Bool
    var nutritionRemindersEnabled: Bool

    /// Recovery score threshold for alerts (0-100)
    var recoveryThreshold: Int

    /// Days of week for workout reminders (1=Sunday, 2=Monday, etc.)
    var workoutReminderDays: Set<Int>

    /// Time for workout reminders
    var workoutReminderTime: DateComponents

    /// Hours before end of day to send nutrition reminder
    var nutritionReminderHours: Int

    init(
        workoutRemindersEnabled: Bool = true,
        recoveryAlertsEnabled: Bool = true,
        nutritionRemindersEnabled: Bool = false,
        recoveryThreshold: Int = 50,
        workoutReminderDays: Set<Int> = [2, 4, 6], // Mon, Wed, Fri
        workoutReminderTime: DateComponents = DateComponents(hour: 18, minute: 0), // 6 PM
        nutritionReminderHours: Int = 3 // 9 PM if EOD is midnight
    ) {
        self.workoutRemindersEnabled = workoutRemindersEnabled
        self.recoveryAlertsEnabled = recoveryAlertsEnabled
        self.nutritionRemindersEnabled = nutritionRemindersEnabled
        self.recoveryThreshold = recoveryThreshold
        self.workoutReminderDays = workoutReminderDays
        self.workoutReminderTime = workoutReminderTime
        self.nutritionReminderHours = nutritionReminderHours
    }

    /// Default preferences for new users
    static var `default`: NotificationPreferences {
        return NotificationPreferences()
    }

    /// Validate preferences are within acceptable ranges
    var isValid: Bool {
        guard (0...100).contains(recoveryThreshold) else { return false }
        guard (1...24).contains(nutritionReminderHours) else { return false }
        guard let hour = workoutReminderTime.hour, (0...23).contains(hour) else { return false }
        guard let minute = workoutReminderTime.minute, (0...59).contains(minute) else { return false }
        return true
    }
}
