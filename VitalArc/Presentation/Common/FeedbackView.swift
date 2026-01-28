//
//  FeedbackView.swift
//  VitalArc
//
//  In-app feedback submission for beta testers
//

import SwiftUI
import MessageUI

struct FeedbackView: View {
    @State private var feedbackType: FeedbackType = .bug
    @State private var feedbackText: String = ""
    @State private var includeDeviceInfo: Bool = true
    @State private var showingMailCompose = false
    @State private var showingMailError = false
    @State private var isSent = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Feedback Type", selection: $feedbackType) {
                        ForEach(FeedbackType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                } header: {
                    Text("Category")
                }

                Section {
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 150)
                        .overlay(alignment: .topLeading) {
                            if feedbackText.isEmpty {
                                Text("Describe your feedback...")
                                    .font(.vitalBody)
                                    .foregroundStyle(Color.vitalAdaptiveTextTertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                } header: {
                    Text("Description")
                } footer: {
                    Text(feedbackType.hint)
                        .font(.vitalCaption)
                }

                Section {
                    Toggle("Include Device Info", isOn: $includeDeviceInfo)
                } footer: {
                    if includeDeviceInfo {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("The following will be included:")
                                .font(.vitalCaption)
                            Text(deviceInfoPreview)
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                    }
                }

                Section {
                    Button {
                        submitFeedback()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Send Feedback", systemImage: "paperplane.fill")
                                .font(.vitalLabel)
                            Spacer()
                        }
                    }
                    .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingMailCompose) {
                MailComposeView(
                    subject: emailSubject,
                    body: emailBody,
                    recipient: "feedback@vitalarc.app"
                ) { result in
                    if result == .sent {
                        isSent = true
                        HapticFeedback.success()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Email Not Available", isPresented: $showingMailError) {
                Button("Copy to Clipboard") {
                    copyToClipboard()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Mail is not configured on this device. You can copy the feedback to send via another email app.")
            }
            .overlay {
                if isSent {
                    sentOverlay
                }
            }
        }
    }

    // MARK: - Sent Overlay

    private var sentOverlay: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: Spacing.iconHero))
                .foregroundStyle(Color.vitalSuccess)

            Text("Feedback Sent!")
                .font(.vitalH2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }

    // MARK: - Computed Properties

    private var emailSubject: String {
        "[VitalArc \(feedbackType.tag)] \(feedbackType.displayName)"
    }

    private var emailBody: String {
        var body = """
        \(feedbackText)

        ---
        """

        if includeDeviceInfo {
            body += """

            \(deviceInfo)
            """
        }

        return body
    }

    private var deviceInfo: String {
        let device = UIDevice.current
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        return """
        App Version: \(appVersion) (\(buildNumber))
        Device: \(device.model)
        iOS Version: \(device.systemVersion)
        """
    }

    private var deviceInfoPreview: String {
        deviceInfo
    }

    // MARK: - Actions

    private func submitFeedback() {
        if MFMailComposeViewController.canSendMail() {
            showingMailCompose = true
        } else {
            showingMailError = true
        }
    }

    private func copyToClipboard() {
        let fullFeedback = """
        Subject: \(emailSubject)

        \(emailBody)
        """
        UIPasteboard.general.string = fullFeedback
        HapticFeedback.success()
    }
}

// MARK: - Feedback Type

enum FeedbackType: String, CaseIterable {
    case bug = "bug"
    case feature = "feature"
    case improvement = "improvement"
    case other = "other"

    var displayName: String {
        switch self {
        case .bug: return "Bug Report"
        case .feature: return "Feature Request"
        case .improvement: return "Improvement Suggestion"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .bug: return "ladybug.fill"
        case .feature: return "lightbulb.fill"
        case .improvement: return "arrow.up.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var tag: String {
        switch self {
        case .bug: return "BUG"
        case .feature: return "FEATURE"
        case .improvement: return "IMPROVE"
        case .other: return "OTHER"
        }
    }

    var hint: String {
        switch self {
        case .bug:
            return "Please describe what happened, what you expected, and steps to reproduce the issue."
        case .feature:
            return "Describe the feature you'd like to see and how it would help you."
        case .improvement:
            return "Tell us how we can improve an existing feature."
        case .other:
            return "Share any other feedback or questions."
        }
    }
}

// MARK: - Mail Compose View

struct MailComposeView: UIViewControllerRepresentable {
    let subject: String
    let body: String
    let recipient: String
    let onDismiss: (MFMailComposeResult) -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.setToRecipients([recipient])
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: (MFMailComposeResult) -> Void

        init(onDismiss: @escaping (MFMailComposeResult) -> Void) {
            self.onDismiss = onDismiss
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            onDismiss(result)
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - Preview

#Preview {
    FeedbackView()
}
