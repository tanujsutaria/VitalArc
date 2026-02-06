//
//  TodayDashboardView.swift
//  VitalArc
//
//  Consolidated daily dashboard combining health, workout, and nutrition summaries
//

import SwiftUI

struct TodayDashboardView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var selectedDate = Date()
    @State private var healthMetrics: HealthMetrics?
    @State private var todaysWorkout: Workout?
    @State private var dailyNutrition: DailyNutrition?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Date Header
                    dateHeader

                    // Quick Stats Summary
                    if isLoading {
                        loadingSection
                    } else {
                        // Recovery & Strain Section
                        recoveryStrainSection

                        // Today's Activity Section
                        activitySection

                        // Nutrition Summary Section
                        nutritionSection

                        // Quick Actions Section
                        quickActionsSection
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.vitalAdaptiveBackgroundV2)
            .navigationTitle("Today")
            .task {
                await loadTodayData()
            }
            .refreshable {
                await loadTodayData()
            }
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                    .font(.vitalLabelV2)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)
                Text(selectedDate.formatted(.dateTime.month().day()))
                    .font(.vitalDisplayMediumV2)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
            }
            Spacer()
            // Date navigation could go here
        }
    }

    // MARK: - Loading State

    private var loadingSection: some View {
        VStack(spacing: Spacing.md) {
            VitalMetricCardSkeleton()
            VitalMetricCardSkeleton()
            VitalWorkoutCardSkeleton()
        }
    }

    // MARK: - Recovery & Strain Section

    private var recoveryStrainSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recovery & Strain")
                .font(.vitalH3V2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)

            HStack(spacing: Spacing.md) {
                // Recovery Score Card
                recoveryCard

                // Strain Score Card
                strainCard
            }
        }
    }

    private var recoveryCard: some View {
        VitalCardV2(elevation: .elevated) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "battery.100.bolt")
                        .font(.vitalIconMedium)
                        .foregroundStyle(Color.vitalSuccessV2)
                    Spacer()
                    Text("Recovery")
                        .font(.vitalLabelSmallV2)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)
                }

                if let metrics = healthMetrics {
                    Text("\(Int(metrics.sleepHours ?? 7))h \(Int((metrics.sleepHours ?? 7).truncatingRemainder(dividingBy: 1) * 60))m")
                        .font(.vitalNumberLargeV2)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                    Text("Sleep")
                        .font(.vitalCaptionV2)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
                } else {
                    Text("--")
                        .font(.vitalNumberLargeV2)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
                    Text("No data")
                        .font(.vitalCaptionV2)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var strainCard: some View {
        VitalCardV2(elevation: .elevated) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.vitalIconMedium)
                        .foregroundStyle(Color.vitalPrimaryV2)
                    Spacer()
                    Text("Strain")
                        .font(.vitalLabelSmallV2)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)
                }

                if let metrics = healthMetrics {
                    Text("\(Int(metrics.activeEnergy ?? 0))")
                        .font(.vitalNumberLargeV2)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                    Text("kcal active")
                        .font(.vitalCaptionV2)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
                } else {
                    Text("--")
                        .font(.vitalNumberLargeV2)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
                    Text("No data")
                        .font(.vitalCaptionV2)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Activity Section

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Today's Activity")
                    .font(.vitalH3V2)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                Spacer()
                if todaysWorkout != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.vitalSuccessV2)
                }
            }

            if let workout = todaysWorkout {
                workoutSummaryCard(workout)
            } else {
                noWorkoutCard
            }
        }
    }

    private func workoutSummaryCard(_ workout: Workout) -> some View {
        VitalCardV2(elevation: .elevated) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Workout Complete")
                            .font(.vitalLabelV2)
                            .foregroundStyle(Color.vitalSuccessV2)
                        Text(workout.name ?? "Workout")
                            .font(.vitalH4V2)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                    }
                    Spacer()
                    if let duration = workout.duration {
                        Text(formatDuration(duration))
                            .font(.vitalDataMediumV2)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)
                    }
                }

                HStack(spacing: Spacing.lg) {
                    statItem(value: "\(workout.sets.count)", label: "Sets")
                    statItem(value: String(format: "%.0f", workout.totalVolume), label: "kg Volume")
                }
            }
        }
    }

    private var noWorkoutCard: some View {
        VitalCardV2(elevation: .raised) {
            HStack(spacing: Spacing.md) {
                Image(systemName: "dumbbell")
                    .font(.vitalIconLarge)
                    .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("No workout logged")
                        .font(.vitalLabelV2)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                    Text("Tap to start a workout")
                        .font(.vitalCaptionV2)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.vitalIconSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
            }
        }
    }

    // MARK: - Nutrition Section

    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Nutrition")
                .font(.vitalH3V2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)

            if let nutrition = dailyNutrition {
                VitalCardV2(elevation: .elevated) {
                    VStack(spacing: Spacing.md) {
                        // Calories progress
                        HStack {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Calories")
                                    .font(.vitalLabelSmallV2)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)
                                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                                    Text("\(Int(nutrition.caloriesConsumed))")
                                        .font(.vitalNumberLargeV2)
                                        .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                                    Text("/ \(Int(nutrition.calorieGoal ?? 2000)) kcal")
                                        .font(.vitalCaptionV2)
                                        .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
                                }
                            }
                            Spacer()
                            let percentage = nutrition.calorieProgress ?? 0
                            Text("\(Int(percentage))%")
                                .font(.vitalDataMediumV2)
                                .foregroundStyle(percentage >= 100 ? Color.vitalSuccessV2 : Color.vitalAccentV2)
                        }

                        // Macro bars
                        HStack(spacing: Spacing.md) {
                            macroBar(label: "Protein", current: nutrition.proteinConsumed, target: nutrition.proteinGoal ?? 150, color: .vitalPrimaryV2)
                            macroBar(label: "Carbs", current: nutrition.carbsConsumed, target: nutrition.carbsGoal ?? 250, color: .vitalAccentV2)
                            macroBar(label: "Fat", current: nutrition.fatConsumed, target: nutrition.fatGoal ?? 65, color: .vitalWarningV2)
                        }
                    }
                }
            } else {
                VitalCardV2(elevation: .raised) {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "fork.knife")
                            .font(.vitalIconLarge)
                            .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)

                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("No food logged")
                                .font(.vitalLabelV2)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                            Text("Tap to log your first meal")
                                .font(.vitalCaptionV2)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.vitalIconSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
                    }
                }
            }
        }
    }

    private func macroBar(label: String, current: Double, target: Double, color: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            Text(label)
                .font(.vitalCaptionSmallV2)
                .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Spacing.radiusTinyV2)
                        .fill(Color.vitalSurfaceRaisedV2)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: Spacing.radiusTinyV2)
                        .fill(color)
                        .frame(width: min(geometry.size.width * (current / target), geometry.size.width), height: 6)
                }
            }
            .frame(height: 6)

            Text("\(Int(current))g")
                .font(.vitalUnitV2)
                .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Quick Actions")
                .font(.vitalH3V2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)

            HStack(spacing: Spacing.md) {
                quickActionButton(icon: "plus.circle.fill", label: "Log Workout", color: .vitalPrimaryV2)
                quickActionButton(icon: "fork.knife.circle.fill", label: "Log Food", color: .vitalAccentV2)
                quickActionButton(icon: "chart.line.uptrend.xyaxis.circle.fill", label: "View Progress", color: .vitalSuccessV2)
            }
        }
    }

    private func quickActionButton(icon: String, label: String, color: Color) -> some View {
        VitalCardV2(elevation: .raised, isTappable: true) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.vitalIconLarge)
                    .foregroundStyle(color)
                Text(label)
                    .font(.vitalCaptionV2)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
        }
    }

    // MARK: - Helper Views

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: Spacing.xxs) {
            Text(value)
                .font(.vitalDataMediumV2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
            Text(label)
                .font(.vitalCaptionSmallV2)
                .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
        }
    }

    // MARK: - Helper Methods

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    // MARK: - Data Loading

    @MainActor
    private func loadTodayData() async {
        isLoading = true
        defer { isLoading = false }

        guard let container = container else { return }

        // Load health metrics using use case
        do {
            let getHealthMetricsUseCase = GetHealthMetricsUseCase(repository: container.healthRepository)
            healthMetrics = try await getHealthMetricsUseCase.execute(for: selectedDate)
        } catch {
            Log.error("Failed to load health metrics", error: error, category: .healthKit)
        }

        // Load today's workout using use case
        do {
            let getTodayWorkoutsUseCase = GetTodayWorkoutsUseCase(repository: container.workoutRepository)
            let workouts = try await getTodayWorkoutsUseCase.execute(for: selectedDate)
            todaysWorkout = workouts.first
        } catch {
            Log.error("Failed to load workouts", error: error, category: .workout)
        }

        // Load nutrition
        do {
            let calculateUseCase = CalculateNutritionUseCase(repository: container.nutritionRepository)
            dailyNutrition = try await calculateUseCase.execute(for: selectedDate)
        } catch {
            Log.error("Failed to load nutrition", error: error, category: .nutrition)
        }
    }
}

#Preview {
    TodayDashboardView()
}
