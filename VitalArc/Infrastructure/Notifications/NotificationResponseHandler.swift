//
//  NotificationResponseHandler.swift
//  VitalArc
//
//  Handles user responses to notifications
//

import Foundation
import UserNotifications

/// Navigation action to perform after handling notification
enum NotificationNavigationAction {
    case openWorkout
    case openRecovery
    case openNutrition
    case none
}

/// Delegate for notification responses
@MainActor
final class NotificationResponseHandler: NSObject {

    /// Callback for navigation actions
    var onNavigationAction: ((NotificationNavigationAction) -> Void)?

    private let notificationScheduler: NotificationScheduler

    init(notificationScheduler: NotificationScheduler) {
        self.notificationScheduler = notificationScheduler
        super.init()
    }

    // MARK: - Response Handling

    func handleResponse(actionIdentifier: String, categoryIdentifier: String) async {
        switch actionIdentifier {
        case NotificationActionIdentifier.startWorkout:
            onNavigationAction?(.openWorkout)

        case NotificationActionIdentifier.snoozeWorkout:
            await snoozeWorkoutReminder()

        case NotificationActionIdentifier.viewRecovery:
            onNavigationAction?(.openRecovery)

        case NotificationActionIdentifier.logMeal:
            onNavigationAction?(.openNutrition)

        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification
            handleDefaultAction(for: categoryIdentifier)

        default:
            break
        }
    }

    private func handleDefaultAction(for categoryIdentifier: String) {
        if categoryIdentifier == NotificationType.workoutReminder.categoryIdentifier {
            onNavigationAction?(.openWorkout)
        } else if categoryIdentifier == NotificationType.recoveryAlert.categoryIdentifier {
            onNavigationAction?(.openRecovery)
        } else if categoryIdentifier == NotificationType.nutritionReminder.categoryIdentifier {
            onNavigationAction?(.openNutrition)
        }
    }

    private func snoozeWorkoutReminder() async {
        // Schedule a one-time reminder in 1 hour
        let content = UNMutableNotificationContent()
        content.title = "Workout Reminder"
        content.body = "You snoozed your workout reminder. Ready to start?"
        content.sound = .default
        content.categoryIdentifier = NotificationType.workoutReminder.categoryIdentifier

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(
            identifier: "com.vitalarc.workout.snoozed",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationResponseHandler: UNUserNotificationCenterDelegate {

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notifications even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        let categoryIdentifier = response.notification.request.content.categoryIdentifier

        Task { @MainActor in
            await handleResponse(actionIdentifier: actionIdentifier, categoryIdentifier: categoryIdentifier)
        }

        completionHandler()
    }
}
