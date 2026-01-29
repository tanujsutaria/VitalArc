//
//  NutritionAnalyticsView.swift
//  VitalArc
//
//  Nutrition analytics including calorie adherence, macro breakdown, and protein trends
//

import SwiftUI
import Charts

// MARK: - Calorie Adherence Data

struct CalorieAdherenceData: Identifiable {
    let id = UUID()
    let date: Date
    let consumed: Double
    let target: Double

    var adherencePercent: Double {
        guard target > 0 else { return 0 }
        return min((consumed / target) * 100, 150) // Cap at 150%
    }

    var isOnTarget: Bool {
        let diff = abs(consumed - target)
        return diff <= target * 0.1 // Within 10%
    }
}

// MARK: - Calorie Adherence Chart

struct CalorieAdherenceChartView: View {
    let data: [CalorieAdherenceData]
    let weeklyAverage: Double
    let targetCalories: Double

    @State private var hasAppeared = false

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                HStack {
                    Text("Calorie Adherence")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Spacer()

                    // Weekly average badge
                    HStack(spacing: Spacing.xs) {
                        Text("Avg:")
                            .font(.vitalCaptionSmall)
                        Text(String(format: "%.0f%%", weeklyAverage))
                            .font(.vitalLabel)
                    }
                    .foregroundStyle(adherenceColor(weeklyAverage))
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(adherenceColor(weeklyAverage).opacity(0.15))
                    .cornerRadius(Spacing.radiusSmall)
                }

                if !data.isEmpty {
                    // Chart
                    Chart {
                        // Target line
                        RuleMark(y: .value("Target", 100))
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                            .annotation(position: .trailing, alignment: .leading) {
                                Text("Target")
                                    .font(.vitalCaptionSmall)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }

                        ForEach(data) { item in
                            BarMark(
                                x: .value("Date", item.date, unit: .day),
                                y: .value("Adherence", hasAppeared ? item.adherencePercent : 0)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [barColor(for: item), barColor(for: item).opacity(0.7)],
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
                                if let percent = value.as(Double.self) {
                                    Text("\(Int(percent))%")
                                        .font(.vitalCaptionSmall)
                                }
                            }
                            AxisGridLine()
                        }
                    }
                    .chartYScale(domain: 0...150)
                    .frame(height: Spacing.chartHeightLarge)
                    .animation(.vitalSpringBouncy, value: hasAppeared)

                    // Summary
                    HStack(spacing: Spacing.lg) {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Days On Target")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text("\(daysOnTarget)/\(data.count)")
                                .font(.vitalNumberSmall)
                                .foregroundStyle(Color.vitalSuccess)
                        }

                        Divider().frame(height: Spacing.xl)

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Avg Consumed")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(String(format: "%.0f kcal", averageConsumed))
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }

                        Divider().frame(height: Spacing.xl)

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Target")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(String(format: "%.0f kcal", targetCalories))
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }

                        Spacer()
                    }
                } else {
                    emptyState
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Computed Properties

    private var daysOnTarget: Int {
        data.filter { $0.isOnTarget }.count
    }

    private var averageConsumed: Double {
        guard !data.isEmpty else { return 0 }
        return data.map { $0.consumed }.reduce(0, +) / Double(data.count)
    }

    // MARK: - Helper Methods

    private func barColor(for item: CalorieAdherenceData) -> Color {
        if item.isOnTarget {
            return .vitalSuccess
        } else if item.consumed > item.target {
            return .vitalWarning
        } else {
            return .vitalInfo
        }
    }

    private func adherenceColor(_ percent: Double) -> Color {
        if percent >= 90 && percent <= 110 {
            return .vitalSuccess
        } else if percent >= 80 && percent <= 120 {
            return .vitalWarning
        } else {
            return .vitalDanger
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "fork.knife")
                .font(.system(size: Spacing.icon2XLarge))
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Text("No nutrition data")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(height: Spacing.chartHeightLarge)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Macro Breakdown Chart

struct MacroBreakdownData {
    let protein: Double
    let carbs: Double
    let fats: Double

    var total: Double { protein * 4 + carbs * 4 + fats * 9 }

    var proteinPercent: Double {
        guard total > 0 else { return 0 }
        return (protein * 4 / total) * 100
    }

    var carbsPercent: Double {
        guard total > 0 else { return 0 }
        return (carbs * 4 / total) * 100
    }

    var fatsPercent: Double {
        guard total > 0 else { return 0 }
        return (fats * 9 / total) * 100
    }
}

struct MacroBreakdownChartView: View {
    let data: MacroBreakdownData
    let proteinTarget: Double
    let carbsTarget: Double
    let fatsTarget: Double

    @State private var hasAppeared = false
    @State private var selectedMacro: String?

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Macro Breakdown")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                HStack(spacing: Spacing.lg) {
                    // Pie chart
                    ZStack {
                        // Background
                        Circle()
                            .fill(Color.vitalAdaptiveBorder.opacity(0.2))
                            .frame(width: Spacing.pieChartSize, height: Spacing.pieChartSize)

                        // Sectors
                        pieChart

                        // Center text
                        VStack(spacing: Spacing.xxs) {
                            Text(String(format: "%.0f", data.total))
                                .font(.vitalNumberMedium)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            Text("kcal")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                    }
                    .frame(width: Spacing.pieChartSize, height: Spacing.pieChartSize)

                    // Legend
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        macroRow(
                            name: "Protein",
                            grams: data.protein,
                            target: proteinTarget,
                            color: .vitalDanger,
                            percent: data.proteinPercent
                        )

                        macroRow(
                            name: "Carbs",
                            grams: data.carbs,
                            target: carbsTarget,
                            color: .vitalInfo,
                            percent: data.carbsPercent
                        )

                        macroRow(
                            name: "Fats",
                            grams: data.fats,
                            target: fatsTarget,
                            color: .vitalWarning,
                            percent: data.fatsPercent
                        )
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Pie Chart

    private var pieChart: some View {
        let proteinAngle = hasAppeared ? data.proteinPercent / 100 * 360 : 0
        let carbsAngle = hasAppeared ? data.carbsPercent / 100 * 360 : 0
        let fatsAngle = hasAppeared ? data.fatsPercent / 100 * 360 : 0

        return ZStack {
            // Protein sector
            PieSlice(startAngle: 0, endAngle: proteinAngle)
                .fill(Color.vitalDanger)

            // Carbs sector
            PieSlice(startAngle: proteinAngle, endAngle: proteinAngle + carbsAngle)
                .fill(Color.vitalInfo)

            // Fats sector
            PieSlice(startAngle: proteinAngle + carbsAngle, endAngle: proteinAngle + carbsAngle + fatsAngle)
                .fill(Color.vitalWarning)

            // Inner circle (donut hole)
            Circle()
                .fill(Color.vitalAdaptiveSurface)
                .frame(width: Spacing.pieChartHole, height: Spacing.pieChartHole)
        }
        .frame(width: Spacing.pieChartSize, height: Spacing.pieChartSize)
        .animation(.vitalSpringBouncy, value: hasAppeared)
    }

    // MARK: - Macro Row

    private func macroRow(name: String, grams: Double, target: Double, color: Color, percent: Double) -> some View {
        HStack(spacing: Spacing.sm) {
            Circle()
                .fill(color)
                .frame(width: Spacing.sm, height: Spacing.sm)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(spacing: Spacing.xs) {
                    Text(name)
                        .font(.vitalLabelSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    Text(String(format: "%.0f%%", percent))
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                HStack(spacing: Spacing.xs) {
                    Text(String(format: "%.0fg", grams))
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    Text("/")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    Text(String(format: "%.0fg", target))
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
    }
}

// MARK: - Pie Slice Shape

private struct PieSlice: Shape {
    var startAngle: Double
    var endAngle: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle, endAngle) }
        set {
            startAngle = newValue.first
            endAngle = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle - 90),
            endAngle: .degrees(endAngle - 90),
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Protein Per Body Weight Chart

struct ProteinTrendData: Identifiable {
    let id = UUID()
    let date: Date
    let proteinPerKg: Double
}

struct ProteinTrendChartView: View {
    let data: [ProteinTrendData]
    let targetPerKg: Double
    let currentWeight: Double

    @State private var hasAppeared = false

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                HStack {
                    Text("Protein per Body Weight")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Spacer()

                    // Current status
                    if let latest = data.last {
                        HStack(spacing: Spacing.xs) {
                            Text(String(format: "%.1fg/kg", latest.proteinPerKg))
                                .font(.vitalLabel)
                        }
                        .foregroundStyle(latest.proteinPerKg >= targetPerKg ? Color.vitalSuccess : Color.vitalWarning)
                    }
                }

                if !data.isEmpty {
                    Chart {
                        // Target line
                        RuleMark(y: .value("Target", targetPerKg))
                            .foregroundStyle(Color.vitalSuccess.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))

                        ForEach(data) { item in
                            LineMark(
                                x: .value("Date", item.date),
                                y: .value("Protein", hasAppeared ? item.proteinPerKg : 0)
                            )
                            .foregroundStyle(Color.vitalDanger)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3))

                            AreaMark(
                                x: .value("Date", item.date),
                                y: .value("Protein", hasAppeared ? item.proteinPerKg : 0)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.vitalDanger.opacity(0.3), Color.vitalDanger.opacity(0.05)],
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
                                    Text(String(format: "%.1f", val))
                                        .font(.vitalCaptionSmall)
                                }
                            }
                            AxisGridLine()
                        }
                    }
                    .frame(height: Spacing.chartHeightSmall)
                    .animation(.vitalSpringBouncy, value: hasAppeared)

                    // Summary
                    HStack(spacing: Spacing.lg) {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Target")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(String(format: "%.1fg/kg", targetPerKg))
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalSuccess)
                        }

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Daily Target")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(String(format: "%.0fg", targetPerKg * currentWeight))
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }

                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                hasAppeared = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            CalorieAdherenceChartView(
                data: (0..<7).map { dayOffset in
                    CalorieAdherenceData(
                        date: Calendar.current.date(byAdding: .day, value: -6 + dayOffset, to: Date())!,
                        consumed: Double.random(in: 1800...2400),
                        target: 2200
                    )
                },
                weeklyAverage: 95,
                targetCalories: 2200
            )

            MacroBreakdownChartView(
                data: MacroBreakdownData(protein: 180, carbs: 250, fats: 70),
                proteinTarget: 200,
                carbsTarget: 300,
                fatsTarget: 80
            )

            ProteinTrendChartView(
                data: (0..<7).map { dayOffset in
                    ProteinTrendData(
                        date: Calendar.current.date(byAdding: .day, value: -6 + dayOffset, to: Date())!,
                        proteinPerKg: Double.random(in: 1.6...2.2)
                    )
                },
                targetPerKg: 2.0,
                currentWeight: 85
            )
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
