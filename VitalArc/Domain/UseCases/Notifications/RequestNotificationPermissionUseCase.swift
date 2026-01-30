//
//  RequestNotificationPermissionUseCase.swift
//  VitalArc
//
//  Handles notification permission request flow
//

import Foundation
import UserNotifications

/// Result of permission request
struct NotificationPermissionResult: Equatable {
    let status: UNAuthorizationStatus
    let granted: Bool
    let shouldShowSettings: Bool
}

/// Protocol for requesting notification permissions
@MainActor
protocol RequestNotificationPermissionUseCaseProtocol {
    func execute() async throws -> NotificationPermissionResult
    func checkCurrentStatus() async -> UNAuthorizationStatus
}

/// Handles notification permission requests
@MainActor
final class RequestNotificationPermissionUseCase: RequestNotificationPermissionUseCaseProtocol {
    private let notificationScheduler: NotificationScheduler

    init(notificationScheduler: NotificationScheduler) {
        self.notificationScheduler = notificationScheduler
    }

    func execute() async throws -> NotificationPermissionResult {
        let currentStatus = await notificationScheduler.checkAuthorizationStatus()

        // If already denied, suggest settings
        if currentStatus == .denied {
            return NotificationPermissionResult(
                status: .denied,
                granted: false,
                shouldShowSettings: true
            )
        }

        // Request permission
        let granted = try await notificationScheduler.requestAuthorization()
        let newStatus = await notificationScheduler.checkAuthorizationStatus()

        return NotificationPermissionResult(
            status: newStatus,
            granted: granted,
            shouldShowSettings: !granted && newStatus == .denied
        )
    }

    func checkCurrentStatus() async -> UNAuthorizationStatus {
        return await notificationScheduler.checkAuthorizationStatus()
    }
}
