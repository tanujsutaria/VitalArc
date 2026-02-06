//
//  ScheduleNotificationsUseCase.swift
//  VitalArc
//
//  Orchestrates notification scheduling based on user preferences
//

import Foundation

/// Result of notification scheduling operation
struct NotificationScheduleResult: Equatable {
    let workoutRemindersScheduled: Int
    let nutritionReminderScheduled: Bool
    let recoveryAlertScheduled: Bool
    let totalPendingNotifications: Int
}

/// Protocol for scheduling notifications
@MainActor
protocol ScheduleNotificationsUseCaseProtocol {
    func execute() async throws -> NotificationScheduleResult
    func execute(preferences: NotificationPreferences) async throws -> NotificationScheduleResult
}

/// Schedules notifications based on user preferences
@MainActor
final class ScheduleNotificationsUseCase: ScheduleNotificationsUseCaseProtocol {
    private let notificationScheduler: NotificationScheduler
    private let preferencesRepository: NotificationPreferencesRepository

    init(
        notificationScheduler: NotificationScheduler,
        preferencesRepository: NotificationPreferencesRepository
    ) {
        self.notificationScheduler = notificationScheduler
        self.preferencesRepository = preferencesRepository
    }

    /// Schedule notifications using stored preferences
    func execute() async throws -> NotificationScheduleResult {
        let preferences = try await preferencesRepository.getPreferences() ?? .default
        return try await execute(preferences: preferences)
    }

    /// Schedule notifications with specific preferences
    func execute(preferences: NotificationPreferences) async throws -> NotificationScheduleResult {
        try await notificationScheduler.scheduleFromPreferences(preferences)

        let pendingCount = await notificationScheduler.getPendingNotificationCount()

        return NotificationScheduleResult(
            workoutRemindersScheduled: preferences.workoutRemindersEnabled ? preferences.workoutReminderDays.count : 0,
            nutritionReminderScheduled: preferences.nutritionRemindersEnabled,
            recoveryAlertScheduled: false, // Recovery alerts are dynamic
            totalPendingNotifications: pendingCount
        )
    }
}
