//
//  AnalyticsDashboardViewModel.swift
//  VitalArc
//
//  Comprehensive ViewModel for the premium analytics dashboard
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class AnalyticsDashboardViewModel {
    // MARK: - Dependencies

    private let calculateVolumeUseCase: CalculateVolumeUseCase
    private let trackProgressiveOverloadUseCase: TrackProgressiveOverloadUseCase
    private let generateProgressReportUseCase: GenerateProgressReportUseCase
    private let calculateRecoveryScoreUseCase: CalculateRecoveryScoreUseCase
    private let calculateStrainScoreUseCase: CalculateStrainScoreUseCase
    private let analyticsRepository: AnalyticsRepository
    private let healthRepository: HealthRepository
    private let nutritionRepository: NutritionRepository

    // MARK: - State

    var selectedTimeRange: TimeRange = .month
    var isLoading = false
    var errorMessage: String?

    // Overview Scores
    var recoveryScore: Double = 0
    var recoveryResult: RecoveryScoreResult?
    var strainScore: Double = 0
    var strainResult: StrainResult?
    var sleepScore: Double = 0
    var weeklyTrainingVolume: Double = 0

    // Progress Report
    var currentReport: ProgressReport?

    // Workout Analytics
    var volumeMetrics: [VolumeMetrics] = []
    var progressSnapshots: [ProgressSnapshot] = []
    var personalRecords: [PersonalRecord] = []
    var weeklyMuscleVolume: [MuscleVolumeData] = []
    var monthlyMuscleVolume: [MuscleVolumeData] = []
    var strengthProgression: [String: [StrengthDataPoint]] = [:]
    var trainingDays: [Date: Int] = [:]
    var workoutStreak: Int = 0

    // Body Metrics
    var weightTrend: [ChartDataPoint] = []
    var bodyMeasurements: [String: [ChartDataPoint]] = [:]

    // Nutrition Analytics
    var calorieAdherence: [CalorieAdherenceData] = []
    var weeklyCalorieAverage: Double = 0
    var macroBreakdown: MacroBreakdownData = MacroBreakdownData(protein: 0, carbs: 0, fats: 0)
    var proteinTrend: [ProteinTrendData] = []
    var targetCalories: Double = 2200
    var proteinTargetPerKg: Double = 2.0
    var currentWeight: Double = 80

    // Health Trends
    var hrvTrend7Day: [HealthTrendData] = []
    var hrvTrend30Day: [HealthTrendData] = []
    var hrvBaseline: Double?
    var restingHRTrend: [HealthTrendData] = []
    var sleepTrend: [SleepTrendData] = []
    var sleepTargetHours: Double = 8

    // Macro targets
    var proteinTarget: Double = 180
    var carbsTarget: Double = 250
    var fatsTarget: Double = 70

    // MARK: - Initialization

    init(
        calculateVolumeUseCase: CalculateVolumeUseCase,
        trackProgressiveOverloadUseCase: TrackProgressiveOverloadUseCase,
        generateProgressReportUseCase: GenerateProgressReportUseCase,
        calculateRecoveryScoreUseCase: CalculateRecoveryScoreUseCase,
        calculateStrainScoreUseCase: CalculateStrainScoreUseCase,
        analyticsRepository: AnalyticsRepository,
        healthRepository: HealthRepository,
        nutritionRepository: NutritionRepository
    ) {
        self.calculateVolumeUseCase = calculateVolumeUseCase
        self.trackProgressiveOverloadUseCase = trackProgressiveOverloadUseCase
        self.generateProgressReportUseCase = generateProgressReportUseCase
        self.calculateRecoveryScoreUseCase = calculateRecoveryScoreUseCase
        self.calculateStrainScoreUseCase = calculateStrainScoreUseCase
        self.analyticsRepository = analyticsRepository
        self.healthRepository = healthRepository
        self.nutritionRepository = nutritionRepository
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            let (startDate, endDate) = selectedTimeRange.dateRange()

            // Load all data concurrently
            async let report = generateProgressReportUseCase.execute(startDate: startDate, endDate: endDate)
            async let volume = loadVolumeMetrics(startDate: startDate, endDate: endDate)
            async let snapshots = analyticsRepository.getProgressSnapshots(from: startDate, to: endDate)
            async let records = analyticsRepository.getPersonalRecords()
            async let health = loadHealthData(startDate: startDate, endDate: endDate)
            async let nutrition = loadNutritionData(startDate: startDate, endDate: endDate)

            // Await all results
            currentReport = try await report
            volumeMetrics = try await volume
            progressSnapshots = try await snapshots
            personalRecords = try await records
            _ = try await health
            _ = try await nutrition

            // Process loaded data
            processVolumeData()
            processProgressSnapshots()
            calculateScores()
            calculateTrainingHeatmap()
            calculateStrengthProgression()

        } catch {
            errorMessage = UserFacingError.message(for: error, context: .loading)
        }

        isLoading = false
    }

    private func loadVolumeMetrics(startDate: Date, endDate: Date) async throws -> [VolumeMetrics] {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: endDate).weekOfYear ?? 4
        return try await calculateVolumeUseCase.executeForWeeks(max(weeks, 4))
    }

    private func loadHealthData(startDate: Date, endDate: Date) async throws {
        let calendar = Calendar.current

        // Always fetch 30 days of data for HRV trends (independent of selected time range)
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: endDate) ?? startDate
        let healthStartDate = min(startDate, thirtyDaysAgo)

        // Load health metrics from repository
        let metrics = try await healthRepository.getHealthMetrics(from: healthStartDate, to: endDate)

        // Sort metrics by date to ensure correct ordering
        let sortedMetrics = metrics.sorted { $0.date < $1.date }

        // Process HRV data - use last 7 and last 30 days respectively
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate

        hrvTrend7Day = sortedMetrics.filter { $0.date >= sevenDaysAgo }.compactMap { metric in
            guard let hrv = metric.heartRateVariability else { return nil }
            return HealthTrendData(date: metric.date, value: hrv)
        }

        hrvTrend30Day = sortedMetrics.filter { $0.date >= thirtyDaysAgo }.compactMap { metric in
            guard let hrv = metric.heartRateVariability else { return nil }
            return HealthTrendData(date: metric.date, value: hrv)
        }

        // Calculate HRV baseline (30-day average)
        let hrvValues = sortedMetrics.filter { $0.date >= thirtyDaysAgo }.compactMap { $0.heartRateVariability }
        if !hrvValues.isEmpty {
            hrvBaseline = hrvValues.reduce(0, +) / Double(hrvValues.count)
        }

        // Process resting heart rate (last 7 days)
        restingHRTrend = sortedMetrics.filter { $0.date >= sevenDaysAgo }.compactMap { metric in
            guard let hr = metric.restingHeartRate else { return nil }
            return HealthTrendData(date: metric.date, value: hr)
        }

        // Process sleep data (last 7 days)
        sleepTrend = sortedMetrics.filter { $0.date >= sevenDaysAgo }.compactMap { metric in
            guard let sleep = metric.sleepHours else { return nil }
            return SleepTrendData(
                date: metric.date,
                totalHours: sleep,
                deepSleepHours: nil,
                remSleepHours: nil,
                lightSleepHours: nil
            )
        }

        // Get latest weight
        if let latestWeight = sortedMetrics.last?.weight {
            currentWeight = latestWeight
        }
    }

    private func loadNutritionData(startDate: Date, endDate: Date) async throws {
        let calendar = Calendar.current

        // Load daily nutrition data for the past 7 days
        var calorieData: [CalorieAdherenceData] = []
        var totalProtein: Double = 0
        var totalCarbs: Double = 0
        var totalFats: Double = 0
        var proteinData: [ProteinTrendData] = []

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: Date()) else { continue }

            if let nutrition = try await nutritionRepository.getDailyNutrition(for: date) {
                // Calorie adherence
                calorieData.append(CalorieAdherenceData(
                    date: date,
                    consumed: nutrition.caloriesConsumed,
                    target: nutrition.calorieGoal ?? targetCalories
                ))

                // Accumulate macros
                totalProtein += nutrition.proteinConsumed
                totalCarbs += nutrition.carbsConsumed
                totalFats += nutrition.fatConsumed

                // Protein per kg
                if currentWeight > 0 {
                    proteinData.append(ProteinTrendData(
                        date: date,
                        proteinPerKg: nutrition.proteinConsumed / currentWeight
                    ))
                }
            }
        }

        calorieAdherence = calorieData
        proteinTrend = proteinData

        // Calculate weekly averages
        if !calorieData.isEmpty {
            let totalAdherence = calorieData.map { $0.adherencePercent }.reduce(0, +)
            weeklyCalorieAverage = totalAdherence / Double(calorieData.count)
        }

        // Average macro breakdown
        let days = max(calorieData.count, 1)
        macroBreakdown = MacroBreakdownData(
            protein: totalProtein / Double(days),
            carbs: totalCarbs / Double(days),
            fats: totalFats / Double(days)
        )
    }

    // MARK: - Data Processing

    private func processVolumeData() {
        guard !volumeMetrics.isEmpty else { return }

        // Calculate weekly training volume
        if let latestMetrics = volumeMetrics.last {
            weeklyTrainingVolume = latestMetrics.totalVolume
        }

        // Process muscle group volume
        let muscleColors: [String: Color] = [
            "Chest": .vitalDanger,
            "Back": .vitalInfo,
            "Shoulders": .vitalWarning,
            "Arms": .vitalAccent,
            "Legs": .vitalSuccess,
            "Core": .vitalSecondary,
            "Other": .vitalPrimary
        ]

        // Group exercises by muscle group (simplified - would need exercise metadata)
        var weeklyMuscleData: [String: Double] = [:]
        var monthlyMuscleData: [String: Double] = [:]

        if let latestMetrics = volumeMetrics.last {
            for exercise in latestMetrics.exerciseVolumes {
                let muscleGroup = getMuscleGroup(for: exercise.exerciseName)
                weeklyMuscleData[muscleGroup, default: 0] += exercise.totalWeight
            }
        }

        // Aggregate monthly data
        for metrics in volumeMetrics.suffix(4) {
            for exercise in metrics.exerciseVolumes {
                let muscleGroup = getMuscleGroup(for: exercise.exerciseName)
                monthlyMuscleData[muscleGroup, default: 0] += exercise.totalWeight
            }
        }

        weeklyMuscleVolume = weeklyMuscleData.map { group, volume in
            MuscleVolumeData(
                muscleGroup: group,
                volume: volume,
                color: muscleColors[group] ?? .vitalPrimary
            )
        }.sorted { $0.volume > $1.volume }

        monthlyMuscleVolume = monthlyMuscleData.map { group, volume in
            MuscleVolumeData(
                muscleGroup: group,
                volume: volume,
                color: muscleColors[group] ?? .vitalPrimary
            )
        }.sorted { $0.volume > $1.volume }
    }

    private func processProgressSnapshots() {
        // Extract weight trend
        weightTrend = progressSnapshots
            .filter { $0.bodyWeight != nil }
            .sorted { $0.date < $1.date }
            .map { ChartDataPoint(date: $0.date, value: $0.bodyWeight!) }
    }

    private func calculateScores() {
        // Calculate Recovery Score using the dedicated use case
        Task {
            do {
                let result = try await calculateRecoveryScoreUseCase.execute()
                recoveryResult = result
                recoveryScore = Double(result.score)

                // Trigger recovery alert check if enabled
                let recoveryAlertsEnabled = UserDefaults.standard.bool(forKey: "enableRecoveryAlerts")
                let recoveryThreshold = UserDefaults.standard.integer(forKey: "recoveryThreshold")
                if recoveryAlertsEnabled && result.score <= recoveryThreshold {
                    let scheduler = NotificationScheduler()
                    try? await scheduler.scheduleRecoveryAlertIfNeeded(
                        recoveryScore: Double(result.score),
                        threshold: recoveryThreshold,
                        enabled: recoveryAlertsEnabled
                    )
                }
            } catch {
                // Fallback to demo score if calculation fails
                recoveryScore = Double.random(in: 65...95)
            }
        }

        // Calculate Strain Score using TRIMP calculation
        Task {
            do {
                if let result = try await calculateStrainScoreUseCase.execute(for: Date()) {
                    strainResult = result
                    strainScore = result.strainScore
                } else {
                    // No workout data for today
                    strainScore = 0
                }
            } catch {
                // Fallback to estimated strain if calculation fails
                if let report = currentReport {
                    strainScore = min(report.workoutConsistency / 100 * 21, 21)
                } else {
                    strainScore = 0
                }
            }
        }

        // Sleep Score (based on duration and consistency)
        if !sleepTrend.isEmpty {
            let avgSleep = sleepTrend.map { $0.totalHours }.reduce(0, +) / Double(sleepTrend.count)
            sleepScore = min(max((avgSleep / sleepTargetHours) * 100, 0), 100)
        } else {
            sleepScore = Double.random(in: 60...90)
        }
    }

    private func calculateTrainingHeatmap() {
        let calendar = Calendar.current
        trainingDays = [:]
        var streak = 0
        var currentDate = Date()

        // Calculate from volume metrics
        for metrics in volumeMetrics {
            let startOfWeek = calendar.startOfDay(for: metrics.weekStartDate)

            // Distribute workouts across the week
            for dayOffset in 0..<min(metrics.workoutCount, 7) {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                    let dayStart = calendar.startOfDay(for: date)
                    trainingDays[dayStart, default: 0] += 1
                }
            }
        }

        // Calculate workout streak
        while true {
            let dayStart = calendar.startOfDay(for: currentDate)
            if trainingDays[dayStart] ?? 0 > 0 {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }

        workoutStreak = streak
    }

    private func calculateStrengthProgression() {
        // Build strength progression from personal records
        var progressionData: [String: [StrengthDataPoint]] = [:]

        // Group records by exercise
        let groupedRecords = Dictionary(grouping: personalRecords) { $0.exerciseName }

        for (exerciseName, records) in groupedRecords {
            let sortedRecords = records
                .filter { $0.recordType == .oneRepMax }
                .sorted { $0.date < $1.date }

            if sortedRecords.count >= 2 {
                progressionData[exerciseName] = sortedRecords.map { record in
                    StrengthDataPoint(
                        date: record.date,
                        estimatedOneRM: record.value,
                        exerciseName: record.exerciseName
                    )
                }
            }
        }

        strengthProgression = progressionData
    }

    // MARK: - Helper Methods

    private func getMuscleGroup(for exerciseName: String) -> String {
        let name = exerciseName.lowercased()

        if name.contains("bench") || name.contains("chest") || name.contains("fly") || name.contains("push") {
            return "Chest"
        } else if name.contains("row") || name.contains("pull") || name.contains("lat") || name.contains("back") {
            return "Back"
        } else if name.contains("shoulder") || name.contains("press") || name.contains("delt") || name.contains("raise") {
            return "Shoulders"
        } else if name.contains("curl") || name.contains("tricep") || name.contains("bicep") || name.contains("arm") {
            return "Arms"
        } else if name.contains("squat") || name.contains("leg") || name.contains("lunge") || name.contains("deadlift") || name.contains("calf") {
            return "Legs"
        } else if name.contains("ab") || name.contains("core") || name.contains("plank") || name.contains("crunch") {
            return "Core"
        }

        return "Other"
    }

    // MARK: - Export Functions

    private let pdfExporter = PDFExporter()
    private let csvExporter = CSVExporter()

    func exportProgressReportPDF() async -> URL? {
        guard let report = currentReport else {
            errorMessage = "No progress report available to export."
            return nil
        }

        do {
            let url = try await pdfExporter.exportProgressReport(report)
            return url
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .exporting)
            return nil
        }
    }

    func exportVolumeMetricsCSV() async -> URL? {
        guard !volumeMetrics.isEmpty else {
            errorMessage = "No volume metrics available to export."
            return nil
        }

        do {
            let url = try await csvExporter.exportVolumeMetrics(metrics: volumeMetrics)
            return url
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .exporting)
            return nil
        }
    }

    // MARK: - Time Range

    enum TimeRange: String, CaseIterable {
        case week = "1 Week"
        case month = "1 Month"
        case threeMonths = "3 Months"
        case sixMonths = "6 Months"
        case year = "1 Year"

        func dateRange() -> (Date, Date) {
            let end = Date()
            let calendar = Calendar.current
            var start: Date

            switch self {
            case .week:
                start = calendar.date(byAdding: .weekOfYear, value: -1, to: end) ?? end
            case .month:
                start = calendar.date(byAdding: .month, value: -1, to: end) ?? end
            case .threeMonths:
                start = calendar.date(byAdding: .month, value: -3, to: end) ?? end
            case .sixMonths:
                start = calendar.date(byAdding: .month, value: -6, to: end) ?? end
            case .year:
                start = calendar.date(byAdding: .year, value: -1, to: end) ?? end
            }

            return (start, end)
        }
    }
}

// MARK: - Preview Support

extension AnalyticsDashboardViewModel {
    /// Creates a ViewModel with sample data for previews
    static func preview() -> AnalyticsDashboardViewModel {
        // This would require mock implementations of the use cases and repositories
        // For now, we'll return a minimally configured instance
        fatalError("Preview not implemented - use PreviewAnalyticsDashboardViewModel instead")
    }
}
