//
//  CreateMesocycleView.swift
//  VitalArc
//
//  Simplified mesocycle creation - Pick template → Set weeks → Done
//

import SwiftUI

struct CreateMesocycleView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: MesocycleViewModel

    // Step-based creation (simplified)
    @State private var currentStep = 0

    // Step 1: Pick template
    @State private var selectedTemplate: QuickTemplate = .pushPullLegs

    // Step 2: Configure
    @State private var programName = ""
    @State private var durationWeeks = 4
    @State private var startDate = Date()
    @State private var autoProgressionEnabled = true
    @State private var progressionType: ProgressionType = .reps

    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator

                // Content based on step
                TabView(selection: $currentStep) {
                    templateSelectionStep
                        .tag(0)

                    configurationStep
                        .tag(1)

                    summaryStep
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4), value: currentStep)
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if currentStep < 2 {
                        Button("Next") {
                            withAnimation { currentStep += 1 }
                        }
                        .disabled(currentStep == 1 && programName.isEmpty)
                    } else {
                        Button("Create") {
                            createMesocycle()
                        }
                        .disabled(isCreating)
                    }
                }
            }
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<3) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.vitalPrimary : Color.vitalAdaptiveBorder)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, Spacing.screenPadding)
        .padding(.vertical, Spacing.md)
    }

    private var stepTitle: String {
        switch currentStep {
        case 0: return "Choose Template"
        case 1: return "Configure"
        default: return "Review"
        }
    }

    // MARK: - Step 1: Template Selection

    private var templateSelectionStep: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.vitalPrimary)

                    Text("Start with a template")
                        .font(.vitalH2)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text("Choose a training split to get started quickly")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.md)

                // Template options
                VStack(spacing: Spacing.md) {
                    ForEach(QuickTemplate.allCases, id: \.self) { template in
                        templateCard(template)
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)
            }
            .padding(.bottom, Spacing.xxxl)
        }
    }

    private func templateCard(_ template: QuickTemplate) -> some View {
        Button {
            HapticFeedback.selection()
            selectedTemplate = template
        } label: {
            HStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(selectedTemplate == template ? Color.vitalPrimary : Color.vitalPrimary.opacity(0.1))
                        .frame(width: 56, height: 56)

                    Image(systemName: template.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(selectedTemplate == template ? .white : Color.vitalPrimary)
                }

                // Text
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(template.name)
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text(template.description)
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .lineLimit(2)

                    Text("\(template.daysPerWeek) days/week")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalPrimary)
                }

                Spacer()

                // Selection indicator
                if selectedTemplate == template {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.vitalPrimary)
                }
            }
            .padding(Spacing.md)
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusLarge)
                    .stroke(selectedTemplate == template ? Color.vitalPrimary : Color.clear, lineWidth: 2)
            )
        }
    }

    // MARK: - Step 2: Configuration

    private var configurationStep: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Program name
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Program Name")
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    TextField("e.g., Summer Bulk 2026", text: $programName)
                        .font(.vitalBody)
                        .padding(Spacing.md)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                }

                // Duration
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Duration")
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    HStack {
                        Text("\(durationWeeks) weeks")
                            .font(.vitalH2)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        Spacer()

                        Stepper("", value: $durationWeeks, in: 1...16)
                            .labelsHidden()
                    }
                    .padding(Spacing.md)
                    .background(Color.vitalAdaptiveSurface)
                    .cornerRadius(Spacing.radiusMedium)

                    // Quick duration buttons
                    HStack(spacing: Spacing.sm) {
                        ForEach([4, 6, 8, 12], id: \.self) { weeks in
                            Button {
                                HapticFeedback.light()
                                durationWeeks = weeks
                            } label: {
                                Text("\(weeks)w")
                                    .font(.vitalLabelSmall)
                                    .foregroundStyle(durationWeeks == weeks ? .white : Color.vitalPrimary)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.vertical, Spacing.sm)
                                    .background(durationWeeks == weeks ? Color.vitalPrimary : Color.vitalPrimary.opacity(0.1))
                                    .cornerRadius(Spacing.radiusSmall)
                            }
                        }
                    }
                }

                // Start date
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Start Date")
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(Spacing.md)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                }

                // Auto-progression
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Toggle(isOn: $autoProgressionEnabled) {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Auto-Progression")
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                            Text("Automatically increase reps or weight week-to-week")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                    }
                    .tint(Color.vitalPrimary)
                    .padding(Spacing.md)
                    .background(Color.vitalAdaptiveSurface)
                    .cornerRadius(Spacing.radiusMedium)

                    if autoProgressionEnabled {
                        Picker("Progression Type", selection: $progressionType) {
                            ForEach(ProgressionType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, Spacing.xs)
                    }
                }
            }
            .padding(Spacing.screenPadding)
        }
    }

    // MARK: - Step 3: Summary

    private var summaryStep: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.vitalSuccess.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.vitalSuccess)
                }
                .padding(.top, Spacing.xl)

                Text("Ready to Start!")
                    .font(.vitalH1)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                // Summary card
                VitalCard(padding: Spacing.lg) {
                    VStack(spacing: Spacing.md) {
                        summaryRow(icon: "calendar", title: "Program", value: programName.isEmpty ? "My Program" : programName)
                        Divider()
                        summaryRow(icon: "figure.strengthtraining.traditional", title: "Template", value: selectedTemplate.name)
                        Divider()
                        summaryRow(icon: "clock", title: "Duration", value: "\(durationWeeks) weeks")
                        Divider()
                        summaryRow(icon: "play.circle", title: "Starts", value: startDate.formatted(date: .abbreviated, time: .omitted))
                        Divider()
                        summaryRow(icon: "flag.checkered", title: "Ends", value: endDate.formatted(date: .abbreviated, time: .omitted))
                        Divider()
                        summaryRow(icon: "arrow.up.right", title: "Progression", value: autoProgressionEnabled ? progressionType.rawValue : "Manual")
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)

                // Weekly schedule preview
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Weekly Schedule")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        .padding(.horizontal, Spacing.screenPadding)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            ForEach(selectedTemplate.days, id: \.self) { day in
                                VStack(spacing: Spacing.xs) {
                                    Text(day)
                                        .font(.vitalLabelSmall)
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 80)
                                .padding(.vertical, Spacing.md)
                                .background(Color.vitalPrimary)
                                .cornerRadius(Spacing.radiusMedium)
                            }
                        }
                        .padding(.horizontal, Spacing.screenPadding)
                    }
                }
                .padding(.top, Spacing.md)
            }
            .padding(.bottom, Spacing.xxxl)
        }
    }

    private func summaryRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalPrimary)
                .frame(width: 24)

            Text(title)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Spacer()

            Text(value)
                .font(.vitalLabel)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
        }
    }

    private var endDate: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: durationWeeks, to: startDate) ?? startDate
    }

    // MARK: - Actions

    private func createMesocycle() {
        isCreating = true
        HapticFeedback.success()

        Task {
            // Convert quick template to training blocks
            let trainingBlocks = selectedTemplate.toTrainingBlocks()

            await viewModel.createMesocycle(
                name: programName.isEmpty ? "My Program" : programName,
                startDate: startDate,
                durationWeeks: durationWeeks,
                goal: .hypertrophy, // Default
                phaseTemplate: .standard,
                trainingBlocks: trainingBlocks
            )

            isCreating = false
            dismiss()
        }
    }
}

// MARK: - Quick Templates

enum QuickTemplate: CaseIterable {
    case pushPullLegs
    case upperLower
    case fullBody
    case broSplit

    var name: String {
        switch self {
        case .pushPullLegs: return "Push/Pull/Legs"
        case .upperLower: return "Upper/Lower"
        case .fullBody: return "Full Body"
        case .broSplit: return "Bro Split"
        }
    }

    var description: String {
        switch self {
        case .pushPullLegs: return "Classic 6-day split focusing on movement patterns"
        case .upperLower: return "4-day split for balanced upper and lower development"
        case .fullBody: return "3 sessions hitting all muscle groups each time"
        case .broSplit: return "5-day split with dedicated muscle group days"
        }
    }

    var icon: String {
        switch self {
        case .pushPullLegs: return "arrow.left.arrow.right"
        case .upperLower: return "arrow.up.arrow.down"
        case .fullBody: return "figure.stand"
        case .broSplit: return "dumbbell.fill"
        }
    }

    var daysPerWeek: Int {
        switch self {
        case .pushPullLegs: return 6
        case .upperLower: return 4
        case .fullBody: return 3
        case .broSplit: return 5
        }
    }

    var days: [String] {
        switch self {
        case .pushPullLegs:
            return ["Push", "Pull", "Legs", "Push", "Pull", "Legs"]
        case .upperLower:
            return ["Upper", "Lower", "Upper", "Lower"]
        case .fullBody:
            return ["Full A", "Full B", "Full C"]
        case .broSplit:
            return ["Chest", "Back", "Shoulders", "Arms", "Legs"]
        }
    }

    func toTrainingBlocks() -> [TrainingBlock] {
        let tempMesocycleId = UUID()
        var dayOfWeek = 2 // Start Monday

        return days.enumerated().map { index, name in
            let block = TrainingBlock(name: name, dayOfWeek: dayOfWeek, mesocycleId: tempMesocycleId)
            dayOfWeek += 1
            if dayOfWeek > 7 { dayOfWeek = 2 } // Wrap around
            return block
        }
    }
}

// MARK: - Progression Types

enum ProgressionType: String, CaseIterable {
    case reps = "Add Reps"
    case weight = "Add Weight"
    case both = "Both"
}

#Preview {
    CreateMesocycleView(
        viewModel: MesocycleViewModel(
            mesocycleRepository: PreviewMesocycleRepository(),
            workoutRepository: PreviewWorkoutRepository()
        )
    )
}
