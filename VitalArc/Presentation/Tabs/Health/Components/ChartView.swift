//
//  ChartView.swift
//  VitalArc
//
//  Simple line chart for health metrics trends (Legacy - use VitalLineChart)
//

import SwiftUI
import Charts

struct ChartView: View {

    // MARK: - Properties

    let title: String
    let data: [ChartDataPoint]
    let color: Color
    let unit: String

    // MARK: - Body

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text(title)
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                if data.isEmpty {
                    emptyStateView
                } else {
                    chart
                }
            }
        }
    }

    // MARK: - Chart

    private var chart: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(color)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Date", point.date),
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

            PointMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(color)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel(format: .dateTime.weekday(.narrow))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 200)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Text("No data available")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        ChartView(
            title: "HRV Trend (7 Days)",
            data: [
                ChartDataPoint(date: Date().addingTimeInterval(-6 * 86400), value: 65),
                ChartDataPoint(date: Date().addingTimeInterval(-5 * 86400), value: 70),
                ChartDataPoint(date: Date().addingTimeInterval(-4 * 86400), value: 68),
                ChartDataPoint(date: Date().addingTimeInterval(-3 * 86400), value: 75),
                ChartDataPoint(date: Date().addingTimeInterval(-2 * 86400), value: 72),
                ChartDataPoint(date: Date().addingTimeInterval(-1 * 86400), value: 78),
                ChartDataPoint(date: Date(), value: 80)
            ],
            color: .vitalDanger,
            unit: "ms"
        )

        ChartView(
            title: "Steps Trend (7 Days)",
            data: [],
            color: .vitalInfo,
            unit: "steps"
        )
    }
    .padding()
    .background(Color.vitalAdaptiveBackground)
}
