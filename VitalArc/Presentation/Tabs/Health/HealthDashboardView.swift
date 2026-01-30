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

    init(healthRepository: HealthRepository) {
        self.healthRepository = healthRepository
        self._viewModel = State(initialValue: HealthDashboardViewModel(healthRepository: healthRepository))
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

    // MARK: - Helpers for Metric Values

    private func getCurrentValue(for metric: HealthMetricType) -> Double {
        guard let today = viewModel.todayMetrics else { return 0 }

        switch metric {
        case .hrv:
            return today.heartRateVariability ?? 0
        case .restingHR:
            return today.restingHeartRate ?? 0
        case .steps:
            return Double(today.steps ?? 0)
        case .activeEnergy:
            return today.activeEnergy ?? 0
        case .sleep:
            return today.sleepHours ?? 0
        case .weight:
            return UnitConversion.kgToLbs(today.weight ?? 0)
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
                // Recovery Score
                ScoreRingView(
                    score: calculateRecoveryScore(metrics),
                    title: "Recovery",
                    subtitle: recoveryLabel(calculateRecoveryScore(metrics)),
                    gradient: Color.vitalSuccessGradient,
                    size: 90,
                    lineWidth: 8
                )

                // Sleep Score
                ScoreRingView(
                    score: calculateSleepScore(metrics),
                    title: "Sleep",
                    subtitle: sleepLabel(calculateSleepScore(metrics)),
                    gradient: Color.vitalAccentGradient,
                    size: 90,
                    lineWidth: 8
                )

                // Activity Score
                ScoreRingView(
                    score: calculateActivityScore(metrics),
                    title: "Activity",
                    subtitle: activityLabel(calculateActivityScore(metrics)),
                    gradient: Color.vitalInfoGradient,
                    size: 90,
                    lineWidth: 8
                )
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Score Calculations

    private func calculateRecoveryScore(_ metrics: HealthMetrics) -> Double {
        // Recovery based on HRV and resting HR
        var score: Double = 50 // Base score

        if let hrv = metrics.heartRateVariability {
            // HRV: Higher is generally better
            // Typical range: 20-100ms
            let hrvScore = min((hrv / 80) * 50, 50)
            score = hrvScore
        }

        if let rhr = metrics.restingHeartRate {
            // RHR: Lower is generally better for athletes
            // Typical range: 50-80 BPM
            let rhrScore = max(0, min((80 - rhr) / 30 * 30, 30))
            score += rhrScore
        }

        return min(max(score, 0), 100)
    }

    private func calculateSleepScore(_ metrics: HealthMetrics) -> Double {
        guard let sleepHours = metrics.sleepHours else { return 0 }
        // Target: 7-9 hours
        if sleepHours >= 7 && sleepHours <= 9 {
            return min(100, 80 + (sleepHours - 7) * 10)
        } else if sleepHours < 7 {
            return max(0, (sleepHours / 7) * 80)
        } else {
            // More than 9 hours, slightly diminishing returns
            return max(70, 90 - (sleepHours - 9) * 10)
        }
    }

    private func calculateActivityScore(_ metrics: HealthMetrics) -> Double {
        var score: Double = 0

        // Steps contribution (target: 10,000)
        if let steps = metrics.steps {
            score += min(Double(steps) / 10000 * 50, 50)
        }

        // Active energy contribution (target: 500 kcal)
        if let energy = metrics.activeEnergy {
            score += min(energy / 500 * 50, 50)
        }

        return min(score, 100)
    }

    private func recoveryLabel(_ score: Double) -> String {
        switch score {
        case 0..<30: return "Poor"
        case 30..<50: return "Fair"
        case 50..<70: return "Good"
        case 70..<85: return "Great"
        default: return "Excellent"
        }
    }

    private func sleepLabel(_ score: Double) -> String {
        switch score {
        case 0..<50: return "Poor"
        case 50..<70: return "Fair"
        case 70..<85: return "Good"
        default: return "Excellent"
        }
    }

    private func activityLabel(_ score: Double) -> String {
        switch score {
        case 0..<30: return "Low"
        case 30..<50: return "Light"
        case 50..<70: return "Moderate"
        case 70..<85: return "Active"
        default: return "High"
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
            }

            // Recovery indicator
            if let recovery = metrics.recoveryIndicator {
                recoveryIndicatorView(recovery)
                    .transition(.vitalScale)
            }
        }
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
                        .frame(width: 100, height: 100)

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
                        .frame(width: 100, height: 100)

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
