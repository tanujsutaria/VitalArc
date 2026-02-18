//
//  VitalEmptyState.swift
//  VitalArc
//
//  Empty state component for when there's no data
//

import SwiftUI

struct VitalEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.vitalPrimary.opacity(0.15))
                        .frame(width: Spacing.illustrationMedium, height: Spacing.illustrationMedium)

                    Image(systemName: icon)
                        .font(.vitalIconHuge)
                        .foregroundStyle(Color.vitalPrimary)
                }

                // Text
                VStack(spacing: Spacing.sm) {
                    Text(title)
                        .font(.vitalDisplaySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }

                // Action button
                if let actionTitle = actionTitle, let action = action {
                    VitalButton(
                        title: actionTitle,
                        style: .primary,
                        fullWidth: true,
                        action: action
                    )
                    .padding(.top, Spacing.sm)
                }
            }
        }
        .transition(.vitalScale)
    }
}

// MARK: - Loading State

struct VitalLoadingState: View {
    let message: String

    init(message: String = "Loading...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.vitalPrimary)

            Text(message)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xxl)
    }
}

// MARK: - Error State

struct VitalErrorState: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.vitalDanger.opacity(0.15))
                        .frame(width: Spacing.illustrationMedium, height: Spacing.illustrationMedium)

                    Image(systemName: "exclamationmark.triangle")
                        .font(.vitalIconHuge)
                        .foregroundStyle(Color.vitalDanger)
                }

                // Text
                VStack(spacing: Spacing.sm) {
                    Text("Something Went Wrong")
                        .font(.vitalDisplaySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        .multilineTextAlignment(.center)

                    Text(error.localizedDescription)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }

                // Retry button
                VitalButton(
                    title: "Try Again",
                    style: .primary,
                    icon: "arrow.clockwise",
                    fullWidth: true,
                    action: retryAction
                )
                .padding(.top, Spacing.sm)
            }
        }
        .transition(.vitalScale)
    }
}

// MARK: - V2 Empty State with Context Variants

enum EmptyStateVariant {
    case noData
    case noResults
    case error
    case offline
    case custom(illustration: AnyView)

    var color: Color {
        switch self {
        case .noData: return Color.vitalPrimary
        case .noResults: return Color.vitalInfo
        case .error: return Color.vitalDanger
        case .offline: return Color.vitalWarning
        case .custom: return Color.vitalPrimary
        }
    }
}

struct VitalEmptyStateV2: View {
    let variant: EmptyStateVariant
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showMessage = false
    @State private var showAction = false

    var body: some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                // Illustration
                illustrationView
                    .scaleEffect(showIcon ? 1.0 : 0.5)
                    .opacity(showIcon ? 1.0 : 0)

                // Text content
                VStack(spacing: Spacing.sm) {
                    Text(title)
                        .font(.vitalDisplaySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        .multilineTextAlignment(.center)
                        .offset(y: showTitle ? 0 : 20)
                        .opacity(showTitle ? 1.0 : 0)

                    Text(message)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                        .offset(y: showMessage ? 0 : 15)
                        .opacity(showMessage ? 1.0 : 0)
                }

                // Action button
                if let actionTitle = actionTitle, let action = action {
                    VitalButton(
                        title: actionTitle,
                        style: .primary,
                        fullWidth: true,
                        action: action
                    )
                    .padding(.top, Spacing.sm)
                    .offset(y: showAction ? 0 : 10)
                    .opacity(showAction ? 1.0 : 0)
                }
            }
        }
        .onAppear {
            animateIn()
        }
    }

    @ViewBuilder
    private var illustrationView: some View {
        switch variant {
        case .noData:
            NoDataIllustration(color: variant.color)
        case .noResults:
            NoResultsIllustration(color: variant.color)
        case .error:
            ErrorIllustration(color: variant.color)
        case .offline:
            OfflineIllustration(color: variant.color)
        case .custom(let illustration):
            illustration
        }
    }

    private func animateIn() {
        withAnimation(.vitalSpring.delay(0.1)) {
            showIcon = true
        }
        withAnimation(.vitalSpring.delay(0.2)) {
            showTitle = true
        }
        withAnimation(.vitalSpring.delay(0.3)) {
            showMessage = true
        }
        withAnimation(.vitalSpring.delay(0.4)) {
            showAction = true
        }
    }
}

// MARK: - Custom Illustrations

struct NoDataIllustration: View {
    let color: Color
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: Spacing.illustrationMedium, height: Spacing.illustrationMedium)

            // Document shape
            RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                .fill(color.opacity(0.3))
                .frame(width: 50, height: 65)
                .overlay(
                    VStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(color)
                                .frame(width: 30, height: 4)
                                .opacity(isAnimating ? 0.8 : 0.4)
                                .animation(
                                    .easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .padding(.top, 15)
                , alignment: .top)

            // Plus icon
            Circle()
                .fill(color)
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                )
                .offset(x: 25, y: 25)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct NoResultsIllustration: View {
    let color: Color
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: Spacing.illustrationMedium, height: Spacing.illustrationMedium)

            // Magnifying glass
            Circle()
                .stroke(color, lineWidth: 5)
                .frame(width: Spacing.avatarSmall, height: Spacing.avatarSmall)
                .offset(x: -5, y: -5)

            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 20, height: 6)
                .rotationEffect(.degrees(45))
                .offset(x: 18, y: 18)

            // X mark inside
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
                .offset(x: -5, y: -5)
                .opacity(isAnimating ? 1.0 : 0.5)
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .animation(
                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ErrorIllustration: View {
    let color: Color
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: Spacing.illustrationMedium, height: Spacing.illustrationMedium)

            // Warning triangle
            TriangleShape()
                .fill(color.opacity(0.3))
                .frame(width: 60, height: 52)

            TriangleShape()
                .stroke(color, lineWidth: 3)
                .frame(width: 60, height: 52)

            // Exclamation
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 5, height: 20)

                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
            }
            .offset(y: 5)
            .scaleEffect(isAnimating ? 1.0 : 0.9)
            .animation(
                .easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                value: isAnimating
            )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct OfflineIllustration: View {
    let color: Color
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: Spacing.illustrationMedium, height: Spacing.illustrationMedium)

            // Cloud shape
            CloudShape()
                .fill(color.opacity(0.3))
                .frame(width: 70, height: 45)

            CloudShape()
                .stroke(color, lineWidth: 2.5)
                .frame(width: 70, height: 45)

            // Slash through
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 50, height: 4)
                .rotationEffect(.degrees(-45))
                .opacity(isAnimating ? 1.0 : 0.6)
                .animation(
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Custom Shapes

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height

        // Main body - series of arcs to create cloud shape
        path.addArc(
            center: CGPoint(x: w * 0.25, y: h * 0.65),
            radius: w * 0.2,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: true
        )
        path.addArc(
            center: CGPoint(x: w * 0.45, y: h * 0.4),
            radius: w * 0.25,
            startAngle: .degrees(210),
            endAngle: .degrees(0),
            clockwise: true
        )
        path.addArc(
            center: CGPoint(x: w * 0.75, y: h * 0.55),
            radius: w * 0.22,
            startAngle: .degrees(220),
            endAngle: .degrees(90),
            clockwise: true
        )
        path.addLine(to: CGPoint(x: w * 0.1, y: h * 0.85))
        path.addArc(
            center: CGPoint(x: w * 0.15, y: h * 0.7),
            radius: w * 0.12,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: true
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.xl) {
            // V1 Components
            Text("V1 Empty State")
                .font(.vitalH3)
                .frame(maxWidth: .infinity, alignment: .leading)

            VitalEmptyState(
                icon: "figure.walk",
                title: "No Workouts Yet",
                message: "Start logging your workouts to track your progress.",
                actionTitle: "Log First Workout"
            ) {
                print("Action tapped")
            }

            Divider()

            // V2 Components
            Text("V2 Empty States (Animated)")
                .font(.vitalH3)
                .frame(maxWidth: .infinity, alignment: .leading)

            VitalEmptyStateV2(
                variant: .noData,
                title: "No Workouts Yet",
                message: "Start logging your workouts to track your progress.",
                actionTitle: "Log First Workout"
            ) {
                print("Action tapped")
            }

            VitalEmptyStateV2(
                variant: .noResults,
                title: "No Results Found",
                message: "Try adjusting your search or filters."
            )

            VitalEmptyStateV2(
                variant: .error,
                title: "Something Went Wrong",
                message: "We couldn't load your data. Please try again.",
                actionTitle: "Retry"
            ) {
                print("Retry tapped")
            }

            VitalEmptyStateV2(
                variant: .offline,
                title: "You're Offline",
                message: "Check your internet connection and try again."
            )
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
