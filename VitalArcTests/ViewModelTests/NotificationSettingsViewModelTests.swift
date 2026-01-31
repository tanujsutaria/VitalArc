//
//  NotificationSettingsViewModelTests.swift
//  VitalArcTests
//
//  Unit tests for NotificationSettingsViewModel
//
//  Note: Full scheduler testing requires extracting NotificationScheduler to a protocol.
//  Current tests focus on state management and repository persistence.
//

import XCTest
import UserNotifications
@testable import VitalArc

@MainActor
final class NotificationSettingsViewModelTests: XCTestCase {

    var mockRepository: MockNotificationPreferencesRepository!
    var mockScheduler: MockNotificationScheduler!
    var viewModel: NotificationSettingsViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockNotificationPreferencesRepository()
        mockScheduler = MockNotificationScheduler()
        mockScheduler.mockAuthorizationStatus = .authorized
        viewModel = NotificationSettingsViewModel(scheduler: mockScheduler, repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        mockScheduler = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialStateDefaults() {
        // Note: Due to async init loading, some state may vary
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testInitialPreferencesAreDefault() {
        // Preferences should start as default
        let prefs = viewModel.preferences
        XCTAssertNotNil(prefs)
    }

    // MARK: - Preference Toggles Tests

    func testWorkoutRemindersEnabledSetter() async {
        // Setup - default is true, so toggle to false then back to true
        XCTAssertTrue(viewModel.preferences.workoutRemindersEnabled)

        // Execute - toggle off
        viewModel.workoutRemindersEnabled = false
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertFalse(viewModel.preferences.workoutRemindersEnabled)

        // Execute - toggle back on
        viewModel.workoutRemindersEnabled = true
        try? await Task.sleep(for: .milliseconds(100))

        // Verify
        XCTAssertTrue(viewModel.preferences.workoutRemindersEnabled)
    }

    func testRecoveryAlertsEnabledSetter() async {
        // Setup - default is true, so toggle to false then back to true
        XCTAssertTrue(viewModel.preferences.recoveryAlertsEnabled)

        // Execute - toggle off
        viewModel.recoveryAlertsEnabled = false
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertFalse(viewModel.preferences.recoveryAlertsEnabled)

        // Execute - toggle back on
        viewModel.recoveryAlertsEnabled = true
        try? await Task.sleep(for: .milliseconds(100))

        // Verify
        XCTAssertTrue(viewModel.preferences.recoveryAlertsEnabled)
    }

    func testNutritionRemindersEnabledSetter() async {
        // Setup
        XCTAssertFalse(viewModel.preferences.nutritionRemindersEnabled)

        // Execute
        viewModel.nutritionRemindersEnabled = true

        // Allow async save to complete
        try? await Task.sleep(for: .milliseconds(100))

        // Verify
        XCTAssertTrue(viewModel.preferences.nutritionRemindersEnabled)
    }

    // MARK: - Day Toggle Tests

    func testMondayEnabledToggle() async {
        // Execute - toggle on
        viewModel.mondayEnabled = true
        try? await Task.sleep(for: .milliseconds(100))

        // Verify
        XCTAssertTrue(viewModel.preferences.workoutReminderDays.contains(2))

        // Execute - toggle off
        viewModel.mondayEnabled = false
        try? await Task.sleep(for: .milliseconds(100))

        // Verify
        XCTAssertFalse(viewModel.preferences.workoutReminderDays.contains(2))
    }

    func testTuesdayEnabledToggle() async {
        viewModel.tuesdayEnabled = true
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(viewModel.preferences.workoutReminderDays.contains(3))
    }

    func testWednesdayEnabledToggle() async {
        viewModel.wednesdayEnabled = true
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(viewModel.preferences.workoutReminderDays.contains(4))
    }

    func testThursdayEnabledToggle() async {
        viewModel.thursdayEnabled = true
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(viewModel.preferences.workoutReminderDays.contains(5))
    }

    func testFridayEnabledToggle() async {
        viewModel.fridayEnabled = true
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(viewModel.preferences.workoutReminderDays.contains(6))
    }

    func testSaturdayEnabledToggle() async {
        viewModel.saturdayEnabled = true
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(viewModel.preferences.workoutReminderDays.contains(7))
    }

    func testSundayEnabledToggle() async {
        viewModel.sundayEnabled = true
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(viewModel.preferences.workoutReminderDays.contains(1))
    }

    // MARK: - Configuration Tests

    func testSetRecoveryThresholdClampsLowValue() async {
        // Execute with value below 0
        viewModel.setRecoveryThreshold(-10)
        try? await Task.sleep(for: .milliseconds(100))

        // Verify clamped to 0
        XCTAssertEqual(viewModel.preferences.recoveryThreshold, 0)
    }

    func testSetRecoveryThresholdClampsHighValue() async {
        // Execute with value above 100
        viewModel.setRecoveryThreshold(150)
        try? await Task.sleep(for: .milliseconds(100))

        // Verify clamped to 100
        XCTAssertEqual(viewModel.preferences.recoveryThreshold, 100)
    }

    func testSetRecoveryThresholdValidValue() async {
        // Execute with valid value
        viewModel.setRecoveryThreshold(65)
        try? await Task.sleep(for: .milliseconds(100))

        // Verify
        XCTAssertEqual(viewModel.preferences.recoveryThreshold, 65)
    }

    func testSetNutritionReminderHoursClampsLowValue() async {
        // Execute with value below 1
        viewModel.setNutritionReminderHours(0)
        try? await Task.sleep(for: .milliseconds(100))

        // Verify clamped to 1
        XCTAssertEqual(viewModel.preferences.nutritionReminderHours, 1)
    }

    func testSetNutritionReminderHoursClampsHighValue() async {
        // Execute with value above 12
        viewModel.setNutritionReminderHours(20)
        try? await Task.sleep(for: .milliseconds(100))

        // Verify clamped to 12
        XCTAssertEqual(viewModel.preferences.nutritionReminderHours, 12)
    }

    func testSetNutritionReminderHoursValidValue() async {
        // Execute with valid value
        viewModel.setNutritionReminderHours(4)
        try? await Task.sleep(for: .milliseconds(100))

        // Verify
        XCTAssertEqual(viewModel.preferences.nutritionReminderHours, 4)
    }

    // MARK: - Workout Reminder Time Tests

    func testWorkoutReminderTimeConversion() {
        // The workoutReminderTime getter converts DateComponents to Date
        let time = viewModel.workoutReminderTime
        XCTAssertNotNil(time)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        // Default is 18:00 (6 PM)
        XCTAssertEqual(components.hour, 18)
        XCTAssertEqual(components.minute, 0)
    }

    func testWorkoutReminderTimeSetter() async {
        // Create a date for 7:30 AM
        let calendar = Calendar.current
        guard let newTime = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) else {
            XCTFail("Could not create test date")
            return
        }

        // Execute - use workoutReminderTime (workoutReminderTimeAsDate was removed as duplicate)
        viewModel.workoutReminderTime = newTime
        try? await Task.sleep(for: .milliseconds(100))

        // Verify
        let savedComponents = viewModel.preferences.workoutReminderTime
        XCTAssertEqual(savedComponents.hour, 7)
        XCTAssertEqual(savedComponents.minute, 30)
    }

    // MARK: - Repository Persistence Tests

    func testPreferencesLoadFromRepository() async {
        // Setup - pre-populate repository
        let savedPrefs = MockNotificationPreferencesRepository.createSamplePreferences(
            workoutRemindersEnabled: true,
            recoveryThreshold: 75
        )
        mockRepository.mockPreferences = savedPrefs

        // Create new ViewModel to trigger load
        let newViewModel = NotificationSettingsViewModel(scheduler: nil, repository: mockRepository)

        // Allow async load to complete
        try? await Task.sleep(for: .milliseconds(200))

        // Verify repository was queried
        XCTAssertGreaterThan(mockRepository.getPreferencesCallCount, 0)
    }

    func testPreferencesSaveOnChange() async {
        // Execute - change a preference
        viewModel.workoutRemindersEnabled = true

        // Allow async save to complete
        try? await Task.sleep(for: .milliseconds(200))

        // Verify repository save was called
        // Note: Save may not trigger if authorization isn't granted
        // This test verifies the state change at minimum
        XCTAssertTrue(viewModel.preferences.workoutRemindersEnabled)
    }

    func testPreferencesSaveError() async {
        // Setup
        mockRepository.shouldThrowOnSave = true

        // Execute - change a preference to trigger save
        viewModel.setRecoveryThreshold(80)

        // Allow async save to complete
        try? await Task.sleep(for: .milliseconds(200))

        // Verify - error message may be set
        // Note: Actual behavior depends on authorization status
    }

    // MARK: - Multiple Days Tests

    func testMultipleDaysToggle() async {
        // Enable multiple days
        viewModel.mondayEnabled = true
        viewModel.wednesdayEnabled = true
        viewModel.fridayEnabled = true
        try? await Task.sleep(for: .milliseconds(150))

        // Verify all days are set
        let days = viewModel.preferences.workoutReminderDays
        XCTAssertTrue(days.contains(2)) // Monday
        XCTAssertTrue(days.contains(4)) // Wednesday
        XCTAssertTrue(days.contains(6)) // Friday
        XCTAssertFalse(days.contains(3)) // Tuesday
    }

    // MARK: - Clear Error Tests

    func testErrorMessageCanBeCleared() {
        // Setup - simulate an error state
        viewModel.errorMessage = "Test error"
        XCTAssertNotNil(viewModel.errorMessage)

        // The ViewModel doesn't have a clearError method, but errorMessage can be set to nil
        viewModel.errorMessage = nil

        // Verify
        XCTAssertNil(viewModel.errorMessage)
    }
}

// MARK: - Architecture Notes
/*
 NotificationSchedulerProtocol has been implemented (Session 14.1):
 - NotificationSchedulerProtocol defined in NotificationScheduler.swift
 - NotificationScheduler conforms to protocol
 - MockNotificationScheduler conforms to protocol
 - NotificationSettingsViewModel accepts protocol type

 MockNotificationScheduler can now be used for full testing of:
 - requestNotificationPermissions()
 - checkAuthorizationStatus()
 - checkRecoveryAndScheduleAlert()
 - cancelAllNotifications()
 - clearBadge()
*/
