//
//  TemplateExercisePickerView.swift
//  VitalArc
//
//  Exercise picker grouped by body part for template editor
//

import SwiftUI

struct TemplateExercisePickerView: View {
    @State private var searchText = ""
    @State private var selectedBodyPart: BodyPart?

    @Environment(\.dismiss) private var dismiss

    let onSelect: (TemplateDayExercise) -> Void

    // Body part groupings for display
    enum BodyPart: String, CaseIterable, Identifiable {
        case chest = "Chest"
        case back = "Back"
        case shoulders = "Shoulders"
        case biceps = "Biceps"
        case triceps = "Triceps"
        case legs = "Legs"
        case core = "Core"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .chest: return "figure.strengthtraining.traditional"
            case .back: return "figure.rowing"
            case .shoulders: return "figure.arms.open"
            case .biceps: return "figure.boxing"
            case .triceps: return "figure.boxing"
            case .legs: return "figure.run"
            case .core: return "figure.core.training"
            }
        }

        var exercises: [ExerciseItem] {
            switch self {
            case .chest:
                return [
                    ExerciseItem(name: "Barbell Bench Press", muscle: "Chest"),
                    ExerciseItem(name: "Incline Barbell Bench Press", muscle: "Upper Chest"),
                    ExerciseItem(name: "Decline Barbell Bench Press", muscle: "Lower Chest"),
                    ExerciseItem(name: "Dumbbell Bench Press", muscle: "Chest"),
                    ExerciseItem(name: "Incline Dumbbell Bench Press", muscle: "Upper Chest"),
                    ExerciseItem(name: "Dumbbell Fly", muscle: "Chest"),
                    ExerciseItem(name: "Incline Dumbbell Fly", muscle: "Upper Chest"),
                    ExerciseItem(name: "Cable Chest Fly", muscle: "Chest"),
                    ExerciseItem(name: "Cable Crossover", muscle: "Chest"),
                    ExerciseItem(name: "Machine Chest Press", muscle: "Chest"),
                    ExerciseItem(name: "Pec Deck Machine", muscle: "Chest"),
                    ExerciseItem(name: "Push-ups", muscle: "Chest"),
                    ExerciseItem(name: "Dips", muscle: "Lower Chest")
                ]
            case .back:
                return [
                    ExerciseItem(name: "Barbell Deadlift", muscle: "Back"),
                    ExerciseItem(name: "Barbell Row", muscle: "Upper Back"),
                    ExerciseItem(name: "Pull-ups", muscle: "Lats"),
                    ExerciseItem(name: "Chin-ups", muscle: "Lats"),
                    ExerciseItem(name: "Lat Pulldown", muscle: "Lats"),
                    ExerciseItem(name: "Wide Grip Lat Pulldown", muscle: "Lats"),
                    ExerciseItem(name: "Cable Row", muscle: "Mid Back"),
                    ExerciseItem(name: "Dumbbell Row", muscle: "Upper Back"),
                    ExerciseItem(name: "Single Arm Dumbbell Row", muscle: "Lats"),
                    ExerciseItem(name: "T-Bar Row", muscle: "Mid Back"),
                    ExerciseItem(name: "Machine Row", muscle: "Mid Back"),
                    ExerciseItem(name: "Face Pull", muscle: "Rear Delts"),
                    ExerciseItem(name: "Straight Arm Pulldown", muscle: "Lats")
                ]
            case .shoulders:
                return [
                    ExerciseItem(name: "Barbell Overhead Press", muscle: "Shoulders"),
                    ExerciseItem(name: "Dumbbell Shoulder Press", muscle: "Shoulders"),
                    ExerciseItem(name: "Arnold Press", muscle: "Shoulders"),
                    ExerciseItem(name: "Lateral Raise", muscle: "Side Delts"),
                    ExerciseItem(name: "Front Raise", muscle: "Front Delts"),
                    ExerciseItem(name: "Reverse Fly", muscle: "Rear Delts"),
                    ExerciseItem(name: "Cable Lateral Raise", muscle: "Side Delts"),
                    ExerciseItem(name: "Machine Shoulder Press", muscle: "Shoulders"),
                    ExerciseItem(name: "Upright Row", muscle: "Shoulders"),
                    ExerciseItem(name: "Shrugs", muscle: "Traps")
                ]
            case .biceps:
                return [
                    ExerciseItem(name: "Barbell Curl", muscle: "Biceps"),
                    ExerciseItem(name: "Dumbbell Curl", muscle: "Biceps"),
                    ExerciseItem(name: "Hammer Curl", muscle: "Biceps"),
                    ExerciseItem(name: "Preacher Curl", muscle: "Biceps"),
                    ExerciseItem(name: "Incline Dumbbell Curl", muscle: "Biceps"),
                    ExerciseItem(name: "Concentration Curl", muscle: "Biceps"),
                    ExerciseItem(name: "Cable Curl", muscle: "Biceps"),
                    ExerciseItem(name: "EZ Bar Curl", muscle: "Biceps"),
                    ExerciseItem(name: "Spider Curl", muscle: "Biceps")
                ]
            case .triceps:
                return [
                    ExerciseItem(name: "Close Grip Bench Press", muscle: "Triceps"),
                    ExerciseItem(name: "Tricep Pushdown", muscle: "Triceps"),
                    ExerciseItem(name: "Overhead Tricep Extension", muscle: "Triceps"),
                    ExerciseItem(name: "Skull Crushers", muscle: "Triceps"),
                    ExerciseItem(name: "Tricep Dips", muscle: "Triceps"),
                    ExerciseItem(name: "Tricep Kickback", muscle: "Triceps"),
                    ExerciseItem(name: "Cable Overhead Extension", muscle: "Triceps"),
                    ExerciseItem(name: "Diamond Push-ups", muscle: "Triceps")
                ]
            case .legs:
                return [
                    ExerciseItem(name: "Barbell Back Squat", muscle: "Quadriceps"),
                    ExerciseItem(name: "Barbell Front Squat", muscle: "Quadriceps"),
                    ExerciseItem(name: "Leg Press", muscle: "Quadriceps"),
                    ExerciseItem(name: "Hack Squat", muscle: "Quadriceps"),
                    ExerciseItem(name: "Leg Extension", muscle: "Quadriceps"),
                    ExerciseItem(name: "Romanian Deadlift", muscle: "Hamstrings"),
                    ExerciseItem(name: "Leg Curl", muscle: "Hamstrings"),
                    ExerciseItem(name: "Walking Lunges", muscle: "Quadriceps"),
                    ExerciseItem(name: "Bulgarian Split Squat", muscle: "Quadriceps"),
                    ExerciseItem(name: "Hip Thrust", muscle: "Glutes"),
                    ExerciseItem(name: "Calf Raise", muscle: "Calves"),
                    ExerciseItem(name: "Goblet Squat", muscle: "Quadriceps"),
                    ExerciseItem(name: "Step-ups", muscle: "Quadriceps")
                ]
            case .core:
                return [
                    ExerciseItem(name: "Plank", muscle: "Core"),
                    ExerciseItem(name: "Hanging Leg Raise", muscle: "Abs"),
                    ExerciseItem(name: "Cable Crunch", muscle: "Abs"),
                    ExerciseItem(name: "Russian Twist", muscle: "Obliques"),
                    ExerciseItem(name: "Ab Wheel Rollout", muscle: "Abs"),
                    ExerciseItem(name: "Bicycle Crunches", muscle: "Abs"),
                    ExerciseItem(name: "Leg Raises", muscle: "Lower Abs"),
                    ExerciseItem(name: "Mountain Climbers", muscle: "Core"),
                    ExerciseItem(name: "Dead Bug", muscle: "Core"),
                    ExerciseItem(name: "Pallof Press", muscle: "Core")
                ]
            }
        }
    }

    struct ExerciseItem: Identifiable {
        let id = UUID()
        let name: String
        let muscle: String
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar

                // Content
                if searchText.isEmpty {
                    bodyPartGrid
                } else {
                    searchResults
                }
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedBodyPart) { bodyPart in
                exerciseListSheet(for: bodyPart)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            TextField("Search exercises...", text: $searchText)
                .font(.vitalBody)
                .textFieldStyle(.plain)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
        .padding(.horizontal, Spacing.screenPadding)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Body Part Grid

    private var bodyPartGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.md),
                GridItem(.flexible(), spacing: Spacing.md)
            ], spacing: Spacing.md) {
                ForEach(BodyPart.allCases) { bodyPart in
                    bodyPartCard(bodyPart)
                }
            }
            .padding(Spacing.screenPadding)
        }
    }

    private func bodyPartCard(_ bodyPart: BodyPart) -> some View {
        Button {
            selectedBodyPart = bodyPart
        } label: {
            VStack(spacing: Spacing.md) {
                Image(systemName: bodyPart.icon)
                    .font(.system(size: Spacing.iconXLarge))
                    .foregroundStyle(Color.vitalPrimary)

                Text(bodyPart.rawValue)
                    .font(.vitalH4)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Text("\(bodyPart.exercises.count) exercises")
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusLarge)
            .vitalCardShadow()
        }
    }

    // MARK: - Exercise List Sheet

    private func exerciseListSheet(for bodyPart: BodyPart) -> some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sm) {
                    ForEach(bodyPart.exercises) { exercise in
                        exerciseRow(exercise, bodyPart: bodyPart)
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle(bodyPart.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        selectedBodyPart = nil
                    }
                }
            }
        }
    }

    private func exerciseRow(_ exercise: ExerciseItem, bodyPart: BodyPart) -> some View {
        Button {
            selectExercise(exercise)
            selectedBodyPart = nil
        } label: {
            HStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.vitalPrimary.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: bodyPart.icon)
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalPrimary)
                }

                // Text
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(exercise.name)
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text(exercise.muscle)
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                Spacer()

                // Add indicator
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .foregroundStyle(Color.vitalPrimary)
            }
            .padding(Spacing.md)
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusMedium)
        }
    }

    // MARK: - Search Results

    private var searchResults: some View {
        let allExercises = BodyPart.allCases.flatMap { bodyPart in
            bodyPart.exercises.map { (bodyPart: bodyPart, exercise: $0) }
        }

        let filtered = allExercises.filter {
            $0.exercise.name.localizedCaseInsensitiveContains(searchText) ||
            $0.exercise.muscle.localizedCaseInsensitiveContains(searchText)
        }

        return ScrollView {
            if filtered.isEmpty {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: Spacing.iconHuge))
                        .foregroundStyle(Color.vitalAdaptiveTextTertiary)

                    Text("No exercises found")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text("Try a different search term")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.xxxl)
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(filtered, id: \.exercise.id) { item in
                        exerciseRow(item.exercise, bodyPart: item.bodyPart)
                    }
                }
                .padding(Spacing.screenPadding)
            }
        }
    }

    // MARK: - Actions

    private func selectExercise(_ exercise: ExerciseItem) {
        let templateExercise = TemplateDayExercise(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            primaryMuscle: exercise.muscle,
            sets: 3,
            repRange: "8-12"
        )

        HapticFeedback.selection()
        onSelect(templateExercise)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    TemplateExercisePickerView { exercise in
        print("Selected: \(exercise.exerciseName)")
    }
}
