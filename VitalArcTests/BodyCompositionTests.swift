//
//  BodyCompositionTests.swift
//  VitalArcTests
//
//  Tests for Body Composition tracking and Configurable Meal Times
//

import XCTest
@testable import VitalArc

final class BodyCompositionTests: XCTestCase {

    // MARK: - BodyCompositionEntry Entity Tests

    func testBodyCompositionEntryCreation() {
        let measurement = BodyCompositionEntry(
            weight: 80.0,
            bodyFatPercentage: 15.0,
            waistCircumference: 85.0,
            hipCircumference: 100.0
        )

        XCTAssertEqual(measurement.weight, 80.0)
        XCTAssertEqual(measurement.bodyFatPercentage, 15.0)
        XCTAssertEqual(measurement.waistCircumference, 85.0)
        XCTAssertEqual(measurement.hipCircumference, 100.0)
        XCTAssertNotNil(measurement.id)
    }

    func testBodyCompositionEntryDefaultValues() {
        let measurement = BodyCompositionEntry()

        XCTAssertNil(measurement.weight)
        XCTAssertNil(measurement.bodyFatPercentage)
        XCTAssertNil(measurement.waistCircumference)
        XCTAssertNil(measurement.hipCircumference)
        XCTAssertNil(measurement.chestCircumference)
        XCTAssertNil(measurement.armCircumference)
        XCTAssertNil(measurement.thighCircumference)
        XCTAssertNil(measurement.neckCircumference)
        XCTAssertNil(measurement.notes)
    }

    func testBodyCompositionEntryEquality() {
        let id = UUID()
        let date = Date()
        let m1 = BodyCompositionEntry(id: id, date: date, weight: 75.0)
        let m2 = BodyCompositionEntry(id: id, date: date, weight: 75.0)

        XCTAssertEqual(m1, m2)
    }

    func testBodyCompositionEntryAllFields() {
        let measurement = BodyCompositionEntry(
            weight: 85.0,
            bodyFatPercentage: 18.0,
            waistCircumference: 90.0,
            hipCircumference: 105.0,
            chestCircumference: 100.0,
            armCircumference: 35.0,
            thighCircumference: 55.0,
            neckCircumference: 38.0,
            notes: "Morning measurement"
        )

        XCTAssertEqual(measurement.chestCircumference, 100.0)
        XCTAssertEqual(measurement.armCircumference, 35.0)
        XCTAssertEqual(measurement.thighCircumference, 55.0)
        XCTAssertEqual(measurement.neckCircumference, 38.0)
        XCTAssertEqual(measurement.notes, "Morning measurement")
    }

    // MARK: - Waist-to-Hip Ratio Tests

    func testWaistToHipRatioCalculation() {
        let measurement = BodyCompositionEntry(
            waistCircumference: 80.0,
            hipCircumference: 100.0
        )

        let whr = measurement.waistToHipRatio
        XCTAssertNotNil(whr)
        XCTAssertEqual(whr!, 0.80, accuracy: 0.001)
    }

    func testWaistToHipRatioHighRisk() {
        // WHR > 0.90 for men is considered high risk
        let measurement = BodyCompositionEntry(
            waistCircumference: 100.0,
            hipCircumference: 100.0
        )

        XCTAssertEqual(measurement.waistToHipRatio!, 1.0, accuracy: 0.001)
    }

    func testWaistToHipRatioMissingWaist() {
        let measurement = BodyCompositionEntry(hipCircumference: 100.0)
        XCTAssertNil(measurement.waistToHipRatio)
    }

    func testWaistToHipRatioMissingHip() {
        let measurement = BodyCompositionEntry(waistCircumference: 80.0)
        XCTAssertNil(measurement.waistToHipRatio)
    }

    func testWaistToHipRatioZeroHip() {
        let measurement = BodyCompositionEntry(
            waistCircumference: 80.0,
            hipCircumference: 0.0
        )
        XCTAssertNil(measurement.waistToHipRatio)
    }

    // MARK: - Body Composition Calculated Values

    func testLeanBodyMass() {
        let measurement = BodyCompositionEntry(
            weight: 80.0,
            bodyFatPercentage: 20.0
        )

        XCTAssertEqual(measurement.leanBodyMass!, 64.0, accuracy: 0.01)
    }

    func testFatMass() {
        let measurement = BodyCompositionEntry(
            weight: 80.0,
            bodyFatPercentage: 20.0
        )

        XCTAssertEqual(measurement.fatMass!, 16.0, accuracy: 0.01)
    }

    func testLeanBodyMassWithZeroFat() {
        let measurement = BodyCompositionEntry(
            weight: 70.0,
            bodyFatPercentage: 0.0
        )

        XCTAssertEqual(measurement.leanBodyMass!, 70.0, accuracy: 0.01)
        XCTAssertEqual(measurement.fatMass!, 0.0, accuracy: 0.01)
    }

    func testLeanBodyMassMissingWeight() {
        let measurement = BodyCompositionEntry(bodyFatPercentage: 20.0)
        XCTAssertNil(measurement.leanBodyMass)
        XCTAssertNil(measurement.fatMass)
    }

    func testLeanBodyMassMissingBodyFat() {
        let measurement = BodyCompositionEntry(weight: 80.0)
        XCTAssertNil(measurement.leanBodyMass)
        XCTAssertNil(measurement.fatMass)
    }

    // MARK: - Unit Conversion for Measurements

    func testCmToInchesConversion() {
        // 2.54 cm = 1 inch
        let cm = 85.0
        let inches = cm / 2.54
        XCTAssertEqual(inches, 33.46, accuracy: 0.01)
    }

    func testInchesToCmConversion() {
        let inches = 33.46
        let cm = inches * 2.54
        XCTAssertEqual(cm, 85.0, accuracy: 0.1)
    }

    func testKgToLbsConversion() {
        let kg = 80.0
        let lbs = UnitConversion.kgToLbs(kg)
        XCTAssertEqual(lbs, 176.37, accuracy: 0.1)
    }

    func testLbsToKgConversion() {
        let lbs = 176.37
        let kg = UnitConversion.lbsToKg(lbs)
        XCTAssertEqual(kg, 80.0, accuracy: 0.1)
    }

    func testRoundTripWeightConversion() {
        let originalKg = 75.5
        let lbs = UnitConversion.kgToLbs(originalKg)
        let backToKg = UnitConversion.lbsToKg(lbs)
        XCTAssertEqual(backToKg, originalKg, accuracy: 0.01)
    }

    // MARK: - BodyCompositionEntryModel Conversion Tests

    func testModelToDomainConversion() {
        let model = BodyCompositionEntryModel(
            weight: 80.0,
            bodyFatPercentage: 15.0,
            waistCircumference: 85.0,
            hipCircumference: 100.0,
            notes: "Test"
        )

        let domain = model.toDomain()

        XCTAssertEqual(domain.id, model.id)
        XCTAssertEqual(domain.weight, 80.0)
        XCTAssertEqual(domain.bodyFatPercentage, 15.0)
        XCTAssertEqual(domain.waistCircumference, 85.0)
        XCTAssertEqual(domain.hipCircumference, 100.0)
        XCTAssertEqual(domain.notes, "Test")
    }

    func testDomainToModelConversion() {
        let domain = BodyCompositionEntry(
            weight: 75.0,
            bodyFatPercentage: 12.0,
            waistCircumference: 80.0,
            hipCircumference: 95.0,
            chestCircumference: 100.0
        )

        let model = BodyCompositionEntryModel.fromDomain(domain)

        XCTAssertEqual(model.id, domain.id)
        XCTAssertEqual(model.weight, 75.0)
        XCTAssertEqual(model.bodyFatPercentage, 12.0)
        XCTAssertEqual(model.waistCircumference, 80.0)
        XCTAssertEqual(model.hipCircumference, 95.0)
        XCTAssertEqual(model.chestCircumference, 100.0)
    }

    func testRoundTripConversion() {
        let original = BodyCompositionEntry(
            weight: 80.0,
            bodyFatPercentage: 15.0,
            waistCircumference: 85.0,
            hipCircumference: 100.0,
            chestCircumference: 100.0,
            armCircumference: 35.0,
            thighCircumference: 55.0,
            neckCircumference: 38.0,
            notes: "Round trip"
        )

        let model = BodyCompositionEntryModel.fromDomain(original)
        let converted = model.toDomain()

        XCTAssertEqual(converted.id, original.id)
        XCTAssertEqual(converted.weight, original.weight)
        XCTAssertEqual(converted.bodyFatPercentage, original.bodyFatPercentage)
        XCTAssertEqual(converted.waistCircumference, original.waistCircumference)
        XCTAssertEqual(converted.hipCircumference, original.hipCircumference)
        XCTAssertEqual(converted.chestCircumference, original.chestCircumference)
        XCTAssertEqual(converted.armCircumference, original.armCircumference)
        XCTAssertEqual(converted.thighCircumference, original.thighCircumference)
        XCTAssertEqual(converted.neckCircumference, original.neckCircumference)
        XCTAssertEqual(converted.notes, original.notes)
    }

    // MARK: - Measurement Trend Calculations

    func testWeightTrendDecreasing() {
        let measurements = [
            BodyCompositionEntry(date: Date().addingTimeInterval(-86400 * 14), weight: 82.0),
            BodyCompositionEntry(date: Date().addingTimeInterval(-86400 * 7), weight: 81.0),
            BodyCompositionEntry(date: Date(), weight: 80.0)
        ]

        let weights = measurements.compactMap { $0.weight }
        let change = (weights.last ?? 0) - (weights.first ?? 0)

        XCTAssertEqual(change, -2.0, accuracy: 0.01)
    }

    func testWeightTrendIncreasing() {
        let measurements = [
            BodyCompositionEntry(date: Date().addingTimeInterval(-86400 * 14), weight: 70.0),
            BodyCompositionEntry(date: Date().addingTimeInterval(-86400 * 7), weight: 71.5),
            BodyCompositionEntry(date: Date(), weight: 73.0)
        ]

        let weights = measurements.compactMap { $0.weight }
        let change = (weights.last ?? 0) - (weights.first ?? 0)

        XCTAssertEqual(change, 3.0, accuracy: 0.01)
    }

    func testBodyFatTrend() {
        let measurements = [
            BodyCompositionEntry(date: Date().addingTimeInterval(-86400 * 30), bodyFatPercentage: 20.0),
            BodyCompositionEntry(date: Date().addingTimeInterval(-86400 * 15), bodyFatPercentage: 18.5),
            BodyCompositionEntry(date: Date(), bodyFatPercentage: 17.0)
        ]

        let bodyFats = measurements.compactMap { $0.bodyFatPercentage }
        let change = (bodyFats.last ?? 0) - (bodyFats.first ?? 0)

        XCTAssertEqual(change, -3.0, accuracy: 0.01)
    }

    func testWaistToHipRatioTrend() {
        let measurements = [
            BodyCompositionEntry(waistCircumference: 90.0, hipCircumference: 100.0),
            BodyCompositionEntry(waistCircumference: 87.0, hipCircumference: 100.0),
            BodyCompositionEntry(waistCircumference: 85.0, hipCircumference: 100.0)
        ]

        let ratios = measurements.compactMap { $0.waistToHipRatio }
        XCTAssertEqual(ratios.count, 3)
        XCTAssertEqual(ratios[0], 0.90, accuracy: 0.001)
        XCTAssertEqual(ratios[1], 0.87, accuracy: 0.001)
        XCTAssertEqual(ratios[2], 0.85, accuracy: 0.001)
    }

    // MARK: - MealTimeConfiguration Tests

    func testMealTimeConfigurationDefaults() {
        let config = MealTimeConfiguration()

        XCTAssertEqual(config.breakfastStart, 5)
        XCTAssertEqual(config.lunchStart, 11)
        XCTAssertEqual(config.dinnerStart, 17)
        XCTAssertEqual(config.snackStart, 21)
    }

    func testMealTimeConfigurationCustomValues() {
        let config = MealTimeConfiguration(
            breakfastStart: 6,
            lunchStart: 12,
            dinnerStart: 18,
            snackStart: 22
        )

        XCTAssertEqual(config.breakfastStart, 6)
        XCTAssertEqual(config.lunchStart, 12)
        XCTAssertEqual(config.dinnerStart, 18)
        XCTAssertEqual(config.snackStart, 22)
    }

    func testMealTimeConfigurationEquality() {
        let c1 = MealTimeConfiguration(breakfastStart: 6, lunchStart: 12, dinnerStart: 18, snackStart: 22)
        let c2 = MealTimeConfiguration(breakfastStart: 6, lunchStart: 12, dinnerStart: 18, snackStart: 22)

        XCTAssertEqual(c1, c2)
    }

    func testMealTimeConfigurationInequality() {
        let c1 = MealTimeConfiguration()
        let c2 = MealTimeConfiguration(breakfastStart: 7)

        XCTAssertNotEqual(c1, c2)
    }

    func testMealTimeConfigurationCodable() throws {
        let original = MealTimeConfiguration(
            breakfastStart: 7,
            lunchStart: 12,
            dinnerStart: 18,
            snackStart: 22
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MealTimeConfiguration.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func testMealTimeConfigurationTimeRange() {
        let config = MealTimeConfiguration()

        let breakfastRange = config.timeRange(for: .breakfast)
        XCTAssertTrue(breakfastRange.contains("5 AM"))
        XCTAssertTrue(breakfastRange.contains("11 AM"))

        let lunchRange = config.timeRange(for: .lunch)
        XCTAssertTrue(lunchRange.contains("11 AM"))
        XCTAssertTrue(lunchRange.contains("5 PM"))

        let dinnerRange = config.timeRange(for: .dinner)
        XCTAssertTrue(dinnerRange.contains("5 PM"))
        XCTAssertTrue(dinnerRange.contains("9 PM"))

        let snackRange = config.timeRange(for: .snack)
        XCTAssertTrue(snackRange.contains("9 PM"))
        XCTAssertTrue(snackRange.contains("5 AM"))
    }

    func testMealTimeConfigurationSaveAndLoad() {
        // Save custom config
        let custom = MealTimeConfiguration(
            breakfastStart: 7,
            lunchStart: 12,
            dinnerStart: 18,
            snackStart: 22
        )
        custom.save()

        // Load and verify
        let loaded = MealTimeConfiguration.load()
        XCTAssertEqual(loaded, custom)

        // Cleanup: restore defaults
        let defaults = MealTimeConfiguration()
        defaults.save()
    }

    // MARK: - MealType.forCurrentTime with Configuration Tests

    func testMealTypeForHourBreakfast() {
        let config = MealTimeConfiguration()

        XCTAssertEqual(MealType.forHour(5, config: config), .breakfast)
        XCTAssertEqual(MealType.forHour(8, config: config), .breakfast)
        XCTAssertEqual(MealType.forHour(10, config: config), .breakfast)
    }

    func testMealTypeForHourLunch() {
        let config = MealTimeConfiguration()

        XCTAssertEqual(MealType.forHour(11, config: config), .lunch)
        XCTAssertEqual(MealType.forHour(13, config: config), .lunch)
        XCTAssertEqual(MealType.forHour(16, config: config), .lunch)
    }

    func testMealTypeForHourDinner() {
        let config = MealTimeConfiguration()

        XCTAssertEqual(MealType.forHour(17, config: config), .dinner)
        XCTAssertEqual(MealType.forHour(19, config: config), .dinner)
        XCTAssertEqual(MealType.forHour(20, config: config), .dinner)
    }

    func testMealTypeForHourSnack() {
        let config = MealTimeConfiguration()

        XCTAssertEqual(MealType.forHour(21, config: config), .snack)
        XCTAssertEqual(MealType.forHour(23, config: config), .snack)
        XCTAssertEqual(MealType.forHour(0, config: config), .snack)
        XCTAssertEqual(MealType.forHour(3, config: config), .snack)
    }

    func testMealTypeForHourCustomConfig() {
        let config = MealTimeConfiguration(
            breakfastStart: 7,
            lunchStart: 12,
            dinnerStart: 18,
            snackStart: 22
        )

        // 6 AM should be snack with custom config (before 7 AM breakfast)
        XCTAssertEqual(MealType.forHour(6, config: config), .snack)

        // 7 AM should be breakfast with custom config
        XCTAssertEqual(MealType.forHour(7, config: config), .breakfast)

        // 11 AM should be breakfast with custom config (lunch starts at 12)
        XCTAssertEqual(MealType.forHour(11, config: config), .breakfast)

        // 12 PM should be lunch with custom config
        XCTAssertEqual(MealType.forHour(12, config: config), .lunch)

        // 17 PM should be lunch with custom config (dinner starts at 18)
        XCTAssertEqual(MealType.forHour(17, config: config), .lunch)

        // 18 PM should be dinner with custom config
        XCTAssertEqual(MealType.forHour(18, config: config), .dinner)

        // 21 PM should be dinner with custom config (snack starts at 22)
        XCTAssertEqual(MealType.forHour(21, config: config), .dinner)

        // 22 PM should be snack with custom config
        XCTAssertEqual(MealType.forHour(22, config: config), .snack)
    }

    func testMealTypeForHourBoundaries() {
        let config = MealTimeConfiguration()

        // Exact boundary hours
        XCTAssertEqual(MealType.forHour(5, config: config), .breakfast)   // breakfast start
        XCTAssertEqual(MealType.forHour(11, config: config), .lunch)      // lunch start
        XCTAssertEqual(MealType.forHour(17, config: config), .dinner)     // dinner start
        XCTAssertEqual(MealType.forHour(21, config: config), .snack)      // snack start
    }

    func testMealTypeForCurrentTimeWithConfig() {
        let config = MealTimeConfiguration(
            breakfastStart: 6,
            lunchStart: 12,
            dinnerStart: 18,
            snackStart: 22
        )

        // This tests the config-based overload compiles and returns a valid meal
        let meal = MealType.forCurrentTime(config: config)
        XCTAssertTrue(MealType.allCases.contains(meal))
    }

    func testMealTypeForHourDefaultConfig() {
        // Test that the default parameter works
        let meal = MealType.forHour(14)
        XCTAssertEqual(meal, .lunch)
    }

    // MARK: - MockBodyCompositionEntryRepository Tests

    func testMockRepositorySave() async throws {
        let repo = MockBodyCompositionEntryRepository()
        let measurement = BodyCompositionEntry(weight: 80.0, bodyFatPercentage: 15.0)

        try await repo.saveMeasurement(measurement)

        XCTAssertEqual(repo.savedMeasurements.count, 1)
        XCTAssertEqual(repo.savedMeasurements.first?.weight, 80.0)
    }

    func testMockRepositoryGetMeasurements() async throws {
        let repo = MockBodyCompositionEntryRepository()
        let now = Date()

        repo.mockMeasurements = [
            BodyCompositionEntry(date: now, weight: 80.0),
            BodyCompositionEntry(date: now.addingTimeInterval(-86400), weight: 81.0)
        ]

        let results = try await repo.getMeasurements(
            from: now.addingTimeInterval(-172800),
            to: now
        )

        XCTAssertEqual(results.count, 2)
    }

    func testMockRepositoryGetLatest() async throws {
        let repo = MockBodyCompositionEntryRepository()
        repo.mockMeasurements = [
            BodyCompositionEntry(date: Date().addingTimeInterval(-86400), weight: 81.0),
            BodyCompositionEntry(date: Date(), weight: 80.0)
        ]

        let latest = try await repo.getLatestMeasurement()

        XCTAssertNotNil(latest)
        XCTAssertEqual(latest?.weight, 80.0)
    }

    func testMockRepositoryDelete() async throws {
        let repo = MockBodyCompositionEntryRepository()
        let id = UUID()
        repo.mockMeasurements = [BodyCompositionEntry(id: id, weight: 80.0)]

        try await repo.deleteMeasurement(id)

        XCTAssertEqual(repo.deletedIds.count, 1)
        XCTAssertEqual(repo.deletedIds.first, id)
    }
}

// MARK: - Mock Body Measurement Repository

final class MockBodyCompositionEntryRepository: BodyCompositionEntryRepository {
    var mockMeasurements: [BodyCompositionEntry] = []
    var savedMeasurements: [BodyCompositionEntry] = []
    var deletedIds: [UUID] = []
    var shouldThrowOnSave = false
    var shouldThrowOnGet = false
    var shouldThrowOnDelete = false

    func saveMeasurement(_ measurement: BodyCompositionEntry) async throws {
        if shouldThrowOnSave { throw NSError(domain: "Test", code: 1) }
        savedMeasurements.append(measurement)
        if let index = mockMeasurements.firstIndex(where: { $0.id == measurement.id }) {
            mockMeasurements[index] = measurement
        } else {
            mockMeasurements.append(measurement)
        }
    }

    func getMeasurements(from startDate: Date, to endDate: Date) async throws -> [BodyCompositionEntry] {
        if shouldThrowOnGet { throw NSError(domain: "Test", code: 2) }
        return mockMeasurements.filter { $0.date >= startDate && $0.date <= endDate }
    }

    func getLatestMeasurement() async throws -> BodyCompositionEntry? {
        if shouldThrowOnGet { throw NSError(domain: "Test", code: 2) }
        return mockMeasurements.sorted { $0.date > $1.date }.first
    }

    func deleteMeasurement(_ id: UUID) async throws {
        if shouldThrowOnDelete { throw NSError(domain: "Test", code: 3) }
        deletedIds.append(id)
        mockMeasurements.removeAll { $0.id == id }
    }
}
