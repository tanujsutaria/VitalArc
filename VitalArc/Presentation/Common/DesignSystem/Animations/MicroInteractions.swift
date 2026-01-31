//
//  MicroInteractions.swift
//  VitalArc
//
//  Premium micro-interactions and scroll-triggered animations
//

import SwiftUI

// MARK: - Scroll-Triggered Animation

struct ScrollRevealModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .offset(y: isVisible ? 0 : 30)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.vitalSpring.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Reveals content with a slide-up animation when it appears
    func scrollReveal(delay: Double = 0) -> some View {
        modifier(ScrollRevealModifier(delay: delay))
    }

    /// Staggered reveal for list items
    func staggeredReveal(index: Int, baseDelay: Double = 0.05) -> some View {
        modifier(ScrollRevealModifier(delay: Double(index) * baseDelay))
    }
}

// MARK: - Chart Animated Reveal

struct ChartRevealModifier: ViewModifier {
    @State private var progress: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .mask(
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: geometry.size.width * progress)
                        .animation(.vitalSmoothSlow, value: progress)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            )
            .onAppear {
                withAnimation(.vitalSmoothSlow.delay(0.2)) {
                    progress = 1
                }
            }
    }
}

struct ChartBarRevealModifier: ViewModifier {
    let index: Int
    @State private var scale: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(y: scale, anchor: .bottom)
            .onAppear {
                withAnimation(.vitalSpringBouncy.delay(Double(index) * 0.08)) {
                    scale = 1
                }
            }
    }
}

extension View {
    /// Reveals chart content from left to right
    func chartReveal() -> some View {
        modifier(ChartRevealModifier())
    }

    /// Reveals bar chart bars with staggered bounce animation
    func barReveal(index: Int) -> some View {
        modifier(ChartBarRevealModifier(index: index))
    }
}

// MARK: - Interactive Glow Effect

struct InteractiveGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .shadow(color: isActive ? color.opacity(0.5) : .clear, radius: radius)
            .shadow(color: isActive ? color.opacity(0.3) : .clear, radius: radius * 2)
            .animation(.vitalSpring, value: isActive)
    }
}

extension View {
    /// Adds an interactive glow effect around the view
    func interactiveGlow(color: Color, radius: CGFloat = 8, isActive: Bool = true) -> some View {
        modifier(InteractiveGlowModifier(color: color, radius: radius, isActive: isActive))
    }
}

// MARK: - Ripple Effect

struct RippleEffect: ViewModifier {
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    @Binding var trigger: Bool
    let color: Color

    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .fill(color)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)
            )
            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    triggerRipple()
                }
            }
    }

    private func triggerRipple() {
        rippleScale = 0
        rippleOpacity = 0.4

        withAnimation(.easeOut(duration: 0.4)) {
            rippleScale = 2.5
            rippleOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            trigger = false
        }
    }
}

extension View {
    /// Adds a ripple effect on trigger
    func ripple(trigger: Binding<Bool>, color: Color = .white) -> some View {
        modifier(RippleEffect(trigger: trigger, color: color))
    }
}

// MARK: - Pulse Animation

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    let color: Color
    let duration: Double

    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
                    .scaleEffect(isPulsing ? 1.5 : 1)
                    .opacity(isPulsing ? 0 : 0.8)
            )
            .onAppear {
                withAnimation(
                    .easeOut(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    /// Adds a pulsing ring animation
    func pulse(color: Color = .vitalPrimary, duration: Double = 1.5) -> some View {
        modifier(PulseModifier(color: color, duration: duration))
    }
}

// MARK: - Bounce In Animation

struct BounceInModifier: ViewModifier {
    let delay: Double
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(hasAppeared ? 1 : 0)
            .opacity(hasAppeared ? 1 : 0)
            .onAppear {
                withAnimation(.vitalSpringBouncy.delay(delay)) {
                    hasAppeared = true
                }
            }
    }
}

extension View {
    /// Bounces the view in when it appears
    func bounceIn(delay: Double = 0) -> some View {
        modifier(BounceInModifier(delay: delay))
    }
}

// MARK: - Typing Animation

struct TypingTextView: View {
    let text: String
    let speed: Double
    @State private var displayedText = ""
    @State private var currentIndex = 0

    init(_ text: String, speed: Double = 0.05) {
        self.text = text
        self.speed = speed
    }

    var body: some View {
        Text(displayedText)
            .onAppear {
                animateText()
            }
    }

    private func animateText() {
        guard currentIndex < text.count else { return }

        let index = text.index(text.startIndex, offsetBy: currentIndex)
        displayedText += String(text[index])
        currentIndex += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + speed) {
            animateText()
        }
    }
}

// MARK: - Counting Animation

struct CountingText: View {
    let value: Double
    let format: String
    let duration: Double

    @State private var displayValue: Double = 0

    init(_ value: Double, format: String = "%.0f", duration: Double = 0.8) {
        self.value = value
        self.format = format
        self.duration = duration
    }

    var body: some View {
        Text(String(format: format, displayValue))
            .onAppear {
                withAnimation(.easeOut(duration: duration)) {
                    displayValue = value
                }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(.easeOut(duration: duration)) {
                    displayValue = newValue
                }
            }
    }
}

// MARK: - Progress Ring Animation

struct AnimatedProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: LinearGradient
    let backgroundColor: Color

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .onAppear {
            withAnimation(.vitalSmoothSlow.delay(0.3)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.vitalSmooth) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Floating Animation

struct FloatingModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    let amplitude: CGFloat
    let duration: Double

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = amplitude
                }
            }
    }
}

extension View {
    /// Makes the view float up and down gently
    func floating(amplitude: CGFloat = 5, duration: Double = 2) -> some View {
        modifier(FloatingModifier(amplitude: amplitude, duration: duration))
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.xl) {
            Text("Micro-Interactions Demo")
                .font(.vitalH2)

            // Scroll reveal
            VStack(spacing: Spacing.md) {
                ForEach(0..<3, id: \.self) { index in
                    VitalCard {
                        Text("Scroll Reveal Item \(index + 1)")
                            .font(.vitalBody)
                    }
                    .staggeredReveal(index: index)
                }
            }

            // Glow effect
            VitalButton(title: "Glowing Button", style: .primary) {}
                .interactiveGlow(color: Color.vitalPrimary, radius: 10)

            // Bounce in
            Circle()
                .fill(Color.vitalSuccess)
                .frame(width: 60, height: 60)
                .bounceIn(delay: 0.5)

            // Animated progress
            AnimatedProgressRing(
                progress: 0.75,
                lineWidth: 8,
                gradient: Color.vitalPrimaryGradientV2,
                backgroundColor: Color.vitalAdaptiveBorder
            )
            .frame(width: 100, height: 100)

            // Counting text
            CountingText(1234, format: "%.0f")
                .font(.vitalDisplayLarge)
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
