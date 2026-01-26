//
//  AboutView.swift
//  VitalArc
//
//  About screen with app information
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    // App Icon
                    Image(systemName: "heart.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color.vitalPrimary.gradient)
                        .padding(.top, Spacing.xxl)

                    // App Name & Version
                    VStack(spacing: Spacing.sm) {
                        Text("VitalArc")
                            .font(.vitalDisplayLarge)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        Text("Version \(appVersion)")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }

                    // Description
                    VStack(spacing: Spacing.lg) {
                        Text("Your Personal Health & Fitness Companion")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            .multilineTextAlignment(.center)

                        Text("VitalArc helps you track your workouts, monitor your nutrition, and achieve your fitness goals with comprehensive health insights powered by HealthKit integration.")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Features
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        Text("Features")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            .padding(.horizontal)

                        VStack(spacing: Spacing.md) {
                            FeatureItem(
                                icon: "dumbbell.fill",
                                title: "Workout Tracking",
                                description: "Log exercises and track your progress"
                            )

                            FeatureItem(
                                icon: "fork.knife",
                                title: "Nutrition Logging",
                                description: "Track meals and meet your dietary goals"
                            )

                            FeatureItem(
                                icon: "heart.fill",
                                title: "HealthKit Integration",
                                description: "Sync with Apple Health for comprehensive tracking"
                            )

                            FeatureItem(
                                icon: "chart.xyaxis.line",
                                title: "Progress Analytics",
                                description: "Visualize your fitness journey with detailed charts"
                            )
                        }
                        .padding(.horizontal)
                    }

                    // Links
                    VStack(spacing: Spacing.md) {
                        Button(action: {
                            // TODO: Add privacy policy link
                        }) {
                            HStack {
                                Image(systemName: "lock.shield")
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.vitalCaption)
                            }
                            .padding(Spacing.lg)
                            .background(Color.vitalAdaptiveSurface)
                            .cornerRadius(Spacing.radiusMedium)
                        }
                        .foregroundColor(Color.vitalAdaptiveTextPrimary)

                        Button(action: {
                            // TODO: Add terms of service link
                        }) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Terms of Service")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.vitalCaption)
                            }
                            .padding(Spacing.lg)
                            .background(Color.vitalAdaptiveSurface)
                            .cornerRadius(Spacing.radiusMedium)
                        }
                        .foregroundColor(Color.vitalAdaptiveTextPrimary)

                        Button(action: {
                            if let url = URL(string: "mailto:support@vitalarc.app") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("Contact Support")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.vitalCaption)
                            }
                            .padding(Spacing.lg)
                            .background(Color.vitalAdaptiveSurface)
                            .cornerRadius(Spacing.radiusMedium)
                        }
                        .foregroundColor(Color.vitalAdaptiveTextPrimary)
                    }
                    .padding(.horizontal)

                    // Credits
                    VStack(spacing: Spacing.sm) {
                        Text("Made with")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(Color.vitalPrimary)
                            Text("by the VitalArc Team")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                    }
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.vitalH2)
                .foregroundStyle(Color.vitalPrimary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                Text(description)
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }

            Spacer()
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }
}

#Preview {
    AboutView()
}
