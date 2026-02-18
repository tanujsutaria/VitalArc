//
//  CreateMesocycleView.swift
//  VitalArc
//
//  Mesocycle creation - Pick YOUR template → Set weeks → Auto-progression
//

import SwiftUI

struct CreateMesocycleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencyContainer) private var container
    let viewModel: MesocycleViewModel

    // User's saved templates
    @State private var userTemplates: [WorkoutTemplate] = []
    @State private var isLoadingTemplates = true

    // Selected template
    @State private var selectedTemplateId: UUID?

    // Configuration
    @State private var programName = ""
    @State private var durationWeeks = 4
    @State private var startDate = Date()
    @State private var autoProgressionEnabled = true
    @State private var weightIncrementLbs: Double = 5.0
    @State private var repIncrement: Int = 1

    @State private var isCreating = false

    var selectedTemplate: WorkoutTemplate? {
        userTemplates.first { $0.id == selectedTemplateId }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoadingTemplates {
                    ProgressView("Loading templates...")
                } else if userTemplates.isEmpty {
                    noTemplatesView
                } else {
                    createMesocycleForm
                }
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle("Create Mesocycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createMesocycle()
                    }
                    .disabled(!canCreate || isCreating)
                }
            }
            .task {
                await loadUserTemplates()
            }
        }
    }

    // MARK: - No Templates View

    private var noTemplatesView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "doc.badge.plus")
                .font(.vitalIconHero)
                .foregroundStyle(Color.vitalAdaptiveTextTertiary)

            Text("No Templates Yet")
                .font(.vitalH2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            Text("Create a workout template first, then come back to build a mesocycle from it.")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            Button {
                dismiss()
            } label: {
                Text("Go to Templates")
                    .font(.vitalLabel)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(Color.vitalPrimary)
                    .cornerRadius(Spacing.radiusMedium)
            }
            .padding(.top, Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Create Mesocycle Form

    private var createMesocycleForm: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Template Selection
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("SELECT TEMPLATE")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiary)
                        .padding(.horizontal, Spacing.screenPadding)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.md) {
                            ForEach(userTemplates) { template in
                                templateCard(template)
                            }
                        }
                        .padding(.horizontal, Spacing.screenPadding)
                    }
                }

                // Program Name
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("PROGRAM NAME")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiary)

                    TextField("e.g., Summer Bulk", text: $programName)
                        .font(.vitalBody)
                        .padding(Spacing.md)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                }
                .padding(.horizontal, Spacing.screenPadding)

                // Duration
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("DURATION")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiary)

                    HStack {
                        Text("\(durationWeeks)")
                            .font(.vitalDisplayLarge)
                            .foregroundStyle(Color.vitalPrimary)

                        Text("weeks")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                        Spacer()

                        Stepper("", value: $durationWeeks, in: 1...16)
                            .labelsHidden()
                    }
                    .padding(Spacing.md)
                    .background(Color.vitalAdaptiveSurface)
                    .cornerRadius(Spacing.radiusMedium)

                    // Quick select
                    HStack(spacing: Spacing.sm) {
                        ForEach([4, 6, 8, 12], id: \.self) { weeks in
                            Button {
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
                .padding(.horizontal, Spacing.screenPadding)

                // Start Date
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("START DATE")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiary)

                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(Spacing.md)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                }
                .padding(.horizontal, Spacing.screenPadding)

                // Auto-Progression
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("AUTO-PROGRESSION")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiary)

                    Toggle(isOn: $autoProgressionEnabled) {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Enable Auto-Progression")
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                            Text("Automatically increase weight/reps each week")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                    }
                    .tint(Color.vitalPrimary)
                    .padding(Spacing.md)
                    .background(Color.vitalAdaptiveSurface)
                    .cornerRadius(Spacing.radiusMedium)

                    if autoProgressionEnabled {
                        VStack(spacing: Spacing.md) {
                            // Weight increment (lbs)
                            HStack {
                                Text("Weight increase per week")
                                    .font(.vitalBody)
                                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                                Spacer()

                                HStack(spacing: Spacing.xs) {
                                    Button {
                                        if weightIncrementLbs > 2.5 {
                                            weightIncrementLbs -= 2.5
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundStyle(Color.vitalPrimary)
                                    }

                                    Text("\(String(format: "%.1f", weightIncrementLbs)) lbs")
                                        .font(.vitalLabel)
                                        .foregroundStyle(Color.vitalPrimary)
                                        .frame(width: 70)

                                    Button {
                                        if weightIncrementLbs < 20 {
                                            weightIncrementLbs += 2.5
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundStyle(Color.vitalPrimary)
                                    }
                                }
                            }

                            Divider()

                            // Rep increment
                            HStack {
                                Text("Rep increase per week")
                                    .font(.vitalBody)
                                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                                Spacer()

                                HStack(spacing: Spacing.xs) {
                                    Button {
                                        if repIncrement > 1 {
                                            repIncrement -= 1
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundStyle(Color.vitalPrimary)
                                    }

                                    Text("+\(repIncrement) reps")
                                        .font(.vitalLabel)
                                        .foregroundStyle(Color.vitalPrimary)
                                        .frame(width: 70)

                                    Button {
                                        if repIncrement < 5 {
                                            repIncrement += 1
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundStyle(Color.vitalPrimary)
                                    }
                                }
                            }
                        }
                        .padding(Spacing.md)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)

                // Summary
                if let template = selectedTemplate {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("SUMMARY")
                            .font(.vitalCaptionSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextTertiary)

                        VStack(spacing: Spacing.md) {
                            summaryRow("Template", template.name)
                            Divider()
                            summaryRow("Duration", "\(durationWeeks) weeks")
                            Divider()
                            summaryRow("Start", startDate.formatted(date: .abbreviated, time: .omitted))
                            Divider()
                            summaryRow("End", endDate.formatted(date: .abbreviated, time: .omitted))
                            if autoProgressionEnabled {
                                Divider()
                                summaryRow("Weekly Progress", "+\(String(format: "%.1f", weightIncrementLbs)) lbs / +\(repIncrement) reps")
                            }
                        }
                        .padding(Spacing.md)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                    }
                    .padding(.horizontal, Spacing.screenPadding)
                }
            }
            .padding(.vertical, Spacing.md)
        }
    }

    private func templateCard(_ template: WorkoutTemplate) -> some View {
        Button {
            selectedTemplateId = template.id
        } label: {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: template.category.icon)
                        .font(.vitalH3)
                        .foregroundStyle(selectedTemplateId == template.id ? .white : Color.vitalPrimary)

                    Spacer()

                    if selectedTemplateId == template.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white)
                    }
                }

                Text(template.name)
                    .font(.vitalLabel)
                    .foregroundStyle(selectedTemplateId == template.id ? .white : Color.vitalAdaptiveTextPrimary)
                    .lineLimit(1)

                Text("\(template.exerciseCount) exercises")
                    .font(.vitalCaption)
                    .foregroundStyle(selectedTemplateId == template.id ? .white.opacity(0.8) : Color.vitalAdaptiveTextSecondary)
            }
            .frame(width: Spacing.illustrationXLarge)
            .padding(Spacing.md)
            .background(selectedTemplateId == template.id ? Color.vitalPrimary : Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(selectedTemplateId == template.id ? Color.clear : Color.vitalAdaptiveBorder, lineWidth: 1)
            )
        }
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack {
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

    private var canCreate: Bool {
        selectedTemplateId != nil && !programName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Actions

    private func loadUserTemplates() async {
        guard let container = container else {
            isLoadingTemplates = false
            return
        }

        do {
            userTemplates = try await container.templateRepository.getTemplates()
        } catch {
            Log.error("Failed to load templates", error: error, category: .workout)
        }

        isLoadingTemplates = false
    }

    private func createMesocycle() {
        guard let template = selectedTemplate else { return }

        isCreating = true
        HapticFeedback.success()

        Task {
            // Create training blocks from the template
            var trainingBlocks: [TrainingBlock] = []
            let tempMesocycleId = UUID()

            // Create a single training block representing the template
            let block = TrainingBlock(
                name: template.name,
                dayOfWeek: 1,
                mesocycleId: tempMesocycleId
            )
            trainingBlocks.append(block)

            await viewModel.createMesocycle(
                name: programName,
                startDate: startDate,
                durationWeeks: durationWeeks,
                goal: .hypertrophy,
                phaseTemplate: .standard,
                trainingBlocks: trainingBlocks
            )

            isCreating = false
            dismiss()
        }
    }
}

#Preview {
    CreateMesocycleView(
        viewModel: MesocycleViewModel(
            mesocycleRepository: PreviewMesocycleRepository(),
            workoutRepository: PreviewWorkoutRepository()
        )
    )
}
