//
//  ViewExtensions.swift
//  VitalArc
//
//  Common view extensions and modifiers for the design system
//

import SwiftUI

// MARK: - Conditional Modifiers

extension View {
    /// Applies a modifier conditionally
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies one of two modifiers based on a condition
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
}

// MARK: - Keyboard Management

extension View {
    /// Hides the keyboard when tapping outside text fields
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

// MARK: - Corner Radius

extension View {
    /// Applies corner radius to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Card Styling

extension View {
    /// Applies the standard card appearance
    func vitalCardStyle() -> some View {
        self
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusLarge)
            .vitalCardShadow()
    }

    /// Applies elevated card appearance
    func vitalElevatedCardStyle() -> some View {
        self
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusLarge)
            .vitalElevatedShadow()
    }
}

// MARK: - Skeleton Loading

extension View {
    /// Adds a skeleton loading effect
    func skeleton(isLoading: Bool) -> some View {
        self.modifier(SkeletonModifier(isLoading: isLoading))
    }
}

private struct SkeletonModifier: ViewModifier {
    let isLoading: Bool
    @State private var animating = false

    func body(content: Content) -> some View {
        if isLoading {
            content
                .redacted(reason: .placeholder)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.vitalAdaptiveSurface.opacity(0.3),
                            Color.vitalAdaptiveSurface.opacity(0.7),
                            Color.vitalAdaptiveSurface.opacity(0.3)
                        ],
                        startPoint: animating ? .leading : .trailing,
                        endPoint: animating ? .trailing : .leading
                    )
                    .animation(
                        Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: animating
                    )
                )
                .onAppear {
                    animating = true
                }
        } else {
            content
        }
    }
}

// MARK: - Badge Modifier

extension View {
    /// Adds a badge to the view
    func badge(
        _ text: String,
        color: Color = .vitalDanger,
        position: BadgePosition = .topTrailing
    ) -> some View {
        self.modifier(BadgeModifier(text: text, color: color, position: position))
    }
}

enum BadgePosition {
    case topTrailing
    case topLeading
    case bottomTrailing
    case bottomLeading
}

private struct BadgeModifier: ViewModifier {
    let text: String
    let color: Color
    let position: BadgePosition

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if !text.isEmpty {
                    Text(text)
                        .font(.vitalLabelTiny)
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, Spacing.xxs)
                        .background(color)
                        .cornerRadius(Spacing.radiusSmall)
                        .offset(x: xOffset, y: yOffset)
                }
            }
    }

    private var alignment: Alignment {
        switch position {
        case .topTrailing: return .topTrailing
        case .topLeading: return .topLeading
        case .bottomTrailing: return .bottomTrailing
        case .bottomLeading: return .bottomLeading
        }
    }

    private var xOffset: CGFloat {
        switch position {
        case .topTrailing, .bottomTrailing: return 8
        case .topLeading, .bottomLeading: return -8
        }
    }

    private var yOffset: CGFloat {
        switch position {
        case .topTrailing, .topLeading: return -8
        case .bottomTrailing, .bottomLeading: return 8
        }
    }
}

// MARK: - Shimmer Effect

extension View {
    /// Adds a shimmer effect (useful for highlighting)
    func shimmer(isActive: Bool = true) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }
}

private struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isActive {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .white.opacity(0.4),
                                .clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 0.3)
                        .offset(x: -geometry.size.width * 0.3 + (geometry.size.width * 1.3 * phase))
                        .blendMode(.overlay)
                    }
                }
            )
            .onAppear {
                if isActive {
                    withAnimation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
            }
    }
}

// MARK: - Accessibility

extension View {
    /// Adds VoiceOver label and hint
    func vitalAccessibility(
        label: String,
        hint: String? = nil,
        value: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
            .if(value != nil) { view in
                view.accessibilityValue(value!)
            }
    }
}

// MARK: - Divider

extension View {
    /// Adds a styled divider
    func vitalDivider(padding: CGFloat = 0) -> some View {
        VStack(spacing: 0) {
            self
            Divider()
                .background(Color.vitalAdaptiveBorder)
                .padding(.horizontal, padding)
        }
    }
}

// MARK: - Safe Area Insets

extension View {
    /// Gets safe area insets
    func onSafeAreaInsetsChange(_ onChange: @escaping (EdgeInsets) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: SafeAreaInsetsKey.self,
                    value: geometry.safeAreaInsets
                )
            }
        )
        .onPreferenceChange(SafeAreaInsetsKey.self, perform: onChange)
    }
}

private struct SafeAreaInsetsKey: PreferenceKey {
    static var defaultValue: EdgeInsets = EdgeInsets()
    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
        value = nextValue()
    }
}

// MARK: - Read Size

extension View {
    /// Reads the view's size
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: SizePreferenceKey.self,
                    value: geometry.size
                )
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Debug

#if DEBUG
extension View {
    /// Adds a border for debugging layout (only in debug builds)
    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        self.overlay(
            Rectangle()
                .strokeBorder(color, lineWidth: width)
        )
    }

    /// Prints when view appears (only in debug builds)
    func debugPrint(_ message: String) -> some View {
        self.onAppear {
            print("[DEBUG] \(message)")
        }
    }
}
#endif

// MARK: - Locale-Aware Parsing

/// Utilities for parsing and formatting numbers respecting the user's locale.
/// Handles both comma (EU) and period (US) decimal separators.
enum LocaleAwareParsing {
    /// NumberFormatter configured for the current locale
    private static var localeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter
    }()

    /// NumberFormatter with US locale for fallback parsing
    private static var usFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    /// Parse a string to Double using locale-aware parsing.
    /// Tries the current locale first, then falls back to US locale.
    /// - Parameter string: The string to parse (e.g., "123.45" or "123,45")
    /// - Returns: The parsed Double, or nil if parsing fails
    static func parseDouble(from string: String) -> Double? {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        // Try current locale first (handles both "123,45" for EU and "123.45" for US)
        if let number = localeFormatter.number(from: trimmed) {
            return number.doubleValue
        }

        // Fallback: try US locale for period-based decimals
        if let number = usFormatter.number(from: trimmed) {
            return number.doubleValue
        }

        // Final fallback: try Swift's Double initializer
        return Double(trimmed)
    }

    /// Format a Double for display using the current locale.
    /// - Parameters:
    ///   - value: The Double value to format
    ///   - fractionDigits: Maximum fraction digits (default: 2)
    /// - Returns: The formatted string
    static func formatDouble(_ value: Double, fractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(fractionDigits)f", value)
    }

    /// Format a Double as an integer (no decimal places).
    /// - Parameter value: The Double value to format
    /// - Returns: The formatted string without decimals
    static func formatAsInteger(_ value: Double) -> String {
        return String(Int(value.rounded()))
    }

    /// Parse a string and validate it's a positive number.
    /// - Parameter string: The string to parse
    /// - Returns: The parsed positive Double, or nil if invalid or non-positive
    static func parsePositiveDouble(from string: String) -> Double? {
        guard let value = parseDouble(from: string), value > 0 else {
            return nil
        }
        return value
    }
}
