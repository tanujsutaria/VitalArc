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
        VStack(spacing: 30) {
            Spacer()

            // App Icon
            Image(systemName: "heart.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundStyle(.pink.gradient)

            // Title
            Text("Welcome to VitalArc")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            // Description
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "dumbbell.fill",
                    title: "Track Workouts",
                    description: "Log your exercises and monitor progress"
                )

                FeatureRow(
                    icon: "fork.knife",
                    title: "Nutrition Logging",
                    description: "Track your meals and meet your goals"
                )

                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Health Insights",
                    description: "Sync with HealthKit for comprehensive tracking"
                )

                FeatureRow(
                    icon: "target",
                    title: "Goal Setting",
                    description: "Set and achieve your fitness goals"
                )
            }
            .padding(.horizontal)

            Spacer()

            // Continue Button
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.pink)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WelcomeView(onContinue: {})
}
