//
//  VitalSkeleton.swift
//  VitalArc
//
//  Premium skeleton loading components with shimmer animation
//

import SwiftUI

// MARK: - Base Skeleton Shape

struct VitalSkeleton: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var cornerRadius: CGFloat = Spacing.radiusSmallV2

    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.vitalSurfaceRaisedV2)
            .frame(width: width, height: height)
            .overlay(shimmerOverlay)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var shimmerOverlay: some View {
        GeometryReader { geometry in
            LinearGradient(
                colors: [
                    Color.white.opacity(0),
                    Color.white.opacity(0.1),
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.1),
                    Color.white.opacity(0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geometry.size.width * 2)
            .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
            .animation(
                Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                value: isAnimating
            )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Text Skeleton

struct VitalTextSkeleton: View {
    var lines: Int = 1
    var lineHeight: CGFloat = 14
    var spacing: CGFloat = Spacing.sm
    var lastLineWidth: CGFloat = 0.7

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<lines, id: \.self) { index in
                VitalSkeleton(
                    width: index == lines - 1 && lines > 1
                        ? nil  // Last line will use percentage
                        : nil,
                    height: lineHeight
                )
                .frame(
                    maxWidth: index == lines - 1 && lines > 1
                        ? .infinity
                        : .infinity,
                    alignment: .leading
                )
                .scaleEffect(
                    x: index == lines - 1 && lines > 1 ? lastLineWidth : 1.0,
                    y: 1.0,
                    anchor: .leading
                )
            }
        }
    }
}

// MARK: - Circle Skeleton

struct VitalCircleSkeleton: View {
    var size: CGFloat = 48

    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(Color.vitalSurfaceRaisedV2)
            .frame(width: size, height: size)
            .overlay(shimmerOverlay)
            .clipShape(Circle())
    }

    private var shimmerOverlay: some View {
        GeometryReader { geometry in
            LinearGradient(
                colors: [
                    Color.white.opacity(0),
                    Color.white.opacity(0.15),
                    Color.white.opacity(0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: geometry.size.width * 2, height: geometry.size.height * 2)
            .offset(
                x: isAnimating ? geometry.size.width : -geometry.size.width,
                y: isAnimating ? geometry.size.height : -geometry.size.height
            )
            .animation(
                Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                value: isAnimating
            )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Metric Card Skeleton

struct VitalMetricCardSkeleton: View {
    @State private var appear = false

    var body: some View {
        VitalCardV2(elevation: .elevated) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    VitalCircleSkeleton(size: 40)
                    Spacer()
                    VitalSkeleton(width: 60, height: 20, cornerRadius: Spacing.radiusSmallV2)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    VitalSkeleton(width: 80, height: 12)
                    VitalSkeleton(width: 120, height: 32, cornerRadius: Spacing.radiusMediumV2)
                }

                VitalSkeleton(height: 8, cornerRadius: Spacing.radiusTinyV2)
            }
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 10)
        .onAppear {
            withAnimation(.vitalSpring.delay(0.1)) {
                appear = true
            }
        }
    }
}

// MARK: - Food Card Skeleton

struct VitalFoodCardSkeleton: View {
    @State private var appear = false

    var body: some View {
        VitalCardV2(padding: Spacing.md, elevation: .raised) {
            HStack(spacing: Spacing.md) {
                VitalCircleSkeleton(size: 48)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    VitalSkeleton(width: 140, height: 16)
                    VitalSkeleton(width: 80, height: 12)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    VitalSkeleton(width: 50, height: 18)
                    VitalSkeleton(width: 30, height: 12)
                }
            }
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 10)
        .onAppear {
            withAnimation(.vitalSpring.delay(0.1)) {
                appear = true
            }
        }
    }
}

// MARK: - Workout Card Skeleton

struct VitalWorkoutCardSkeleton: View {
    @State private var appear = false

    var body: some View {
        VitalCardV2(elevation: .elevated) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    VitalSkeleton(width: 100, height: 18)
                    Spacer()
                    VitalSkeleton(width: 70, height: 14)
                }

                HStack(spacing: Spacing.lg) {
                    statSkeleton
                    statSkeleton
                    statSkeleton
                }

                VitalSkeleton(height: 6, cornerRadius: Spacing.radiusTinyV2)
            }
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 10)
        .onAppear {
            withAnimation(.vitalSpring.delay(0.15)) {
                appear = true
            }
        }
    }

    private var statSkeleton: some View {
        VStack(spacing: Spacing.xs) {
            VitalSkeleton(width: 40, height: 24)
            VitalSkeleton(width: 30, height: 10)
        }
    }
}

// MARK: - Chart Skeleton

struct VitalChartSkeleton: View {
    var height: CGFloat = 150

    @State private var appear = false
    @State private var barHeights: [CGFloat] = []

    var body: some View {
        VitalCardV2(padding: 0, elevation: .flat) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    VitalSkeleton(width: 100, height: 16)
                    Spacer()
                    VitalSkeleton(width: 60, height: 14)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)

                // Bar chart skeleton with stable heights
                HStack(alignment: .bottom, spacing: Spacing.sm) {
                    ForEach(0..<7, id: \.self) { index in
                        VitalSkeleton(
                            height: barHeights.indices.contains(index) ? barHeights[index] : 40,
                            cornerRadius: Spacing.radiusTinyV2
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.md)
                .frame(height: height)
            }
        }
        .opacity(appear ? 1 : 0)
        .onAppear {
            if barHeights.isEmpty {
                barHeights = (0..<7).map { _ in
                    CGFloat.random(in: 40...height * 0.8)
                }
            }
            withAnimation(.vitalSpring.delay(0.2)) {
                appear = true
            }
        }
    }
}

// MARK: - List Skeleton

struct VitalListSkeleton: View {
    var itemCount: Int = 5
    var itemHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(0..<itemCount, id: \.self) { index in
                VitalListItemSkeleton()
                    .animation(.vitalSpring.delay(Double(index) * 0.05), value: true)
            }
        }
    }
}

struct VitalListItemSkeleton: View {
    @State private var appear = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            VitalCircleSkeleton(size: 44)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                VitalSkeleton(width: 140, height: 14)
                VitalSkeleton(width: 90, height: 12)
            }

            Spacer()

            VitalSkeleton(width: 24, height: 24, cornerRadius: Spacing.radiusSmallV2)
        }
        .padding(.vertical, Spacing.sm)
        .opacity(appear ? 1 : 0)
        .offset(x: appear ? 0 : -20)
        .onAppear {
            withAnimation(.vitalSpring) {
                appear = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Skeleton Components") {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            Section {
                VitalMetricCardSkeleton()
                VitalMetricCardSkeleton()
            } header: {
                Text("Metric Cards")
                    .font(.vitalH3V2)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Section {
                VitalFoodCardSkeleton()
                VitalFoodCardSkeleton()
                VitalFoodCardSkeleton()
            } header: {
                Text("Food Cards")
                    .font(.vitalH3V2)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Section {
                VitalWorkoutCardSkeleton()
            } header: {
                Text("Workout Card")
                    .font(.vitalH3V2)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Section {
                VitalChartSkeleton()
            } header: {
                Text("Chart")
                    .font(.vitalH3V2)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackgroundV2)
}
