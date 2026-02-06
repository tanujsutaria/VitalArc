//
//  MetricCard.swift
//  VitalArc
//
//  Modern metric card with gradient and sparkline
//

import SwiftUI

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
        case .up: return .vitalSuccess
        case .down: return .vitalDanger
        case .stable: return .vitalTextSecondary
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let trend: TrendDirection?
    let sparklineData: [Double]?
    var onTap: (() -> Void)?

    init(
        title: String,
        value: String,
        unit: String,
        icon: String,
        color: Color,
        trend: TrendDirection? = nil,
        sparklineData: [Double]? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.unit = unit
        self.icon = icon
        self.color = color
        self.trend = trend
        self.sparklineData = sparklineData
        self.onTap = onTap
    }

    var body: some View {
        Group {
            if let onTap = onTap {
                Button(action: onTap) {
                    cardContent
                }
                .buttonStyle(.plain)
            } else {
                cardContent
            }
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        VitalCard(shadow: true) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Header with icon and trend
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

                // Title
                Text(title)
                    .font(.vitalLabelSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                // Value
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    Text(value)
                        .font(.vitalNumberMedium)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text(unit)
                        .font(.vitalBodySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                // Sparkline
                if let data = sparklineData, !data.isEmpty {
                    SparklineView(data: data, color: color)
                        .frame(height: 30)
                        .padding(.top, Spacing.xs)
                }
            }
        }
    }

    @ViewBuilder
    private func trendIndicator(_ trend: TrendDirection) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: trend.icon)
                .font(.vitalCaptionSmall)
            Text(trend.description)
                .font(.vitalCaptionSmall)
        }
        .foregroundStyle(trend.color)
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(trend.color.opacity(0.15))
        .cornerRadius(Spacing.radiusSmall)
    }
}

// MARK: - Sparkline View

struct SparklineView: View {
    let data: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 1
            let minValue = data.min() ?? 0
            let range = maxValue - minValue

            Path { path in
                guard !data.isEmpty else { return }

                let stepX = geometry.size.width / CGFloat(data.count - 1)
                let stepY = geometry.size.height / CGFloat(max(range, 1))

                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = geometry.size.height - CGFloat(value - minValue) * stepY

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Preview

/*
#Preview {
    VStack(spacing: Spacing.md) {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
            MetricCard(
                title: "Heart Rate",
                value: "72",
                unit: "BPM",
                icon: "heart.fill",
                color: .vitalDanger,
                trend: .down,
                sparklineData: [65, 68, 70, 72, 71, 69, 72]
            )

            MetricCard(
                title: "Steps",
                value: "8,432",
                unit: "steps",
                icon: "figure.walk",
                color: .vitalInfo,
                trend: .up,
                sparklineData: [6000, 7200, 8100, 7800, 8432]
            )

            MetricCard(
                title: "Active Energy",
                value: "450",
                unit: "kcal",
                icon: "flame.fill",
                color: .vitalWarning,
                sparklineData: [400, 420, 410, 430, 450]
            )

            MetricCard(
                title: "Sleep",
                value: "7.5",
                unit: "hours",
                icon: "bed.double.fill",
                color: .vitalSecondary,
                trend: .stable
            )
        }
    }
    .padding()
    .background(Color.vitalAdaptiveBackground)
}
*/
