//
//  TodayDashboardViewModel.swift
//  VitalArc
//
//  ViewModel for TodayDashboardView — manages daily data loading and date navigation
//

import Foundation

@Observable
@MainActor
final class TodayDashboardViewModel {
    // MARK: - State

    var selectedDate = Date()
    var healthMetrics: HealthMetrics?
    var todaysWorkout: Workout?
    var isLoading = true
    var recoveryScore: RecoveryScoreResult?
    var strainResult: StrainResult?
    var showDatePicker = false

    // MARK: - Dependencies

    private let healthRepository: HealthRepository
    private let workoutRepository: WorkoutRepository
    private let userRepository: UserRepository

    // MARK: - Init

    init(
        healthRepository: HealthRepository,
        workoutRepository: WorkoutRepository,
        userRepository: UserRepository
    ) {
        self.healthRepository = healthRepository
        self.workoutRepository = workoutRepository
        self.userRepository = userRepository
    }

    convenience init(container: DependencyContainer) {
        self.init(
            healthRepository: container.healthRepository,
            workoutRepository: container.workoutRepository,
            userRepository: container.userRepository
        )
    }

    // MARK: - Date Navigation

    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    func previousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }

    func nextDay() {
        guard !isToday else { return }
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }

    func goToToday() {
        selectedDate = Date()
    }

    // MARK: - Data Loading

    func loadTodayData() async {
        isLoading = true
        defer { isLoading = false }

        // Capture date once to avoid race if user navigates mid-load
        let date = selectedDate

        // Load health metrics
        do {
            let getHealthMetricsUseCase = GetHealthMetricsUseCase(repository: healthRepository)
            let metrics = try await getHealthMetricsUseCase.execute(for: date)
            guard selectedDate == date else { return }
            healthMetrics = metrics
        } catch {
            guard selectedDate == date else { return }
            healthMetrics = nil
            Log.error("Failed to load health metrics", error: error, category: .healthKit)
        }

        // Load today's workout
        do {
            let getTodayWorkoutsUseCase = GetTodayWorkoutsUseCase(repository: workoutRepository)
            let workouts = try await getTodayWorkoutsUseCase.execute(for: date)
            guard selectedDate == date else { return }
            todaysWorkout = workouts.first
        } catch {
            guard selectedDate == date else { return }
            todaysWorkout = nil
            Log.error("Failed to load workouts", error: error, category: .workout)
        }

        // Load recovery score for the selected date
        do {
            let recoveryUseCase = CalculateRecoveryScoreUseCase(healthDataProvider: healthRepository)
            let recovery = try await recoveryUseCase.execute(for: date)
            guard selectedDate == date else { return }
            recoveryScore = recovery
        } catch {
            guard selectedDate == date else { return }
            recoveryScore = nil
            Log.error("Failed to load recovery score", error: error, category: .healthKit)
        }

        // Load strain score
        do {
            let strainUseCase = CalculateStrainScoreUseCase(
                userProfileProvider: userRepository
            )
            let strain = try await strainUseCase.execute(for: date)
            guard selectedDate == date else { return }
            strainResult = strain
        } catch {
            guard selectedDate == date else { return }
            strainResult = nil
            Log.error("Failed to load strain score", error: error, category: .healthKit)
        }
    }

    // MARK: - Formatting

    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    /// Volume display in user-facing units (lbs)
    func formattedVolume(_ volumeKg: Double) -> String {
        let lbs = UnitConversion.kgToLbs(volumeKg)
        return String(format: "%.0f", lbs)
    }
}
