//
//  NotificationPreviewCard.swift
//  VitalArc
//
//  iOS-style notification preview component
//

import SwiftUI

struct NotificationPreviewCard: View {
    let title: String
    let message: String
    let icon: String
    let color: Color

    var body: some View {
        VitalCard(padding: Spacing.md) {
            HStack(spacing: Spacing.md) {
                // App Icon
                ZStack {
                    RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: Spacing.iconMedium, weight: .semibold))
                        .foregroundStyle(color)
                }

                // Notification Content
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // Header
                    HStack(spacing: Spacing.xs) {
                        Text("VITALARC")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextTertiary)
                            .fontWeight(.semibold)

                        Text("now")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextTertiary)
                    }

                    // Title
                    Text(title)
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    // Body
                    Text(message)
                        .font(.vitalBodySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        NotificationPreviewCard(
            title: "Time to Train!",
            message: "Your scheduled workout is ready. Let's crush those goals!",
            icon: "figure.walk",
            color: .vitalPrimary
        )

        NotificationPreviewCard(
            title: "Recovery Day",
            message: "Your body needs rest. Consider a lighter workout today.",
            icon: "bed.double.fill",
            color: .vitalWarning
        )

        NotificationPreviewCard(
            title: "Great Job!",
            message: "You've completed 5 workouts this week. Keep it up!",
            icon: "star.fill",
            color: .vitalSuccess
        )
    }
    .padding()
    .background(Color.vitalAdaptiveBackground)
}
