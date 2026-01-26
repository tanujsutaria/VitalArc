//
//  TermsOfServiceView.swift
//  VitalArc
//
//  Terms of service information screen
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("Terms of Service")
                    .font(.vitalH1)

                Text("Last updated: January 2026")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                Text("""
                By using VitalArc, you agree to these terms.

                Use of Service:
                • VitalArc is a fitness and health tracking app
                • You must be 13 years or older to use this app
                • You are responsible for maintaining accurate information

                Health Disclaimer:
                • VitalArc is not a medical device
                • Consult healthcare professionals for medical advice
                • Recovery scores and recommendations are estimates only

                Data:
                • You own your data
                • We do not sell or share your personal information
                • You can export or delete your data at any time

                Limitation of Liability:
                • VitalArc is provided "as is" without warranty
                • We are not liable for any health decisions made based on app data

                Contact:
                For questions, contact support@vitalarc.app
                """)
                    .font(.vitalBody)
            }
            .padding(Spacing.screenPadding)
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.vitalAdaptiveBackground)
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}
