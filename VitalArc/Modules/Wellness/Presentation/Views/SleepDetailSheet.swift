//
//  SleepDetailSheet.swift
//  VitalArc
//
//  Drill-down sheet for viewing detailed sleep analysis and stage breakdown
//

import SwiftUI
import Charts

struct SleepDetailSheet: View {
    let sleepHours: Double
    let sleepStages: SleepStages?
    let sleepTrend: [SleepTrendData]

    @Environment(\.dismiss) private var dismiss
    @State private var hasAppeared = false

    private let targetHours: Double = 8.0

    /// Actual sleep time (from stages if available, otherwise sleepHours)
    /// Uses stages.total to exclude awake time for accurate quality assessment
    private var actualSleepTime: Double {
        sleepStages?.total ?? sleepHours
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Current sleep card
                    currentSleepCard

                    // Sleep stages breakdown
                    if let stages = sleepStages {
                        sleepStagesCard(stages: stages)
                    }

                    // Weekly trend chart
                    if !sleepTrend.isEmpty {
                        weeklyTrendSection
                    }

                    // Sleep quality insights
                    if let stages = sleepStages {
                        sleepInsightsCard(stages: stages)
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle("Sleep Analysis")
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
                    .accessibilityLabel("Close sleep analysis")
                }
            }
        }
        .onAppear {
            withAnimation(.vitalSpring.delay(0.2)) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Current Sleep Card

    private var currentSleepCard: some View {
        VitalGradientCard(
            gradient: LinearGradient(
                colors: [Color.vitalInfo, Color.vitalInfo.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: Spacing.avatarLargish, height: Spacing.avatarLargish)

                    Image(systemName: "moon.zzz.fill")
                        .font(.vitalIconLargeSemibold)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Last Night")
                        .font(.vitalBodySmall)
                        .foregroundStyle(.white.opacity(0.9))

                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        Text(String(format: "%.1f", sleepHours))
                            .font(.vitalNumberLarge)
                            .foregroundStyle(.white)

                        Text("hours")
                            .font(.vitalBody)
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Text(sleepQualityLabel)
                        .font(.vitalCaption)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                // Progress ring
                sleepProgressRing
            }
        }
        .scaleEffect(hasAppeared ? 1 : 0.95)
        .opacity(hasAppeared ? 1 : 0)
    }

    private var sleepProgressRing: some View {
        let progress = min(actualSleepTime / targetHours, 1.0)

        return ZStack {
            Circle()
                .stroke(.white.opacity(0.3), lineWidth: 6)
                .frame(width: 60, height: 60)

            Circle()
                .trim(from: 0, to: hasAppeared ? progress : 0)
                .stroke(.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0).delay(0.3), value: hasAppeared)

            Text("\(Int(progress * 100))%")
                .font(.vitalCaption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Sleep target progress")
        .accessibilityValue("\(Int(progress * 100)) percent of \(Int(targetHours)) hour target")
    }

    private var sleepQualityLabel: String {
        if actualSleepTime >= 7 && actualSleepTime <= 9 {
            return "Optimal sleep duration"
        } else if actualSleepTime >= 6 && actualSleepTime < 7 {
            return "Slightly below target"
        } else if actualSleepTime < 6 {
            return "Below recommended"
        } else {
            return "Above typical range"
        }
    }

    // MARK: - Sleep Stages Card

    private func sleepStagesCard(stages: SleepStages) -> some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Sleep Stages")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                // Stacked bar showing stage distribution
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        let total = stages.total
                        if total > 0 {
                            // Deep sleep
                            Rectangle()
                                .fill(Color.vitalInfo.opacity(0.9))
                                .frame(width: geometry.size.width * (stages.deepSleep / total))

                            // REM sleep
                            Rectangle()
                                .fill(Color.vitalAccent)
                                .frame(width: geometry.size.width * (stages.remSleep / total))

                            // Core/Light sleep
                            Rectangle()
                                .fill(Color.vitalInfo.opacity(0.4))
                                .frame(width: geometry.size.width * (stages.coreSleep / total))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                }
                .frame(height: 24)

                // Legend
                VStack(spacing: Spacing.sm) {
                    stageRow(
                        label: "Deep Sleep",
                        hours: stages.deepSleep,
                        percent: stages.deepPercent,
                        color: Color.vitalInfo.opacity(0.9),
                        icon: "powersleep"
                    )

                    stageRow(
                        label: "REM Sleep",
                        hours: stages.remSleep,
                        percent: stages.remPercent,
                        color: Color.vitalAccent,
                        icon: "brain.head.profile"
                    )

                    stageRow(
                        label: "Light Sleep",
                        hours: stages.coreSleep,
                        percent: stages.corePercent,
                        color: Color.vitalInfo.opacity(0.4),
                        icon: "moon"
                    )

                    if stages.awake > 0 {
                        stageRow(
                            label: "Awake",
                            hours: stages.awake,
                            percent: (stages.awake / (stages.total + stages.awake)) * 100,
                            color: Color.vitalWarning,
                            icon: "sun.max"
                        )
                    }
                }
            }
            .padding(Spacing.cardPadding)
        }
        .scaleEffect(hasAppeared ? 1 : 0.95)
        .opacity(hasAppeared ? 1 : 0)
        .animation(.vitalSpring.delay(0.1), value: hasAppeared)
    }

    private func stageRow(label: String, hours: Double, percent: Double, color: Color, icon: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Image(systemName: icon)
                .font(.vitalIconSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .frame(width: 20)

            Text(label)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            Spacer()

            Text(String(format: "%.1fh", hours))
                .font(.vitalBody).fontWeight(.semibold)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            Text(String(format: "(%.0f%%)", percent))
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .frame(width: 45, alignment: .trailing)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label)")
        .accessibilityValue(String(format: "%.1f hours, %.0f percent", hours, percent))
    }

    // MARK: - Weekly Trend Section

    private var weeklyTrendSection: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("7-Day Trend")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Chart(sleepTrend, id: \.date) { data in
                    BarMark(
                        x: .value("Day", data.date, unit: .day),
                        y: .value("Hours", data.totalHours)
                    )
                    .foregroundStyle(data.totalHours >= 7 ? Color.vitalSuccess : Color.vitalWarning)
                    .cornerRadius(Spacing.radiusSmall / 2)

                    // Target line
                    RuleMark(y: .value("Target", targetHours))
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
                .chartYScale(domain: 0...12)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let hours = value.as(Double.self) {
                                Text("\(Int(hours))h")
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .frame(height: 180)

                // Average
                HStack {
                    Text("Weekly Average")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    Spacer()

                    Text(String(format: "%.1f hours", averageSleep))
                        .font(.vitalBody).fontWeight(.semibold)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                }
            }
            .padding(Spacing.cardPadding)
        }
        .scaleEffect(hasAppeared ? 1 : 0.95)
        .opacity(hasAppeared ? 1 : 0)
        .animation(.vitalSpring.delay(0.2), value: hasAppeared)
    }

    private var averageSleep: Double {
        guard !sleepTrend.isEmpty else { return 0 }
        return sleepTrend.map { $0.totalHours }.reduce(0, +) / Double(sleepTrend.count)
    }

    // MARK: - Sleep Insights Card

    private func sleepInsightsCard(stages: SleepStages) -> some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("Sleep Quality")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Spacer()

                    Text("\(Int(stages.qualityScore))/100")
                        .font(.vitalH2)
                        .foregroundStyle(qualityColor(for: stages.qualityScore))
                }

                Divider()

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    insightRow(
                        insight: deepSleepInsight(stages),
                        icon: "powersleep"
                    )

                    insightRow(
                        insight: remSleepInsight(stages),
                        icon: "brain.head.profile"
                    )

                    insightRow(
                        insight: durationInsight,
                        icon: "clock"
                    )
                }
            }
            .padding(Spacing.cardPadding)
        }
        .scaleEffect(hasAppeared ? 1 : 0.95)
        .opacity(hasAppeared ? 1 : 0)
        .animation(.vitalSpring.delay(0.3), value: hasAppeared)
    }

    private func insightRow(insight: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.vitalIconSmall)
                .foregroundStyle(Color.vitalInfo)
                .frame(width: 24)

            Text(insight)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
    }

    private func deepSleepInsight(_ stages: SleepStages) -> String {
        let percent = stages.deepPercent
        if percent >= 20 && percent <= 25 {
            return "Deep sleep is optimal for physical recovery."
        } else if percent < 15 {
            return "Low deep sleep. Try earlier bedtime and avoiding alcohol."
        } else if percent > 30 {
            return "High deep sleep may indicate sleep debt recovery."
        } else {
            return "Deep sleep supports physical restoration."
        }
    }

    private func remSleepInsight(_ stages: SleepStages) -> String {
        let percent = stages.remPercent
        if percent >= 20 && percent <= 25 {
            return "REM sleep is optimal for cognitive function."
        } else if percent < 15 {
            return "Low REM sleep. Consider stress reduction techniques."
        } else {
            return "REM sleep aids memory consolidation."
        }
    }

    private var durationInsight: String {
        if actualSleepTime >= 7 && actualSleepTime <= 9 {
            return "Sleep duration is in the recommended 7-9 hour range."
        } else if actualSleepTime < 7 {
            return "Below recommended duration. Aim for 7-9 hours."
        } else {
            return "Above typical range. Monitor daytime energy levels."
        }
    }

    private func qualityColor(for score: Double) -> Color {
        switch score {
        case 80...100:
            return .vitalSuccess
        case 60..<80:
            return .vitalInfo
        case 40..<60:
            return .vitalWarning
        default:
            return .vitalDanger
        }
    }
}

// MARK: - Preview

#Preview {
    SleepDetailSheet(
        sleepHours: 7.5,
        sleepStages: SleepStages(
            deepSleep: 1.5,
            remSleep: 1.8,
            coreSleep: 4.2,
            awake: 0.3
        ),
        sleepTrend: [
            SleepTrendData(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, totalHours: 7.2, deepSleepHours: nil, remSleepHours: nil, lightSleepHours: nil),
            SleepTrendData(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, totalHours: 6.5, deepSleepHours: nil, remSleepHours: nil, lightSleepHours: nil),
            SleepTrendData(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, totalHours: 8.0, deepSleepHours: nil, remSleepHours: nil, lightSleepHours: nil),
            SleepTrendData(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, totalHours: 7.8, deepSleepHours: nil, remSleepHours: nil, lightSleepHours: nil),
            SleepTrendData(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, totalHours: 5.5, deepSleepHours: nil, remSleepHours: nil, lightSleepHours: nil),
            SleepTrendData(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, totalHours: 7.5, deepSleepHours: nil, remSleepHours: nil, lightSleepHours: nil),
            SleepTrendData(date: Date(), totalHours: 7.5, deepSleepHours: nil, remSleepHours: nil, lightSleepHours: nil)
        ]
    )
}
