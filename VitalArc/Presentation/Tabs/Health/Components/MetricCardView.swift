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
                            .font(.system(size: 16, weight: .semibold))
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

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.vitalNumberMedium)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text(unit)
                        .font(.vitalBodySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
    }

    // MARK: - Helpers

    private func trendIndicator(_ trend: TrendDirection) -> some View {
        HStack(spacing: 2) {
            Image(systemName: trend.icon)
                .font(.system(size: 10, weight: .semibold))
            Text(trend.description)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(trend.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(trend.color.opacity(0.15))
        .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        MetricCardView(
            title: "Heart Rate Variability",
            value: "75",
            unit: "ms",
            icon: "heart.fill",
            color: .red,
            trend: .up
        )

        MetricCardView(
            title: "Steps",
            value: "10,000",
            unit: "steps",
            icon: "figure.walk",
            color: .blue
        )

        MetricCardView(
            title: "Active Energy",
            value: "450",
            unit: "kcal",
            icon: "flame.fill",
            color: .orange,
            trend: .down
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
