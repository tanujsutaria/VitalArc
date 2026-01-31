//
//  VitalButton.swift
//  VitalArc
//
//  Modern button component with various styles
//

import SwiftUI

struct VitalButton: View {
    enum Style {
        case primary
        case secondary
        case outline
        case text
        case danger
        case success

        var backgroundColor: Color {
            switch self {
            case .primary: return .vitalPrimary
            case .secondary: return .vitalSecondary
            case .outline: return .clear
            case .text: return .clear
            case .danger: return .vitalDanger
            case .success: return .vitalSuccess
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .secondary, .danger, .success: return .white
            case .outline: return .vitalPrimary
            case .text: return .vitalAdaptiveTextPrimary
            }
        }

        var borderColor: Color? {
            switch self {
            case .outline: return .vitalPrimary
            default: return nil
            }
        }
    }

    enum Size {
        case small
        case medium
        case large

        var fontSize: Font {
            switch self {
            case .small: return .vitalLabelSmall
            case .medium: return .vitalLabel
            case .large: return .vitalH4
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            case .medium: return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            case .large: return EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
            }
        }
    }

    let title: String
    let style: Style
    let size: Size
    let icon: String?
    let fullWidth: Bool
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    init(
        title: String,
        style: Style = .primary,
        size: Size = .medium,
        icon: String? = nil,
        fullWidth: Bool = false,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.icon = icon
        self.fullWidth = fullWidth
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(size.fontSize)
                    }
                    Text(title)
                        .font(size.fontSize)
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(style.foregroundColor)
            .padding(size.padding)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(style.backgroundColor)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(style.borderColor ?? .clear, lineWidth: Spacing.borderMedium)
            )
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .vitalScaleButton()
    }
}

// MARK: - Icon Button

struct VitalIconButton: View {
    let icon: String
    let style: VitalButton.Style
    let size: CGFloat
    let action: () -> Void

    init(
        icon: String,
        style: VitalButton.Style = .primary,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4))
                .foregroundStyle(style.foregroundColor)
                .frame(width: size, height: size)
                .background(style.backgroundColor)
                .clipShape(Circle())
                .vitalCardShadow()
        }
        .vitalScaleButton()
    }
}

// MARK: - V2 Premium Button

struct VitalButtonV2: View {
    enum Style {
        case primary
        case secondary
        case accent
        case outline
        case ghost
        case danger
        case success

        var backgroundColor: Color {
            switch self {
            case .primary: return .vitalPrimaryV2
            case .secondary: return .vitalSecondaryV2
            case .accent: return .vitalAccentV2
            case .outline, .ghost: return .clear
            case .danger: return .vitalDangerV2
            case .success: return .vitalSuccessV2
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .secondary, .danger, .success: return .white
            case .accent: return .vitalBackgroundV2
            case .outline: return .vitalPrimaryV2
            case .ghost: return .vitalAdaptiveTextPrimaryV2
            }
        }

        var borderColor: Color? {
            switch self {
            case .outline: return .vitalPrimaryV2
            default: return nil
            }
        }

        var glowColor: Color {
            switch self {
            case .primary, .danger: return .vitalPrimaryV2
            case .secondary: return .vitalSecondaryV2
            case .accent: return .vitalAccentV2
            case .success: return .vitalSuccessV2
            case .outline, .ghost: return .clear
            }
        }

        var gradient: LinearGradient? {
            switch self {
            case .primary: return Color.vitalPrimaryGradientV2
            case .accent: return Color.vitalAccentGradientV2
            case .success: return Color.vitalSuccessGradientV2
            default: return nil
            }
        }
    }

    enum Size {
        case small
        case medium
        case large

        var fontSize: Font {
            switch self {
            case .small: return .vitalLabelSmallV2
            case .medium: return .vitalLabelV2
            case .large: return .vitalH4V2
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
            case .medium: return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
            case .large: return EdgeInsets(top: 16, leading: 28, bottom: 16, trailing: 28)
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return Spacing.radiusSmallV2
            case .medium: return Spacing.radiusMediumV2
            case .large: return Spacing.radiusLargeV2
            }
        }
    }

    let title: String
    var style: Style = .primary
    var size: Size = .medium
    var icon: String? = nil
    var iconPosition: IconPosition = .leading
    var fullWidth: Bool = false
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var showGlow: Bool = true
    let action: () -> Void

    enum IconPosition {
        case leading
        case trailing
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticFeedback.medium()
            action()
        }) {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    LoadingDotsV2()
                } else {
                    if let icon = icon, iconPosition == .leading {
                        Image(systemName: icon)
                            .font(size.fontSize)
                    }
                    Text(title)
                        .font(size.fontSize)
                        .fontWeight(.semibold)
                    if let icon = icon, iconPosition == .trailing {
                        Image(systemName: icon)
                            .font(size.fontSize)
                    }
                }
            }
            .foregroundStyle(style.foregroundColor)
            .padding(size.padding)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
            .overlay(borderOverlay)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(PremiumButtonStyle(
            glowColor: showGlow ? style.glowColor : .clear,
            glowIntensity: isPressed ? 0.5 : 0.3
        ))
    }

    @ViewBuilder
    private var buttonBackground: some View {
        if let gradient = style.gradient {
            gradient
        } else {
            style.backgroundColor
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if let borderColor = style.borderColor {
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .stroke(borderColor, lineWidth: Spacing.borderMedium)
        }
    }
}

// MARK: - Premium Button Style (Glow + Scale)

private struct PremiumButtonStyle: ButtonStyle {
    let glowColor: Color
    let glowIntensity: Double

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .shadow(
                color: configuration.isPressed
                    ? glowColor.opacity(glowIntensity + 0.2)
                    : glowColor.opacity(glowIntensity),
                radius: configuration.isPressed ? 16 : 12,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .animation(.vitalSpring, value: configuration.isPressed)
    }
}

// MARK: - Animated Loading Dots

struct LoadingDotsV2: View {
    @State private var animatingDot = 0

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .scaleEffect(animatingDot == index ? 1.2 : 0.8)
                    .opacity(animatingDot == index ? 1.0 : 0.5)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            withAnimation(.vitalSpring) {
                animatingDot = (animatingDot + 1) % 3
            }
        }
    }
}

// MARK: - V2 Icon Button

struct VitalIconButtonV2: View {
    let icon: String
    var style: VitalButtonV2.Style = .primary
    var size: CGFloat = 44
    var showGlow: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.medium()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(style.foregroundColor)
                .frame(width: size, height: size)
                .background(style.backgroundColor)
                .clipShape(Circle())
        }
        .buttonStyle(PremiumButtonStyle(
            glowColor: showGlow ? style.glowColor : .clear,
            glowIntensity: 0.3
        ))
    }
}

// MARK: - V2 Floating Action Button

struct VitalFABV2: View {
    let icon: String
    var size: CGFloat = 56
    var backgroundColor: Color = .vitalPrimaryV2
    var foregroundColor: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.medium()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(foregroundColor)
                .frame(width: size, height: size)
                .background(
                    LinearGradient(
                        colors: [backgroundColor, backgroundColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PremiumButtonStyle(
            glowColor: backgroundColor,
            glowIntensity: 0.4
        ))
        .vitalHeroShadowV2()
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            // Primary buttons
            VStack(spacing: Spacing.md) {
                Text("Primary Buttons").font(.vitalH3)

                VitalButton(title: "Primary Large", size: .large, fullWidth: true) {}
                VitalButton(title: "Primary Medium", size: .medium, fullWidth: true) {}
                VitalButton(title: "Primary Small", size: .small, fullWidth: true) {}
                VitalButton(title: "With Icon", icon: "heart.fill", fullWidth: true) {}
                VitalButton(title: "Loading", fullWidth: true, isLoading: true) {}
                VitalButton(title: "Disabled", fullWidth: true, isDisabled: true) {}
            }

            Divider()

            // Other styles
            VStack(spacing: Spacing.md) {
                Text("Button Styles").font(.vitalH3)

                VitalButton(title: "Secondary", style: .secondary, fullWidth: true) {}
                VitalButton(title: "Outline", style: .outline, fullWidth: true) {}
                VitalButton(title: "Text", style: .text, fullWidth: true) {}
                VitalButton(title: "Danger", style: .danger, fullWidth: true) {}
                VitalButton(title: "Success", style: .success, fullWidth: true) {}
            }

            Divider()

            // Icon buttons
            VStack(spacing: Spacing.md) {
                Text("Icon Buttons").font(.vitalH3)

                HStack(spacing: Spacing.md) {
                    VitalIconButton(icon: "heart.fill") {}
                    VitalIconButton(icon: "plus", style: .secondary) {}
                    VitalIconButton(icon: "trash", style: .danger) {}
                    VitalIconButton(icon: "checkmark", style: .success) {}
                }
            }
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
