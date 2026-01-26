//
//  CreateMesocycleView.swift
//  VitalArc
//
//  View for creating a new mesocycle
//

import SwiftUI

struct CreateMesocycleView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: MesocycleViewModel

    @State private var name = ""
    @State private var startDate = Date()
    @State private var durationWeeks = 8
    @State private var selectedGoal: TrainingGoal = .hypertrophy
    @State private var selectedTemplate: PhaseTemplate = .standard
    @State private var trainingBlocks: [TrainingBlock] = []
    @State private var showingTemplateSheet = false
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            Form {
                // Basic Information
                Section("Program Details") {
                    TextField("Program Name", text: $name)
                        .autocorrectionDisabled()

                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)

                    Stepper("Duration: \(durationWeeks) weeks", value: $durationWeeks, in: 1...52)
                }

                // Goal Selection
                Section("Training Goal") {
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(TrainingGoal.allCases, id: \.self) { goal in
                            Label(goal.rawValue, systemImage: goal.icon)
                                .tag(goal)
                        }
                    }
                    .pickerStyle(.menu)

                    Text(selectedGoal.description)
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                // Phase Template
                Section("Periodization") {
                    Picker("Template", selection: $selectedTemplate) {
                        Text("Standard").tag(PhaseTemplate.standard)
                        Text("Beginner").tag(PhaseTemplate.beginner)
                        Text("Advanced").tag(PhaseTemplate.advanced)
                    }
                    .pickerStyle(.segmented)

                    templateDescription
                }

                // Training Blocks
                Section {
                    Button {
                        showingTemplateSheet = true
                    } label: {
                        Label("Add Training Blocks", systemImage: "plus.circle.fill")
                    }

                    if !trainingBlocks.isEmpty {
                        ForEach(trainingBlocks) { block in
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text(block.name)
                                    .font(.vitalH3)

                                Text("\(block.dayName) • \(block.exercises.count) exercises")
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                        }
                        .onDelete { indexSet in
                            trainingBlocks.remove(atOffsets: indexSet)
                        }
                    }
                } header: {
                    Text("Training Schedule")
                } footer: {
                    Text("Add training blocks to define your weekly workout schedule. You can also add these later.")
                        .font(.vitalCaption)
                }

                // Preview
                Section("Summary") {
                    LabeledContent("Total Weeks", value: "\(durationWeeks)")
                    LabeledContent("Training Days", value: "\(trainingBlocks.count)")
                    LabeledContent("End Date", value: endDate, format: .dateTime.year().month().day())
                }
            }
            .navigationTitle("Create Program")
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
                    .disabled(!isValid || isCreating)
                }
            }
            .sheet(isPresented: $showingTemplateSheet) {
                TrainingBlockTemplateView(trainingBlocks: $trainingBlocks)
            }
        }
    }

    private var templateDescription: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            switch selectedTemplate {
            case .standard:
                Text("Classic 4-week blocks with accumulation, intensification, and deload weeks")
            case .beginner:
                Text("Simplified 3-week blocks with more recovery time")
            case .advanced:
                Text("Block periodization with distinct training phases")
            case .custom:
                Text("Custom phase progression")
            }
        }
        .font(.vitalCaption)
        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
    }

    private var endDate: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: durationWeeks - 1, to: startDate) ?? startDate
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && durationWeeks > 0
    }

    private func createMesocycle() {
        isCreating = true

        Task {
            await viewModel.createMesocycle(
                name: name,
                startDate: startDate,
                durationWeeks: durationWeeks,
                goal: selectedGoal,
                phaseTemplate: selectedTemplate,
                trainingBlocks: trainingBlocks
            )

            isCreating = false
            dismiss()
        }
    }
}

struct TrainingBlockTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var trainingBlocks: [TrainingBlock]

    @State private var selectedTemplate: TrainingTemplate = .pushPullLegs

    var body: some View {
        NavigationStack {
            List {
                Section("Select Template") {
                    Picker("Template", selection: $selectedTemplate) {
                        ForEach(TrainingTemplate.allCases, id: \.self) { template in
                            Text(template.name).tag(template)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("Preview") {
                    Text(selectedTemplate.description)
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    ForEach(selectedTemplate.blocks, id: \.name) { block in
                        VitalCard(padding: Spacing.sm, shadow: false) {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text(block.name)
                                    .font(.vitalH3)

                                Text(block.dayName)
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .navigationTitle("Training Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        trainingBlocks = selectedTemplate.blocks
                        dismiss()
                    }
                }
            }
        }
    }
}

enum TrainingTemplate: CaseIterable {
    case pushPullLegs
    case upperLower
    case fullBody

    var name: String {
        switch self {
        case .pushPullLegs: return "Push/Pull/Legs"
        case .upperLower: return "Upper/Lower"
        case .fullBody: return "Full Body"
        }
    }

    var description: String {
        switch self {
        case .pushPullLegs:
            return "6-day split focusing on push movements, pull movements, and legs separately"
        case .upperLower:
            return "4-day split alternating between upper and lower body"
        case .fullBody:
            return "3-day split training all muscle groups each session"
        }
    }

    var blocks: [TrainingBlock] {
        let tempMesocycleId = UUID()

        switch self {
        case .pushPullLegs:
            return [
                TrainingBlock(name: "Push A", dayOfWeek: 2, mesocycleId: tempMesocycleId), // Monday
                TrainingBlock(name: "Pull A", dayOfWeek: 3, mesocycleId: tempMesocycleId), // Tuesday
                TrainingBlock(name: "Legs A", dayOfWeek: 4, mesocycleId: tempMesocycleId), // Wednesday
                TrainingBlock(name: "Push B", dayOfWeek: 5, mesocycleId: tempMesocycleId), // Thursday
                TrainingBlock(name: "Pull B", dayOfWeek: 6, mesocycleId: tempMesocycleId), // Friday
                TrainingBlock(name: "Legs B", dayOfWeek: 7, mesocycleId: tempMesocycleId)  // Saturday
            ]
        case .upperLower:
            return [
                TrainingBlock(name: "Upper A", dayOfWeek: 2, mesocycleId: tempMesocycleId), // Monday
                TrainingBlock(name: "Lower A", dayOfWeek: 3, mesocycleId: tempMesocycleId), // Tuesday
                TrainingBlock(name: "Upper B", dayOfWeek: 5, mesocycleId: tempMesocycleId), // Thursday
                TrainingBlock(name: "Lower B", dayOfWeek: 6, mesocycleId: tempMesocycleId)  // Friday
            ]
        case .fullBody:
            return [
                TrainingBlock(name: "Full Body A", dayOfWeek: 2, mesocycleId: tempMesocycleId), // Monday
                TrainingBlock(name: "Full Body B", dayOfWeek: 4, mesocycleId: tempMesocycleId), // Wednesday
                TrainingBlock(name: "Full Body C", dayOfWeek: 6, mesocycleId: tempMesocycleId)  // Friday
            ]
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
