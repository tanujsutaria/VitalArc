//
//  TemplateEditorView.swift
//  VitalArc
//
//  Visual workout template editor with day columns
//

import SwiftUI

// MARK: - Data Models

/// Represents a day in the weekly template
struct TemplateDay: Identifiable {
    let id = UUID()
    var name: String
    var exercises: [TemplateDayExercise]

    init(name: String = "Rest", exercises: [TemplateDayExercise] = []) {
        self.name = name
        self.exercises = exercises
    }
}

/// Exercise within a template day
struct TemplateDayExercise: Identifiable, Equatable {
    let id = UUID()
    let exerciseId: UUID
    let exerciseName: String
    let primaryMuscle: String
    var sets: Int
    var repRange: String

    init(
        exerciseId: UUID,
        exerciseName: String,
        primaryMuscle: String,
        sets: Int = 3,
        repRange: String = "8-12"
    ) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.primaryMuscle = primaryMuscle
        self.sets = sets
        self.repRange = repRange
    }
}

// MARK: - Template Editor View

struct TemplateEditorView: View {
    @State private var templateName: String = "My Template"
    @State private var days: [TemplateDay] = [
        TemplateDay(name: "Day 1"),
        TemplateDay(name: "Day 2"),
        TemplateDay(name: "Day 3"),
        TemplateDay(name: "Day 4"),
        TemplateDay(name: "Day 5"),
        TemplateDay(name: "Day 6"),
        TemplateDay(name: "Day 7")
    ]

    @State private var selectedDayIndex: Int?
    @State private var showingExercisePicker = false
    @State private var editingDayNameIndex: Int?
    @State private var editingTemplateName = false

    @Environment(\.dismiss) private var dismiss

    private let dayColumnWidth: CGFloat = 160

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Template name header
                templateNameHeader

                // Day columns in horizontal scroll
                dayColumnsScrollView
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                if let dayIndex = selectedDayIndex {
                    TemplateExercisePickerView { exercise in
                        addExercise(exercise, toDayIndex: dayIndex)
                    }
                }
            }
        }
    }

    // MARK: - Template Name Header

    private var templateNameHeader: some View {
        VStack(spacing: Spacing.sm) {
            if editingTemplateName {
                HStack {
                    TextField("Template Name", text: $templateName)
                        .font(.vitalH1)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)

                    Button {
                        editingTemplateName = false
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.vitalPrimary)
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)
            } else {
                Button {
                    editingTemplateName = true
                } label: {
                    HStack(spacing: Spacing.sm) {
                        Text(templateName)
                            .font(.vitalH1)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        Image(systemName: "pencil")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }
            }

            Text("Tap day names to rename, + to add exercises")
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Day Columns Scroll View

    private var dayColumnsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                    dayColumn(day: day, index: index)
                }
            }
            .padding(.horizontal, Spacing.screenPadding)
            .padding(.bottom, Spacing.lg)
        }
    }

    // MARK: - Day Column

    private func dayColumn(day: TemplateDay, index: Int) -> some View {
        VStack(spacing: 0) {
            // Day header
            dayHeader(day: day, index: index)

            // Exercises list
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.sm) {
                    ForEach(day.exercises) { exercise in
                        exerciseRow(exercise: exercise, dayIndex: index)
                    }
                    .onMove { from, to in
                        days[index].exercises.move(fromOffsets: from, toOffset: to)
                    }

                    // Add exercise button
                    addExerciseButton(dayIndex: index)
                }
                .padding(Spacing.sm)
            }
        }
        .frame(width: dayColumnWidth)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusLarge)
        .vitalCardShadow()
    }

    // MARK: - Day Header

    private func dayHeader(day: TemplateDay, index: Int) -> some View {
        Group {
            if editingDayNameIndex == index {
                HStack {
                    TextField("Day Name", text: $days[index].name)
                        .font(.vitalH4)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)

                    Button {
                        editingDayNameIndex = nil
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.vitalLabelSmall)
                            .foregroundStyle(Color.vitalPrimary)
                    }
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.md)
            } else {
                Button {
                    editingDayNameIndex = index
                } label: {
                    VStack(spacing: Spacing.xs) {
                        Text(day.name)
                            .font(.vitalH4)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        Text("\(day.exercises.count) exercises")
                            .font(.vitalCaptionSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                }
            }
        }
        .background(dayHeaderBackground(index: index))
    }

    private func dayHeaderBackground(index: Int) -> some View {
        Group {
            if days[index].exercises.isEmpty {
                Color.vitalAdaptiveSurface
            } else {
                Color.vitalPrimary.opacity(0.1)
            }
        }
        .cornerRadius(Spacing.radiusLarge, corners: [.topLeft, .topRight])
    }

    // MARK: - Exercise Row

    private func exerciseRow(exercise: TemplateDayExercise, dayIndex: Int) -> some View {
        SwipeToDeleteView(
            onDelete: {
                withAnimation(.vitalSpring) {
                    deleteExercise(exercise, fromDayIndex: dayIndex)
                }
            }
        ) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(exercise.exerciseName)
                        .font(.vitalLabelSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    Image(systemName: "line.3.horizontal")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiary)
                }

                HStack(spacing: Spacing.sm) {
                    Text("\(exercise.sets) sets")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    Text(exercise.repRange)
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                Text(exercise.primaryMuscle)
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalPrimary)
            }
            .padding(Spacing.sm)
            .background(Color.vitalAdaptiveBackground)
            .cornerRadius(Spacing.radiusSmall)
        }
    }

    // MARK: - Add Exercise Button

    private func addExerciseButton(dayIndex: Int) -> some View {
        Button {
            selectedDayIndex = dayIndex
            showingExercisePicker = true
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "plus.circle.fill")
                    .font(.vitalLabel)
                Text("Add")
                    .font(.vitalLabelSmall)
            }
            .foregroundStyle(Color.vitalPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.vitalPrimary.opacity(0.1))
            .cornerRadius(Spacing.radiusSmall)
        }
    }

    // MARK: - Helper Properties

    private var isValid: Bool {
        !templateName.trimmingCharacters(in: .whitespaces).isEmpty &&
        days.contains { !$0.exercises.isEmpty }
    }

    // MARK: - Actions

    private func addExercise(_ exercise: TemplateDayExercise, toDayIndex dayIndex: Int) {
        days[dayIndex].exercises.append(exercise)
    }

    private func deleteExercise(_ exercise: TemplateDayExercise, fromDayIndex dayIndex: Int) {
        days[dayIndex].exercises.removeAll { $0.id == exercise.id }
    }

    private func saveTemplate() {
        // Convert to domain model and save
        // For now, just dismiss
        HapticFeedback.success()
        dismiss()
    }
}

// MARK: - Swipe to Delete View

struct SwipeToDeleteView<Content: View>: View {
    let onDelete: () -> Void
    let content: Content

    @State private var offset: CGFloat = 0
    @State private var showingDelete = false

    private let deleteThreshold: CGFloat = -60
    private let deleteButtonWidth: CGFloat = 60

    init(onDelete: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onDelete = onDelete
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button background
            HStack {
                Spacer()
                Button {
                    HapticFeedback.medium()
                    onDelete()
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.vitalLabel)
                        .foregroundStyle(.white)
                        .frame(width: deleteButtonWidth, height: .infinity)
                }
            }
            .background(Color.vitalDanger)
            .cornerRadius(Spacing.radiusSmall)

            // Main content
            content
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = max(value.translation.width, -deleteButtonWidth)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.vitalSpring) {
                                if value.translation.width < deleteThreshold {
                                    offset = -deleteButtonWidth
                                    showingDelete = true
                                } else {
                                    offset = 0
                                    showingDelete = false
                                }
                            }
                        }
                )
                .onTapGesture {
                    if showingDelete {
                        withAnimation(.vitalSpring) {
                            offset = 0
                            showingDelete = false
                        }
                    }
                }
        }
    }
}

// MARK: - Color Extension for Tertiary Text

extension Color {
    static var vitalAdaptiveTextTertiary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "#9CA3AF"))
                : UIColor(Color.vitalTextTertiary)
        })
    }
}

// MARK: - Preview

#Preview {
    TemplateEditorView()
}
