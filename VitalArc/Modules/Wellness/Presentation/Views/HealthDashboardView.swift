//
//  HealthDashboardView.swift
//  VitalArc
//
//  Main health dashboard view
//

import SwiftUI

struct HealthDashboardView: View {

    // MARK: - Properties

    @State private var viewModel: HealthDashboardViewModel
    @State private var selectedMetric: HealthMetricType?

    private let healthRepository: HealthRepository

    // MARK: - Initialization

    init(healthRepository: HealthRepository, importHealthKitWorkoutsUseCase: ImportHealthKitWorkoutsUseCase? = nil) {
        self.healthRepository = healthRepository
        self._viewModel = State(initialValue: HealthDashboardViewModel(
            healthRepository: healthRepository,
            importHealthKitWorkoutsUseCase: importHealthKitWorkoutsUseCase
        ))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    if viewModel.isLoading {
                        loadingView
                    } else if let error = viewModel.error {
                        errorView(error)
                    } else {
                        contentView
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle("Health")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    VitalIconButton(
                        icon: "arrow.clockwise",
                        style: .outline,
                        size: 36
                    ) {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    .accessibilityLabel("Refresh health data")
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadAllMetrics()
            }
            .alert("HealthKit Access Required", isPresented: $viewModel.showingPermissionAlert) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please grant access to HealthKit in Settings to view your health data.")
            }
            .sheet(item: $selectedMetric) { metric in
                if metric == .sleep {
                    SleepDetailSheet(
                        sleepHours: viewModel.todayMetrics?.sleepHours ?? 0,
                        sleepStages: viewModel.todayMetrics?.sleepStages,
                        sleepTrend: viewModel.weekMetrics.compactMap { metrics in
                            guard let sleep = metrics.sleepHours else { return nil }
                            return SleepTrendData(
                                date: metrics.date,
                                totalHours: sleep,
                                deepSleepHours: metrics.sleepStages?.deepSleep,
                                remSleepHours: metrics.sleepStages?.remSleep,
                                lightSleepHours: metrics.sleepStages?.coreSleep
                            )
                        },
                        sleepConsistency: viewModel.sleepConsistency
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                } else {
                    MetricDetailSheet(
                        metricType: metric,
                        currentValue: getCurrentValue(for: metric),
                        healthRepository: healthRepository
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            }
        }
    }

    // MARK: - Helpers for Metric Values

    /// Returns the current value for a metric, or -1 if no data is available
    private func getCurrentValue(for metric: HealthMetricType) -> Double {
        guard let today = viewModel.todayMetrics else { return -1 }

        switch metric {
        case .hrv:
            return today.heartRateVariability ?? -1
        case .restingHR:
            return today.restingHeartRate ?? -1
        case .steps:
            guard let steps = today.steps else { return -1 }
            return Double(steps)
        case .activeEnergy:
            return today.activeEnergy ?? -1
        case .sleep:
            return today.sleepHours ?? -1
        case .weight:
            guard let w = today.weight else { return -1 }
            return UnitConversion.kgToLbs(w)
        case .bodyFat:
            return today.bodyFatPercentage ?? -1
        case .leanBodyMass:
            guard let lbm = today.leanBodyMass else { return -1 }
            return UnitConversion.kgToLbs(lbm)
        case .respiratoryRate:
            return today.respiratoryRate ?? -1
        case .spo2:
            return today.oxygenSaturation ?? -1
        case .vo2Max:
            return today.vo2Max ?? -1
        case .hydration:
            guard let water = today.waterIntake else { return -1 }
            return water * 0.033814 // mL to fl oz
        }
    }

    // MARK: - Content Views

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: Spacing.sectionSpacing) {
            // Score rings section (Recovery & Sleep)
            if let today = viewModel.todayMetrics {
                scoreRingsSection(today)
                    .transition(.vitalScale)
            }

            // SpO2 warning banner
            if viewModel.isSpO2Low {
                spo2WarningBanner
                    .transition(.vitalScale)
            }

            // HRV Tracking section
            if viewModel.todayMetrics?.heartRateVariability != nil || !viewModel.hrvTrendData7Day.isEmpty {
                VitalCard {
                    HRVTrendView(
                        currentHRV: viewModel.todayMetrics?.heartRateVariability,
                        baseline: viewModel.hrvBaseline,
                        isAboveBaseline: viewModel.isHRVAboveBaseline,
                        deviationSignificant: viewModel.hrvDeviationSignificant,
                        statusText: viewModel.hrvStatusText,
                        trendData7Day: viewModel.hrvTrendData7Day,
                        trendData30Day: viewModel.hrvTrendData30Day,
                        sleepCorrelationHint: viewModel.hrvSleepCorrelationHint
                    )
                }
                .transition(.vitalSlideUp)
            }

            // Stress Analysis section
            if let stress = viewModel.stressAnalysis {
                VitalCard {
                    StressAnalysisView(analysis: stress)
                }
                .transition(.vitalSlideUp)
            }

            // Today's metrics section
            if let today = viewModel.todayMetrics {
                todayMetricsSection(today)
                    .transition(.vitalSlideUp)
            } else {
                emptyStateView
            }

            // Weekly trends section
            if !viewModel.weekMetrics.isEmpty {
                weeklyTrendsSection
                    .transition(.vitalSlideUp)
            }
        }
        .animation(.vitalSpring, value: viewModel.todayMetrics != nil)
    }

    // MARK: - Score Rings

    private func scoreRingsSection(_ metrics: HealthMetrics) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Today's Scores")
                .font(.vitalDisplaySmall)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            HStack(spacing: Spacing.md) {
                // Readiness Score (from personalized baselines use case)
                if let readiness = viewModel.readinessScore {
                    ScoreRingView(
                        score: readiness.overallScore,
                        title: "Readiness",
                        subtitle: readiness.level.rawValue,
                        gradient: Color.vitalSuccessGradient,
                        size: 90,
                        lineWidth: 8
                    )
                }

                // Sleep Score
                if let sleep = viewModel.sleepScore {
                    ScoreRingView(
                        score: sleep.value,
                        title: "Sleep",
                        subtitle: sleep.label,
                        gradient: Color.vitalAccentGradient,
                        size: 90,
                        lineWidth: 8
                    )
                }

                // Activity Score
                if let activity = viewModel.activityScore {
                    ScoreRingView(
                        score: activity.value,
                        title: "Activity",
                        subtitle: activity.label,
                        gradient: Color.vitalInfoGradient,
                        size: 90,
                        lineWidth: 8
                    )
                }
            }
            .frame(maxWidth: .infinity)

            // Readiness recommendation
            if let readiness = viewModel.readinessScore {
                readinessRecommendationView(readiness)
            }
        }
    }

    // MARK: - Readiness Recommendation

    private func readinessRecommendationView(_ readiness: ReadinessScore) -> some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "brain.head.profile")
                        .font(.vitalIconMedium)
                        .foregroundStyle(readinessColor(readiness.level))

                    Text("Readiness Insight")
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Spacer()

                    // Level badge
                    Text(readiness.level.rawValue)
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xxs)
                        .background(readinessColor(readiness.level))
                        .cornerRadius(Spacing.radiusSmall)

                    // Trend arrow
                    Image(systemName: trendIcon(readiness.trend))
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(trendColor(readiness.trend))
                }

                Text(readiness.result?.recommendation ?? readiness.recommendation)
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                // Contribution breakdown
                HStack(spacing: Spacing.md) {
                    contributionPill("HRV", value: readiness.hrvContribution, max: 40)
                    contributionPill("RHR", value: readiness.rhrContribution, max: 25)
                    contributionPill("Quality", value: readiness.sleepQualityContribution, max: 20)
                    contributionPill("Duration", value: readiness.sleepDurationContribution, max: 15)
                }
                .padding(.top, Spacing.xs)
            }
        }
    }

    private func trendIcon(_ trend: ReadinessTrend) -> String {
        switch trend {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }

    private func trendColor(_ trend: ReadinessTrend) -> Color {
        switch trend {
        case .improving: return .vitalSuccess
        case .stable: return .vitalAdaptiveTextSecondary
        case .declining: return .vitalDanger
        }
    }

    private func contributionPill(_ label: String, value: Double, max: Double) -> some View {
        VStack(spacing: Spacing.xxs) {
            Text(label)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            Text(String(format: "%.0f", value))
                .font(.vitalLabelSmall)
                .foregroundStyle(value / max > 0.6 ? Color.vitalSuccess : Color.vitalWarning)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) contribution")
        .accessibilityValue(String(format: "%.0f out of %.0f", value, max))
    }

    private func readinessColor(_ level: ReadinessLevel) -> Color {
        switch level {
        case .optimal: return .vitalSuccess
        case .good: return .vitalInfo
        case .moderate: return .vitalWarning
        case .low: return .vitalWarning
        case .rest: return .vitalDanger
        }
    }

    // MARK: - Today's Metrics

    private func todayMetricsSection(_ metrics: HealthMetrics) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Today")
                .font(.vitalDisplaySmall)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                if let hrv = metrics.heartRateVariability {
                    MetricCard(
                        title: "HRV",
                        value: String(format: "%.0f", hrv),
                        unit: "ms",
                        icon: "heart.fill",
                        color: .vitalDanger,
                        sparklineData: getSparklineData(for: \.heartRateVariability),
                        onTap: { selectedMetric = .hrv }
                    )
                }

                if let heartRate = metrics.restingHeartRate {
                    MetricCard(
                        title: "Resting HR",
                        value: String(format: "%.0f", heartRate),
                        unit: "BPM",
                        icon: "waveform.path.ecg",
                        color: .vitalAccent,
                        sparklineData: getSparklineData(for: \.restingHeartRate),
                        onTap: { selectedMetric = .restingHR }
                    )
                }

                if let steps = metrics.steps {
                    MetricCard(
                        title: "Steps",
                        value: formatNumber(steps),
                        unit: "steps",
                        icon: "figure.walk",
                        color: .vitalInfo,
                        sparklineData: viewModel.weekMetrics.compactMap { $0.steps.map(Double.init) },
                        onTap: { selectedMetric = .steps }
                    )
                }

                if let energy = metrics.activeEnergy {
                    MetricCard(
                        title: "Active Energy",
                        value: String(format: "%.0f", energy),
                        unit: "kcal",
                        icon: "flame.fill",
                        color: .vitalWarning,
                        sparklineData: getSparklineData(for: \.activeEnergy),
                        onTap: { selectedMetric = .activeEnergy }
                    )
                }

                if let sleep = metrics.sleepHours {
                    MetricCard(
                        title: "Sleep",
                        value: String(format: "%.1f", sleep),
                        unit: "hours",
                        icon: "bed.double.fill",
                        color: .vitalSecondary,
                        sparklineData: getSparklineData(for: \.sleepHours),
                        onTap: { selectedMetric = .sleep }
                    )
                }

                if let weight = metrics.weight {
                    MetricCard(
                        title: "Weight",
                        value: String(format: "%.1f", UnitConversion.kgToLbs(weight)),
                        unit: "lbs",
                        icon: "scalemass.fill",
                        color: .vitalSuccess,
                        sparklineData: getWeightSparklineData(),
                        onTap: { selectedMetric = .weight }
                    )
                }

                if let bodyFat = metrics.bodyFatPercentage {
                    MetricCard(
                        title: "Body Fat",
                        value: String(format: "%.1f", bodyFat),
                        unit: "%",
                        icon: "figure.arms.open",
                        color: .vitalWarning,
                        sparklineData: getSparklineData(for: \.bodyFatPercentage),
                        onTap: { selectedMetric = .bodyFat }
                    )
                }

                if let leanMass = metrics.leanBodyMass {
                    MetricCard(
                        title: "Lean Mass",
                        value: String(format: "%.1f", UnitConversion.kgToLbs(leanMass)),
                        unit: "lbs",
                        icon: "figure.strengthtraining.traditional",
                        color: .vitalInfo,
                        sparklineData: viewModel.weekMetrics.compactMap { $0.leanBodyMass.map { UnitConversion.kgToLbs($0) } },
                        onTap: { selectedMetric = .leanBodyMass }
                    )
                }

                if let respRate = metrics.respiratoryRate {
                    MetricCard(
                        title: "Respiratory",
                        value: String(format: "%.0f", respRate),
                        unit: "brpm",
                        icon: "lungs.fill",
                        color: .vitalAccent,
                        sparklineData: getSparklineData(for: \.respiratoryRate),
                        onTap: { selectedMetric = .respiratoryRate }
                    )
                }

                if let spo2 = metrics.oxygenSaturation {
                    MetricCard(
                        title: "Blood Oxygen",
                        value: String(format: "%.0f", spo2),
                        unit: "%",
                        icon: viewModel.isSpO2Low ? "exclamationmark.triangle.fill" : "lungs.fill",
                        color: viewModel.isSpO2Critical ? .vitalDanger : (viewModel.isSpO2Low ? .vitalWarning : .vitalInfo),
                        sparklineData: getSparklineData(for: \.oxygenSaturation),
                        onTap: { selectedMetric = .spo2 }
                    )
                }

                if let vo2Max = metrics.vo2Max {
                    MetricCard(
                        title: "VO2 Max",
                        value: String(format: "%.1f", vo2Max),
                        unit: "mL/kg/min",
                        icon: "figure.run",
                        color: .vitalSuccess,
                        sparklineData: getSparklineData(for: \.vo2Max)
                    )
                }

                if let water = metrics.waterIntake {
                    MetricCard(
                        title: "Hydration",
                        value: String(format: "%.0f", water * 0.033814),
                        unit: "fl oz",
                        icon: "drop.fill",
                        color: .vitalInfo,
                        sparklineData: viewModel.weekMetrics.compactMap { $0.waterIntake.map { $0 * 0.033814 } },
                        onTap: { selectedMetric = .hydration }
                    )
                }
            }

            // Recovery indicator
            if let recovery = metrics.recoveryIndicator {
                recoveryIndicatorView(recovery)
                    .transition(.vitalScale)
            }
        }
    }

    // MARK: - SpO2 Warning

    private var spo2WarningBanner: some View {
        let isCritical = viewModel.isSpO2Critical
        let spo2Value = viewModel.todayMetrics?.oxygenSaturation ?? 0

        return VitalCard {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill((isCritical ? Color.vitalDanger : Color.vitalWarning).opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.vitalIconMedium)
                        .foregroundStyle(isCritical ? Color.vitalDanger : Color.vitalWarning)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(isCritical ? "Critically Low Blood Oxygen" : "Low Blood Oxygen")
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text("SpO2 is \(String(format: "%.0f", spo2Value))% — \(isCritical ? "seek medical attention if symptoms persist" : "normal range is 95-100%")")
                        .font(.vitalBodySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                Spacer()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isCritical ? "Critical: Blood oxygen is \(String(format: "%.0f", spo2Value)) percent" : "Warning: Blood oxygen is \(String(format: "%.0f", spo2Value)) percent")
    }

    // MARK: - Weekly Trends

    private var weeklyTrendsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Weekly Trends")
                .font(.vitalDisplaySmall)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            // HRV Chart
            if !viewModel.weekMetrics.compactMap({ $0.heartRateVariability }).isEmpty {
                VitalLineChart(
                    title: "Heart Rate Variability",
                    data: viewModel.weekMetrics.compactMap { metrics in
                        guard let hrv = metrics.heartRateVariability else { return nil }
                        return ChartDataPoint(date: metrics.date, value: hrv)
                    },
                    color: .vitalDanger,
                    unit: "ms"
                )
                .transition(.vitalSlideUp)
            }

            // Steps Chart
            if !viewModel.weekMetrics.compactMap({ $0.steps }).isEmpty {
                VitalBarChart(
                    title: "Daily Steps",
                    data: viewModel.weekMetrics.compactMap { metrics in
                        guard let steps = metrics.steps else { return nil }
                        return ChartDataPoint(date: metrics.date, value: Double(steps))
                    },
                    color: .vitalInfo,
                    unit: "steps"
                )
                .transition(.vitalSlideUp)
            }

            // Sleep Chart
            if !viewModel.weekMetrics.compactMap({ $0.sleepHours }).isEmpty {
                VitalLineChart(
                    title: "Sleep Duration",
                    data: viewModel.weekMetrics.compactMap { metrics in
                        guard let sleep = metrics.sleepHours else { return nil }
                        return ChartDataPoint(date: metrics.date, value: sleep)
                    },
                    color: .vitalSecondary,
                    unit: "hours"
                )
                .transition(.vitalSlideUp)
            }

            // Weekly summary
            weeklySummaryView
                .transition(.vitalScale)
        }
    }

    // MARK: - Recovery Indicator

    private func recoveryIndicatorView(_ recovery: RecoveryLevel) -> some View {
        VitalGradientCard(
            gradient: LinearGradient(
                colors: [recoveryColor(recovery), recoveryColor(recovery).opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 48, height: 48)

                    Image(systemName: "figure.mind.and.body")
                        .font(.vitalIconLargeSemibold)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Recovery Status")
                        .font(.vitalBodySmall)
                        .foregroundStyle(.white.opacity(0.9))

                    Text(recovery.rawValue)
                        .font(.vitalH2)
                        .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: recoveryIcon(recovery))
                    .font(.vitalIconXLarge)
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Recovery Status")
        .accessibilityValue(recovery.rawValue)
    }

    private func recoveryColor(_ recovery: RecoveryLevel) -> Color {
        switch recovery {
        case .excellent: return .vitalSuccess
        case .good: return .vitalInfo
        case .fair: return .vitalWarning
        case .poor: return .vitalDanger
        }
    }

    private func recoveryIcon(_ recovery: RecoveryLevel) -> String {
        switch recovery {
        case .excellent: return "star.fill"
        case .good: return "checkmark.circle.fill"
        case .fair: return "exclamationmark.triangle.fill"
        case .poor: return "xmark.circle.fill"
        }
    }

    // MARK: - Weekly Summary

    private var weeklySummaryView: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Weekly Summary")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Grid(alignment: .leading, horizontalSpacing: Spacing.md, verticalSpacing: Spacing.sm) {
                    if let avgHRV = viewModel.averageHRV {
                        GridRow {
                            Text("Avg HRV:")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(String(format: "%.0f ms", avgHRV))
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }
                    }

                    if let avgHR = viewModel.averageHeartRate {
                        GridRow {
                            Text("Avg Resting HR:")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(String(format: "%.0f BPM", avgHR))
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }
                    }

                    if let avgSteps = viewModel.averageSteps {
                        GridRow {
                            Text("Avg Steps:")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text("\(formatNumber(avgSteps)) steps")
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }
                    }

                    if viewModel.totalActiveEnergy > 0 {
                        GridRow {
                            Text("Total Active Energy:")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(String(format: "%.0f kcal", viewModel.totalActiveEnergy))
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }
                    }

                    if let avgSleep = viewModel.averageSleepHours {
                        GridRow {
                            Text("Avg Sleep:")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(String(format: "%.1f hours", avgSleep))
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(Color.vitalDanger.opacity(0.15))
                        .frame(width: Spacing.illustrationMedium, height: Spacing.illustrationMedium)

                    Image(systemName: "heart.text.square")
                        .font(.vitalIconHuge)
                        .foregroundStyle(Color.vitalDanger)
                }

                VStack(spacing: Spacing.sm) {
                    Text("No Health Data")
                        .font(.vitalDisplaySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text("Sync your HealthKit data to see your health metrics here.")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }

                VitalButton(
                    title: "Enable HealthKit",
                    style: .primary,
                    icon: "heart.fill",
                    fullWidth: true
                ) {
                    Task {
                        await viewModel.requestHealthKitPermissions()
                    }
                }
                .padding(.top, Spacing.sm)
                .accessibilityHint("Double tap to open HealthKit permissions")
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.vitalPrimary)

            Text("Loading health data...")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xxl)
    }

    // MARK: - Error View

    private func errorView(_ error: Error) -> some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(Color.vitalWarning.opacity(0.15))
                        .frame(width: Spacing.illustrationMedium, height: Spacing.illustrationMedium)

                    Image(systemName: "exclamationmark.triangle")
                        .font(.vitalIconHuge)
                        .foregroundStyle(Color.vitalWarning)
                }

                VStack(spacing: Spacing.sm) {
                    Text("Error Loading Data")
                        .font(.vitalDisplaySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text(error.localizedDescription)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }

                VitalButton(
                    title: "Try Again",
                    style: .primary,
                    icon: "arrow.clockwise",
                    fullWidth: true
                ) {
                    Task {
                        await viewModel.refresh()
                    }
                }
                .padding(.top, Spacing.sm)
            }
        }
    }

    // MARK: - Helpers

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    private func getSparklineData(for keyPath: KeyPath<HealthMetrics, Double?>) -> [Double]? {
        let data = viewModel.weekMetrics.compactMap { $0[keyPath: keyPath] }
        return data.isEmpty ? nil : data
    }

    private func getWeightSparklineData() -> [Double]? {
        let data = viewModel.weekMetrics.compactMap { $0.weight }.map { UnitConversion.kgToLbs($0) }
        return data.isEmpty ? nil : data
    }
}

// MARK: - Preview

@MainActor
private struct PreviewHealthRepository: HealthRepository {
    func getHealthMetrics(for date: Date) async throws -> HealthMetrics? { nil }
    func getHealthMetrics(from startDate: Date, to endDate: Date) async throws -> [HealthMetrics] { [] }
    func saveHealthMetrics(_ metrics: HealthMetrics) async throws {}
    func syncFromHealthKit() async throws {}
    func requestHealthKitAuthorization() async throws -> Bool { true }
}

#Preview {
    HealthDashboardView(healthRepository: PreviewHealthRepository())
}
