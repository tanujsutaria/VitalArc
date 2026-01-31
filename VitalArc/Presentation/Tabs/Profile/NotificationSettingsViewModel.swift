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

    var preferences: NotificationPreferences
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    /// User's intent to enable notifications (separate from system authorization)
    var userWantsNotifications = false
    var isLoading = false
    var errorMessage: String?
    var pendingNotificationCount: Int = 0

    // MARK: - Dependencies

    private let scheduler: NotificationSchedulerProtocol
    private let repository: NotificationPreferencesRepository?
    private let requestPermissionUseCase: RequestNotificationPermissionUseCaseProtocol?
    private let scheduleNotificationsUseCase: ScheduleNotificationsUseCaseProtocol?
    private let checkRecoveryUseCase: CheckRecoveryAndNotifyUseCaseProtocol?

    // MARK: - Debouncing

    /// Task handle for debounced saveAndReschedule - cancelled on new changes
    private var saveTask: Task<Void, Never>?
    /// Debounce interval in nanoseconds (300ms)
    private let debounceInterval: UInt64 = 300_000_000

    // MARK: - Computed Properties

    /// Notifications are enabled when user wants them AND system has authorized
    var notificationsEnabled: Bool {
        get { userWantsNotifications && authorizationStatus == .authorized }
        set {
            userWantsNotifications = newValue
            // Actual permission/scheduling handled by .onChange in View
        }
    }

    var workoutRemindersEnabled: Bool {
        get { preferences.workoutRemindersEnabled }
        set {
            preferences.workoutRemindersEnabled = newValue
            Task { await saveAndReschedule() }
        }
    }

    var recoveryAlertsEnabled: Bool {
        get { preferences.recoveryAlertsEnabled }
        set {
            preferences.recoveryAlertsEnabled = newValue
            Task { await saveAndReschedule() }
        }
    }

    var nutritionRemindersEnabled: Bool {
        get { preferences.nutritionRemindersEnabled }
        set {
            preferences.nutritionRemindersEnabled = newValue
            Task { await saveAndReschedule() }
        }
    }

    var workoutReminderTime: Date {
        get {
            let calendar = Calendar.current
            let hour = preferences.workoutReminderTime.hour ?? 18
            let minute = preferences.workoutReminderTime.minute ?? 0
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
        }
        set {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: newValue)
            preferences.workoutReminderTime = components
            Task { await saveAndReschedule() }
        }
    }

    // MARK: - Day Selection Helpers

    var mondayEnabled: Bool {
        get { preferences.workoutReminderDays.contains(2) }
        set { toggleDay(2, enabled: newValue) }
    }

    var tuesdayEnabled: Bool {
        get { preferences.workoutReminderDays.contains(3) }
        set { toggleDay(3, enabled: newValue) }
    }

    var wednesdayEnabled: Bool {
        get { preferences.workoutReminderDays.contains(4) }
        set { toggleDay(4, enabled: newValue) }
    }

    var thursdayEnabled: Bool {
        get { preferences.workoutReminderDays.contains(5) }
        set { toggleDay(5, enabled: newValue) }
    }

    var fridayEnabled: Bool {
        get { preferences.workoutReminderDays.contains(6) }
        set { toggleDay(6, enabled: newValue) }
    }

    var saturdayEnabled: Bool {
        get { preferences.workoutReminderDays.contains(7) }
        set { toggleDay(7, enabled: newValue) }
    }

    var sundayEnabled: Bool {
        get { preferences.workoutReminderDays.contains(1) }
        set { toggleDay(1, enabled: newValue) }
    }

    private func toggleDay(_ day: Int, enabled: Bool) {
        if enabled {
            preferences.workoutReminderDays.insert(day)
        } else {
            preferences.workoutReminderDays.remove(day)
        }
        Task { await saveAndReschedule() }
    }

    // MARK: - Initialization

    init(
        scheduler: NotificationSchedulerProtocol? = nil,
        repository: NotificationPreferencesRepository? = nil,
        requestPermissionUseCase: RequestNotificationPermissionUseCaseProtocol? = nil,
        scheduleNotificationsUseCase: ScheduleNotificationsUseCaseProtocol? = nil,
        checkRecoveryUseCase: CheckRecoveryAndNotifyUseCaseProtocol? = nil
    ) {
        self.scheduler = scheduler ?? NotificationScheduler()
        self.repository = repository
        self.requestPermissionUseCase = requestPermissionUseCase
        self.scheduleNotificationsUseCase = scheduleNotificationsUseCase
        self.checkRecoveryUseCase = checkRecoveryUseCase
        self.preferences = .default

        Task {
            await loadPreferences()
            await checkAuthorizationStatus()
            await updatePendingCount()
        }
    }

    // MARK: - Notification Permissions

    func requestNotificationPermissions() async {
        // Guard: Skip if already authorized to prevent re-triggering from .onChange
        guard authorizationStatus != .authorized else {
            userWantsNotifications = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // Use the use case if available, otherwise fall back to scheduler
            if let useCase = requestPermissionUseCase {
                let result = try await useCase.execute()
                authorizationStatus = result.status

                if !result.granted {
                    // Revert user intent and disable all notification preferences
                    userWantsNotifications = false
                    preferences.workoutRemindersEnabled = false
                    preferences.recoveryAlertsEnabled = false
                    preferences.nutritionRemindersEnabled = false
                    await savePreferences()

                    errorMessage = result.shouldShowSettings
                        ? "Notification permissions were denied. You can enable them in Settings."
                        : nil
                } else {
                    // User successfully enabled - save preference and schedule
                    userWantsNotifications = true
                    await saveAndReschedule()
                }
            } else {
                // Fallback to direct scheduler call
                let granted = try await scheduler.requestAuthorization()
                authorizationStatus = granted ? .authorized : .denied

                if !granted {
                    // Revert user intent and disable all notification preferences
                    userWantsNotifications = false
                    preferences.workoutRemindersEnabled = false
                    preferences.recoveryAlertsEnabled = false
                    preferences.nutritionRemindersEnabled = false
                    await savePreferences()

                    errorMessage = "Notification permissions were denied. You can enable them in Settings."
                } else {
                    // User successfully enabled - save preference and schedule
                    userWantsNotifications = true
                    await saveAndReschedule()
                }
            }
        } catch {
            authorizationStatus = .denied
            userWantsNotifications = false
            // Explicitly reset preferences on error
            preferences.workoutRemindersEnabled = false
            preferences.recoveryAlertsEnabled = false
            preferences.nutritionRemindersEnabled = false
            await savePreferences()

            errorMessage = "Failed to request notification permissions."
        }
    }

    func checkAuthorizationStatus() async {
        // Use the use case if available, otherwise fall back to scheduler
        if let useCase = requestPermissionUseCase {
            authorizationStatus = await useCase.checkCurrentStatus()
        } else {
            authorizationStatus = await scheduler.checkAuthorizationStatus()
        }

        // Sync userWantsNotifications with actual authorization on initial check
        // If authorized, assume user wants notifications (can be overridden by toggle)
        if authorizationStatus == .authorized {
            userWantsNotifications = true
        }
    }

    // MARK: - Preference Updates

    func setWorkoutRemindersEnabled(_ enabled: Bool) {
        preferences.workoutRemindersEnabled = enabled
        Task { await saveAndReschedule() }
    }

    func setRecoveryAlertsEnabled(_ enabled: Bool) {
        preferences.recoveryAlertsEnabled = enabled
        Task { await saveAndReschedule() }
    }

    func setNutritionRemindersEnabled(_ enabled: Bool) {
        preferences.nutritionRemindersEnabled = enabled
        Task { await saveAndReschedule() }
    }

    func setRecoveryThreshold(_ threshold: Int) {
        preferences.recoveryThreshold = max(0, min(100, threshold))
        Task { await savePreferences() }
    }

    func setNutritionReminderHours(_ hours: Int) {
        preferences.nutritionReminderHours = max(1, min(12, hours))
        Task { await saveAndReschedule() }
    }

    // MARK: - Recovery Alert Scheduling

    /// Call this after calculating recovery score to conditionally schedule alert
    func checkRecoveryAndScheduleAlert(recoveryScore: Double) async {
        do {
            // Use the use case if available, otherwise fall back to scheduler
            if let useCase = checkRecoveryUseCase {
                _ = try await useCase.execute(recoveryScore: recoveryScore)
            } else {
                try await scheduler.scheduleRecoveryAlertIfNeeded(
                    recoveryScore: recoveryScore,
                    threshold: preferences.recoveryThreshold,
                    enabled: preferences.recoveryAlertsEnabled
                )
            }
            await updatePendingCount()
        } catch {
            errorMessage = "Failed to schedule recovery alert."
        }
    }

    // MARK: - Individual Notification Scheduling

    func scheduleWorkoutReminder() async {
        guard authorizationStatus == .authorized else { return }
        do {
            try await scheduler.scheduleFromPreferences(preferences)
            await updatePendingCount()
        } catch {
            errorMessage = "Failed to schedule workout reminder."
        }
    }

    func cancelWorkoutReminder() async {
        preferences.workoutRemindersEnabled = false
        await saveAndReschedule()
    }

    func scheduleRecoveryAlerts() async {
        guard authorizationStatus == .authorized else { return }
        preferences.recoveryAlertsEnabled = true
        await saveAndReschedule()
    }

    func cancelRecoveryAlerts() async {
        preferences.recoveryAlertsEnabled = false
        await saveAndReschedule()
    }

    // MARK: - Bulk Operations

    func cancelAllNotifications() async {
        await scheduler.cancelAllScheduledNotifications()
        preferences.workoutRemindersEnabled = false
        preferences.recoveryAlertsEnabled = false
        preferences.nutritionRemindersEnabled = false
        await savePreferences()
        await updatePendingCount()
    }

    // MARK: - Badge Management

    func clearBadge() async {
        do {
            try await scheduler.clearBadge()
        } catch {
            // Badge clearing failed - non-critical
        }
    }

    // MARK: - Persistence

    private func loadPreferences() async {
        guard let repository = repository else {
            // Fall back to UserDefaults if no repository
            loadFromUserDefaults()
            return
        }

        do {
            if let saved = try await repository.getPreferences() {
                preferences = saved
            }
        } catch {
            // Fall back to defaults on error
            loadFromUserDefaults()
        }
    }

    private func savePreferences() async {
        // Use repository as single source of truth when available
        if let repository = repository {
            do {
                try await repository.savePreferences(preferences)
                // Only sync to UserDefaults on successful repository save
                saveToUserDefaults()
            } catch {
                // Don't update UserDefaults on repository failure to maintain consistency
                errorMessage = "Failed to save notification preferences."
            }
        } else {
            // No repository - use UserDefaults as fallback
            saveToUserDefaults()
        }
    }

    /// Debounced save and reschedule - cancels previous pending task to avoid race conditions
    private func saveAndReschedule() async {
        guard authorizationStatus == .authorized else { return }

        // Cancel any pending save task to prevent race conditions
        saveTask?.cancel()

        // Create new debounced task
        saveTask = Task {
            // Wait for debounce interval
            do {
                try await Task.sleep(nanoseconds: debounceInterval)
            } catch {
                // Task was cancelled - another change came in
                return
            }

            // Check if task was cancelled during sleep
            guard !Task.isCancelled else { return }

            await performSaveAndReschedule()
        }

        // Wait for the task to complete (or be cancelled)
        await saveTask?.value
    }

    /// Actual save and reschedule implementation
    private func performSaveAndReschedule() async {
        await savePreferences()

        do {
            // Use the use case if available, otherwise fall back to scheduler
            if let useCase = scheduleNotificationsUseCase {
                _ = try await useCase.execute(preferences: preferences)
            } else {
                try await scheduler.scheduleFromPreferences(preferences)
            }
            await updatePendingCount()
        } catch {
            errorMessage = "Failed to schedule notifications."
        }
    }

    private func updatePendingCount() async {
        pendingNotificationCount = await scheduler.getPendingNotificationCount()
    }

    // MARK: - UserDefaults Fallback

    private func loadFromUserDefaults() {
        let defaults = UserDefaults.standard

        preferences.workoutRemindersEnabled = defaults.bool(forKey: "enableWorkoutReminders")
        preferences.recoveryAlertsEnabled = defaults.bool(forKey: "enableRecoveryAlerts")
        preferences.nutritionRemindersEnabled = defaults.bool(forKey: "enableNutritionReminders")
        preferences.recoveryThreshold = defaults.integer(forKey: "recoveryThreshold")

        if preferences.recoveryThreshold == 0 {
            preferences.recoveryThreshold = 50 // Default
        }

        // Load workout days
        if let daysArray = defaults.array(forKey: "workoutReminderDays") as? [Int] {
            preferences.workoutReminderDays = Set(daysArray)
        }

        // Load workout time
        if let timeData = defaults.data(forKey: "workoutReminderTime"),
           let savedTime = try? JSONDecoder().decode(Date.self, from: timeData) {
            let calendar = Calendar.current
            preferences.workoutReminderTime = calendar.dateComponents([.hour, .minute], from: savedTime)
        }
    }

    private func saveToUserDefaults() {
        let defaults = UserDefaults.standard

        defaults.set(preferences.workoutRemindersEnabled, forKey: "enableWorkoutReminders")
        defaults.set(preferences.recoveryAlertsEnabled, forKey: "enableRecoveryAlerts")
        defaults.set(preferences.nutritionRemindersEnabled, forKey: "enableNutritionReminders")
        defaults.set(preferences.recoveryThreshold, forKey: "recoveryThreshold")
        defaults.set(Array(preferences.workoutReminderDays), forKey: "workoutReminderDays")

        // Save time as Date for backward compatibility
        let calendar = Calendar.current
        let hour = preferences.workoutReminderTime.hour ?? 18
        let minute = preferences.workoutReminderTime.minute ?? 0
        if let timeDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()),
           let encoded = try? JSONEncoder().encode(timeDate) {
            defaults.set(encoded, forKey: "workoutReminderTime")
        }
    }
}
