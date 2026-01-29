//
//  NotificationPreferencesModel.swift
//  VitalArc
//
//  SwiftData model for persisting notification preferences
//

import Foundation
import SwiftData

@Model
final class NotificationPreferencesModel {
    var id: UUID
    var workoutRemindersEnabled: Bool
    var recoveryAlertsEnabled: Bool
    var nutritionRemindersEnabled: Bool
    var recoveryThreshold: Int
    var workoutReminderDaysData: Data?
    var workoutReminderHour: Int
    var workoutReminderMinute: Int
    var nutritionReminderHours: Int
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        workoutRemindersEnabled: Bool = true,
        recoveryAlertsEnabled: Bool = true,
        nutritionRemindersEnabled: Bool = false,
        recoveryThreshold: Int = 50,
        workoutReminderDaysData: Data? = nil,
        workoutReminderHour: Int = 18,
        workoutReminderMinute: Int = 0,
        nutritionReminderHours: Int = 3,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.workoutRemindersEnabled = workoutRemindersEnabled
        self.recoveryAlertsEnabled = recoveryAlertsEnabled
        self.nutritionRemindersEnabled = nutritionRemindersEnabled
        self.recoveryThreshold = recoveryThreshold
        self.workoutReminderDaysData = workoutReminderDaysData
        self.workoutReminderHour = workoutReminderHour
        self.workoutReminderMinute = workoutReminderMinute
        self.nutritionReminderHours = nutritionReminderHours
        self.updatedAt = updatedAt
    }

    // MARK: - Domain Conversion

    func toDomain() -> NotificationPreferences {
        let days: Set<Int>
        if let data = workoutReminderDaysData,
           let decoded = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            days = decoded
        } else {
            days = [2, 4, 6] // Default: Mon, Wed, Fri
        }

        return NotificationPreferences(
            workoutRemindersEnabled: workoutRemindersEnabled,
            recoveryAlertsEnabled: recoveryAlertsEnabled,
            nutritionRemindersEnabled: nutritionRemindersEnabled,
            recoveryThreshold: recoveryThreshold,
            workoutReminderDays: days,
            workoutReminderTime: DateComponents(hour: workoutReminderHour, minute: workoutReminderMinute),
            nutritionReminderHours: nutritionReminderHours
        )
    }

    static func fromDomain(_ preferences: NotificationPreferences) -> NotificationPreferencesModel {
        let daysData = try? JSONEncoder().encode(preferences.workoutReminderDays)

        return NotificationPreferencesModel(
            workoutRemindersEnabled: preferences.workoutRemindersEnabled,
            recoveryAlertsEnabled: preferences.recoveryAlertsEnabled,
            nutritionRemindersEnabled: preferences.nutritionRemindersEnabled,
            recoveryThreshold: preferences.recoveryThreshold,
            workoutReminderDaysData: daysData,
            workoutReminderHour: preferences.workoutReminderTime.hour ?? 18,
            workoutReminderMinute: preferences.workoutReminderTime.minute ?? 0,
            nutritionReminderHours: preferences.nutritionReminderHours
        )
    }
}
