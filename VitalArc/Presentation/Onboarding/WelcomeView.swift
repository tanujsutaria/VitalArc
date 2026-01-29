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
                colors: [Color.vitalPrimary.opacity(0.1), Color.vitalAccent.opacity(0.1)],
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
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)

                    Image(systemName: "heart.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
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
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: Spacing.iconMedium, weight: .semibold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
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
