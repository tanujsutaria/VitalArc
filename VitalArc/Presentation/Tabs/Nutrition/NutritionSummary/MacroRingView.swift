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
        VStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 100, height: 100)

                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)

                // Center text
                VStack(spacing: 2) {
                    Text("\(Int(consumed))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(color)

                    if let goal = goal {
                        Text("/ \(Int(goal))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Label
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HStack(spacing: 32) {
        MacroRingView(
            name: "Calories",
            consumed: 1500,
            goal: 2000,
            color: .orange,
            unit: "kcal"
        )

        MacroRingView(
            name: "Protein",
            consumed: 120,
            goal: 150,
            color: .blue,
            unit: "g"
        )

        MacroRingView(
            name: "Carbs",
            consumed: 180,
            goal: 200,
            color: .green,
            unit: "g"
        )

        MacroRingView(
            name: "Fat",
            consumed: 50,
            goal: 60,
            color: .red,
            unit: "g"
        )
    }
    .padding()
}
