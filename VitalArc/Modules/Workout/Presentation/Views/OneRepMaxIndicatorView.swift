//
//  OneRepMaxIndicatorView.swift
//  VitalArc
//
//  Shows estimated 1RM with color-coded historical comparison
//

import SwiftUI

struct OneRepMaxIndicatorView: View {
    let estimated1RM: Double?
    let historicalBest: Double?

    var body: some View {
        if let e1rm = estimated1RM {
            HStack(spacing: Spacing.xs) {
                Text("e1RM: \(Int(e1rm)) kg")
                    .font(.vitalCaption)
                    .monospacedDigit()

                if let best = historicalBest, e1rm >= best {
                    Text("PR!")
                        .font(.vitalCaption)
                        .fontWeight(.bold)
                }
            }
            .foregroundStyle(indicatorColor)
        }
    }

    private var indicatorColor: Color {
        guard let best = historicalBest, let e1rm = estimated1RM else {
            return Color.vitalAdaptiveTextSecondary
        }
        if e1rm >= best {
            return Color.vitalSuccess
        } else if e1rm >= best * 0.95 {
            return Color.vitalWarning
        } else {
            return Color.vitalAdaptiveTextSecondary
        }
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        OneRepMaxIndicatorView(estimated1RM: 133.3, historicalBest: 130.0)
        OneRepMaxIndicatorView(estimated1RM: 125.0, historicalBest: 130.0)
        OneRepMaxIndicatorView(estimated1RM: 100.0, historicalBest: 130.0)
        OneRepMaxIndicatorView(estimated1RM: nil, historicalBest: 130.0)
    }
    .padding()
}
