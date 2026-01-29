//
//  HealthTrendsView.swift
//  VitalArc
//
//  Health trends including HRV, resting heart rate, and sleep analytics
//

import SwiftUI
import Charts

// MARK: - Health Trend Data

struct HealthTrendData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - HRV Trend Chart

struct HRVTrendChartView: View {
    let sevenDayData: [HealthTrendData]
    let thirtyDayData: [HealthTrendData]
    let baseline: Double?

    @State private var selectedPeriod: Period = .sevenDay
    @State private var hasAppeared = false

    enum Period: String, CaseIterable {
        case sevenDay = "7 Days"
        case thirtyDay = "30 Days"
    }

    var currentData: [HealthTrendData] {
        selectedPeriod == .sevenDay ? sevenDayData : thirtyDayData
    }

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                HStack {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Color.vitalDanger)

                        Text("HRV Trend")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    }

                    Spacer()

                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(Period.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                }

                if !currentData.isEmpty {
                    // Current value highlight
                    if let latest = currentData.last {
                        HStack(spacing: Spacing.lg) {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text("Current")
                                    .font(.vitalCaptionSmall)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                                    Text(String(format: "%.0f", latest.value))
                                        .font(.vitalNumberLarge)
                                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                                    Text("ms")
                                        .font(.vitalBodySmall)
                                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                }
                            }

                            if let baseline = baseline {
                                Divider().frame(height: 40)

                                VStack(alignment: .leading, spacing: Spacing.xxs) {
                                    Text("vs Baseline")
                                        .font(.vitalCaptionSmall)
                                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                    let diff = latest.value - baseline
                                    HStack(spacing: Spacing.xs) {
                                        Image(systemName: diff >= 0 ? "arrow.up" : "arrow.down")
                                            .font(.vitalLabelSmall)
                                        Text(String(format: "%+.0f ms", diff))
                                            .font(.vitalLabel)
                                    }
                                    .foregroundStyle(diff >= 0 ? Color.vitalSuccess : Color.vitalDanger)
                                }
                            }

                            Spacer()

                            // Status indicator
                            hrvStatusBadge(latest.value)
                        }
                    }

                    // Chart
                    Chart {
                        if let baseline = baseline {
                            RuleMark(y: .value("Baseline", baseline))
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary.opacity(0.3))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                        }

                        ForEach(currentData) { item in
                            LineMark(
                                x: .value("Date", item.date),
                                y: .value("HRV", hasAppeared ? item.value : (baseline ?? 50))
                            )
                            .foregroundStyle(Color.vitalDanger)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))

                            AreaMark(
                                x: .value("Date", item.date),
                                y: .value("HRV", hasAppeared ? item.value : (baseline ?? 50))
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.vitalDanger.opacity(0.3), Color.vitalDanger.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("Date", item.date),
                                y: .value("HRV", hasAppeared ? item.value : (baseline ?? 50))
                            )
                            .foregroundStyle(Color.vitalDanger)
                            .symbolSize(30)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisValueLabel(format: selectedPeriod == .sevenDay ? .dateTime.weekday(.abbreviated) : .dateTime.day())
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let val = value.as(Double.self) {
                                    Text("\(Int(val))")
                                        .font(.vitalCaptionSmall)
                                }
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        }
                    }
                    .frame(height: 180)
                    .animation(.vitalSpringBouncy, value: hasAppeared)
                    .animation(.vitalSpring, value: selectedPeriod)
                } else {
                    emptyState
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                hasAppeared = true
            }
        }
    }

    // MARK: - HRV Status Badge

    private func hrvStatusBadge(_ value: Double) -> some View {
        let status: (text: String, color: Color) = {
            switch value {
            case 0..<30: return ("Low", .vitalDanger)
            case 30..<50: return ("Fair", .vitalWarning)
            case 50..<80: return ("Good", .vitalInfo)
            default: return ("Excellent", .vitalSuccess)
            }
        }()

        return Text(status.text)
            .font(.vitalLabelSmall)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(status.color)
            .cornerRadius(Spacing.radiusSmall)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "heart.text.square")
                .font(.system(size: Spacing.icon2XLarge))
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            Text("No HRV data available")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Resting Heart Rate Chart

struct RestingHRChartView: View {
    let data: [HealthTrendData]

    @State private var hasAppeared = false

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                HStack {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundStyle(Color.vitalAccent)

                        Text("Resting Heart Rate")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    }

                    Spacer()

                    if let latest = data.last {
                        HStack(spacing: Spacing.xs) {
                            Text(String(format: "%.0f", latest.value))
                                .font(.vitalNumberSmall)
                            Text("BPM")
                                .font(.vitalCaptionSmall)
                        }
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    }
                }

                if !data.isEmpty {
                    Chart {
                        ForEach(data) { item in
                            LineMark(
                                x: .value("Date", item.date),
                                y: .value("HR", hasAppeared ? item.value : averageValue)
                            )
                            .foregroundStyle(Color.vitalAccent)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 2.5))

                            AreaMark(
                                x: .value("Date", item.date),
                                y: .value("HR", hasAppeared ? item.value : averageValue)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.vitalAccent.opacity(0.25), Color.vitalAccent.opacity(0.02)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let val = value.as(Double.self) {
                                    Text("\(Int(val))")
                                        .font(.vitalCaptionSmall)
                                }
                            }
                        }
                    }
                    .frame(height: 120)
                    .animation(.vitalSpringBouncy, value: hasAppeared)

                    // Summary stats
                    HStack(spacing: Spacing.lg) {
                        statItem(title: "Avg", value: String(format: "%.0f", averageValue), unit: "BPM")
                        Divider().frame(height: 24)
                        statItem(title: "Min", value: String(format: "%.0f", minValue), unit: "BPM")
                        Divider().frame(height: 24)
                        statItem(title: "Max", value: String(format: "%.0f", maxValue), unit: "BPM")
                        Spacer()
                    }
                } else {
                    emptyState
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                hasAppeared = true
            }
        }
    }

    private var averageValue: Double {
        guard !data.isEmpty else { return 0 }
        return data.map { $0.value }.reduce(0, +) / Double(data.count)
    }

    private var minValue: Double {
        data.map { $0.value }.min() ?? 0
    }

    private var maxValue: Double {
        data.map { $0.value }.max() ?? 0
    }

    private func statItem(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            HStack(spacing: Spacing.xxs) {
                Text(value)
                    .font(.vitalLabel)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                Text(unit)
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }
    }

    private var emptyState: some View {
        Text("No heart rate data")
            .font(.vitalBody)
            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            .frame(height: 120)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Sleep Trend Chart

struct SleepTrendData: Identifiable {
    let id = UUID()
    let date: Date
    let totalHours: Double
    let deepSleepHours: Double?
    let remSleepHours: Double?
    let lightSleepHours: Double?
}

struct SleepTrendChartView: View {
    let data: [SleepTrendData]
    let targetHours: Double

    @State private var hasAppeared = false

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                HStack {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "bed.double.fill")
                            .foregroundStyle(Color.vitalSecondary)

                        Text("Sleep Duration")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    }

                    Spacer()

                    if let latest = data.last {
                        sleepDurationBadge(latest.totalHours)
                    }
                }

                if !data.isEmpty {
                    // Chart
                    Chart {
                        // Target line
                        RuleMark(y: .value("Target", targetHours))
                            .foregroundStyle(Color.vitalSuccess.opacity(0.4))
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                            .annotation(position: .leading) {
                                Text("Goal")
                                    .font(.vitalCaptionSmall)
                                    .foregroundStyle(Color.vitalSuccess)
                            }

                        ForEach(data) { item in
                            BarMark(
                                x: .value("Date", item.date, unit: .day),
                                y: .value("Sleep", hasAppeared ? item.totalHours : 0)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.vitalSecondary, Color.vitalSecondary.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(Spacing.xs)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let val = value.as(Double.self) {
                                    Text(String(format: "%.0fh", val))
                                        .font(.vitalCaptionSmall)
                                }
                            }
                            AxisGridLine()
                        }
                    }
                    .chartYScale(domain: 0...max(maxSleepHours + 2, 12))
                    .frame(height: 160)
                    .animation(.vitalSpringBouncy, value: hasAppeared)

                    // Weekly summary
                    HStack(spacing: Spacing.lg) {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Avg Sleep")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(String(format: "%.1f hrs", averageSleep))
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }

                        Divider().frame(height: 30)

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Goal Met")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text("\(daysMetGoal)/\(data.count) days")
                                .font(.vitalLabel)
                                .foregroundStyle(daysMetGoal >= data.count / 2 ? Color.vitalSuccess : Color.vitalWarning)
                        }

                        Spacer()

                        // Quality indicator
                        VStack(alignment: .trailing, spacing: Spacing.xxs) {
                            Text("Quality")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            sleepQualityIndicator
                        }
                    }
                } else {
                    emptyState
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Computed Properties

    private var averageSleep: Double {
        guard !data.isEmpty else { return 0 }
        return data.map { $0.totalHours }.reduce(0, +) / Double(data.count)
    }

    private var daysMetGoal: Int {
        data.filter { $0.totalHours >= targetHours }.count
    }

    private var maxSleepHours: Double {
        data.map { $0.totalHours }.max() ?? 12
    }

    private func sleepDurationBadge(_ hours: Double) -> some View {
        HStack(spacing: Spacing.xs) {
            Text(String(format: "%.1f", hours))
                .font(.vitalLabel)
            Text("hrs")
                .font(.vitalCaptionSmall)
        }
        .foregroundStyle(hours >= targetHours ? Color.vitalSuccess : Color.vitalWarning)
    }

    private var sleepQualityIndicator: some View {
        let quality: (text: String, color: Color) = {
            let avgSleepPercent = (averageSleep / targetHours) * 100
            switch avgSleepPercent {
            case 0..<70: return ("Poor", .vitalDanger)
            case 70..<85: return ("Fair", .vitalWarning)
            case 85..<95: return ("Good", .vitalInfo)
            default: return ("Excellent", .vitalSuccess)
            }
        }()

        return HStack(spacing: Spacing.xs) {
            Circle()
                .fill(quality.color)
                .frame(width: Spacing.sm, height: Spacing.sm)
            Text(quality.text)
                .font(.vitalLabelSmall)
                .foregroundStyle(quality.color)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "moon.zzz")
                .font(.system(size: Spacing.icon2XLarge))
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            Text("No sleep data available")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            HRVTrendChartView(
                sevenDayData: (0..<7).map { dayOffset in
                    HealthTrendData(
                        date: Calendar.current.date(byAdding: .day, value: -6 + dayOffset, to: Date())!,
                        value: Double.random(in: 45...75)
                    )
                },
                thirtyDayData: (0..<30).map { dayOffset in
                    HealthTrendData(
                        date: Calendar.current.date(byAdding: .day, value: -29 + dayOffset, to: Date())!,
                        value: Double.random(in: 40...80)
                    )
                },
                baseline: 55
            )

            RestingHRChartView(
                data: (0..<7).map { dayOffset in
                    HealthTrendData(
                        date: Calendar.current.date(byAdding: .day, value: -6 + dayOffset, to: Date())!,
                        value: Double.random(in: 58...68)
                    )
                }
            )

            SleepTrendChartView(
                data: (0..<7).map { dayOffset in
                    SleepTrendData(
                        date: Calendar.current.date(byAdding: .day, value: -6 + dayOffset, to: Date())!,
                        totalHours: Double.random(in: 6...9),
                        deepSleepHours: nil,
                        remSleepHours: nil,
                        lightSleepHours: nil
                    )
                },
                targetHours: 8
            )
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
