//
//  MacroRingView.swift
//  VitalArc
//
//  Circular progress ring for displaying macro progress
//

import SwiftUI

struct MacroRingView: View {
    let name: String
    let consumed: Double
    let goal: Double?
    let color: Color
    let unit: String

    private var progress: Double {
        guard let goal = goal, goal > 0 else { return 0 }
        return min(consumed / goal, 1.0)
    }

    private var progressText: String {
        if let goal = goal {
            return "\(Int(consumed)) / \(Int(goal))"
        } else {
            return "\(Int(consumed))"
        }
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                    .frame(width: Spacing.illustrationMedium, height: Spacing.illustrationMedium)

                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: Spacing.illustrationMedium, height: Spacing.illustrationMedium)
                    .rotationEffect(.degrees(-90))
                    .animation(.vitalSpring, value: progress)

                // Center text
                VStack(spacing: Spacing.xxs) {
                    Text("\(Int(consumed))")
                        .font(.vitalNumberSmall)
                        .foregroundStyle(color)

                    if let goal = goal {
                        Text("/ \(Int(goal))")
                            .font(.vitalCaptionSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }
            }

            // Label
            Text(name)
                .font(.vitalLabel)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            Text(unit)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
    }
}

#Preview {
    HStack(spacing: Spacing.xl) {
        MacroRingView(
            name: "Calories",
            consumed: 1500,
            goal: 2000,
            color: .vitalWarning,
            unit: "kcal"
        )

        MacroRingView(
            name: "Protein",
            consumed: 120,
            goal: 150,
            color: .vitalDanger,
            unit: "g"
        )

        MacroRingView(
            name: "Carbs",
            consumed: 180,
            goal: 200,
            color: .vitalInfo,
            unit: "g"
        )

        MacroRingView(
            name: "Fat",
            consumed: 50,
            goal: 60,
            color: .vitalWarning,
            unit: "g"
        )
    }
    .padding()
}
