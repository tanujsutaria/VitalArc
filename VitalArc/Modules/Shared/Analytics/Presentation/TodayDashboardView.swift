//
//  TodayDashboardView.swift
//  VitalArc
//
//  Consolidated daily dashboard combining health, workout, and nutrition summaries
//

import SwiftUI

struct TodayDashboardView: View {
    @Environment(\.dependencyContainer) private var container
    @Environment(\.selectedTab) private var selectedTab
    @State private var viewModel: TodayDashboardViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    dashboardContent(viewModel)
                } else {
                    VStack(spacing: Spacing.md) {
                        VitalMetricCardSkeleton()
                        VitalMetricCardSkeleton()
                        VitalWorkoutCardSkeleton()
                    }
                    .padding(Spacing.screenPadding)
                }
            }
            .background(Color.vitalAdaptiveBackgroundV2)
            .navigationTitle("Today")
        }
        .task {
            if viewModel == nil, let container {
                viewModel = TodayDashboardViewModel(container: container)
            }
            await viewModel?.loadTodayData()
        }
    }

    @ViewBuilder
    private func dashboardContent(_ vm: TodayDashboardViewModel) -> some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Date Header
                dateHeader(vm)

                // Quick Stats Summary
                if vm.isLoading {
                    loadingSection
                } else {
                    // Recovery & Strain Section
                    recoveryStrainSection(vm)

                    // Today's Activity Section
                    activitySection(vm)

                    // Nutrition Summary Section
                    nutritionSection(vm)

                    // Quick Actions Section
                    quickActionsSection
                }
            }
            .padding(Spacing.screenPadding)
        }
        .refreshable {
            await vm.loadTodayData()
        }
        .onChange(of: vm.selectedDate) {
            Task {
                await vm.loadTodayData()
            }
        }
        .sheet(isPresented: Binding(
            get: { vm.showDatePicker },
            set: { vm.showDatePicker = $0 }
        )) {
            datePickerSheet(vm)
        }
    }

    // MARK: - Date Header

    private func dateHeader(_ vm: TodayDashboardViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(vm.selectedDate.formatted(.dateTime.weekday(.wide)))
                    .font(.vitalLabelV2)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)
                Text(vm.selectedDate.formatted(.dateTime.month().day()))
                    .font(.vitalDisplayMediumV2)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                    .onTapGesture {
                        vm.showDatePicker = true
                    }
            }
            Spacer()
            HStack(spacing: Spacing.sm) {
                Button {
                    vm.previousDay()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.vitalIconSmall)
                        .foregroundStyle(Color.vitalPrimaryV2)
                }
                .accessibilityLabel("Previous day")

                if !vm.isToday {
                    Button {
                        vm.goToToday()
                    } label: {
                        Text("Today")
                            .font(.vitalCaptionV2)
                            .foregroundStyle(Color.vitalPrimaryV2)
                    }
                    .accessibilityLabel("Go to today")
                }

                Button {
                    vm.nextDay()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.vitalIconSmall)
                        .foregroundStyle(vm.isToday ? Color.vitalAdaptiveTextTertiaryV2 : Color.vitalPrimaryV2)
                }
                .disabled(vm.isToday)
                .accessibilityLabel("Next day")
            }
        }
    }

    private func datePickerSheet(_ vm: TodayDashboardViewModel) -> some View {
        NavigationStack {
            DatePicker("Select Date", selection: Binding(
                get: { vm.selectedDate },
                set: { vm.selectedDate = $0 }
            ), in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color.vitalPrimaryV2)
                .padding(Spacing.screenPadding)
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            vm.showDatePicker = false
                        }
                    }
                }
        }
        .presentationDetents([.medium])
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

    private func recoveryStrainSection(_ vm: TodayDashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recovery & Strain")
                .font(.vitalH3V2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)

            HStack(spacing: Spacing.md) {
                // Recovery Score Card
                recoveryCard(vm)

                // Strain Score Card
                strainCard(vm)
            }
        }
    }

    private func recoveryCard(_ vm: TodayDashboardViewModel) -> some View {
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

                if let recovery = vm.recoveryScore, recovery.score > 0 {
                    Text("\(recovery.score)")
                        .font(.vitalNumberLargeV2)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                    Text(recovery.readiness.rawValue)
                        .font(.vitalCaptionV2)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
                } else if let metrics = vm.healthMetrics, let sleep = metrics.sleepHours {
                    Text("\(Int(sleep))h \(Int(sleep.truncatingRemainder(dividingBy: 1) * 60))m")
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Recovery")
        .accessibilityValue({
            if let recovery = vm.recoveryScore, recovery.score > 0 {
                return "\(recovery.score), \(recovery.readiness.rawValue)"
            } else if let metrics = vm.healthMetrics, let sleep = metrics.sleepHours {
                return "\(Int(sleep)) hours \(Int(sleep.truncatingRemainder(dividingBy: 1) * 60)) minutes sleep"
            }
            return "No data"
        }())
    }

    private func strainCard(_ vm: TodayDashboardViewModel) -> some View {
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

                if let strain = vm.strainResult {
                    Text(String(format: "%.1f", strain.strainScore))
                        .font(.vitalNumberLargeV2)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                    Text(strain.strainLevel.rawValue)
                        .font(.vitalCaptionV2)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
                } else if let metrics = vm.healthMetrics {
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Strain")
        .accessibilityValue({
            if let strain = vm.strainResult {
                return String(format: "%.1f, %@", strain.strainScore, strain.strainLevel.rawValue)
            } else if let metrics = vm.healthMetrics {
                return "\(Int(metrics.activeEnergy ?? 0)) kilocalories active"
            }
            return "No data"
        }())
    }

    // MARK: - Activity Section

    private func activitySection(_ vm: TodayDashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Today's Activity")
                    .font(.vitalH3V2)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                Spacer()
                if vm.todaysWorkout != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.vitalSuccessV2)
                }
            }

            if let workout = vm.todaysWorkout {
                workoutSummaryCard(workout, vm: vm)
            } else {
                noWorkoutCard
            }
        }
    }

    private func workoutSummaryCard(_ workout: Workout, vm: TodayDashboardViewModel) -> some View {
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
                        Text(vm.formatDuration(duration))
                            .font(.vitalDataMediumV2)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)
                    }
                }

                HStack(spacing: Spacing.lg) {
                    statItem(value: "\(workout.sets.count)", label: "Sets")
                    statItem(value: vm.formattedVolume(workout.totalVolume), label: "lbs Volume")
                }
            }
        }
    }

    private var noWorkoutCard: some View {
        Button {
            selectedTab.wrappedValue = 1
        } label: {
            VitalCardV2(elevation: .raised, isTappable: true) {
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
        .buttonStyle(.plain)
        .accessibilityLabel("No workout logged")
        .accessibilityHint("Double tap to start a workout")
    }

    // MARK: - Nutrition Section

    private func nutritionSection(_ vm: TodayDashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Nutrition")
                .font(.vitalH3V2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)

            if let nutrition = vm.dailyNutrition {
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
                Button {
                    selectedTab.wrappedValue = 2
                } label: {
                    VitalCardV2(elevation: .raised, isTappable: true) {
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
                .buttonStyle(.plain)
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
                        .frame(height: Spacing.progressBarHeight)

                    RoundedRectangle(cornerRadius: Spacing.radiusTinyV2)
                        .fill(color)
                        .frame(width: min(geometry.size.width * (current / target), geometry.size.width), height: Spacing.progressBarHeight)
                }
            }
            .frame(height: Spacing.progressBarHeight)

            Text("\(Int(current))g")
                .font(.vitalUnitV2)
                .foregroundStyle(Color.vitalAdaptiveTextTertiaryV2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue("\(Int(current)) of \(Int(target)) grams")
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Quick Actions")
                .font(.vitalH3V2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)

            HStack(spacing: Spacing.md) {
                quickActionButton(icon: "plus.circle.fill", label: "Log Workout", color: .vitalPrimaryV2, tab: 1)
                quickActionButton(icon: "fork.knife.circle.fill", label: "Log Food", color: .vitalAccentV2, tab: 2)
                quickActionButton(icon: "chart.line.uptrend.xyaxis.circle.fill", label: "View Progress", color: .vitalSuccessV2, tab: 3)
            }
        }
    }

    private func quickActionButton(icon: String, label: String, color: Color, tab: Int) -> some View {
        Button {
            selectedTab.wrappedValue = tab
        } label: {
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
                .frame(height: Spacing.quickActionCardHeight)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityHint("Double tap to navigate to \(label)")
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
}

#Preview {
    TodayDashboardView()
}
