//
//  RestTimerView.swift
//  VitalArc
//
//  Countdown rest timer displayed between sets
//

import SwiftUI

struct RestTimerView: View {
    let endDate: Date
    let totalDuration: Int
    let onCancel: () -> Void
    let onFinished: () -> Void

    @State private var hasNotified = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.25)) { context in
            let remaining = max(endDate.timeIntervalSince(context.date), 0)
            let progress = 1.0 - (remaining / TimeInterval(totalDuration))

            VStack(spacing: Spacing.sm) {
                HStack(spacing: Spacing.md) {
                    // Timer circle
                    ZStack {
                        Circle()
                            .stroke(Color.vitalPrimary.opacity(0.2), lineWidth: 4)
                            .frame(width: Spacing.frameTouchTarget, height: Spacing.frameTouchTarget)

                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(Color.vitalPrimary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: Spacing.frameTouchTarget, height: Spacing.frameTouchTarget)
                            .rotationEffect(.degrees(-90))

                        Image(systemName: "timer")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalPrimary)
                    }

                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Rest Timer")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                        Text(formatTime(remaining))
                            .font(.vitalH2)
                            .monospacedDigit()
                            .foregroundStyle(remaining <= 10 ? Color.vitalDanger : Color.vitalAdaptiveTextPrimary)
                    }

                    Spacer()

                    Button {
                        onCancel()
                    } label: {
                        Text("Skip")
                            .font(.vitalLabel)
                            .foregroundStyle(Color.vitalPrimary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.vitalPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Spacing.md)
            .background(Color.vitalAdaptiveSurface)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
            .onChange(of: remaining <= 0) { _, finished in
                if finished && !hasNotified {
                    hasNotified = true
                    triggerHaptic()
                    onFinished()
                }
            }
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    RestTimerView(
        endDate: Date().addingTimeInterval(90),
        totalDuration: 90,
        onCancel: {},
        onFinished: {}
    )
    .padding()
}
