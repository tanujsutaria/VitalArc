//
//  HRVTrendView.swift
//  VitalArc
//
//  Dedicated HRV tracking view with trend visualization and baseline comparison
//

import SwiftUI
import Charts

struct HRVTrendView: View {
    let currentHRV: Double?
    let baseline: Double?
    let isAboveBaseline: Bool
    let deviationSignificant: Bool
    let statusText: String
    let trendData7Day: [ChartDataPoint]
    let trendData30Day: [ChartDataPoint]
    let sleepCorrelationHint: String?

    @State private var selectedRange: HRVRange = .week

    enum HRVRange: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.vitalDanger.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: "heart.fill")
                        .font(.vitalIconSmallSemibold)
                        .foregroundStyle(Color.vitalDanger)
                }

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("HRV Tracking")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text("Heart Rate Variability")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                Spacer()
            }

            // Current value with status
            if let hrv = currentHRV {
                currentValueSection(hrv)
            }

            // Range picker
            Picker("Range", selection: $selectedRange) {
                ForEach(HRVRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)

            // Trend chart
            trendChart

            // Baseline reference
            if let baseline = baseline {
                baselineReferenceView(baseline)
            }

            // Sleep correlation hint
            if let hint = sleepCorrelationHint {
                sleepCorrelationView(hint)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("HRV Tracking")
    }

    // MARK: - Current Value

    private func currentValueSection(_ hrv: Double) -> some View {
        HStack(spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Current")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    Text(String(format: "%.0f", hrv))
                        .font(.vitalNumberLarge)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text("ms")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }

            Spacer()

            // Status badge
            HStack(spacing: Spacing.xs) {
                Image(systemName: isAboveBaseline ? "arrow.up.right" : "arrow.down.right")
                    .font(.vitalCaptionSmall)

                Text(statusText)
                    .font(.vitalCaptionSmall)
            }
            .foregroundStyle(statusColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(statusColor.opacity(0.15))
            .cornerRadius(Spacing.radiusSmall)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Current HRV")
        .accessibilityValue("\(String(format: "%.0f", hrv)) milliseconds, \(statusText)")
    }

    // MARK: - Trend Chart

    private var trendChart: some View {
        let data = selectedRange == .week ? trendData7Day : trendData30Day

        return Group {
            if data.isEmpty {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.vitalIcon2XLarge)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    Text("No HRV data available")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
                .frame(height: Spacing.chartHeightMedium)
                .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("HRV", point.value)
                        )
                        .foregroundStyle(Color.vitalDanger)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("HRV", point.value)
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
                            x: .value("Date", point.date, unit: .day),
                            y: .value("HRV", point.value)
                        )
                        .foregroundStyle(Color.vitalDanger)
                        .symbolSize(20)
                    }

                    // Baseline reference line
                    if let baseline = baseline {
                        RuleMark(y: .value("Baseline", baseline))
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .annotation(position: .trailing, alignment: .trailing) {
                                Text("Baseline")
                                    .font(.vitalCaptionSmall)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: selectedRange == .week ? .day : .weekOfYear)) { _ in
                        AxisValueLabel(format: selectedRange == .week ? .dateTime.weekday(.abbreviated) : .dateTime.month(.abbreviated).day())
                        AxisGridLine()
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
                        AxisGridLine()
                    }
                }
                .frame(height: Spacing.chartHeightMedium)
            }
        }
    }

    // MARK: - Baseline Reference

    private func baselineReferenceView(_ baseline: Double) -> some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("30-Day Baseline")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                Text(String(format: "%.0f ms", baseline))
                    .font(.vitalLabel)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
            }

            Spacer()

            if deviationSignificant {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.vitalCaptionSmall)

                    Text("Significant deviation")
                        .font(.vitalCaptionSmall)
                }
                .foregroundStyle(Color.vitalWarning)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(Color.vitalWarning.opacity(0.15))
                .cornerRadius(Spacing.radiusSmall)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("30-day HRV baseline")
        .accessibilityValue(String(format: "%.0f milliseconds", baseline) + (deviationSignificant ? ", significant deviation detected" : ""))
    }

    // MARK: - Sleep Correlation

    private func sleepCorrelationView(_ hint: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "bed.double.fill")
                .font(.vitalIconSmallSemibold)
                .foregroundStyle(Color.vitalSecondary)

            Text(hint)
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .padding(Spacing.sm)
        .background(Color.vitalSecondary.opacity(0.08))
        .cornerRadius(Spacing.radiusSmall)
    }

    // MARK: - Helpers

    private var statusColor: Color {
        if deviationSignificant {
            return isAboveBaseline ? .vitalSuccess : .vitalWarning
        }
        return isAboveBaseline ? .vitalSuccess : .vitalDanger
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VitalCard {
            HRVTrendView(
                currentHRV: 72,
                baseline: 65,
                isAboveBaseline: true,
                deviationSignificant: true,
                statusText: "11% above baseline",
                trendData7Day: (0..<7).map { day in
                    ChartDataPoint(
                        date: Date().addingTimeInterval(Double(-6 + day) * 86400),
                        value: 60 + Double.random(in: 0...20)
                    )
                },
                trendData30Day: (0..<30).map { day in
                    ChartDataPoint(
                        date: Date().addingTimeInterval(Double(-29 + day) * 86400),
                        value: 55 + Double.random(in: 0...25)
                    )
                },
                sleepCorrelationHint: "Your HRV tends to be higher on nights with 7+ hours of sleep."
            )
        }
        .padding(Spacing.screenPadding)
    }
    .background(Color.vitalAdaptiveBackground)
}
