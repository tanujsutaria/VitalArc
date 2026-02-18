//
//  ProgressChart.swift
//  VitalArc
//
//  Modern chart components using Swift Charts
//

import SwiftUI
import Charts

// MARK: - Chart Data Point

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Line Chart

struct VitalLineChart: View {
    let title: String
    let data: [ChartDataPoint]
    let color: Color
    let unit: String

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text(title)
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Chart(data) { point in
                    LineMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(color)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        AxisGridLine()
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text("\(Int(val)) \(unit)")
                                    .font(.vitalCaptionSmall)
                            }
                        }
                        AxisGridLine()
                    }
                }
                .frame(height: Spacing.chartHeightExtraLarge)

                // Summary
                if let avg = averageValue, let min = minValue, let max = maxValue {
                    HStack(spacing: Spacing.lg) {
                        StatLabel(title: "Avg", value: String(format: "%.0f", avg), color: color)
                        StatLabel(title: "Min", value: String(format: "%.0f", min), color: .vitalTextSecondary)
                        StatLabel(title: "Max", value: String(format: "%.0f", max), color: .vitalTextSecondary)
                    }
                    .font(.vitalBodySmall)
                }
            }
        }
    }

    private var averageValue: Double? {
        guard !data.isEmpty else { return nil }
        return data.map { $0.value }.reduce(0, +) / Double(data.count)
    }

    private var minValue: Double? {
        data.map { $0.value }.min()
    }

    private var maxValue: Double? {
        data.map { $0.value }.max()
    }
}

// MARK: - Bar Chart

struct VitalBarChart: View {
    let title: String
    let data: [ChartDataPoint]
    let color: Color
    let unit: String

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text(title)
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Chart(data) { point in
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(Spacing.radiusSmall)
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
                .frame(height: Spacing.chartHeightExtraLarge)
            }
        }
    }
}

// MARK: - Circular Progress Ring

struct CircularProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat

    init(
        progress: Double,
        color: Color,
        lineWidth: CGFloat = 12,
        size: CGFloat = 120
    ) {
        self.progress = max(0, min(1, progress))
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.vitalSpring, value: progress)

            // Percentage text
            VStack(spacing: Spacing.xxs) {
                Text("\(Int(progress * 100))%")
                    .font(.vitalNumberLarge)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Stat Label

private struct StatLabel: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            Text(value)
                .font(.vitalLabel)
                .foregroundStyle(color)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            VitalLineChart(
                title: "Heart Rate Variability",
                data: [
                    ChartDataPoint(date: Date().addingTimeInterval(-6 * 86400), value: 65),
                    ChartDataPoint(date: Date().addingTimeInterval(-5 * 86400), value: 68),
                    ChartDataPoint(date: Date().addingTimeInterval(-4 * 86400), value: 70),
                    ChartDataPoint(date: Date().addingTimeInterval(-3 * 86400), value: 72),
                    ChartDataPoint(date: Date().addingTimeInterval(-2 * 86400), value: 71),
                    ChartDataPoint(date: Date().addingTimeInterval(-1 * 86400), value: 69),
                    ChartDataPoint(date: Date(), value: 72)
                ],
                color: .vitalDanger,
                unit: "ms"
            )

            VitalBarChart(
                title: "Daily Steps",
                data: [
                    ChartDataPoint(date: Date().addingTimeInterval(-6 * 86400), value: 8000),
                    ChartDataPoint(date: Date().addingTimeInterval(-5 * 86400), value: 10200),
                    ChartDataPoint(date: Date().addingTimeInterval(-4 * 86400), value: 9500),
                    ChartDataPoint(date: Date().addingTimeInterval(-3 * 86400), value: 11000),
                    ChartDataPoint(date: Date().addingTimeInterval(-2 * 86400), value: 8800),
                    ChartDataPoint(date: Date().addingTimeInterval(-1 * 86400), value: 9200),
                    ChartDataPoint(date: Date(), value: 10500)
                ],
                color: .vitalInfo,
                unit: "steps"
            )

            HStack(spacing: Spacing.xl) {
                VStack {
                    Text("Protein")
                        .font(.vitalLabel)
                    CircularProgressRing(progress: 0.75, color: .vitalDanger, size: 100)
                }

                VStack {
                    Text("Carbs")
                        .font(.vitalLabel)
                    CircularProgressRing(progress: 0.60, color: .vitalInfo, size: 100)
                }

                VStack {
                    Text("Fats")
                        .font(.vitalLabel)
                    CircularProgressRing(progress: 0.85, color: .vitalWarning, size: 100)
                }
            }
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
