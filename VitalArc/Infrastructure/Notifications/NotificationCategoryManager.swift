//
//  NotificationCategoryManager.swift
//  VitalArc
//
//  Registers notification categories with action buttons
//

import Foundation
import UserNotifications

/// Manages notification categories and their actions
@MainActor
final class NotificationCategoryManager {

    static let shared = NotificationCategoryManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    /// Register all notification categories with the system
    func registerCategories() {
        let categories: Set<UNNotificationCategory> = [
            createWorkoutReminderCategory(),
            createRecoveryAlertCategory(),
            createNutritionReminderCategory()
        ]

        notificationCenter.setNotificationCategories(categories)
    }

    // MARK: - Category Definitions

    private func createWorkoutReminderCategory() -> UNNotificationCategory {
        let startAction = UNNotificationAction(
            identifier: NotificationActionIdentifier.startWorkout,
            title: "Start Workout",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: NotificationActionIdentifier.snoozeWorkout,
            title: "Remind in 1 Hour",
            options: []
        )

        return UNNotificationCategory(
            identifier: NotificationType.workoutReminder.categoryIdentifier,
            actions: [startAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
    }

    private func createRecoveryAlertCategory() -> UNNotificationCategory {
        let viewAction = UNNotificationAction(
            identifier: NotificationActionIdentifier.viewRecovery,
            title: "View Details",
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: NotificationActionIdentifier.dismissRecovery,
            title: "Dismiss",
            options: [.destructive]
        )

        return UNNotificationCategory(
            identifier: NotificationType.recoveryAlert.categoryIdentifier,
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
    }

    private func createNutritionReminderCategory() -> UNNotificationCategory {
        let logAction = UNNotificationAction(
            identifier: NotificationActionIdentifier.logMeal,
            title: "Log Meal",
            options: [.foreground]
        )

        let skipAction = UNNotificationAction(
            identifier: NotificationActionIdentifier.skipNutrition,
            title: "Skip Today",
            options: []
        )

        return UNNotificationCategory(
            identifier: NotificationType.nutritionReminder.categoryIdentifier,
            actions: [logAction, skipAction],
            intentIdentifiers: [],
            options: []
        )
    }
}

// MARK: - Action Identifiers

/// Constants for notification action identifiers
enum NotificationActionIdentifier {
    static let startWorkout = "START_WORKOUT"
    static let snoozeWorkout = "SNOOZE_WORKOUT"
    static let viewRecovery = "VIEW_RECOVERY"
    static let dismissRecovery = "DISMISS_RECOVERY"
    static let logMeal = "LOG_MEAL"
    static let skipNutrition = "SKIP_NUTRITION"
}
