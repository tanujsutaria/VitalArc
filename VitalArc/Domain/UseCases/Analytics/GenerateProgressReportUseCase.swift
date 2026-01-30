//
//  GenerateProgressReportUseCase.swift
//  VitalArc
//
//  Use case for generating comprehensive progress reports
//

import Foundation

/// Generates comprehensive progress reports
class GenerateProgressReportUseCase {
    private let workoutRepository: WorkoutRepository
    private let healthRepository: HealthRepository
    private let nutritionRepository: NutritionRepository
    private let analyticsRepository: AnalyticsRepository
    private let calculateVolumeUseCase: CalculateVolumeUseCase

    init(
        workoutRepository: WorkoutRepository,
        healthRepository: HealthRepository,
        nutritionRepository: NutritionRepository,
        analyticsRepository: AnalyticsRepository,
        calculateVolumeUseCase: CalculateVolumeUseCase
    ) {
        self.workoutRepository = workoutRepository
        self.healthRepository = healthRepository
        self.nutritionRepository = nutritionRepository
        self.analyticsRepository = analyticsRepository
        self.calculateVolumeUseCase = calculateVolumeUseCase
    }

    /// Generate a comprehensive progress report for a date range
    func execute(startDate: Date, endDate: Date) async throws -> ProgressReport {
        let period = DateInterval(start: startDate, end: endDate)

        // Fetch all necessary data in parallel
        async let workouts = workoutRepository.getWorkouts(from: startDate, to: endDate)
        async let healthMetrics = healthRepository.getHealthMetrics(from: startDate, to: endDate)
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

        // Calculate calorie adherence
        let avgCalorieAdherence = try await calculateCalorieAdherence(
            startDate: startDate,
            endDate: endDate
        )

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

    private func calculateCalorieAdherence(startDate: Date, endDate: Date) async throws -> Double {
        let calendar = Calendar.current
        var totalAdherence = 0.0
        var daysWithData = 0

        var currentDate = startDate
        while currentDate <= endDate {
            if let nutrition = try await nutritionRepository.getDailyNutrition(for: currentDate) {
                let adherence = calculateDayAdherence(nutrition)
                totalAdherence += adherence
                daysWithData += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }

        guard daysWithData > 0 else { return 0 }

        return totalAdherence / Double(daysWithData)
    }

    private func calculateDayAdherence(_ nutrition: DailyNutrition) -> Double {
        guard let calorieGoal = nutrition.calorieGoal, calorieGoal > 0 else { return 0 }

        let difference = abs(nutrition.caloriesConsumed - calorieGoal)
        let percentage = (difference / calorieGoal) * 100

        // Perfect adherence = within 5%, decreases linearly to 0% at 25% off
        if percentage <= 5 {
            return 100
        } else if percentage >= 25 {
            return 0
        } else {
            return 100 - ((percentage - 5) / 20 * 100)
        }
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
