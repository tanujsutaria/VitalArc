//
//  VitalArcTests.swift
//  VitalArcTests
//
//  Created by Claude on 2026-01-25.
//

import XCTest
@testable import VitalArc

final class VitalArcTests: XCTestCase {

    override func setUpWithError() throws {
        // Setup code before each test
    }

    override func tearDownWithError() throws {
        // Cleanup code after each test
    }

    func testExerciseCreation() throws {
        let exercise = Exercise(
            name: "Bench Press",
            category: .push,
            primaryMuscles: [.chest, .triceps],
            secondaryMuscles: [.shoulders],
            equipment: .barbell
        )

        XCTAssertEqual(exercise.name, "Bench Press")
        XCTAssertEqual(exercise.category, .push)
        XCTAssertEqual(exercise.primaryMuscles.count, 2)
        XCTAssertEqual(exercise.equipment, .barbell)
    }

    func testWorkoutVolumeCalculation() throws {
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1),
            WorkoutSet(exerciseId: exerciseId, weight: 110, reps: 8, setNumber: 2),
            WorkoutSet(exerciseId: exerciseId, weight: 120, reps: 6, setNumber: 3)
        ]

        let workout = Workout(sets: sets)

        // Volume = (100*10) + (110*8) + (120*6) = 1000 + 880 + 720 = 2600
        XCTAssertEqual(workout.totalVolume, 2600)
        XCTAssertEqual(workout.totalSets, 3)
    }

    func testFoodScaling() throws {
        let food = Food(
            name: "Chicken Breast",
            servingSize: 100,
            servingUnit: "g",
            calories: 165,
            protein: 31,
            carbs: 0,
            fat: 3.6
        )

        let scaled = food.scaled(to: 200)

        XCTAssertEqual(scaled.servingSize, 200)
        XCTAssertEqual(scaled.calories, 330, accuracy: 0.1)
        XCTAssertEqual(scaled.protein, 62, accuracy: 0.1)
        XCTAssertEqual(scaled.fat, 7.2, accuracy: 0.1)
    }

    func testUserProfileBMI() throws {
        // Use a deterministic date calculation
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -30, to: Date())!

        let profile = UserProfile(
            name: "Test User",
            birthDate: birthDate,
            biologicalSex: .male,
            height: 180, // cm
            weight: 80, // kg
            activityLevel: .moderate
        )

        // BMI = weight / (height in m)^2 = 80 / 1.8^2 = 24.69
        XCTAssertEqual(profile.bmi, 24.69, accuracy: 0.1)
        XCTAssertEqual(profile.age, 30)
    }

    func testHealthMetricsRecoveryIndicator() throws {
        let goodRecovery = HealthMetrics(
            date: Date(),
            heartRateVariability: 75
        )

        let poorRecovery = HealthMetrics(
            date: Date(),
            heartRateVariability: 15
        )

        XCTAssertEqual(goodRecovery.recoveryIndicator, .good)
        XCTAssertEqual(poorRecovery.recoveryIndicator, .poor)
    }
}
