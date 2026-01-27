//
//  WorkoutTemplatesView.swift
//  VitalArc
//
//  View for browsing and managing workout templates
//

import SwiftUI

struct WorkoutTemplatesView: View {
    @State private var viewModel: WorkoutTemplatesViewModel
    @State private var showingCreateTemplate = false
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var searchText = ""

    init(viewModel: WorkoutTemplatesViewModel) {
        self.viewModel = viewModel
    }

    var filteredTemplates: [WorkoutTemplate] {
        if searchText.isEmpty {
            return viewModel.templates
        } else {
            return viewModel.templates.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    var templatesByCategory: [TemplateCategory: [WorkoutTemplate]] {
        Dictionary(grouping: filteredTemplates) { $0.category }
    }

    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("Templates")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingCreateTemplate = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .task {
                    await viewModel.loadTemplates()
                }
                .sheet(isPresented: $showingCreateTemplate) {
                    TemplateEditorView(viewModel: viewModel)
                }
                .sheet(item: $selectedTemplate) { template in
                    startWorkoutSheet(for: template)
                }
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            if !viewModel.templates.isEmpty {
                templatesList
            } else {
                emptyStateView
            }
        }
    }

    private var templatesList: some View {
        List {
            recentTemplatesSection
            mostUsedTemplatesSection
            allTemplatesByCategory
        }
        .searchable(text: $searchText, prompt: "Search templates")
    }

    @ViewBuilder
    private var recentTemplatesSection: some View {
        if !viewModel.recentTemplates.isEmpty {
            Section("Recently Used") {
                ForEach(viewModel.recentTemplates) { template in
                    TemplateRow(template: template) {
                        selectedTemplate = template
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var mostUsedTemplatesSection: some View {
        if !viewModel.mostUsedTemplates.isEmpty {
            Section("Most Used") {
                ForEach(viewModel.mostUsedTemplates) { template in
                    TemplateRow(template: template) {
                        selectedTemplate = template
                    }
                }
            }
        }
    }

    private var allTemplatesByCategory: some View {
        ForEach(TemplateCategory.allCases, id: \.self) { category in
            categorySection(for: category)
        }
    }

    @ViewBuilder
    private func categorySection(for category: TemplateCategory) -> some View {
        if let templates = templatesByCategory[category], !templates.isEmpty {
            Section(category.displayName) {
                ForEach(templates) { template in
                    NavigationLink {
                        templateDetailView(for: template)
                    } label: {
                        TemplateRow(template: template) {
                            selectedTemplate = template
                        }
                    }
                }
            }
        }
    }

    private func templateDetailView(for template: WorkoutTemplate) -> some View {
        TemplateDetailView(
            template: template,
            onUseTemplate: { selectedTemplate = $0 },
            onDeleteTemplate: { templateToDelete in
                Task {
                    await viewModel.deleteTemplate(templateToDelete)
                }
            }
        )
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Templates",
            systemImage: "list.clipboard",
            description: Text("Create your first workout template")
        )
    }

    private func startWorkoutSheet(for template: WorkoutTemplate) -> some View {
        StartWorkoutFromTemplateSheet(
            template: template,
            onStart: { workout in
                Task {
                    await viewModel.startWorkout(from: template)
                }
            }
        )
    }
}

struct TemplateRow: View {
    let template: WorkoutTemplate
    let onQuickStart: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Category icon
            Image(systemName: template.category.icon)
                .font(.title2)
                .foregroundStyle(Color.vitalPrimary)
                .frame(width: 40)

            // Template details
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(template.name)
                    .font(.vitalH4)

                HStack(spacing: Spacing.md) {
                    Label("\(template.exerciseCount) exercises", systemImage: "figure.strengthtraining.traditional")
                    Label("\(template.estimatedDuration) min", systemImage: "clock")
                }
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                if let description = template.description, !description.isEmpty {
                    Text(description)
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            // Usage stats
            if template.useCount > 0 {
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("\(template.useCount)")
                        .font(.vitalH3)
                        .fontWeight(.semibold)
                    Text("uses")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
        .contentShape(Rectangle())
    }
}

struct StartWorkoutFromTemplateSheet: View {
    let template: WorkoutTemplate
    let onStart: (Workout) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                // Template info
                VStack(spacing: Spacing.sm) {
                    Image(systemName: template.category.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(Color.vitalPrimary)

                    Text(template.name)
                        .font(.vitalH2)
                        .fontWeight(.bold)

                    if let description = template.description {
                        Text(description)
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(Spacing.lg)

                // Stats
                HStack(spacing: Spacing.xl) {
                    StatItem(value: "\(template.exerciseCount)", label: "Exercises")
                    StatItem(value: "\(template.totalSets)", label: "Sets")
                    StatItem(value: "\(template.estimatedDuration) min", label: "Duration")
                }

                // Exercise list
                List {
                    ForEach(template.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { exercise in
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(exercise.exerciseName)
                                .font(.vitalH4)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                            HStack {
                                Text("\(exercise.sets) × \(exercise.repsDisplay) reps")
                                    .font(.vitalBody)
                                Spacer()
                                Text("Rest: \(exercise.restDisplay)")
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                        }
                    }
                }
                .listStyle(.plain)

                // Start button
                Button {
                    // Create workout from template
                    dismiss()
                } label: {
                    Text("Start Workout")
                        .font(.vitalH3)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.lg)
                        .background(Color.vitalPrimary)
                        .cornerRadius(Spacing.radiusMedium)
                }
                .padding(Spacing.screenPadding)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.vitalH2)
                .fontWeight(.bold)
            Text(label)
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class WorkoutTemplatesViewModel {
    let loadTemplateUseCase: LoadWorkoutTemplateUseCase
    let saveTemplateUseCase: SaveWorkoutTemplateUseCase
    private let templateRepository: TemplateRepository

    var templates: [WorkoutTemplate] = []
    var recentTemplates: [WorkoutTemplate] = []
    var mostUsedTemplates: [WorkoutTemplate] = []
    var isLoading = false
    var errorMessage: String?

    init(
        loadTemplateUseCase: LoadWorkoutTemplateUseCase,
        saveTemplateUseCase: SaveWorkoutTemplateUseCase,
        templateRepository: TemplateRepository
    ) {
        self.loadTemplateUseCase = loadTemplateUseCase
        self.saveTemplateUseCase = saveTemplateUseCase
        self.templateRepository = templateRepository
    }

    func loadTemplates() async {
        isLoading = true
        errorMessage = nil

        do {
            async let allTemplates = loadTemplateUseCase.execute()
            async let recent = loadTemplateUseCase.getRecentlyUsedTemplates(limit: 3)
            async let mostUsed = loadTemplateUseCase.getMostUsedTemplates(limit: 3)

            templates = try await allTemplates
            recentTemplates = try await recent
            mostUsedTemplates = try await mostUsed
        } catch {
            errorMessage = "Failed to load templates: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func deleteTemplate(_ template: WorkoutTemplate) async {
        do {
            try await templateRepository.deleteTemplate(id: template.id)
            await loadTemplates()
        } catch {
            errorMessage = "Failed to delete template: \(error.localizedDescription)"
        }
    }

    func startWorkout(from template: WorkoutTemplate) async {
        do {
            _ = try await loadTemplateUseCase.createWorkoutFromTemplate(template)
            await loadTemplates() // Reload to update usage stats
        } catch {
            errorMessage = "Failed to create workout: \(error.localizedDescription)"
        }
    }
}
