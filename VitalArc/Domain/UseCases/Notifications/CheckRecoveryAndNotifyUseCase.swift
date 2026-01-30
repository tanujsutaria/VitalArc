//
//  CheckRecoveryAndNotifyUseCase.swift
//  VitalArc
//
//  Checks recovery score and schedules alert if below threshold
//

import Foundation

/// Protocol for checking recovery and scheduling notifications
@MainActor
protocol CheckRecoveryAndNotifyUseCaseProtocol {
    func execute() async throws -> Bool
    func execute(recoveryScore: Double) async throws -> Bool
}

/// Checks recovery score and schedules alert if needed
@MainActor
final class CheckRecoveryAndNotifyUseCase: CheckRecoveryAndNotifyUseCaseProtocol {
    private let notificationScheduler: NotificationScheduler
    private let preferencesRepository: NotificationPreferencesRepository

    init(
        notificationScheduler: NotificationScheduler,
        preferencesRepository: NotificationPreferencesRepository
    ) {
        self.notificationScheduler = notificationScheduler
        self.preferencesRepository = preferencesRepository
    }

    /// Check recovery using provided score and schedule alert if needed
    /// Returns true if a recovery alert was scheduled
    func execute(recoveryScore: Double) async throws -> Bool {
        let preferences = try await preferencesRepository.getPreferences() ?? .default

        guard preferences.recoveryAlertsEnabled else {
            return false
        }

        try await notificationScheduler.scheduleRecoveryAlertIfNeeded(
            recoveryScore: recoveryScore,
            threshold: preferences.recoveryThreshold,
            enabled: preferences.recoveryAlertsEnabled
        )

        return recoveryScore < Double(preferences.recoveryThreshold)
    }

    /// Execute without a pre-calculated recovery score
    /// This method requires external recovery calculation
    func execute() async throws -> Bool {
        // This method is a placeholder for when recovery score
        // needs to be calculated within this use case
        // Currently, the score should be passed from the caller
        return false
    }
}
