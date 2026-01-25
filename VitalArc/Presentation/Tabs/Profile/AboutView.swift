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
                VStack(spacing: 32) {
                    // App Icon
                    Image(systemName: "heart.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.pink.gradient)
                        .padding(.top, 32)

                    // App Name & Version
                    VStack(spacing: 8) {
                        Text("VitalArc")
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text("Version \(appVersion)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Description
                    VStack(spacing: 16) {
                        Text("Your Personal Health & Fitness Companion")
                            .font(.headline)
                            .multilineTextAlignment(.center)

                        Text("VitalArc helps you track your workouts, monitor your nutrition, and achieve your fitness goals with comprehensive health insights powered by HealthKit integration.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
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
                    VStack(spacing: 12) {
                        Button(action: {
                            // TODO: Add privacy policy link
                        }) {
                            HStack {
                                Image(systemName: "lock.shield")
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.primary)

                        Button(action: {
                            // TODO: Add terms of service link
                        }) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Terms of Service")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.primary)

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
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.primary)
                    }
                    .padding(.horizontal)

                    // Credits
                    VStack(spacing: 8) {
                        Text("Made with")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.pink)
                            Text("by the VitalArc Team")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.bottom, 32)
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
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.pink)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    AboutView()
}
