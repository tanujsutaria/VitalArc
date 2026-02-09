//
//  ProgressChartView.swift
//  VitalArc
//
//  Charts for body composition and progress tracking
//

import SwiftUI
import Charts

struct ProgressChartView: View {
    let snapshots: [ProgressSnapshot]
    @State private var selectedMeasurement: BodyPart?

    var sortedSnapshots: [ProgressSnapshot] {
        snapshots.sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                if !snapshots.isEmpty {
                    // Body Weight Chart
                    if snapshots.contains(where: { $0.bodyWeight != nil }) {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Body Weight")
                                .font(.vitalH3)

                            Chart {
                                ForEach(sortedSnapshots.filter { $0.bodyWeight != nil }) { snapshot in
                                    LineMark(
                                        x: .value("Date", snapshot.date),
                                        y: .value("Weight", snapshot.bodyWeight ?? 0)
                                    )
                                    .foregroundStyle(Color.vitalInfo)
                                    .interpolationMethod(.catmullRom)

                                    PointMark(
                                        x: .value("Date", snapshot.date),
                                        y: .value("Weight", snapshot.bodyWeight ?? 0)
                                    )
                                    .foregroundStyle(Color.vitalInfo)
                                }
                            }
                            .frame(height: Spacing.chartHeightExtraLarge)
                            .chartXAxis {
                                AxisMarks { _ in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.month().day())
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisGridLine()
                                    AxisValueLabel()
                                }
                            }

                            // Weight change summary
                            if let firstWeight = sortedSnapshots.first(where: { $0.bodyWeight != nil })?.bodyWeight,
                               let lastWeight = sortedSnapshots.last(where: { $0.bodyWeight != nil })?.bodyWeight {
                                let change = lastWeight - firstWeight
                                let changePercent = (change / firstWeight) * 100

                                HStack {
                                    VStack(alignment: .leading, spacing: Spacing.xs) {
                                        Text("Total Change")
                                            .font(.vitalCaption)
                                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                        Text(String(format: "%+.1f kg", change))
                                            .font(.vitalH2)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                                        Text("Percentage")
                                            .font(.vitalCaption)
                                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                        Text(String(format: "%+.1f%%", changePercent))
                                            .font(.vitalH2)
                                    }
                                }
                                .padding(.top, Spacing.sm)
                            }
                        }
                        .padding(Spacing.lg)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                    }

                    // Body Fat Percentage
                    if snapshots.contains(where: { $0.bodyFatPercentage != nil }) {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Body Fat Percentage")
                                .font(.vitalH3)

                            Chart {
                                ForEach(sortedSnapshots.filter { $0.bodyFatPercentage != nil }) { snapshot in
                                    LineMark(
                                        x: .value("Date", snapshot.date),
                                        y: .value("Body Fat", snapshot.bodyFatPercentage ?? 0)
                                    )
                                    .foregroundStyle(Color.vitalWarning)
                                    .interpolationMethod(.catmullRom)

                                    PointMark(
                                        x: .value("Date", snapshot.date),
                                        y: .value("Body Fat", snapshot.bodyFatPercentage ?? 0)
                                    )
                                    .foregroundStyle(Color.vitalWarning)
                                }
                            }
                            .frame(height: Spacing.chartHeightLarge)
                            .chartXAxis {
                                AxisMarks { _ in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.month().day())
                                }
                            }
                        }
                        .padding(Spacing.lg)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                    }

                    // Body Measurements
                    if !sortedSnapshots.flatMap({ $0.measurements }).isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Body Measurements")
                                .font(.vitalH3)

                            // Measurement selector
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Spacing.sm) {
                                    ForEach(BodyPart.allCases, id: \.self) { bodyPart in
                                        if hasMeasurements(for: bodyPart) {
                                            Button {
                                                selectedMeasurement = selectedMeasurement == bodyPart ? nil : bodyPart
                                            } label: {
                                                Text(bodyPart.displayName)
                                                    .font(.vitalCaption)
                                                    .padding(.horizontal, Spacing.md)
                                                    .padding(.vertical, Spacing.sm)
                                                    .background(
                                                        selectedMeasurement == bodyPart ?
                                                        Color.vitalPrimary : Color.vitalAdaptiveSurface
                                                    )
                                                    .foregroundStyle(
                                                        selectedMeasurement == bodyPart ?
                                                        .white : Color.vitalAdaptiveTextPrimary
                                                    )
                                                    .cornerRadius(Spacing.radiusSmall)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, Spacing.xs)
                            }

                            // Chart for selected measurement
                            if let selectedMeasurement = selectedMeasurement {
                                Chart {
                                    ForEach(sortedSnapshots) { snapshot in
                                        if let measurement = snapshot.measurements.first(where: { $0.bodyPart == selectedMeasurement }) {
                                            LineMark(
                                                x: .value("Date", snapshot.date),
                                                y: .value("Measurement", measurement.value)
                                            )
                                            .foregroundStyle(Color.vitalAccent)
                                            .interpolationMethod(.catmullRom)

                                            PointMark(
                                                x: .value("Date", snapshot.date),
                                                y: .value("Measurement", measurement.value)
                                            )
                                            .foregroundStyle(Color.vitalAccent)
                                        }
                                    }
                                }
                                .frame(height: Spacing.chartHeightLarge)
                                .chartXAxis {
                                    AxisMarks { _ in
                                        AxisGridLine()
                                        AxisValueLabel(format: .dateTime.month().day())
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { value in
                                        AxisGridLine()
                                        AxisValueLabel {
                                            if let cm = value.as(Double.self) {
                                                Text("\(Int(cm)) cm")
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("Select a measurement to view chart")
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(Spacing.lg)
                            }
                        }
                        .padding(Spacing.lg)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                    }

                    // Latest Snapshot Details
                    if let latestSnapshot = sortedSnapshots.last {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Latest Snapshot")
                                .font(.vitalH3)

                            Text(latestSnapshot.date.formatted(date: .long, time: .omitted))
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                            if let notes = latestSnapshot.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.vitalBody)
                                    .padding(.top, Spacing.xs)
                            }

                            if !latestSnapshot.measurements.isEmpty {
                                Divider()
                                    .padding(.vertical, Spacing.xs)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                                    ForEach(latestSnapshot.measurements) { measurement in
                                        VStack(alignment: .leading, spacing: Spacing.xs) {
                                            Text(measurement.bodyPart.displayName)
                                                .font(.vitalCaption)
                                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                            Text("\(String(format: "%.1f", measurement.value)) cm")
                                                .font(.vitalLabel)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .padding(Spacing.lg)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                    }
                } else {
                    ContentUnavailableView(
                        "No Progress Data",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Add progress snapshots to track changes")
                    )
                }
            }
            .padding(Spacing.lg)
        }
    }

    private func hasMeasurements(for bodyPart: BodyPart) -> Bool {
        sortedSnapshots.contains { snapshot in
            snapshot.measurements.contains { $0.bodyPart == bodyPart }
        }
    }
}

#Preview("Empty State") {
    ProgressChartView(snapshots: [])
}
