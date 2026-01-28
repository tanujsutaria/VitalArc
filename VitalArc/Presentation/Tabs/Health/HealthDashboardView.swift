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

    // MARK: - Initialization

    init(healthRepository: HealthRepository) {
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
        }
    }

    // MARK: - Content Views

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: Spacing.sectionSpacing) {
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
                        sparklineData: getSparklineData(for: \.heartRateVariability)
                    )
                }

                if let heartRate = metrics.restingHeartRate {
                    MetricCard(
                        title: "Resting HR",
                        value: String(format: "%.0f", heartRate),
                        unit: "BPM",
                        icon: "waveform.path.ecg",
                        color: .vitalAccent,
                        sparklineData: getSparklineData(for: \.restingHeartRate)
                    )
                }

                if let steps = metrics.steps {
                    MetricCard(
                        title: "Steps",
                        value: formatNumber(steps),
                        unit: "steps",
                        icon: "figure.walk",
                        color: .vitalInfo,
                        sparklineData: viewModel.weekMetrics.compactMap { $0.steps.map(Double.init) }
                    )
                }

                if let energy = metrics.activeEnergy {
                    MetricCard(
                        title: "Active Energy",
                        value: String(format: "%.0f", energy),
                        unit: "kcal",
                        icon: "flame.fill",
                        color: .vitalWarning,
                        sparklineData: getSparklineData(for: \.activeEnergy)
                    )
                }

                if let sleep = metrics.sleepHours {
                    MetricCard(
                        title: "Sleep",
                        value: String(format: "%.1f", sleep),
                        unit: "hours",
                        icon: "bed.double.fill",
                        color: .vitalSecondary,
                        sparklineData: getSparklineData(for: \.sleepHours)
                    )
                }

                if let weight = metrics.weight {
                    MetricCard(
                        title: "Weight",
                        value: String(format: "%.1f", UnitConversion.kgToLbs(weight)),
                        unit: "lbs",
                        icon: "scalemass.fill",
                        color: .vitalSuccess,
                        sparklineData: getWeightSparklineData()
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
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Recovery Status")
                        .font(.vitalBodySmall)
                        .foregroundStyle(.white.opacity(0.9))

                    Text(recovery.rawValue)
                        .font(.vitalH2)
                        .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: recoveryIcon(recovery))
                    .font(.system(size: Spacing.iconXLarge))
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
                        .font(.system(size: Spacing.iconHuge))
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
                        .font(.system(size: Spacing.iconHuge))
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
