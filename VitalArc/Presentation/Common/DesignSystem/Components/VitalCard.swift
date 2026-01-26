//
//  VitalCard.swift
//  VitalArc
//
//  Reusable card component with modern design
//

import SwiftUI

struct VitalCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = Spacing.cardPadding
    var shadow: Bool = true
    var backgroundColor: Color = .vitalAdaptiveSurface
    var cornerRadius: CGFloat = Spacing.radiusLarge

    init(
        padding: CGFloat = Spacing.cardPadding,
        shadow: Bool = true,
        backgroundColor: Color = .vitalAdaptiveSurface,
        cornerRadius: CGFloat = Spacing.radiusLarge,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.shadow = shadow
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .modifier(ShadowModifier(enabled: shadow))
    }
}

// MARK: - Shadow Modifier

private struct ShadowModifier: ViewModifier {
    let enabled: Bool
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        if enabled {
            content.shadow(
                color: colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.05),
                radius: 8,
                x: 0,
                y: 2
            )
        } else {
            content
        }
    }
}

// MARK: - Gradient Card

struct VitalGradientCard<Content: View>: View {
    let gradient: LinearGradient
    let content: Content
    var padding: CGFloat = Spacing.cardPadding
    var cornerRadius: CGFloat = Spacing.radiusLarge

    init(
        gradient: LinearGradient,
        padding: CGFloat = Spacing.cardPadding,
        cornerRadius: CGFloat = Spacing.radiusLarge,
        @ViewBuilder content: () -> Content
    ) {
        self.gradient = gradient
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(gradient)
            .cornerRadius(cornerRadius)
            .vitalCardShadow()
    }
}

// MARK: - Bordered Card

struct VitalBorderedCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = Spacing.cardPadding
    var borderColor: Color = .vitalAdaptiveBorder
    var cornerRadius: CGFloat = Spacing.radiusLarge

    init(
        padding: CGFloat = Spacing.cardPadding,
        borderColor: Color = .vitalAdaptiveBorder,
        cornerRadius: CGFloat = Spacing.radiusLarge,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: Spacing.borderThin)
            )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Standard Card")
                    .font(.vitalH3)
                Text("This is a standard card with shadow")
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }

        VitalGradientCard(gradient: Color.vitalPrimaryGradient) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Gradient Card")
                    .font(.vitalH3)
                    .foregroundStyle(.white)
                Text("This is a gradient card")
                    .font(.vitalBody)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }

        VitalBorderedCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Bordered Card")
                    .font(.vitalH3)
                Text("This is a bordered card without shadow")
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }
    }
    .padding()
    .background(Color.vitalAdaptiveBackground)
}
