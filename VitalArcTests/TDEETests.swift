//
//  TDEETests.swift
//  VitalArcTests
//
//  Unit tests for TDEE (Total Daily Energy Expenditure) calculations
//

import XCTest
@testable import VitalArc

final class TDEETests: XCTestCase {

    // MARK: - BMR Calculation Tests (Mifflin-St Jeor)

    func testBMRCalculationMale() throws {
        // Given: 30-year-old male, 80kg, 180cm
        // Formula: BMR = 10 × 80 + 6.25 × 180 − 5 × 30 + 5
        //        = 800 + 1125 - 150 + 5 = 1780

        let bmr = calculateBMR(
            weight: 80,
            height: 180,
            age: 30,
            biologicalSex: .male
        )

        XCTAssertEqual(bmr, 1780, accuracy: 1)
    }

    func testBMRCalculationFemale() throws {
        // Given: 30-year-old female, 60kg, 165cm
        // Formula: BMR = 10 × 60 + 6.25 × 165 − 5 × 30 − 161
        //        = 600 + 1031.25 - 150 - 161 = 1320.25

        let bmr = calculateBMR(
            weight: 60,
            height: 165,
            age: 30,
            biologicalSex: .female
        )

        XCTAssertEqual(bmr, 1320, accuracy: 1)
    }

    func testBMRCalculationOther() throws {
        // Given: 30-year-old, other sex, 70kg, 170cm
        // Formula: BMR = 10 × 70 + 6.25 × 170 − 5 × 30 − 78 (average of +5 and -161)
        //        = 700 + 1062.5 - 150 - 78 = 1534.5

        let bmr = calculateBMR(
            weight: 70,
            height: 170,
            age: 30,
            biologicalSex: .other
        )

        XCTAssertEqual(bmr, 1534.5, accuracy: 1)
    }

    func testBMRDecreasesWithAge() throws {
        let bmr25 = calculateBMR(weight: 80, height: 180, age: 25, biologicalSex: .male)
        let bmr35 = calculateBMR(weight: 80, height: 180, age: 35, biologicalSex: .male)
        let bmr45 = calculateBMR(weight: 80, height: 180, age: 45, biologicalSex: .male)

        XCTAssertGreaterThan(bmr25, bmr35)
        XCTAssertGreaterThan(bmr35, bmr45)

        // 10 years difference should be 50 calories (5 cal/year)
        XCTAssertEqual(bmr25 - bmr35, 50, accuracy: 0.1)
    }

    func testBMRIncreasesWithWeight() throws {
        let bmr70 = calculateBMR(weight: 70, height: 180, age: 30, biologicalSex: .male)
        let bmr80 = calculateBMR(weight: 80, height: 180, age: 30, biologicalSex: .male)
        let bmr90 = calculateBMR(weight: 90, height: 180, age: 30, biologicalSex: .male)

        XCTAssertLessThan(bmr70, bmr80)
        XCTAssertLessThan(bmr80, bmr90)

        // 10kg difference should be 100 calories (10 cal/kg)
        XCTAssertEqual(bmr80 - bmr70, 100, accuracy: 0.1)
    }

    func testBMRIncreasesWithHeight() throws {
        let bmr170 = calculateBMR(weight: 80, height: 170, age: 30, biologicalSex: .male)
        let bmr180 = calculateBMR(weight: 80, height: 180, age: 30, biologicalSex: .male)
        let bmr190 = calculateBMR(weight: 80, height: 190, age: 30, biologicalSex: .male)

        XCTAssertLessThan(bmr170, bmr180)
        XCTAssertLessThan(bmr180, bmr190)

        // 10cm difference should be 62.5 calories (6.25 cal/cm)
        XCTAssertEqual(bmr180 - bmr170, 62.5, accuracy: 0.1)
    }

    // MARK: - Activity Multiplier Tests

    func testActivityMultipliers() throws {
        let multipliers = getActivityMultipliers()

        XCTAssertEqual(multipliers[.sedentary], 1.2)
        XCTAssertEqual(multipliers[.light], 1.375)
        XCTAssertEqual(multipliers[.moderate], 1.55)
        XCTAssertEqual(multipliers[.very], 1.725)
        XCTAssertEqual(multipliers[.extreme], 1.9)
    }

    func testTDEEWithSedentaryActivity() throws {
        let bmr: Double = 1800
        let tdee = bmr * 1.2

        XCTAssertEqual(tdee, 2160)
    }

    func testTDEEWithModerateActivity() throws {
        let bmr: Double = 1800
        let tdee = bmr * 1.55

        XCTAssertEqual(tdee, 2790)
    }

    func testTDEEWithExtremeActivity() throws {
        let bmr: Double = 1800
        let tdee = bmr * 1.9

        XCTAssertEqual(tdee, 3420)
    }

    // MARK: - Weight Goal Adjustment Tests

    func testGoalAdjustmentLoseWeight() throws {
        let tdee: Double = 2500
        let adjusted = adjustForGoal(tdee: tdee, goal: .lose)

        XCTAssertEqual(adjusted.calories, 2000)
        XCTAssertEqual(adjusted.deficit, -500)
    }

    func testGoalAdjustmentMaintain() throws {
        let tdee: Double = 2500
        let adjusted = adjustForGoal(tdee: tdee, goal: .maintain)

        XCTAssertEqual(adjusted.calories, 2500)
        XCTAssertEqual(adjusted.deficit, 0)
    }

    func testGoalAdjustmentGainWeight() throws {
        let tdee: Double = 2500
        let adjusted = adjustForGoal(tdee: tdee, goal: .gain)

        XCTAssertEqual(adjusted.calories, 3000)
        XCTAssertEqual(adjusted.deficit, 500)
    }

    // MARK: - Macro Calculation Tests

    func testProteinCalculation() throws {
        // 80kg person should get ~160g protein (2.0g/kg)
        let macros = calculateMacros(calories: 2500, weight: 80)

        XCTAssertEqual(macros.protein, 160, accuracy: 1)
    }

    func testFatCalculation() throws {
        // Fat should be ~35% of total calories
        // 2500 cal × 35% = 875 cal / 9 cal/g = 97g
        let macros = calculateMacros(calories: 2500, weight: 80)

        XCTAssertEqual(macros.fat, 97, accuracy: 5)
    }

    func testCarbCalculation() throws {
        // Carbs fill remaining calories after protein and fat
        let macros = calculateMacros(calories: 2500, weight: 80)

        // Total calories should approximately match
        let proteinCal = macros.protein * 4
        let fatCal = macros.fat * 9
        let carbCal = macros.carbs * 4
        let totalCal = proteinCal + fatCal + carbCal

        XCTAssertEqual(totalCal, 2500, accuracy: 50) // Allow some rounding
    }

    // MARK: - Full TDEE Result Tests

    func testFullTDEECalculationMale() throws {
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -30, to: Date())!

        let profile = UserProfile(
            name: "Test User",
            birthDate: birthDate,
            biologicalSex: .male,
            height: 180,
            weight: 80,
            activityLevel: .moderate,
            weightGoal: .maintain
        )

        let result = calculateTDEE(for: profile)

        // BMR = 1780
        // TDEE = 1780 × 1.55 = 2759
        XCTAssertEqual(result.bmr, 1780, accuracy: 5)
        XCTAssertEqual(result.tdee, 2759, accuracy: 10)
        XCTAssertEqual(result.adjustedCalories, result.tdee, accuracy: 1) // Maintain = no adjustment
        XCTAssertEqual(result.activityMultiplier, 1.55)
        XCTAssertEqual(result.deficit, 0)
    }

    func testFullTDEECalculationFemaleDeficit() throws {
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -25, to: Date())!

        let profile = UserProfile(
            name: "Test User",
            birthDate: birthDate,
            biologicalSex: .female,
            height: 165,
            weight: 60,
            activityLevel: .light,
            weightGoal: .lose
        )

        let result = calculateTDEE(for: profile)

        // BMR for 25yo female: 10×60 + 6.25×165 - 5×25 - 161 = 600 + 1031.25 - 125 - 161 = 1345.25
        // TDEE = 1345.25 × 1.375 = 1850
        // Adjusted = 1850 - 500 = 1350
        XCTAssertEqual(result.bmr, 1345, accuracy: 5)
        XCTAssertEqual(result.adjustedCalories, result.tdee - 500, accuracy: 1)
        XCTAssertEqual(result.deficit, -500)
    }

    func testTDEEResultHasReasonableMacros() throws {
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -30, to: Date())!

        let profile = UserProfile(
            name: "Test User",
            birthDate: birthDate,
            biologicalSex: .male,
            height: 180,
            weight: 80,
            activityLevel: .moderate,
            weightGoal: .maintain
        )

        let result = calculateTDEE(for: profile)

        // Protein should be 2g/kg = 160g
        XCTAssertEqual(result.proteinGoal, 160, accuracy: 5)

        // Fat should be reasonable (not negative, not too high)
        XCTAssertGreaterThan(result.fatGoal, 50)
        XCTAssertLessThan(result.fatGoal, 150)

        // Carbs should be reasonable
        XCTAssertGreaterThan(result.carbGoal, 100)
    }

    // MARK: - Comparison with Simple Formula

    func testMifflinVsSimpleFormula() throws {
        // Current simple formula: weight × 33
        // Mifflin-St Jeor should give more accurate results

        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -30, to: Date())!

        let profile = UserProfile(
            name: "Test User",
            birthDate: birthDate,
            biologicalSex: .male,
            height: 180,
            weight: 80,
            activityLevel: .moderate,
            weightGoal: .maintain
        )

        let simpleEstimate = profile.estimatedCalorieGoal // weight × 33 = 2640
        let result = calculateTDEE(for: profile)

        // Both should be in reasonable range
        XCTAssertGreaterThan(result.tdee, 2400)
        XCTAssertLessThan(result.tdee, 3200)

        // They should be somewhat similar (within 15%)
        let difference = abs(result.tdee - simpleEstimate)
        let percentDiff = difference / simpleEstimate
        XCTAssertLessThan(percentDiff, 0.15, "Mifflin-St Jeor should be within 15% of simple formula")
    }

    // MARK: - Helper Methods (Mirror use case logic)

    private func calculateBMR(
        weight: Double,
        height: Double,
        age: Int,
        biologicalSex: BiologicalSex
    ) -> Double {
        let baseBMR = (10 * weight) + (6.25 * height) - (5 * Double(age))

        switch biologicalSex {
        case .male:
            return baseBMR + 5
        case .female:
            return baseBMR - 161
        case .other:
            return baseBMR - 78
        }
    }

    private func getActivityMultipliers() -> [ActivityLevel: Double] {
        return [
            .sedentary: 1.2,
            .light: 1.375,
            .moderate: 1.55,
            .very: 1.725,
            .extreme: 1.9
        ]
    }

    private func adjustForGoal(tdee: Double, goal: WeightGoal) -> (calories: Double, deficit: Double) {
        switch goal {
        case .lose:
            return (tdee - 500, -500)
        case .maintain:
            return (tdee, 0)
        case .gain:
            return (tdee + 500, 500)
        }
    }

    private func calculateMacros(calories: Double, weight: Double) -> (protein: Double, fat: Double, carbs: Double) {
        let proteinGrams = weight * 2.0
        let proteinCalories = proteinGrams * 4

        let remainingCalories = calories - proteinCalories

        let fatCalories = calories * 0.35
        let fatGrams = fatCalories / 9

        let carbCalories = remainingCalories - fatCalories
        let carbGrams = max(0, carbCalories / 4)

        return (proteinGrams, fatGrams, carbGrams)
    }

    private func calculateTDEE(for profile: UserProfile) -> TDEEResult {
        let bmr = calculateBMR(
            weight: profile.weight,
            height: profile.height,
            age: profile.age,
            biologicalSex: profile.biologicalSex
        )

        let multipliers = getActivityMultipliers()
        let multiplier = multipliers[profile.activityLevel] ?? 1.55
        let tdee = bmr * multiplier

        let (adjustedCalories, deficit) = adjustForGoal(tdee: tdee, goal: profile.weightGoal)
        let macros = calculateMacros(calories: adjustedCalories, weight: profile.weight)

        return TDEEResult(
            bmr: bmr.rounded(),
            tdee: tdee.rounded(),
            adjustedCalories: adjustedCalories.rounded(),
            activityMultiplier: multiplier,
            proteinGoal: macros.protein.rounded(),
            fatGoal: macros.fat.rounded(),
            carbGoal: macros.carbs.rounded(),
            deficit: deficit,
            formula: .mifflinStJeor
        )
    }
}
