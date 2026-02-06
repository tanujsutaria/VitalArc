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

// MARK: - V2 Text Field with Floating Label

struct VitalTextFieldV2: View {
    let label: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var errorMessage: String? = nil
    var isSuccess: Bool = false
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool
    @State private var shakeOffset: CGFloat = 0
    @State private var showSuccessCheck: Bool = false

    private var isFloating: Bool {
        isFocused || !text.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            ZStack(alignment: .leading) {
                // Floating label
                Text(label)
                    .font(isFloating ? .vitalCaptionSmall : .vitalBody)
                    .foregroundStyle(
                        errorMessage != nil ? Color.vitalDanger :
                        isFocused ? Color.vitalPrimary : Color.vitalAdaptiveTextSecondary
                    )
                    .offset(y: isFloating ? -24 : 0)
                    .scaleEffect(isFloating ? 0.85 : 1.0, anchor: .leading)
                    .animation(.vitalSpring, value: isFloating)

                // Input row
                HStack(spacing: Spacing.sm) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: Spacing.iconMedium))
                            .foregroundStyle(
                                errorMessage != nil ? Color.vitalDanger :
                                isFocused ? Color.vitalPrimary : Color.vitalAdaptiveTextSecondary
                            )
                            .frame(width: Spacing.iconMedium)
                    }

                    Group {
                        if isSecure {
                            SecureField("", text: $text)
                        } else {
                            TextField("", text: $text)
                                .keyboardType(keyboardType)
                                .textInputAutocapitalization(autocapitalization)
                        }
                    }
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    .focused($isFocused)
                    .onSubmit {
                        onSubmit?()
                    }

                    // Success checkmark
                    if isSuccess && showSuccessCheck {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: Spacing.iconMedium))
                            .foregroundStyle(Color.vitalSuccess)
                            .transition(.scale.combined(with: .opacity))
                    }

                    // Error icon
                    if errorMessage != nil {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: Spacing.iconMedium))
                            .foregroundStyle(Color.vitalDanger)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.top, isFloating ? Spacing.sm : 0)
            }
            .padding(Spacing.md)
            .padding(.top, Spacing.xs)
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(
                        errorMessage != nil ? Color.vitalDanger :
                        isSuccess ? Color.vitalSuccess :
                        isFocused ? Color.vitalPrimary : Color.vitalAdaptiveBorder,
                        lineWidth: isFocused || errorMessage != nil || isSuccess
                            ? Spacing.borderMedium : Spacing.borderThin
                    )
            )
            .offset(x: shakeOffset)
            .animation(.vitalSpring, value: isFocused)

            // Error message
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
        .onChange(of: errorMessage) { oldValue, newValue in
            if newValue != nil && oldValue == nil {
                triggerShake()
            }
        }
        .onChange(of: isSuccess) { _, newValue in
            if newValue {
                withAnimation(.vitalSpring) {
                    showSuccessCheck = true
                }
                HapticFeedback.success()
            } else {
                showSuccessCheck = false
            }
        }
    }

    private func triggerShake() {
        HapticFeedback.error()
        withAnimation(.vitalBounce) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.vitalBounce) {
                shakeOffset = -10
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.vitalBounce) {
                shakeOffset = 5
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.vitalBounce) {
                shakeOffset = 0
            }
        }
    }
}

// MARK: - Shake Effect Modifier

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

extension View {
    func shake(trigger: Bool) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}

struct ShakeModifier: ViewModifier {
    let trigger: Bool
    @State private var shakeAmount: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(animatableData: shakeAmount))
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    withAnimation(.vitalBounce) {
                        shakeAmount = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        shakeAmount = 0
                    }
                }
            }
    }
}

// MARK: - V2 Search Field

struct VitalSearchFieldV2: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onClear: (() -> Void)? = nil
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: Spacing.iconMedium))
                .foregroundStyle(isFocused ? Color.vitalPrimary : Color.vitalAdaptiveTextSecondary)
                .scaleEffect(isFocused ? 1.1 : 1.0)
                .animation(.vitalSpring, value: isFocused)

            TextField(placeholder, text: $text)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                .focused($isFocused)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button(action: {
                    withAnimation(.vitalSpring) {
                        text = ""
                    }
                    onClear?()
                    HapticFeedback.light()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: Spacing.iconMedium))
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(Spacing.md)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMediumV2)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMediumV2)
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
        VStack(spacing: Spacing.xl) {
            // V1 Components
            Text("V1 Components")
                .font(.vitalH3)
                .frame(maxWidth: .infinity, alignment: .leading)

            VitalTextField(title: "Email", text: .constant(""), placeholder: "Enter your email", icon: "envelope", keyboardType: .emailAddress)

            VitalTextField(title: "Password", text: .constant(""), placeholder: "Enter your password", icon: "lock", isSecure: true)

            VitalTextField(title: "With Error", text: .constant("invalid"), placeholder: "Enter value", errorMessage: "This field is required")

            Divider()

            // V2 Components
            Text("V2 Components (Floating Labels)")
                .font(.vitalH3)
                .frame(maxWidth: .infinity, alignment: .leading)

            VitalTextFieldV2(
                label: "Email Address",
                text: .constant("user@example.com"),
                icon: "envelope"
            )

            VitalTextFieldV2(
                label: "Password",
                text: .constant(""),
                icon: "lock",
                isSecure: true
            )

            VitalTextFieldV2(
                label: "Username",
                text: .constant("tanuj"),
                icon: "person",
                isSuccess: true
            )

            VitalTextFieldV2(
                label: "Email",
                text: .constant("invalid"),
                icon: "envelope",
                errorMessage: "Please enter a valid email"
            )

            VitalSearchFieldV2(text: .constant("bench press"))
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
