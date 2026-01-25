//
//  ChartView.swift
//  VitalArc
//
//  Simple line chart for health metrics trends
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
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            if data.isEmpty {
                emptyStateView
            } else {
                chart
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
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
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("No data available")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Chart Data Point

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
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
            color: .red,
            unit: "ms"
        )

        ChartView(
            title: "Steps Trend (7 Days)",
            data: [],
            color: .blue,
            unit: "steps"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
