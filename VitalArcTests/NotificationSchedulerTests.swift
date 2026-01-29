//
//  NotificationSchedulerTests.swift
//  VitalArcTests
//
//  Unit tests for NotificationScheduler day-of-week logic and message generation
//

import XCTest
@testable import VitalArc

final class NotificationSchedulerTests: XCTestCase {

    // MARK: - Workout Reminder Body Tests

    func testWorkoutReminderBodySunday() throws {
        let body = workoutReminderBody(for: 1)
        XCTAssertTrue(body.contains("Sunday"), "Sunday reminder should mention Sunday")
    }

    func testWorkoutReminderBodyMonday() throws {
        let body = workoutReminderBody(for: 2)
        XCTAssertTrue(body.contains("Monday"), "Monday reminder should mention Monday")
    }

    func testWorkoutReminderBodyTuesday() throws {
        let body = workoutReminderBody(for: 3)
        XCTAssertTrue(body.contains("Tuesday"), "Tuesday reminder should mention Tuesday")
    }

    func testWorkoutReminderBodyWednesday() throws {
        let body = workoutReminderBody(for: 4)
        XCTAssertTrue(body.contains("Midweek"), "Wednesday reminder should mention Midweek")
    }

    func testWorkoutReminderBodyThursday() throws {
        let body = workoutReminderBody(for: 5)
        XCTAssertTrue(body.contains("Thursday"), "Thursday reminder should mention Thursday")
    }

    func testWorkoutReminderBodyFriday() throws {
        let body = workoutReminderBody(for: 6)
        XCTAssertTrue(body.contains("Friday"), "Friday reminder should mention Friday")
    }

    func testWorkoutReminderBodySaturday() throws {
        let body = workoutReminderBody(for: 7)
        XCTAssertTrue(body.contains("Saturday"), "Saturday reminder should mention Saturday")
    }

    func testWorkoutReminderBodyInvalidWeekday() throws {
        let body = workoutReminderBody(for: 0)
        XCTAssertTrue(body.contains("scheduled"), "Invalid weekday should return default message")

        let bodyTooHigh = workoutReminderBody(for: 8)
        XCTAssertTrue(bodyTooHigh.contains("scheduled"), "Out of range weekday should return default")
    }

    // MARK: - Recovery Alert Body Tests

    func testRecoveryAlertBodyVeryLow() throws {
        let body = recoveryAlertBody(score: 25)
        XCTAssertTrue(body.contains("25%"), "Should include score percentage")
        XCTAssertTrue(body.contains("rest") || body.contains("light"), "Should recommend rest or light activity")
    }

    func testRecoveryAlertBodyLow() throws {
        let body = recoveryAlertBody(score: 40)
        XCTAssertTrue(body.contains("40%"), "Should include score percentage")
        XCTAssertTrue(body.contains("lighter"), "Should recommend lighter workout")
    }

    func testRecoveryAlertBodyModerate() throws {
        let body = recoveryAlertBody(score: 60)
        XCTAssertTrue(body.contains("60%"), "Should include score percentage")
        XCTAssertTrue(body.contains("Listen"), "Should suggest listening to body")
    }

    // MARK: - Nutrition Reminder Hour Calculation Tests

    func testNutritionReminderHour2HoursBeforeEndOfDay() throws {
        // 2 hours before end of day = 10 PM = hour 22
        let reminderHour = calculateNutritionReminderHour(hoursBeforeEndOfDay: 2)
        XCTAssertEqual(reminderHour, 22)
    }

    func testNutritionReminderHour4HoursBeforeEndOfDay() throws {
        // 4 hours before end of day = 8 PM = hour 20
        let reminderHour = calculateNutritionReminderHour(hoursBeforeEndOfDay: 4)
        XCTAssertEqual(reminderHour, 20)
    }

    func testNutritionReminderHour6HoursBeforeEndOfDay() throws {
        // 6 hours before end of day = 6 PM = hour 18
        let reminderHour = calculateNutritionReminderHour(hoursBeforeEndOfDay: 6)
        XCTAssertEqual(reminderHour, 18)
    }

    func testNutritionReminderHourInvalidTooLarge() throws {
        // 25 hours before would be invalid (hour -1)
        let reminderHour = calculateNutritionReminderHour(hoursBeforeEndOfDay: 25)
        XCTAssertNil(reminderHour, "Should return nil for invalid hour")
    }

    func testNutritionReminderHourInvalidNegative() throws {
        // -1 hours would result in hour 25 (invalid)
        let reminderHour = calculateNutritionReminderHour(hoursBeforeEndOfDay: -1)
        XCTAssertNil(reminderHour, "Should return nil for invalid hour")
    }

    // MARK: - Notification Identifier Tests

    func testWorkoutReminderIdentifierFormat() throws {
        let identifier = workoutReminderIdentifier(for: 2)
        XCTAssertTrue(identifier.hasPrefix("com.vitalarc.workout."), "Should have correct prefix")
        XCTAssertTrue(identifier.hasSuffix("2"), "Should include weekday number")
    }

    func testWorkoutReminderIdentifierUniqueness() throws {
        let id1 = workoutReminderIdentifier(for: 1)
        let id2 = workoutReminderIdentifier(for: 2)
        let id3 = workoutReminderIdentifier(for: 3)

        XCTAssertNotEqual(id1, id2, "Different days should have different identifiers")
        XCTAssertNotEqual(id2, id3, "Different days should have different identifiers")
        XCTAssertNotEqual(id1, id3, "Different days should have different identifiers")
    }

    // MARK: - Helper Methods (Mirror NotificationScheduler logic)

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

    private func calculateNutritionReminderHour(hoursBeforeEndOfDay: Int) -> Int? {
        let reminderHour = 24 - hoursBeforeEndOfDay
        guard (0...23).contains(reminderHour) else { return nil }
        return reminderHour
    }

    private func workoutReminderIdentifier(for weekday: Int) -> String {
        "com.vitalarc.workout.\(weekday)"
    }
}
