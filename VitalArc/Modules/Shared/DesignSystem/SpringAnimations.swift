//
//  SpringAnimations.swift
//  VitalArc
//
//  VitalArc Design System - Animation Library
//

import SwiftUI

extension Animation {
    // MARK: - Spring Animations

    static let vitalSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let vitalSpringBouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let vitalSpringSnappy = Animation.spring(response: 0.25, dampingFraction: 0.8)

    // MARK: - Easing Animations

    static let vitalEaseOut = Animation.easeOut(duration: 0.2)
    static let vitalEaseInOut = Animation.easeInOut(duration: 0.25)
    static let vitalEase = Animation.easeOut(duration: 0.3)

    // MARK: - Interactive Spring

    static let vitalBounce = Animation.interpolatingSpring(stiffness: 300, damping: 15)
    static let vitalInteractive = Animation.interpolatingSpring(stiffness: 250, damping: 20)

    // MARK: - Smooth Animations

    static let vitalSmooth = Animation.smooth(duration: 0.3)
    static let vitalSmoothSlow = Animation.smooth(duration: 0.5)
}

// MARK: - Haptic Feedback

enum HapticFeedback {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

// MARK: - View Modifiers

struct VitalScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.vitalSpring, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticFeedback.light()
                }
            }
    }
}

struct VitalPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.vitalEaseOut, value: configuration.isPressed)
    }
}

extension View {
    func vitalScaleButton() -> some View {
        self.buttonStyle(VitalScaleButtonStyle())
    }

    func vitalPressButton() -> some View {
        self.buttonStyle(VitalPressButtonStyle())
    }
}

// MARK: - Transition Animations

extension AnyTransition {
    static var vitalSlideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }

    static var vitalScale: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }

    static var vitalFade: AnyTransition {
        .opacity
    }
}
