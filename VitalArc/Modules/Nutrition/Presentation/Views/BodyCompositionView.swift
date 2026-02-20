//
//  BodyCompositionView.swift
//  VitalArc
//
//  Body composition tracking view with trends and measurement input
//

import SwiftUI
import Charts

struct BodyCompositionView: View {
    @Bindable var viewModel: BodyCompositionViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Latest Measurements Summary
                if let latest = viewModel.latestMeasurement {
                    LatestMeasurementCard(
                        measurement: latest,
                        viewModel: viewModel
                    )
                } else if !viewModel.isLoading {
                    VitalEmptyState(
                        icon: "figure.arms.open",
                        title: "No Measurements Yet",
                        message: "Track your body composition to see trends over time."
                    )
                }

                // Add Measurement Button
                VitalButton(
                    title: "Add Measurement",
                    style: .primary,
                    icon: "plus.circle.fill"
                ) {
                    viewModel.prefillFromLatest()
                    viewModel.showingAddForm = true
                }

                // Trend Charts
                if !viewModel.weightTrend.isEmpty {
                    TrendChartCard(
                        title: "Weight",
                        data: viewModel.weightTrend,
                        unit: viewModel.weightUnit,
                        color: .vitalPrimary
                    )
                }

                if !viewModel.bodyFatTrend.isEmpty {
                    TrendChartCard(
                        title: "Body Fat",
                        data: viewModel.bodyFatTrend,
                        unit: "%",
                        color: .vitalWarning
                    )
                }

                if !viewModel.waistToHipTrend.isEmpty {
                    TrendChartCard(
                        title: "Waist-to-Hip Ratio",
                        data: viewModel.waistToHipTrend,
                        unit: "",
                        color: .vitalInfo,
                        decimalPlaces: 2
                    )
                }

                // Time Range Picker
                if !viewModel.measurements.isEmpty {
                    ChartRangePicker(selectedMonths: $viewModel.chartMonths) {
                        Task { await viewModel.loadData() }
                    }
                }
            }
            .padding(Spacing.screenPadding)
        }
        .background(Color.vitalAdaptiveBackground)
        .navigationTitle("Body Composition")
        .sheet(isPresented: $viewModel.showingAddForm) {
            AddMeasurementSheet(viewModel: viewModel)
        }
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - Latest Measurement Card

private struct LatestMeasurementCard: View {
    let measurement: BodyCompositionEntry
    let viewModel: BodyCompositionViewModel

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: measurement.date)
    }

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("Latest Measurements")
                        .font(.vitalH2)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    Spacer()
                    Text(dateString)
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                // Primary metrics row
                HStack(spacing: Spacing.lg) {
                    if let weight = measurement.weight {
                        MetricPill(
                            label: "Weight",
                            value: viewModel.displayWeight(weight),
                            icon: "scalemass"
                        )
                    }

                    if let bf = measurement.bodyFatPercentage {
                        MetricPill(
                            label: "Body Fat",
                            value: String(format: "%.1f%%", bf),
                            icon: "percent"
                        )
                    }

                    if let whr = measurement.waistToHipRatio {
                        MetricPill(
                            label: "WHR",
                            value: String(format: "%.2f", whr),
                            icon: "figure.stand"
                        )
                    }
                }

                // Circumference details
                let circumferences: [(String, Double?)] = [
                    ("Waist", measurement.waistCircumference),
                    ("Hip", measurement.hipCircumference),
                    ("Chest", measurement.chestCircumference),
                    ("Arm", measurement.armCircumference),
                    ("Thigh", measurement.thighCircumference),
                    ("Neck", measurement.neckCircumference)
                ]

                let available = circumferences.compactMap { name, val -> (String, Double)? in
                    guard let v = val else { return nil }
                    return (name, v)
                }

                if !available.isEmpty {
                    Divider()
                        .background(Color.vitalAdaptiveBorder)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Spacing.sm) {
                        ForEach(available, id: \.0) { name, value in
                            VStack(spacing: Spacing.xs) {
                                Text(name)
                                    .font(.vitalCaptionSmall)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                Text(viewModel.displayCircumference(value))
                                    .font(.vitalBody)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            }
                        }
                    }
                }

                // Lean mass / Fat mass
                if let lbm = measurement.leanBodyMass, let fm = measurement.fatMass {
                    Divider()
                        .background(Color.vitalAdaptiveBorder)

                    HStack(spacing: Spacing.lg) {
                        VStack(spacing: Spacing.xs) {
                            Text("Lean Mass")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(viewModel.displayWeight(lbm))
                                .font(.vitalBody)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.vitalSuccess)
                        }

                        VStack(spacing: Spacing.xs) {
                            Text("Fat Mass")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(viewModel.displayWeight(fm))
                                .font(.vitalBody)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.vitalWarning)
                        }
                    }
                }

                if let notes = measurement.notes {
                    Text(notes)
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
    }
}

// MARK: - Metric Pill

private struct MetricPill: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: Spacing.iconSmall))
                .foregroundStyle(Color.vitalPrimary)
            Text(value)
                .font(.vitalBody)
                .fontWeight(.bold)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
            Text(label)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Trend Chart Card

private struct TrendChartCard: View {
    let title: String
    let data: [(date: Date, value: Double)]
    let unit: String
    let color: Color
    var decimalPlaces: Int = 1

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text(title)
                        .font(.vitalH2)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    Spacer()
                    if let latest = data.last {
                        Text(formatValue(latest.value))
                            .font(.vitalBody)
                            .fontWeight(.semibold)
                            .foregroundStyle(color)
                    }
                }

                if data.count >= 2 {
                    Chart(data, id: \.date) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value(title, point.value)
                        )
                        .foregroundStyle(color)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Date", point.date),
                            y: .value(title, point.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color.opacity(0.2), color.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value(title, point.value)
                        )
                        .foregroundStyle(color)
                        .symbolSize(Spacing.iconXSmall)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 4)) {
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                .font(.vitalCaptionSmall)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) {
                            AxisValueLabel()
                                .font(.vitalCaptionSmall)
                        }
                    }
                    .frame(height: 180)
                } else {
                    Text("Need at least 2 data points for chart")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, Spacing.lg)
                }

                // Change indicator
                if data.count >= 2, let first = data.first, let last = data.last {
                    let change = last.value - first.value
                    let changePercent = first.value > 0 ? (change / first.value) * 100 : 0

                    HStack(spacing: Spacing.xs) {
                        Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: Spacing.iconXSmall))
                        Text("\(change >= 0 ? "+" : "")\(formatValue(change)) \(unit)")
                            .font(.vitalCaptionSmall)
                        Text("(\(changePercent >= 0 ? "+" : "")\(String(format: "%.1f", changePercent))%)")
                            .font(.vitalCaptionSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                    .foregroundStyle(change >= 0 ? Color.vitalDanger : Color.vitalSuccess)
                }
            }
        }
    }

    private func formatValue(_ value: Double) -> String {
        let formatted = String(format: "%.\(decimalPlaces)f", value)
        return unit.isEmpty ? formatted : "\(formatted) \(unit)"
    }
}

// MARK: - Chart Range Picker

private struct ChartRangePicker: View {
    @Binding var selectedMonths: Int
    let onChange: () -> Void

    private let options = [1, 3, 6, 12]

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(options, id: \.self) { months in
                Button {
                    selectedMonths = months
                    onChange()
                } label: {
                    Text(months == 12 ? "1Y" : "\(months)M")
                        .font(.vitalCaption)
                        .fontWeight(selectedMonths == months ? .semibold : .regular)
                        .foregroundStyle(selectedMonths == months ? Color.vitalPrimary : Color.vitalAdaptiveTextSecondary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(
                            selectedMonths == months
                                ? Color.vitalPrimary.opacity(0.1)
                                : Color.clear
                        )
                        .cornerRadius(Spacing.radiusSmall)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Add Measurement Sheet

private struct AddMeasurementSheet: View {
    @Bindable var viewModel: BodyCompositionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Unit Toggle
                    VitalCard {
                        HStack {
                            Text("Units")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            Spacer()
                            Picker("Units", selection: $viewModel.useImperial) {
                                Text("Imperial").tag(true)
                                Text("Metric").tag(false)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 180)
                        }
                    }

                    // Primary Measurements
                    VitalCard {
                        VStack(spacing: Spacing.md) {
                            Text("Primary")
                                .font(.vitalH2)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            MeasurementField(
                                label: "Weight",
                                value: $viewModel.formWeight,
                                unit: viewModel.weightUnit,
                                icon: "scalemass"
                            )

                            MeasurementField(
                                label: "Body Fat",
                                value: $viewModel.formBodyFat,
                                unit: "%",
                                icon: "percent"
                            )
                        }
                    }

                    // Circumference Measurements
                    VitalCard {
                        VStack(spacing: Spacing.md) {
                            Text("Circumferences")
                                .font(.vitalH2)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            MeasurementField(
                                label: "Waist",
                                value: $viewModel.formWaist,
                                unit: viewModel.circumferenceUnit,
                                icon: "figure.stand"
                            )

                            MeasurementField(
                                label: "Hip",
                                value: $viewModel.formHip,
                                unit: viewModel.circumferenceUnit,
                                icon: "figure.stand"
                            )

                            MeasurementField(
                                label: "Chest",
                                value: $viewModel.formChest,
                                unit: viewModel.circumferenceUnit,
                                icon: "figure.arms.open"
                            )

                            MeasurementField(
                                label: "Arm",
                                value: $viewModel.formArm,
                                unit: viewModel.circumferenceUnit,
                                icon: "figure.strengthtraining.traditional"
                            )

                            MeasurementField(
                                label: "Thigh",
                                value: $viewModel.formThigh,
                                unit: viewModel.circumferenceUnit,
                                icon: "figure.walk"
                            )

                            MeasurementField(
                                label: "Neck",
                                value: $viewModel.formNeck,
                                unit: viewModel.circumferenceUnit,
                                icon: "person"
                            )
                        }
                    }

                    // Notes
                    VitalCard {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Notes")
                                .font(.vitalH2)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                            TextField("Optional notes...", text: $viewModel.formNotes, axis: .vertical)
                                .font(.vitalBody)
                                .lineLimit(3...6)
                                .padding(Spacing.sm)
                                .background(Color.vitalAdaptiveSurface)
                                .cornerRadius(Spacing.radiusSmall)
                        }
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle("Add Measurement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.clearForm()
                        dismiss()
                    }
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.saveMeasurement()
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.vitalPrimary)
                    .disabled(!viewModel.hasFormData)
                }
            }
        }
    }
}

// MARK: - Measurement Field

private struct MeasurementField: View {
    let label: String
    @Binding var value: String
    let unit: String
    let icon: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: Spacing.iconSmall))
                .foregroundStyle(Color.vitalPrimary)
                .frame(width: Spacing.iconLarge)

            Text(label)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                .frame(width: 60, alignment: .leading)

            TextField("0", text: $value)
                .font(.vitalBody)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(Color.vitalAdaptiveSurface)
                .cornerRadius(Spacing.radiusSmall)

            Text(unit)
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .frame(width: 30, alignment: .leading)
        }
    }
}
