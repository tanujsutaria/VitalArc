//
//  MockWorkoutImportSource.swift
//  VitalArcTests
//
//  Mock implementation of WorkoutImportSource for testing
//

import Foundation
@testable import VitalArc

final class MockWorkoutImportSource: WorkoutImportSource {
    var mockWorkouts: [ImportedWorkoutData] = []
    var shouldThrow = false
    var fetchCallCount = 0
    var lastStartDate: Date?
    var lastEndDate: Date?

    func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [ImportedWorkoutData] {
        fetchCallCount += 1
        lastStartDate = startDate
        lastEndDate = endDate

        if shouldThrow {
            throw MockError.fetchFailed
        }
        return mockWorkouts
    }

    enum MockError: Error {
        case fetchFailed
    }
}
