import SwiftUI

// MARK: - Error Handling Guide
//
// VitalArc uses two patterns for error handling:
//
// 1. Alert-based (for user actions that fail):
//    @State private var error: Error?
//    .errorAlert($error)
//
// 2. Inline error state (for failed data loads):
//    if let errorMessage = viewModel.errorMessage {
//        ErrorStateView(errorMessage, retryAction: viewModel.retry)
//    }
//
// Guidelines:
// - Use alerts for action failures (save, delete, submit)
// - Use inline ErrorStateView for load failures
// - Always log errors for debugging: print("[Feature] Error: \(error)")
// - Use VitalArcError for typed errors when appropriate

// MARK: - Error Alert Modifier

/// A view modifier that displays an alert for errors.
/// Usage: .errorAlert($viewModel.error)
struct ErrorAlertModifier: ViewModifier {
    @Binding var error: Error?
    var title: String

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: .init(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            )) {
                Button("OK") { error = nil }
            } message: {
                Text(error?.localizedDescription ?? "An unknown error occurred")
            }
    }
}

extension View {
    /// Shows an error alert when the error binding is non-nil.
    /// - Parameters:
    ///   - error: A binding to an optional Error
    ///   - title: The alert title (default: "Error")
    func errorAlert(_ error: Binding<Error?>, title: String = "Error") -> some View {
        modifier(ErrorAlertModifier(error: error, title: title))
    }
}

// MARK: - Error State View

/// A view that displays an error state with retry option.
/// Use this for inline error displays instead of alerts.
struct ErrorStateView: View {
    let message: String
    let retryAction: (() -> Void)?

    init(_ message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.vitalH1)
                .foregroundStyle(Color.vitalWarning)

            Text(message)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .multilineTextAlignment(.center)

            if let retryAction {
                Button("Try Again") {
                    retryAction()
                }
                .buttonStyle(.bordered)
                .tint(Color.vitalPrimary)
            }
        }
        .padding(Spacing.xl)
    }
}

// MARK: - App Error Types

/// Standard error types for the app
enum VitalArcError: LocalizedError {
    case networkError(String)
    case dataError(String)
    case healthKitError(String)
    case validationError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .dataError(let message):
            return "Data error: \(message)"
        case .healthKitError(let message):
            return "HealthKit error: \(message)"
        case .validationError(let message):
            return message
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}

// MARK: - Preview

#Preview("Error State View") {
    VStack(spacing: Spacing.xl) {
        ErrorStateView("Failed to load data")

        ErrorStateView("Connection failed", retryAction: {
            print("Retry tapped")
        })
    }
    .padding()
}

#Preview("Error Alert Usage") {
    struct PreviewWrapper: View {
        @State private var error: Error? = VitalArcError.networkError("Connection timeout")

        var body: some View {
            VStack {
                Text("Main Content")
                Button("Trigger Error") {
                    error = VitalArcError.validationError("Invalid input")
                }
            }
            .errorAlert($error)
        }
    }

    return PreviewWrapper()
}
