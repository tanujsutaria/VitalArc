//
//  MetricCardView.swift
//  VitalArc
//
//  Card view for displaying individual health metrics
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)

                Spacer()

                if let trend = trend {
                    trendIndicator(trend)
                }
            }

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(unit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Helpers

    private func trendIndicator(_ trend: TrendDirection) -> some View {
        HStack(spacing: 2) {
            Image(systemName: trend.icon)
                .font(.caption)
            Text(trend.description)
                .font(.caption2)
        }
        .foregroundStyle(trend.color)
    }
}

// MARK: - Trend Direction

enum TrendDirection {
    case up
    case down
    case stable

    var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }

    var description: String {
        switch self {
        case .up: return "Up"
        case .down: return "Down"
        case .stable: return "Stable"
        }
    }

    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .stable: return .gray
        }
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
