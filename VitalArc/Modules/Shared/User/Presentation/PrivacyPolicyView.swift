//
//  PrivacyPolicyView.swift
//  VitalArc
//
//  Privacy policy information screen
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("Privacy Policy")
                    .font(.vitalH1)

                Text("Last updated: January 2026")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                Text("""
                VitalArc respects your privacy. This app stores all your health and fitness data locally on your device.

                Data Collection:
                • Health metrics from Apple HealthKit (with your permission)
                • Workout and nutrition logs you create
                • Profile information you provide

                Data Storage:
                • All data is stored locally on your device
                • No data is transmitted to external servers
                • You can delete all data at any time from Settings

                Third-Party Services:
                • Only search queries are sent, no personal data

                Contact:
                For privacy concerns, contact support@vitalarc.app
                """)
                    .font(.vitalBody)
            }
            .padding(Spacing.screenPadding)
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.vitalAdaptiveBackground)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
