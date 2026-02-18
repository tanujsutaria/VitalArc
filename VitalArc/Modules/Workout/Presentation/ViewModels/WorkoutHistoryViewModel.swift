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
    let repository: WorkoutRepository
    private let importUseCase: ImportHealthKitWorkoutsUseCase?

    var workouts: [Workout] = []
    var isLoading: Bool = false
    var isImporting: Bool = false
    var errorMessage: String? = nil
    var importResultMessage: String? = nil
    var selectedDateRange: DateRange = .week

    init(repository: WorkoutRepository, importUseCase: ImportHealthKitWorkoutsUseCase? = nil) {
        self.repository = repository
        self.importUseCase = importUseCase
    }

    func loadWorkouts() async {
        isLoading = true
        errorMessage = nil

        do {
            let (startDate, endDate) = selectedDateRange.dateRange
            workouts = try await repository.getWorkouts(from: startDate, to: endDate)
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .loading)
        }

        isLoading = false
    }

    func deleteWorkout(_ workout: Workout) async {
        do {
            try await repository.deleteWorkout(id: workout.id)
            workouts.removeAll { $0.id == workout.id }
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .deleting)
        }
    }

    func selectDateRange(_ range: DateRange) async {
        selectedDateRange = range
        await loadWorkouts()
    }

    // MARK: - HealthKit Import

    var canImportFromHealthKit: Bool {
        importUseCase != nil
    }

    func importFromHealthKit() async {
        guard let importUseCase else { return }
        isImporting = true
        importResultMessage = nil
        errorMessage = nil

        do {
            let calendar = Calendar.current
            let now = Date()
            let startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now.addingTimeInterval(-90 * 86400)
            let count = try await importUseCase.execute(from: startDate, to: now)
            if count > 0 {
                importResultMessage = "Imported \(count) workout\(count == 1 ? "" : "s") from Health"
                await loadWorkouts()
            } else {
                importResultMessage = "No new workouts to import"
            }
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .loading)
        }

        isImporting = false
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
