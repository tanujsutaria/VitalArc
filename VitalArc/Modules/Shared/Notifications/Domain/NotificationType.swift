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
    case goalAchievement = "goal_achievement"
    case streakMilestone = "streak_milestone"
    case personalRecord = "personal_record"

    /// User-facing label
    var label: String {
        switch self {
        case .workoutReminder:
            return "Workout Reminders"
        case .recoveryAlert:
            return "Recovery Alerts"
        case .nutritionReminder:
            return "Nutrition Reminders"
        case .goalAchievement:
            return "Goal Achievement"
        case .streakMilestone:
            return "Streak Milestones"
        case .personalRecord:
            return "Personal Records"
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
        case .goalAchievement:
            return "trophy.fill"
        case .streakMilestone:
            return "flame.fill"
        case .personalRecord:
            return "star.fill"
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
        case .goalAchievement:
            return true
        case .streakMilestone:
            return true
        case .personalRecord:
            return true
        }
    }

    /// Category identifier for iOS notification system
    var categoryIdentifier: String {
        return "vitalarc.\(rawValue)"
    }
}
