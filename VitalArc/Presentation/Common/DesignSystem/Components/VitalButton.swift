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
