//
//  WelcomeView.swift
//  VitalArc
//
//  Welcome screen for onboarding
//

import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.vitalPrimary.vitalVeryLight(), Color.vitalAccent.vitalVeryLight()],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // App Icon with animated gradient
                ZStack {
                    Circle()
                        .fill(Color.vitalPrimaryGradient)
                        .frame(width: Spacing.illustrationXLarge, height: Spacing.illustrationXLarge)
                        .blur(radius: 20)

                    Image(systemName: "heart.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Spacing.illustrationLarge, height: Spacing.illustrationLarge)
                        .foregroundStyle(Color.vitalPrimaryGradient)
                }

                // Title
                VStack(spacing: Spacing.sm) {
                    Text("Welcome to")
                        .font(.vitalH2)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    Text("VitalArc")
                        .font(.vitalDisplayLarge)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                }
                .multilineTextAlignment(.center)

                // Description
                VStack(spacing: Spacing.md) {
                    FeatureRow(
                        icon: "dumbbell.fill",
                        title: "Track Workouts",
                        description: "Log your exercises and monitor progress",
                        color: .vitalDanger
                    )

                    FeatureRow(
                        icon: "fork.knife",
                        title: "Nutrition Logging",
                        description: "Track your meals and meet your goals",
                        color: .vitalWarning
                    )

                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Health Insights",
                        description: "Sync with HealthKit for comprehensive tracking",
                        color: .vitalInfo
                    )

                    FeatureRow(
                        icon: "target",
                        title: "Goal Setting",
                        description: "Set and achieve your fitness goals",
                        color: .vitalSuccess
                    )
                }
                .padding(.horizontal, Spacing.screenPadding)

                Spacer()

                // Continue Button
                VitalButton(
                    title: "Get Started",
                    style: .primary,
                    size: .large,
                    fullWidth: true
                ) {
                    onContinue()
                }
                .padding(.horizontal, Spacing.screenPadding)
                .padding(.bottom, Spacing.md)
            }
            .padding(.vertical, Spacing.xl)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.vitalLight())
                    .frame(width: Spacing.avatarMedium, height: Spacing.avatarMedium)

                Image(systemName: icon)
                    .font(.vitalIconMediumSemibold)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.vitalLabel)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Text(description)
                    .font(.vitalBodySmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }

            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
        .vitalCardShadow()
    }
}

#Preview {
    WelcomeView(onContinue: {})
}
