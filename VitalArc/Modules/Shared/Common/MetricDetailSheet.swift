//
//  MetricDetailSheet.swift
//  VitalArc
//
//  Drill-down sheet for viewing detailed metric history and trends
//

import SwiftUI
import Charts

struct MetricDetailSheet: View {
    let metricType: HealthMetricType
    let currentValue: Double
    let healthRepository: HealthRepository

    @State private var selectedRange: MetricDetailViewModel.DateRange = .week
    @State private var viewModel: MetricDetailViewModel?
    @State private var hasAppeared = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Time range picker
                    dateRangePicker

                    if let viewModel = viewModel {
                        if viewModel.isLoading {
                            loadingView
                        } else if viewModel.historyData.isEmpty {
                            emptyStateView
                        } else {
                            // Current value highlight
                            currentValueCard

                            // Trend chart
                            chartSection(viewModel: viewModel)

                            // Summary statistics
                            summaryStatsCard(viewModel: viewModel)
                        }
                    } else {
                        loadingView
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle(metricType.chartTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.vitalIconMedium)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                    .accessibilityLabel("Close metric detail")
                }
            }
        }
        .task {
            viewModel = MetricDetailViewModel(healthRepository: healthRepository)
            await viewModel?.loadHistory(for: metricType, range: selectedRange)
            withAnimation(.vitalSpring.delay(0.2)) {
                hasAppeared = true
            }
        }
        .onChange(of: selectedRange) { _, newRange in
            Task {
                await viewModel?.loadHistory(for: metricType, range: newRange)
            }
        }
    }

    // MARK: - Date Range Picker

    private var dateRangePicker: some View {
        Picker("Time Range", selection: $selectedRange) {
            ForEach(MetricDetailViewModel.DateRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Current Value Card

    private var currentValueCard: some View {
        VitalGradientCard(
            gradient: LinearGradient(
                colors: [metricColor, metricColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: Spacing.avatarLargish, height: Spacing.avatarLargish)

                    Image(systemName: metricType.icon)
                        .font(.vitalIconLargeSemibold)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Current")
                        .font(.vitalBodySmall)
                        .foregroundStyle(.white.opacity(0.9))

                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        Text(formattedCurrentValue)
                            .font(.vitalNumberLarge)
                            .foregroundStyle(.white)

                        Text(metricType.unit)
                            .font(.vitalBody)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }

                Spacer()

                if let trend = viewModel?.trend {
                    trendBadge(trend)
                }
            }
        }
        .transition(.vitalScale)
        .opacity(hasAppeared ? 1 : 0)
    }

    // MARK: - Chart Section

    @ViewBuilder
    private func chartSection(viewModel: MetricDetailViewModel) -> some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("\(selectedRange.rawValue) Trend")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Spacer()
                }

                chartForMetricType(data: viewModel.historyData)
            }
        }
        .transition(.vitalSlideUp)
        .opacity(hasAppeared ? 1 : 0)
    }

    @ViewBuilder
    private func chartForMetricType(data: [ChartDataPoint]) -> some View {
        switch metricType {
        case .steps:
            // Bar chart for steps
            Chart(data) { point in
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [metricColor, metricColor.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(Spacing.radiusSmall)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel(format: selectedRange == .week ? .dateTime.weekday(.abbreviated) : .dateTime.day())
                    AxisGridLine()
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let val = value.as(Double.self) {
                            Text(formatAxisValue(val))
                                .font(.vitalCaptionSmall)
                        }
                    }
                    AxisGridLine()
                }
            }
            .frame(height: Spacing.chartHeightLarge)

        default:
            // Line chart for other metrics
            Chart(data) { point in
                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(metricColor)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))

                AreaMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [metricColor.opacity(0.3), metricColor.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(metricColor)
                .symbolSize(30)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel(format: selectedRange == .week ? .dateTime.weekday(.abbreviated) : .dateTime.day())
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let val = value.as(Double.self) {
                            Text(formatAxisValue(val))
                                .font(.vitalCaptionSmall)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                }
            }
            .frame(height: Spacing.chartHeightLarge)
        }
    }

    // MARK: - Summary Stats Card

    private func summaryStatsCard(viewModel: MetricDetailViewModel) -> some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Statistics")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                HStack(spacing: Spacing.lg) {
                    if let avg = viewModel.average {
                        statItem(title: "Average", value: formatValue(avg), color: metricColor)
                    }

                    if let min = viewModel.minimum {
                        Divider().frame(height: Spacing.xl)
                        statItem(title: "Minimum", value: formatValue(min), color: .vitalAdaptiveTextSecondary)
                    }

                    if let max = viewModel.maximum {
                        Divider().frame(height: Spacing.xl)
                        statItem(title: "Maximum", value: formatValue(max), color: .vitalAdaptiveTextSecondary)
                    }

                    Spacer()
                }
            }
        }
        .transition(.vitalSlideUp)
        .opacity(hasAppeared ? 1 : 0)
    }

    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xxs) {
                Text(value)
                    .font(.vitalLabel)
                    .foregroundStyle(color)
                Text(metricType.unit)
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }
    }

    // MARK: - Trend Badge

    private func trendBadge(_ trend: TrendDirection) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: trend.icon)
                .font(.vitalLabelSmall)
            Text(trend.description)
                .font(.vitalLabelSmall)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(.white.opacity(0.2))
        .cornerRadius(Spacing.radiusSmall)
    }

    // MARK: - Loading & Empty States

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(metricColor)

            Text("Loading data...")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xxl)
    }

    private var emptyStateView: some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(metricColor.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: metricType.icon)
                        .font(.vitalIcon2XLarge)
                        .foregroundStyle(metricColor)
                }

                VStack(spacing: Spacing.sm) {
                    Text("No Data Available")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text("No \(metricType.rawValue.lowercased()) data found for the selected time range.")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    // MARK: - Helpers

    private var metricColor: Color {
        switch metricType.colorName {
        case "danger": return .vitalDanger
        case "accent": return .vitalAccent
        case "info": return .vitalInfo
        case "warning": return .vitalWarning
        case "secondary": return .vitalSecondary
        case "success": return .vitalSuccess
        default: return .vitalPrimary
        }
    }

    private var formattedCurrentValue: String {
        guard currentValue >= 0, currentValue.isFinite else { return "--" }
        switch metricType {
        case .steps:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: Int(currentValue))) ?? "\(Int(currentValue))"
        case .sleep, .weight, .leanBodyMass, .bodyFat:
            return String(format: "%.1f", currentValue)
        default:
            return String(format: "%.0f", currentValue)
        }
    }

    private func formatValue(_ value: Double) -> String {
        switch metricType {
        case .steps:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: Int(value))) ?? "\(Int(value))"
        case .sleep, .weight, .leanBodyMass, .bodyFat:
            return String(format: "%.1f", value)
        default:
            return String(format: "%.0f", value)
        }
    }

    private func formatAxisValue(_ value: Double) -> String {
        switch metricType {
        case .steps:
            if value >= 1000 {
                return String(format: "%.0fk", value / 1000)
            }
            return String(format: "%.0f", value)
        case .activeEnergy:
            return String(format: "%.0f", value)
        default:
            return String(format: "%.0f", value)
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewContainer: View {
        var body: some View {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    MetricDetailSheet(
                        metricType: .hrv,
                        currentValue: 65,
                        healthRepository: PreviewHealthRepository()
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
        }
    }

    return PreviewContainer()
}

@MainActor
private struct PreviewHealthRepository: HealthRepository {
    func getHealthMetrics(for date: Date) async throws -> HealthMetrics? { nil }
    func getHealthMetrics(from startDate: Date, to endDate: Date) async throws -> [HealthMetrics] {
        // Generate sample data
        let calendar = Calendar.current
        return (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: Date()) else { return nil }
            return HealthMetrics(
                date: date,
                heartRateVariability: Double.random(in: 50...80),
                restingHeartRate: Double.random(in: 55...70),
                activeEnergy: Double.random(in: 300...600),
                steps: Int.random(in: 5000...12000),
                sleepHours: Double.random(in: 6...9),
                weight: Double.random(in: 75...80)
            )
        }
    }
    func saveHealthMetrics(_ metrics: HealthMetrics) async throws {}
    func syncFromHealthKit() async throws {}
    func requestHealthKitAuthorization() async throws -> Bool { true }
}
