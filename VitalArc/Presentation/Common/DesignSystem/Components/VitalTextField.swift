//
//  VitalTextField.swift
//  VitalArc
//
//  Modern text field component
//

import SwiftUI

struct VitalTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if !title.isEmpty {
                Text(title)
                    .font(.vitalLabelSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }

            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundStyle(isFocused ? Color.vitalPrimary : Color.vitalAdaptiveTextSecondary)
                        .frame(width: Spacing.iconMedium)
                }

                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .textInputAutocapitalization(autocapitalization)
                    }
                }
                .font(.vitalBody)
                .focused($isFocused)
            }
            .padding(Spacing.md)
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(
                        errorMessage != nil ? Color.vitalDanger :
                        isFocused ? Color.vitalPrimary : Color.vitalAdaptiveBorder,
                        lineWidth: isFocused ? Spacing.borderMedium : Spacing.borderThin
                    )
            )
            .animation(.vitalSpring, value: isFocused)

            if let errorMessage = errorMessage {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.vitalCaptionSmall)
                    Text(errorMessage)
                        .font(.vitalCaptionSmall)
                }
                .foregroundStyle(Color.vitalDanger)
                .transition(.vitalSlideUp)
            }
        }
    }
}

// MARK: - Multi-line Text Field

struct VitalTextEditor: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var minHeight: CGFloat = 100

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if !title.isEmpty {
                Text(title)
                    .font(.vitalLabelSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalTextTertiary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.md)
                }

                TextEditor(text: $text)
                    .font(.vitalBody)
                    .focused($isFocused)
                    .padding(Spacing.sm)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: minHeight)
            }
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(
                        isFocused ? Color.vitalPrimary : Color.vitalAdaptiveBorder,
                        lineWidth: isFocused ? Spacing.borderMedium : Spacing.borderThin
                    )
            )
            .animation(.vitalSpring, value: isFocused)
        }
    }
}

// MARK: - Search Field

struct VitalSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onClear: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .frame(width: Spacing.iconMedium)

            TextField(placeholder, text: $text)
                .font(.vitalBody)
                .focused($isFocused)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onClear?()
                    HapticFeedback.light()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .stroke(
                    isFocused ? Color.vitalPrimary : Color.vitalAdaptiveBorder,
                    lineWidth: isFocused ? Spacing.borderMedium : Spacing.borderThin
                )
        )
        .animation(.vitalSpring, value: isFocused)
        .animation(.vitalSpring, value: text.isEmpty)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            VitalTextField(title: "Email", text: .constant(""), placeholder: "Enter your email", icon: "envelope", keyboardType: .emailAddress)

            VitalTextField(title: "Password", text: .constant(""), placeholder: "Enter your password", icon: "lock", isSecure: true)

            VitalTextField(title: "With Error", text: .constant("invalid"), placeholder: "Enter value", errorMessage: "This field is required")

            VitalTextEditor(title: "Notes", text: .constant(""), placeholder: "Enter your notes...")

            VitalSearchField(text: .constant(""), placeholder: "Search exercises...")
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
