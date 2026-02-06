//
//  MetricCardView.swift
//  VitalArc
//
//  Card view for displaying individual health metrics (Legacy - use MetricCard)
//

import SwiftUI

struct MetricCardView: View {

    // MARK: - Properties

    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let trend: TrendDirection?

    // MARK: - Initialization

    init(
        title: String,
        value: String,
        unit: String,
        icon: String,
        color: Color,
        trend: TrendDirection? = nil
    ) {
        self.title = title
        self.value = value
        self.unit = unit
        self.icon = icon
        self.color = color
        self.trend = trend
    }

    // MARK: - Body

    var body: some View {
        VitalCard(shadow: true) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 36, height: 36)

                        Image(systemName: icon)
                            .font(.vitalIconSmallSemibold)
                            .foregroundStyle(color)
                    }

                    Spacer()

                    if let trend = trend {
                        trendIndicator(trend)
                    }
                }

                Text(title)
                    .font(.vitalLabelSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    Text(value)
                        .font(.vitalNumberMedium)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text(unit)
                        .font(.vitalBodySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title)")
        .accessibilityValue("\(value) \(unit)\(trend.map { ", trending \($0.description)" } ?? "")")
    }

    // MARK: - Helpers

    private func trendIndicator(_ trend: TrendDirection) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: trend.icon)
                .font(.vitalCaptionSmall)
            Text(trend.description)
                .font(.vitalCaptionSmall)
        }
        .foregroundStyle(trend.color)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(trend.color.opacity(0.15))
        .cornerRadius(Spacing.radiusSmall)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        MetricCardView(
            title: "Heart Rate Variability",
            value: "75",
            unit: "ms",
            icon: "heart.fill",
            color: .vitalDanger,
            trend: .up
        )

        MetricCardView(
            title: "Steps",
            value: "10,000",
            unit: "steps",
            icon: "figure.walk",
            color: .vitalInfo
        )

        MetricCardView(
            title: "Active Energy",
            value: "450",
            unit: "kcal",
            icon: "flame.fill",
            color: .vitalWarning,
            trend: .down
        )
    }
    .padding()
    .background(Color.vitalAdaptiveBackground)
}
