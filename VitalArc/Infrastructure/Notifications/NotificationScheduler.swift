//
//  NotificationScheduler.swift
//  VitalArc
//
//  Infrastructure service for scheduling local notifications
//

import Foundation
import UserNotifications

/// Handles scheduling and management of local notifications
@MainActor
final class NotificationScheduler {

    // MARK: - Notification Identifiers

    private enum NotificationID {
        static let workoutReminderPrefix = "com.vitalarc.workout."
        static let recoveryAlert = "com.vitalarc.recovery.alert"
        static let nutritionReminder = "com.vitalarc.nutrition.reminder"
    }

    // MARK: - Properties

    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Authorization

    /// Request notification permissions
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await notificationCenter.requestAuthorization(options: options)
    }

    /// Check current authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule All From Preferences

    /// Schedule all notifications based on user preferences
    func scheduleFromPreferences(_ preferences: NotificationPreferences) async throws {
        // Cancel existing notifications first
        await cancelAllScheduledNotifications()

        // Schedule workout reminders
        if preferences.workoutRemindersEnabled {
            try await scheduleWorkoutReminders(
                days: preferences.workoutReminderDays,
                time: preferences.workoutReminderTime
            )
        }

        // Schedule nutrition reminders
        if preferences.nutritionRemindersEnabled {
            try await scheduleNutritionReminder(
                hoursBeforeEndOfDay: preferences.nutritionReminderHours
            )
        }

        // Note: Recovery alerts are scheduled dynamically based on score
        // See scheduleRecoveryAlertIfNeeded()
    }

    // MARK: - Workout Reminders

    /// Schedule workout reminders for specific days and time
    private func scheduleWorkoutReminders(
        days: Set<Int>,
        time: DateComponents
    ) async throws {
        guard let hour = time.hour, let minute = time.minute else { return }

        for day in days {
            var dateComponents = DateComponents()
            dateComponents.weekday = day
            dateComponents.hour = hour
            dateComponents.minute = minute

            let content = UNMutableNotificationContent()
            content.title = "Time to Train!"
            content.body = workoutReminderBody(for: day)
            content.sound = .default
            content.categoryIdentifier = NotificationType.workoutReminder.categoryIdentifier

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )

            let identifier = "\(NotificationID.workoutReminderPrefix)\(day)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            try await notificationCenter.add(request)
        }
    }

    /// Generate contextual workout reminder message
    private func workoutReminderBody(for weekday: Int) -> String {
        switch weekday {
        case 1: return "Sunday session! Start your week strong."
        case 2: return "Monday motivation - let's crush it!"
        case 3: return "Tuesday training time. Stay consistent!"
        case 4: return "Midweek workout - you're halfway there!"
        case 5: return "Thursday thunder - push your limits!"
        case 6: return "Friday fitness - finish the week strong!"
        case 7: return "Saturday session - work hard, rest harder!"
        default: return "Your scheduled workout is ready. Let's go!"
        }
    }

    /// Cancel all workout reminders
    func cancelWorkoutReminders() async {
        let pending = await notificationCenter.pendingNotificationRequests()
        let workoutIDs = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(NotificationID.workoutReminderPrefix) }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: workoutIDs)
    }

    // MARK: - Recovery Alerts

    /// Schedule a recovery alert if score is below threshold
    /// Call this after calculating recovery score
    func scheduleRecoveryAlertIfNeeded(
        recoveryScore: Double,
        threshold: Int,
        enabled: Bool
    ) async throws {
        // Cancel any existing recovery alert
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [NotificationID.recoveryAlert]
        )

        guard enabled, recoveryScore < Double(threshold) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Recovery Day Recommended"
        content.body = recoveryAlertBody(score: recoveryScore)
        content.sound = .default
        content.categoryIdentifier = NotificationType.recoveryAlert.categoryIdentifier

        // Schedule for next morning at 8 AM
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0

        // Find next occurrence
        let calendar = Calendar.current
        if let nextMorning = calendar.nextDate(
            after: Date(),
            matching: dateComponents,
            matchingPolicy: .nextTime
        ) {
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextMorning),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: NotificationID.recoveryAlert,
                content: content,
                trigger: trigger
            )

            try await notificationCenter.add(request)
        }
    }

    /// Generate recovery alert message based on score
    private func recoveryAlertBody(score: Double) -> String {
        let roundedScore = Int(score)
        if score < 30 {
            return "Recovery score is \(roundedScore)%. Consider rest or light activity today."
        } else if score < 50 {
            return "Recovery score is \(roundedScore)%. A lighter workout is recommended."
        } else {
            return "Recovery score is \(roundedScore)%. Listen to your body today."
        }
    }

    /// Cancel recovery alerts
    func cancelRecoveryAlerts() {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [NotificationID.recoveryAlert]
        )
    }

    // MARK: - Nutrition Reminders

    /// Schedule daily nutrition reminder
    private func scheduleNutritionReminder(hoursBeforeEndOfDay: Int) async throws {
        let reminderHour = 24 - hoursBeforeEndOfDay
        guard (0...23).contains(reminderHour) else { return }

        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Log Your Meals"
        content.body = "Don't forget to track your nutrition for today!"
        content.sound = .default
        content.categoryIdentifier = NotificationType.nutritionReminder.categoryIdentifier

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: NotificationID.nutritionReminder,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    /// Cancel nutrition reminders
    func cancelNutritionReminders() {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [NotificationID.nutritionReminder]
        )
    }

    // MARK: - Badge Management

    /// Update app badge count
    func updateBadgeCount(_ count: Int) async throws {
        try await notificationCenter.setBadgeCount(count)
    }

    /// Clear app badge
    func clearBadge() async throws {
        try await notificationCenter.setBadgeCount(0)
    }

    // MARK: - Bulk Operations

    /// Cancel all scheduled notifications
    func cancelAllScheduledNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    /// Get count of pending notifications
    func getPendingNotificationCount() async -> Int {
        let pending = await notificationCenter.pendingNotificationRequests()
        return pending.count
    }

    /// Get all pending notification identifiers (for debugging)
    func getPendingNotificationIdentifiers() async -> [String] {
        let pending = await notificationCenter.pendingNotificationRequests()
        return pending.map(\.identifier)
    }
}
