//
//  VitalBottomSheet.swift
//  VitalArc
//
//  Modern bottom sheet component
//

import SwiftUI

struct VitalBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String?
    let content: Content

    init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Dimmed background
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.vitalSpring) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
            }

            // Bottom sheet
            if isPresented {
                VStack(spacing: 0) {
                    // Handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.vitalAdaptiveBorder)
                        .frame(width: 40, height: 6)
                        .padding(.vertical, Spacing.sm)

                    // Title
                    if let title = title {
                        Text(title)
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            .padding(.horizontal, Spacing.screenPadding)
                            .padding(.bottom, Spacing.md)
                    }

                    // Content
                    content
                        .padding(.horizontal, Spacing.screenPadding)
                        .padding(.bottom, Spacing.screenPadding)
                }
                .background(
                    Color.vitalAdaptiveSurface
                        .cornerRadius(Spacing.radiusXLarge, corners: [.topLeft, .topRight])
                )
                .vitalElevatedShadow()
                .transition(.vitalSlideUp)
            }
        }
        .animation(.vitalSpring, value: isPresented)
    }
}

// MARK: - Confirmation Bottom Sheet

struct VitalConfirmationSheet: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let confirmTitle: String
    let confirmStyle: VitalButton.Style
    let onConfirm: () -> Void

    init(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmTitle: String = "Confirm",
        confirmStyle: VitalButton.Style = .primary,
        onConfirm: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.confirmTitle = confirmTitle
        self.confirmStyle = confirmStyle
        self.onConfirm = onConfirm
    }

    var body: some View {
        VitalBottomSheet(isPresented: $isPresented, title: title) {
            VStack(spacing: Spacing.lg) {
                Text(message)
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: Spacing.md) {
                    VitalButton(
                        title: "Cancel",
                        style: .outline,
                        fullWidth: true
                    ) {
                        withAnimation(.vitalSpring) {
                            isPresented = false
                        }
                    }

                    VitalButton(
                        title: confirmTitle,
                        style: confirmStyle,
                        fullWidth: true
                    ) {
                        onConfirm()
                        withAnimation(.vitalSpring) {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Action Sheet

struct VitalActionSheet: View {
    @Binding var isPresented: Bool
    let title: String?
    let message: String?
    let actions: [ActionSheetAction]

    init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        message: String? = nil,
        actions: [ActionSheetAction]
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.actions = actions
    }

    var body: some View {
        VitalBottomSheet(isPresented: $isPresented, title: title) {
            VStack(spacing: Spacing.md) {
                if let message = message {
                    Text(message)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, Spacing.sm)
                }

                VStack(spacing: Spacing.sm) {
                    ForEach(actions) { action in
                        Button(action: {
                            action.action()
                            withAnimation(.vitalSpring) {
                                isPresented = false
                            }
                        }) {
                            HStack(spacing: Spacing.md) {
                                if let icon = action.icon {
                                    Image(systemName: icon)
                                        .font(.system(size: Spacing.iconMedium, weight: .medium))
                                        .foregroundStyle(action.style.color)
                                        .frame(width: 24)
                                }

                                Text(action.title)
                                    .font(.vitalLabel)
                                    .foregroundStyle(action.style.color)

                                Spacer()
                            }
                            .padding(Spacing.md)
                            .background(Color.vitalAdaptiveSurface)
                            .cornerRadius(Spacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                                    .stroke(Color.vitalAdaptiveBorder, lineWidth: Spacing.borderThin)
                            )
                        }
                        .vitalScaleButton()
                    }
                }
            }
        }
    }
}

struct ActionSheetAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String?
    let style: ActionStyle
    let action: () -> Void

    enum ActionStyle {
        case `default`
        case destructive
        case cancel

        var color: Color {
            switch self {
            case .default: return .vitalAdaptiveTextPrimary
            case .destructive: return .vitalDanger
            case .cancel: return .vitalAdaptiveTextSecondary
            }
        }
    }

    init(
        title: String,
        icon: String? = nil,
        style: ActionStyle = .default,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
}

// MARK: - Preview

#Preview {
    struct BottomSheetDemo: View {
        @State private var showBasic = false
        @State private var showConfirmation = false
        @State private var showActions = false

        var body: some View {
            ZStack {
                VStack(spacing: Spacing.lg) {
                    VitalButton(title: "Show Basic Sheet", fullWidth: true) {
                        showBasic = true
                    }

                    VitalButton(title: "Show Confirmation", fullWidth: true) {
                        showConfirmation = true
                    }

                    VitalButton(title: "Show Action Sheet", fullWidth: true) {
                        showActions = true
                    }
                }
                .padding()

                // Basic sheet
                VitalBottomSheet(isPresented: $showBasic, title: "Custom Content") {
                    VStack(spacing: Spacing.md) {
                        Text("This is a custom bottom sheet with any content you want.")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                        VitalButton(title: "Close", fullWidth: true) {
                            showBasic = false
                        }
                    }
                }

                // Confirmation sheet
                VitalConfirmationSheet(
                    isPresented: $showConfirmation,
                    title: "Delete Workout",
                    message: "Are you sure you want to delete this workout? This action cannot be undone.",
                    confirmTitle: "Delete",
                    confirmStyle: .danger
                ) {
                    print("Confirmed!")
                }

                // Action sheet
                VitalActionSheet(
                    isPresented: $showActions,
                    title: "Workout Options",
                    message: "Choose an action for this workout",
                    actions: [
                        ActionSheetAction(
                            title: "Edit Workout",
                            icon: "pencil",
                            action: { print("Edit") }
                        ),
                        ActionSheetAction(
                            title: "Duplicate",
                            icon: "doc.on.doc",
                            action: { print("Duplicate") }
                        ),
                        ActionSheetAction(
                            title: "Share",
                            icon: "square.and.arrow.up",
                            action: { print("Share") }
                        ),
                        ActionSheetAction(
                            title: "Delete",
                            icon: "trash",
                            style: .destructive,
                            action: { print("Delete") }
                        )
                    ]
                )
            }
        }
    }

    return BottomSheetDemo()
}
