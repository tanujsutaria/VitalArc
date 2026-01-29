//
//  NotificationType.swift
//  VitalArc
//
//  Domain Entity for Notification Type
//

import Foundation

/// Types of notifications supported by VitalArc
enum NotificationType: String, CaseIterable, Codable {
    case workoutReminder = "workout_reminder"
    case recoveryAlert = "recovery_alert"
    case nutritionReminder = "nutrition_reminder"

    /// User-facing label
    var label: String {
        switch self {
        case .workoutReminder:
            return "Workout Reminders"
        case .recoveryAlert:
            return "Recovery Alerts"
        case .nutritionReminder:
            return "Nutrition Reminders"
        }
    }

    /// SF Symbol icon name
    var icon: String {
        switch self {
        case .workoutReminder:
            return "dumbbell.fill"
        case .recoveryAlert:
            return "heart.text.square.fill"
        case .nutritionReminder:
            return "fork.knife"
        }
    }

    /// Default enabled state for new users
    var defaultEnabled: Bool {
        switch self {
        case .workoutReminder:
            return true
        case .recoveryAlert:
            return true
        case .nutritionReminder:
            return false
        }
    }

    /// Category identifier for iOS notification system
    var categoryIdentifier: String {
        return "vitalarc.\(rawValue)"
    }
}
