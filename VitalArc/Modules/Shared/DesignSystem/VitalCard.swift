//
//  VitalCard.swift
//  VitalArc
//
//  Reusable card component with modern design
//

import SwiftUI

// MARK: - Card Elevation Levels (V2)

enum CardElevation {
    case flat       // No shadow, base surface
    case raised     // Subtle lift for interactive elements
    case elevated   // Standard card elevation (default)
    case floating   // High elevation for modals
    case hero       // Maximum elevation for featured content
}

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

// MARK: - V2 Premium Card

/// Premium card component with elevation system, inner glow, and press animations
struct VitalCardV2<Content: View>: View {
    let content: Content
    var padding: CGFloat = Spacing.cardPadding
    var elevation: CardElevation = .elevated
    var backgroundColor: Color = .vitalAdaptiveSurfaceV2
    var cornerRadius: CGFloat = Spacing.radiusLargeV2
    var isTappable: Bool = false
    var showInnerGlow: Bool = true

    @State private var isPressed = false

    init(
        padding: CGFloat = Spacing.cardPadding,
        elevation: CardElevation = .elevated,
        backgroundColor: Color = .vitalAdaptiveSurfaceV2,
        cornerRadius: CGFloat = Spacing.radiusLargeV2,
        isTappable: Bool = false,
        showInnerGlow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.elevation = elevation
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.isTappable = isTappable
        self.showInnerGlow = showInnerGlow
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(innerGlowOverlay)
            .modifier(ElevationModifierV2(elevation: elevation))
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.vitalSpring, value: isPressed)
            .simultaneousGesture(
                isTappable ? pressGesture : nil
            )
    }

    @ViewBuilder
    private var innerGlowOverlay: some View {
        if showInnerGlow {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        }
    }

    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if !isPressed {
                    isPressed = true
                    HapticFeedback.light()
                }
            }
            .onEnded { _ in
                isPressed = false
            }
    }
}

// MARK: - V2 Elevation Modifier

private struct ElevationModifierV2: ViewModifier {
    let elevation: CardElevation
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        switch elevation {
        case .flat:
            content
        case .raised:
            content
                .shadow(
                    color: shadowColor(opacity: 0.12),
                    radius: 4,
                    x: 0,
                    y: 1
                )
        case .elevated:
            content
                .shadow(
                    color: shadowColor(opacity: 0.08),
                    radius: 2,
                    x: 0,
                    y: 1
                )
                .shadow(
                    color: shadowColor(opacity: 0.12),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        case .floating:
            content
                .shadow(
                    color: shadowColor(opacity: 0.08),
                    radius: 2,
                    x: 0,
                    y: 1
                )
                .shadow(
                    color: shadowColor(opacity: 0.16),
                    radius: 16,
                    x: 0,
                    y: 8
                )
        case .hero:
            content
                .shadow(
                    color: shadowColor(opacity: 0.08),
                    radius: 4,
                    x: 0,
                    y: 2
                )
                .shadow(
                    color: shadowColor(opacity: 0.24),
                    radius: 24,
                    x: 0,
                    y: 12
                )
        }
    }

    private func shadowColor(opacity: Double) -> Color {
        colorScheme == .dark
            ? Color.black.opacity(opacity * 1.5)
            : Color.black.opacity(opacity)
    }
}

// MARK: - V2 Tappable Card

/// Convenience wrapper for tappable cards with press animation
struct VitalTappableCardV2<Content: View>: View {
    let content: Content
    var padding: CGFloat = Spacing.cardPadding
    var elevation: CardElevation = .elevated
    var backgroundColor: Color = .vitalAdaptiveSurfaceV2
    var cornerRadius: CGFloat = Spacing.radiusLargeV2
    let action: () -> Void

    @State private var isPressed = false

    init(
        padding: CGFloat = Spacing.cardPadding,
        elevation: CardElevation = .elevated,
        backgroundColor: Color = .vitalAdaptiveSurfaceV2,
        cornerRadius: CGFloat = Spacing.radiusLargeV2,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.elevation = elevation
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            content
                .padding(padding)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
                .modifier(ElevationModifierV2(elevation: elevation))
        }
        .buttonStyle(CardPressStyle())
    }
}

private struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.vitalSpring, value: configuration.isPressed)
    }
}

// MARK: - V2 Gradient Card

struct VitalGradientCardV2<Content: View>: View {
    let gradient: LinearGradient
    let content: Content
    var padding: CGFloat = Spacing.cardPadding
    var cornerRadius: CGFloat = Spacing.radiusLargeV2
    var glowColor: Color? = nil
    var glowIntensity: Double = 0.3

    init(
        gradient: LinearGradient,
        padding: CGFloat = Spacing.cardPadding,
        cornerRadius: CGFloat = Spacing.radiusLargeV2,
        glowColor: Color? = nil,
        glowIntensity: Double = 0.3,
        @ViewBuilder content: () -> Content
    ) {
        self.gradient = gradient
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.glowColor = glowColor
        self.glowIntensity = glowIntensity
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .modifier(GlowModifier(color: glowColor, intensity: glowIntensity))
            .vitalElevatedShadowV2()
    }
}

private struct GlowModifier: ViewModifier {
    let color: Color?
    let intensity: Double

    func body(content: Content) -> some View {
        if let color = color {
            content.shadow(color: color.opacity(intensity), radius: 12, x: 0, y: 0)
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
