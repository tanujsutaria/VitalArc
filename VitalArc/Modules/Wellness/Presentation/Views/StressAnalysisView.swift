//
//  StressAnalysisView.swift
//  VitalArc
//
//  Displays stress and HRV variability analysis with daytime vs sleep comparison
//

import SwiftUI

struct StressAnalysisView: View {
    let analysis: StressAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(stressColor.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: "brain.head.profile")
                        .font(.vitalIconSmallSemibold)
                        .foregroundStyle(stressColor)
                }

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Stress Analysis")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text("HRV-based stress detection")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                Spacer()

                // Stress level badge
                Text(analysis.stressLevel.rawValue)
                    .font(.vitalLabelSmall)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(stressColor)
                    .cornerRadius(Spacing.radiusSmall)
            }

            // Daytime vs Sleep HRV comparison
            if analysis.daytimeHRV != nil || analysis.sleepHRV != nil {
                hrvComparisonSection
            }

            // Variability indicator
            if let cv = analysis.hrvCoeffientOfVariation {
                variabilityIndicator(cv)
            }

            // Insight text
            Text(analysis.insight)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Stress Analysis")
    }

    // MARK: - HRV Comparison

    private var hrvComparisonSection: some View {
        HStack(spacing: Spacing.md) {
            if let daytime = analysis.daytimeHRV {
                hrvPill(
                    label: "Daytime",
                    value: daytime,
                    icon: "sun.max.fill",
                    count: analysis.daytimeReadingCount
                )
            }

            if let sleep = analysis.sleepHRV {
                hrvPill(
                    label: "Sleep",
                    value: sleep,
                    icon: "moon.fill",
                    count: analysis.sleepReadingCount
                )
            }

            if let ratio = analysis.daytimeToSleepRatio {
                VStack(spacing: Spacing.xxs) {
                    Text("Ratio")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    Text(String(format: "%.2f", ratio))
                        .font(.vitalLabel)
                        .foregroundStyle(ratio < 0.8 ? Color.vitalWarning : Color.vitalSuccess)

                    Text(ratio < 0.8 ? "Stressed" : "Balanced")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func hrvPill(label: String, value: Double, icon: String, count: Int) -> some View {
        VStack(spacing: Spacing.xxs) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                Text(label)
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }

            Text(String(format: "%.0f", value))
                .font(.vitalLabel)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            Text("\(count) readings")
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) HRV")
        .accessibilityValue(String(format: "%.0f milliseconds from %d readings", value, count))
    }

    // MARK: - Variability Indicator

    private func variabilityIndicator(_ cv: Double) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "waveform.path.ecg")
                .font(.vitalCaptionSmall)
                .foregroundStyle(cv > 30 ? Color.vitalWarning : Color.vitalInfo)

            Text("HRV Variability: \(String(format: "%.0f%%", cv))")
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Spacer()

            Text(cv > 40 ? "Erratic" : cv > 25 ? "Variable" : "Stable")
                .font(.vitalCaptionSmall)
                .foregroundStyle(cv > 30 ? Color.vitalWarning : Color.vitalSuccess)
        }
        .padding(Spacing.sm)
        .background((cv > 30 ? Color.vitalWarning : Color.vitalInfo).opacity(0.08))
        .cornerRadius(Spacing.radiusSmall)
    }

    // MARK: - Helpers

    private var stressColor: Color {
        switch analysis.stressLevel {
        case .low: return .vitalSuccess
        case .moderate: return .vitalInfo
        case .elevated: return .vitalWarning
        case .high: return .vitalDanger
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VitalCard {
            StressAnalysisView(
                analysis: StressAnalysis(
                    date: Date(),
                    daytimeHRV: 45,
                    sleepHRV: 68,
                    overallHRV: 55,
                    stressLevel: .elevated,
                    hrvCoeffientOfVariation: 32,
                    daytimeReadingCount: 12,
                    sleepReadingCount: 8,
                    insight: "Daytime HRV is significantly below your baseline. Consider reducing intense activity and prioritizing recovery."
                )
            )
        }
        .padding(Spacing.screenPadding)
    }
    .background(Color.vitalAdaptiveBackground)
}
