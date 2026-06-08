//
//  SharedContainer.swift
//  VitalArc
//
//  Dependency container for shared/cross-domain dependencies
//

import Foundation
import SwiftData

/// Container for user, analytics, notifications, and cross-domain dependencies
@MainActor
final class SharedContainer {
    let userRepository: SwiftDataUserRepository
    let analyticsRepository: SwiftDataAnalyticsRepository
    let notificationPreferencesRepository: SwiftDataNotificationPreferencesRepository
    let notificationScheduler: NotificationScheduler
    let scheduleNotificationsUseCase: ScheduleNotificationsUseCase
    let requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase
    let checkRecoveryAndNotifyUseCase: CheckRecoveryAndNotifyUseCase

    init(modelContext: ModelContext) {
        self.userRepository = SwiftDataUserRepository(modelContext: modelContext)
        self.analyticsRepository = SwiftDataAnalyticsRepository(modelContext: modelContext)
        self.notificationPreferencesRepository = SwiftDataNotificationPreferencesRepository(modelContext: modelContext)
        self.notificationScheduler = NotificationScheduler()
        self.scheduleNotificationsUseCase = ScheduleNotificationsUseCase(
            notificationScheduler: self.notificationScheduler,
            preferencesRepository: self.notificationPreferencesRepository
        )
        self.requestNotificationPermissionUseCase = RequestNotificationPermissionUseCase(
            notificationScheduler: self.notificationScheduler
        )
        self.checkRecoveryAndNotifyUseCase = CheckRecoveryAndNotifyUseCase(
            notificationScheduler: self.notificationScheduler,
            preferencesRepository: self.notificationPreferencesRepository
        )
    }
}

// UserProfileProviding conformance inherited from UserRepository
