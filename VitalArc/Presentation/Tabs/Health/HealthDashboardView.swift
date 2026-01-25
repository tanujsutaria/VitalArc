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
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        loadingView
                    } else if let error = viewModel.error {
                        errorView(error)
                    } else {
                        contentView
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Health")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
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
        VStack(spacing: 20) {
            // Today's metrics section
            if let today = viewModel.todayMetrics {
                todayMetricsSection(today)
            } else {
                emptyStateView
            }

            // Weekly trends section
            if !viewModel.weekMetrics.isEmpty {
                weeklyTrendsSection
            }
        }
    }

    // MARK: - Today's Metrics

    private func todayMetricsSection(_ metrics: HealthMetrics) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today")
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                if let hrv = metrics.heartRateVariability {
                    MetricCardView(
                        title: "HRV",
                        value: String(format: "%.0f", hrv),
                        unit: "ms",
                        icon: "heart.fill",
                        color: .red
                    )
                }

                if let heartRate = metrics.restingHeartRate {
                    MetricCardView(
                        title: "Resting HR",
                        value: String(format: "%.0f", heartRate),
                        unit: "BPM",
                        icon: "waveform.path.ecg",
                        color: .pink
                    )
                }

                if let steps = metrics.steps {
                    MetricCardView(
                        title: "Steps",
                        value: formatNumber(steps),
                        unit: "steps",
                        icon: "figure.walk",
                        color: .blue
                    )
                }

                if let energy = metrics.activeEnergy {
                    MetricCardView(
                        title: "Active Energy",
                        value: String(format: "%.0f", energy),
                        unit: "kcal",
                        icon: "flame.fill",
                        color: .orange
                    )
                }

                if let sleep = metrics.sleepHours {
                    MetricCardView(
                        title: "Sleep",
                        value: String(format: "%.1f", sleep),
                        unit: "hours",
                        icon: "bed.double.fill",
                        color: .purple
                    )
                }

                if let weight = metrics.weight {
                    MetricCardView(
                        title: "Weight",
                        value: String(format: "%.1f", weight),
                        unit: "kg",
                        icon: "scalemass.fill",
                        color: .green
                    )
                }
            }

            // Recovery indicator
            if let recovery = metrics.recoveryIndicator {
                recoveryIndicatorView(recovery)
            }
        }
    }

    // MARK: - Weekly Trends

    private var weeklyTrendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Trends")
                .font(.title2)
                .fontWeight(.bold)

            // HRV Chart
            if !viewModel.weekMetrics.compactMap({ $0.heartRateVariability }).isEmpty {
                ChartView(
                    title: "Heart Rate Variability",
                    data: viewModel.weekMetrics.compactMap { metrics in
                        guard let hrv = metrics.heartRateVariability else { return nil }
                        return ChartDataPoint(date: metrics.date, value: hrv)
                    },
                    color: .red,
                    unit: "ms"
                )
            }

            // Steps Chart
            if !viewModel.weekMetrics.compactMap({ $0.steps }).isEmpty {
                ChartView(
                    title: "Daily Steps",
                    data: viewModel.weekMetrics.compactMap { metrics in
                        guard let steps = metrics.steps else { return nil }
                        return ChartDataPoint(date: metrics.date, value: Double(steps))
                    },
                    color: .blue,
                    unit: "steps"
                )
            }

            // Sleep Chart
            if !viewModel.weekMetrics.compactMap({ $0.sleepHours }).isEmpty {
                ChartView(
                    title: "Sleep Duration",
                    data: viewModel.weekMetrics.compactMap { metrics in
                        guard let sleep = metrics.sleepHours else { return nil }
                        return ChartDataPoint(date: metrics.date, value: sleep)
                    },
                    color: .purple,
                    unit: "hours"
                )
            }

            // Weekly summary
            weeklySummaryView
        }
    }

    // MARK: - Recovery Indicator

    private func recoveryIndicatorView(_ recovery: RecoveryLevel) -> some View {
        HStack {
            Image(systemName: "figure.mind.and.body")
                .font(.title2)
                .foregroundStyle(recoveryColor(recovery))

            VStack(alignment: .leading, spacing: 4) {
                Text("Recovery Status")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(recovery.rawValue)
                    .font(.headline)
                    .foregroundStyle(recoveryColor(recovery))
            }

            Spacer()
        }
        .padding()
        .background(recoveryColor(recovery).opacity(0.1))
        .cornerRadius(12)
    }

    private func recoveryColor(_ recovery: RecoveryLevel) -> Color {
        switch recovery {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        }
    }

    // MARK: - Weekly Summary

    private var weeklySummaryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Summary")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                if let avgHRV = viewModel.averageHRV {
                    GridRow {
                        Text("Avg HRV:")
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.0f ms", avgHRV))
                            .fontWeight(.medium)
                    }
                }

                if let avgHR = viewModel.averageHeartRate {
                    GridRow {
                        Text("Avg Resting HR:")
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.0f BPM", avgHR))
                            .fontWeight(.medium)
                    }
                }

                if let avgSteps = viewModel.averageSteps {
                    GridRow {
                        Text("Avg Steps:")
                            .foregroundStyle(.secondary)
                        Text("\(formatNumber(avgSteps)) steps")
                            .fontWeight(.medium)
                    }
                }

                if viewModel.totalActiveEnergy > 0 {
                    GridRow {
                        Text("Total Active Energy:")
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.0f kcal", viewModel.totalActiveEnergy))
                            .fontWeight(.medium)
                    }
                }

                if let avgSleep = viewModel.averageSleepHours {
                    GridRow {
                        Text("Avg Sleep:")
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.1f hours", avgSleep))
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Health Data")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Sync your HealthKit data to see your health metrics here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await viewModel.requestHealthKitPermissions()
                }
            } label: {
                Label("Enable HealthKit", systemImage: "heart.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading health data...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }

    // MARK: - Error View

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Error Loading Data")
                .font(.title2)
                .fontWeight(.semibold)

            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await viewModel.refresh()
                }
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }

    // MARK: - Helpers

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Preview

#Preview {
    HealthDashboardView(healthRepository: MockHealthRepository())
}
