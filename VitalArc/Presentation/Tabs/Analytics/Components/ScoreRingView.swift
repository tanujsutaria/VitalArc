//
//  ScoreRingView.swift
//  VitalArc
//
//  Animated circular score ring for recovery, strain, and sleep scores
//

import SwiftUI

struct ScoreRingView: View {
    let score: Double // 0-100
    let title: String
    let subtitle: String
    let gradient: LinearGradient
    let size: CGFloat
    let lineWidth: CGFloat

    @State private var animatedProgress: Double = 0

    init(
        score: Double,
        title: String,
        subtitle: String = "",
        gradient: LinearGradient,
        size: CGFloat = 100,
        lineWidth: CGFloat = 10
    ) {
        self.score = max(0, min(100, score))
        self.title = title
        self.subtitle = subtitle
        self.gradient = gradient
        self.size = size
        self.lineWidth = lineWidth
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.vitalAdaptiveBorder.opacity(0.3), lineWidth: lineWidth)

                // Progress ring
                Circle()
                    .trim(from: 0, to: animatedProgress / 100)
                    .stroke(
                        gradient,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                // Score text
                VStack(spacing: 0) {
                    Text("\(Int(animatedProgress))")
                        .font(.vitalNumberLarge)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        .contentTransition(.numericText())
                }
            }
            .frame(width: size, height: size)

            VStack(spacing: 2) {
                Text(title)
                    .font(.vitalLabelSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
        .onAppear {
            withAnimation(.vitalSpringBouncy.delay(0.2)) {
                animatedProgress = score
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.vitalSpring) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Large Score Card

struct LargeScoreCard: View {
    let score: Double
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    let trend: TrendDirection?
    let trendValue: String?

    @State private var animatedScore: Double = 0

    var body: some View {
        VitalGradientCard(gradient: gradient, padding: Spacing.lg) {
            HStack(spacing: Spacing.lg) {
                // Score ring
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: animatedScore / 100)
                        .stroke(
                            .white,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(animatedScore))")
                        .font(.vitalNumberMedium)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: icon)
                            .font(.system(size: Spacing.iconSmall, weight: .semibold))
                        Text(title)
                            .font(.vitalLabel)
                    }
                    .foregroundStyle(.white.opacity(0.9))

                    Text(subtitle)
                        .font(.vitalH2)
                        .foregroundStyle(.white)

                    if let trend = trend, let trendValue = trendValue {
                        HStack(spacing: 4) {
                            Image(systemName: trend.icon)
                                .font(.system(size: Spacing.iconTiny, weight: .semibold))
                            Text(trendValue)
                                .font(.vitalCaptionSmall)
                        }
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2))
                        .cornerRadius(Spacing.radiusSmall)
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.vitalSpringBouncy.delay(0.1)) {
                animatedScore = score
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.vitalSpring) {
                animatedScore = newValue
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            HStack(spacing: Spacing.lg) {
                ScoreRingView(
                    score: 85,
                    title: "Recovery",
                    subtitle: "Excellent",
                    gradient: Color.vitalSuccessGradient
                )

                ScoreRingView(
                    score: 62,
                    title: "Strain",
                    subtitle: "Moderate",
                    gradient: Color.vitalPrimaryGradient
                )

                ScoreRingView(
                    score: 78,
                    title: "Sleep",
                    subtitle: "Good",
                    gradient: Color.vitalAccentGradient
                )
            }

            LargeScoreCard(
                score: 85,
                title: "Recovery Score",
                subtitle: "Excellent",
                icon: "heart.fill",
                gradient: Color.vitalSuccessGradient,
                trend: .up,
                trendValue: "+5% vs last week"
            )

            LargeScoreCard(
                score: 14.2,
                title: "Day Strain",
                subtitle: "High Intensity",
                icon: "flame.fill",
                gradient: Color.vitalPrimaryGradient,
                trend: .stable,
                trendValue: "On target"
            )
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
