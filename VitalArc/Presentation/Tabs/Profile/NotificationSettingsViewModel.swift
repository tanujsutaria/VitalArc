//
//  NotificationSettingsViewModel.swift
//  VitalArc
//
//  ViewModel for notification settings
//

import Foundation
import UserNotifications

@MainActor
@Observable
final class NotificationSettingsViewModel {
    // MARK: - State
    var notificationsEnabled: Bool {
        didSet { syncToUserDefaults() }
    }
    var workoutRemindersEnabled: Bool {
        didSet { syncToUserDefaults() }
    }
    var recoveryAlertsEnabled: Bool {
        didSet { syncToUserDefaults() }
    }
    var workoutReminderTime: Date {
        didSet { syncToUserDefaults() }
    }
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var isLoading = false
    var errorMessage: String?

    // MARK: - Constants
    private let workoutReminderID = "com.vitalarc.notification.workoutReminder"
    private let recoveryAlertID = "com.vitalarc.notification.recoveryAlert"

    // MARK: - Initialization
    init() {
        // Load from UserDefaults
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "enableNotifications")
        self.workoutRemindersEnabled = UserDefaults.standard.bool(forKey: "enableWorkoutReminders")
        self.recoveryAlertsEnabled = UserDefaults.standard.bool(forKey: "enableRecoveryAlerts")

        // Load time (default to 6:00 PM)
        if let timeData = UserDefaults.standard.data(forKey: "workoutReminderTime"),
           let savedTime = try? JSONDecoder().decode(Date.self, from: timeData) {
            self.workoutReminderTime = savedTime
        } else {
            let calendar = Calendar.current
            self.workoutReminderTime = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
        }

        // Check authorization status
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Notification Permissions
    func requestNotificationPermissions() async {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            authorizationStatus = granted ? .authorized : .denied

            if !granted {
                notificationsEnabled = false
                errorMessage = "Notification permissions were denied. You can enable them in Settings."
            }
        } catch {
            authorizationStatus = .denied
            notificationsEnabled = false
            errorMessage = "Failed to request notification permissions."
        }
    }

    func checkAuthorizationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - Workout Reminder Scheduling
    func scheduleWorkoutReminder() async {
        // Cancel existing reminder first
        await cancelWorkoutReminder()

        guard workoutRemindersEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to Train!"
        content.body = "Your scheduled workout is ready. Let's crush those goals!"
        content.sound = .default
        content.badge = 1

        // Create trigger from selected time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: workoutReminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: workoutReminderID, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            errorMessage = "Failed to schedule workout reminder."
        }
    }

    func cancelWorkoutReminder() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [workoutReminderID])
    }

    // MARK: - Recovery Alert Scheduling
    func scheduleRecoveryAlerts() async {
        // Cancel existing alerts first
        await cancelRecoveryAlerts()

        guard recoveryAlertsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Recovery Day"
        content.body = "Your body needs rest. Consider a lighter workout today."
        content.sound = .default

        // Schedule check for next morning (8 AM)
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: recoveryAlertID, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            errorMessage = "Failed to schedule recovery alert."
        }
    }

    func cancelRecoveryAlerts() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [recoveryAlertID])
    }

    // MARK: - Bulk Operations
    func cancelAllNotifications() async {
        await cancelWorkoutReminder()
        await cancelRecoveryAlerts()
        workoutRemindersEnabled = false
        recoveryAlertsEnabled = false
    }

    // MARK: - Persistence
    private func syncToUserDefaults() {
        UserDefaults.standard.set(notificationsEnabled, forKey: "enableNotifications")
        UserDefaults.standard.set(workoutRemindersEnabled, forKey: "enableWorkoutReminders")
        UserDefaults.standard.set(recoveryAlertsEnabled, forKey: "enableRecoveryAlerts")

        if let encoded = try? JSONEncoder().encode(workoutReminderTime) {
            UserDefaults.standard.set(encoded, forKey: "workoutReminderTime")
        }
    }
}
