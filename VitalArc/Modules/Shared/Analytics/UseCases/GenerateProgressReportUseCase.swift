//
//  GenerateProgressReportUseCase.swift
//  VitalArc
//
//  Use case for generating comprehensive progress reports
//

import Foundation

/// Generates comprehensive progress reports
class GenerateProgressReportUseCase {
    private let workoutDataProvider: WorkoutDataProviding
    private let healthDataProvider: HealthDataProviding
    private let analyticsRepository: AnalyticsRepository
    private let calculateVolumeUseCase: CalculateVolumeUseCase

    init(
        workoutDataProvider: WorkoutDataProviding,
        healthDataProvider: HealthDataProviding,
        analyticsRepository: AnalyticsRepository,
        calculateVolumeUseCase: CalculateVolumeUseCase
    ) {
        self.workoutDataProvider = workoutDataProvider
        self.healthDataProvider = healthDataProvider
        self.analyticsRepository = analyticsRepository
        self.calculateVolumeUseCase = calculateVolumeUseCase
    }

    /// Generate a comprehensive progress report for a date range
    func execute(startDate: Date, endDate: Date) async throws -> ProgressReport {
        let period = DateInterval(start: startDate, end: endDate)

        // Fetch all necessary data in parallel
        async let workouts = workoutDataProvider.getWorkouts(from: startDate, to: endDate)
        async let healthMetrics = healthDataProvider.getHealthMetrics(from: startDate, to: endDate)
        async let snapshots = analyticsRepository.getProgressSnapshots(from: startDate, to: endDate)
        async let records = analyticsRepository.getPersonalRecords()

        // Calculate body weight change
        let bodyWeightChange = try await calculateBodyWeightChange(snapshots: snapshots)

        // Calculate volume change
        let volumeChange = try await calculateVolumeChange(
            startDate: startDate,
            endDate: endDate,
            workouts: workouts
        )

        // Filter records broken in this period
        let recordsBroken = try await records.filter { record in
            record.date >= startDate && record.date <= endDate
        }

        // Calculate workout consistency
        let workoutConsistency = try await calculateWorkoutConsistency(
            workouts: workouts,
            startDate: startDate,
            endDate: endDate
        )

        // Calorie adherence (nutrition module removed)
        let avgCalorieAdherence = 0.0

        // Calculate sleep and HRV averages
        let metrics = try await healthMetrics
        let avgSleepHours = calculateAverageSleep(metrics: metrics)
        let avgHRV = calculateAverageHRV(metrics: metrics)

        return ProgressReport(
            period: period,
            bodyWeightChange: bodyWeightChange,
            volumeChange: volumeChange,
            recordsBroken: recordsBroken,
            workoutConsistency: workoutConsistency,
            avgCalorieAdherence: avgCalorieAdherence,
            avgSleepHours: avgSleepHours,
            avgHRV: avgHRV
        )
    }

    // MARK: - Private Helpers

    private func calculateBodyWeightChange(snapshots: [ProgressSnapshot]) async throws -> Double? {
        let sortedSnapshots = snapshots.sorted { $0.date < $1.date }

        guard let firstWeight = sortedSnapshots.first?.bodyWeight,
              let lastWeight = sortedSnapshots.last?.bodyWeight else {
            return nil
        }

        return lastWeight - firstWeight
    }

    private func calculateVolumeChange(
        startDate: Date,
        endDate: Date,
        workouts: [Workout]
    ) async throws -> Double {
        let calendar = Calendar.current
        let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0

        guard totalDays >= 14 else { return 0 }

        let midpoint = calendar.date(byAdding: .day, value: totalDays / 2, to: startDate) ?? startDate

        // Calculate volume for first half
        let firstHalfVolume = try await calculateVolumeUseCase.execute(
            startDate: startDate,
            endDate: midpoint
        )

        // Calculate volume for second half
        let secondHalfVolume = try await calculateVolumeUseCase.execute(
            startDate: midpoint,
            endDate: endDate
        )

        guard firstHalfVolume.totalVolume > 0 else { return 0 }

        return ((secondHalfVolume.totalVolume - firstHalfVolume.totalVolume) / firstHalfVolume.totalVolume) * 100
    }

    private func calculateWorkoutConsistency(
        workouts: [Workout],
        startDate: Date,
        endDate: Date
    ) async throws -> Double {
        let calendar = Calendar.current
        let totalWeeks = calendar.dateComponents([.weekOfYear], from: startDate, to: endDate).weekOfYear ?? 1

        // Calculate expected workouts (assume 3-4 per week)
        let expectedWorkouts = Double(totalWeeks * 3)
        let actualWorkouts = Double(workouts.count)

        guard expectedWorkouts > 0 else { return 0 }

        return min((actualWorkouts / expectedWorkouts) * 100, 100)
    }

    private func calculateAverageSleep(metrics: [HealthMetrics]) -> Double? {
        let sleepValues = metrics.compactMap { $0.sleepHours }
        guard !sleepValues.isEmpty else { return nil }

        return sleepValues.reduce(0, +) / Double(sleepValues.count)
    }

    private func calculateAverageHRV(metrics: [HealthMetrics]) -> Double? {
        let hrvValues = metrics.compactMap { $0.heartRateVariability }
        guard !hrvValues.isEmpty else { return nil }

        return hrvValues.reduce(0, +) / Double(hrvValues.count)
    }
}
