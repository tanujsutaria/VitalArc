//
//  HealthKitTests.swift
//  VitalArcTests
//
//  Test suite for HealthKit integration
//

import XCTest
import HealthKit
@testable import VitalArc

final class HealthKitTests: XCTestCase {

    // MARK: - HealthKitMapper Tests

    func testHealthKitMapperHRV() throws {
        let date = Date()
        let quantity = HKQuantity(unit: HKUnit.secondUnit(with: .milli), doubleValue: 75.5)
        let sample = HKQuantitySample(
            type: HKQuantityType(.heartRateVariabilitySDNN),
            quantity: quantity,
            start: date,
            end: date
        )

        let metrics = HealthKitMapper.mapToHealthMetrics(
            date: date,
            hrvSample: sample,
            heartRateSample: nil,
            activeEnergySample: nil,
            stepsSample: nil,
            sleepSample: nil,
            weightSample: nil
        )

        XCTAssertNotNil(metrics)
        XCTAssertEqual(metrics?.heartRateVariability ?? 0, 75.5, accuracy: 0.1)
        XCTAssertEqual(metrics?.date.timeIntervalSince1970 ?? 0, date.timeIntervalSince1970, accuracy: 1.0)
    }

    func testHealthKitMapperHeartRate() throws {
        let date = Date()
        let quantity = HKQuantity(unit: HKUnit.count().unitDivided(by: .minute()), doubleValue: 65.0)
        let sample = HKQuantitySample(
            type: HKQuantityType(.heartRate),
            quantity: quantity,
            start: date,
            end: date
        )

        let metrics = HealthKitMapper.mapToHealthMetrics(
            date: date,
            hrvSample: nil,
            heartRateSample: sample,
            activeEnergySample: nil,
            stepsSample: nil,
            sleepSample: nil,
            weightSample: nil
        )

        XCTAssertNotNil(metrics)
        XCTAssertEqual(metrics?.restingHeartRate ?? 0, 65.0, accuracy: 0.1)
    }

    func testHealthKitMapperActiveEnergy() throws {
        let date = Date()
        let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: 450.0)
        let sample = HKQuantitySample(
            type: HKQuantityType(.activeEnergyBurned),
            quantity: quantity,
            start: date,
            end: date
        )

        let metrics = HealthKitMapper.mapToHealthMetrics(
            date: date,
            hrvSample: nil,
            heartRateSample: nil,
            activeEnergySample: sample,
            stepsSample: nil,
            sleepSample: nil,
            weightSample: nil
        )

        XCTAssertNotNil(metrics)
        XCTAssertEqual(metrics?.activeEnergy ?? 0, 450.0, accuracy: 0.1)
    }

    func testHealthKitMapperSteps() throws {
        let date = Date()
        let quantity = HKQuantity(unit: .count(), doubleValue: 10000.0)
        let sample = HKQuantitySample(
            type: HKQuantityType(.stepCount),
            quantity: quantity,
            start: date,
            end: date
        )

        let metrics = HealthKitMapper.mapToHealthMetrics(
            date: date,
            hrvSample: nil,
            heartRateSample: nil,
            activeEnergySample: nil,
            stepsSample: sample,
            sleepSample: nil,
            weightSample: nil
        )

        XCTAssertNotNil(metrics)
        XCTAssertEqual(metrics?.steps, 10000)
    }

    func testHealthKitMapperWeight() throws {
        let date = Date()
        let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: 75.5)
        let sample = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: quantity,
            start: date,
            end: date
        )

        let metrics = HealthKitMapper.mapToHealthMetrics(
            date: date,
            hrvSample: nil,
            heartRateSample: nil,
            activeEnergySample: nil,
            stepsSample: nil,
            sleepSample: nil,
            weightSample: sample
        )

        XCTAssertNotNil(metrics)
        XCTAssertEqual(metrics?.weight ?? 0, 75.5, accuracy: 0.1)
    }

    func testHealthKitMapperAllMetrics() throws {
        let date = Date()

        let hrvSample = HKQuantitySample(
            type: HKQuantityType(.heartRateVariabilitySDNN),
            quantity: HKQuantity(unit: HKUnit.secondUnit(with: .milli), doubleValue: 75.5),
            start: date,
            end: date
        )

        let heartRateSample = HKQuantitySample(
            type: HKQuantityType(.heartRate),
            quantity: HKQuantity(unit: HKUnit.count().unitDivided(by: .minute()), doubleValue: 65.0),
            start: date,
            end: date
        )

        let energySample = HKQuantitySample(
            type: HKQuantityType(.activeEnergyBurned),
            quantity: HKQuantity(unit: .kilocalorie(), doubleValue: 450.0),
            start: date,
            end: date
        )

        let stepsSample = HKQuantitySample(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 10000.0),
            start: date,
            end: date
        )

        let weightSample = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: 75.5),
            start: date,
            end: date
        )

        let metrics = HealthKitMapper.mapToHealthMetrics(
            date: date,
            hrvSample: hrvSample,
            heartRateSample: heartRateSample,
            activeEnergySample: energySample,
            stepsSample: stepsSample,
            sleepSample: nil,
            weightSample: weightSample
        )

        XCTAssertNotNil(metrics)
        XCTAssertEqual(metrics?.heartRateVariability ?? 0, 75.5, accuracy: 0.1)
        XCTAssertEqual(metrics?.restingHeartRate ?? 0, 65.0, accuracy: 0.1)
        XCTAssertEqual(metrics?.activeEnergy ?? 0, 450.0, accuracy: 0.1)
        XCTAssertEqual(metrics?.steps, 10000)
        XCTAssertEqual(metrics?.weight ?? 0, 75.5, accuracy: 0.1)
    }

    // MARK: - HealthKitQuery Tests

    func testDateRangeForToday() throws {
        let dateRange = HealthKitQuery.dateRangeForToday()

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        XCTAssertEqual(dateRange.start.timeIntervalSince1970, startOfDay.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertEqual(dateRange.end.timeIntervalSince1970, endOfDay.timeIntervalSince1970, accuracy: 1.0)
    }

    func testDateRangeForLastDays() throws {
        let days = 7
        let dateRange = HealthKitQuery.dateRangeForLastDays(days)

        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let startDate = calendar.date(byAdding: .day, value: -days + 1, to: startOfToday)!

        XCTAssertEqual(dateRange.start.timeIntervalSince1970, startDate.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertEqual(dateRange.end.timeIntervalSince1970, endOfToday.timeIntervalSince1970, accuracy: 1.0)
    }

    func testPredicateForDateRange() throws {
        let start = Date()
        let end = start.addingTimeInterval(86400) // +1 day

        let predicate = HealthKitQuery.predicateForDateRange(start: start, end: end)

        XCTAssertNotNil(predicate)
    }

    // MARK: - HealthKitPermissions Tests

    func testRequiredHealthKitTypes() throws {
        let readTypes = HealthKitPermissions.requiredReadTypes()

        XCTAssertTrue(readTypes.contains(HKQuantityType(.heartRateVariabilitySDNN)))
        XCTAssertTrue(readTypes.contains(HKQuantityType(.restingHeartRate)))
        XCTAssertTrue(readTypes.contains(HKQuantityType(.activeEnergyBurned)))
        XCTAssertTrue(readTypes.contains(HKQuantityType(.stepCount)))
        XCTAssertTrue(readTypes.contains(HKQuantityType(.bodyMass)))
        XCTAssertTrue(readTypes.contains(HKCategoryType(.sleepAnalysis)))
    }

    // MARK: - HealthDashboardViewModel Tests

    func testViewModelInitialState() throws {
        let viewModel = HealthDashboardViewModel(healthRepository: MockHealthRepository())

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertNil(viewModel.todayMetrics)
        XCTAssertTrue(viewModel.weekMetrics.isEmpty)
    }

    func testViewModelLoadTodayMetrics() async throws {
        let mockRepo = MockHealthRepository()
        let mockMetrics = HealthMetrics(
            date: Date(),
            heartRateVariability: 75.0,
            restingHeartRate: 65.0,
            activeEnergy: 450.0,
            steps: 10000,
            sleepHours: 7.5,
            weight: 75.0
        )
        mockRepo.mockTodayMetrics = mockMetrics

        let viewModel = HealthDashboardViewModel(healthRepository: mockRepo)

        await viewModel.loadTodayMetrics()

        XCTAssertNotNil(viewModel.todayMetrics)
        XCTAssertEqual(viewModel.todayMetrics?.heartRateVariability ?? 0, 75.0, accuracy: 0.1)
        XCTAssertEqual(viewModel.todayMetrics?.steps, 10000)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testViewModelLoadWeekMetrics() async throws {
        let mockRepo = MockHealthRepository()
        let mockMetrics = (0..<7).map { day in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-day * 86400)),
                heartRateVariability: Double(70 + day),
                restingHeartRate: Double(60 + day),
                steps: 10000 + day * 1000
            )
        }
        mockRepo.mockWeekMetrics = mockMetrics

        let viewModel = HealthDashboardViewModel(healthRepository: mockRepo)

        await viewModel.loadWeekMetrics()

        XCTAssertEqual(viewModel.weekMetrics.count, 7)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testViewModelRequestPermissions() async throws {
        let mockRepo = MockHealthRepository()
        mockRepo.mockAuthorizationSuccess = true

        let viewModel = HealthDashboardViewModel(healthRepository: mockRepo)

        await viewModel.requestHealthKitPermissions()

        XCTAssertTrue(mockRepo.authorizationRequested)
    }

    func testViewModelSyncFromHealthKit() async throws {
        let mockRepo = MockHealthRepository()

        let viewModel = HealthDashboardViewModel(healthRepository: mockRepo)

        await viewModel.syncFromHealthKit()

        XCTAssertTrue(mockRepo.syncRequested)
    }
}

// MARK: - Mock Health Repository

class MockHealthRepository: HealthRepository {
    var mockTodayMetrics: HealthMetrics?
    var mockWeekMetrics: [HealthMetrics] = []
    var mockAuthorizationSuccess = false
    var authorizationRequested = false
    var syncRequested = false

    func getHealthMetrics(for date: Date) async throws -> HealthMetrics? {
        return mockTodayMetrics
    }

    func getHealthMetrics(from startDate: Date, to endDate: Date) async throws -> [HealthMetrics] {
        return mockWeekMetrics
    }

    func saveHealthMetrics(_ metrics: HealthMetrics) async throws {
        // Mock implementation
    }

    func syncFromHealthKit() async throws {
        syncRequested = true
    }

    func requestHealthKitAuthorization() async throws -> Bool {
        authorizationRequested = true
        return mockAuthorizationSuccess
    }
}
