//
//  WorkoutHistoryViewModel.swift
//  VitalArc
//
//  ViewModel for Workout History
//

import Foundation
import Observation

@MainActor
@Observable
final class WorkoutHistoryViewModel {
    private let repository: WorkoutRepository

    var workouts: [Workout] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var selectedDateRange: DateRange = .week

    init(repository: WorkoutRepository) {
        self.repository = repository
    }

    @MainActor
    func loadWorkouts() async {
        isLoading = true
        errorMessage = nil

        do {
            let (startDate, endDate) = selectedDateRange.dateRange
            workouts = try await repository.getWorkouts(from: startDate, to: endDate)
        } catch {
            errorMessage = "Failed to load workouts: \(error.localizedDescription)"
        }

        isLoading = false
    }

    @MainActor
    func deleteWorkout(_ workout: Workout) async {
        do {
            try await repository.deleteWorkout(id: workout.id)
            workouts.removeAll { $0.id == workout.id }
        } catch {
            errorMessage = "Failed to delete workout: \(error.localizedDescription)"
        }
    }

    @MainActor
    func selectDateRange(_ range: DateRange) async {
        selectedDateRange = range
        await loadWorkouts()
    }

    // MARK: - Statistics

    var totalWorkouts: Int {
        workouts.count
    }

    var totalVolume: Double {
        workouts.reduce(0) { $0 + $1.totalVolume }
    }

    var totalSets: Int {
        workouts.reduce(0) { $0 + $1.totalSets }
    }

    var averageDuration: TimeInterval {
        let durations = workouts.compactMap { $0.duration }
        guard !durations.isEmpty else { return 0 }
        return durations.reduce(0, +) / Double(durations.count)
    }
}

// MARK: - Date Range

enum DateRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
    case year = "Year"
    case all = "All Time"

    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: now) ?? now.addingTimeInterval(-7 * 86400)
            return (start, now)
        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now.addingTimeInterval(-30 * 86400)
            return (start, now)
        case .threeMonths:
            let start = calendar.date(byAdding: .month, value: -3, to: now) ?? now.addingTimeInterval(-90 * 86400)
            return (start, now)
        case .year:
            let start = calendar.date(byAdding: .year, value: -1, to: now) ?? now.addingTimeInterval(-365 * 86400)
            return (start, now)
        case .all:
            let start = calendar.date(byAdding: .year, value: -10, to: now) ?? now.addingTimeInterval(-3650 * 86400)
            return (start, now)
        }
    }
}
