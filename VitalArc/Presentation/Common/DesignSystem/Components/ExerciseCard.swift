//
//  ExerciseCard.swift
//  VitalArc
//
//  Modern exercise card component
//

import SwiftUI

struct ExerciseCard: View {
    let exerciseName: String
    let muscleGroup: String
    let equipment: String?
    let sets: Int?
    let reps: String?
    let weight: String?
    let onTap: (() -> Void)?
    let onDelete: (() -> Void)?

    init(
        exerciseName: String,
        muscleGroup: String,
        equipment: String? = nil,
        sets: Int? = nil,
        reps: String? = nil,
        weight: String? = nil,
        onTap: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.exerciseName = exerciseName
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.onTap = onTap
        self.onDelete = onDelete
    }

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            onTap?()
        }) {
            VitalCard(padding: Spacing.md) {
                HStack(spacing: Spacing.md) {
                    // Muscle group icon
                    ZStack {
                        Circle()
                            .fill(muscleGroupColor.opacity(0.15))
                            .frame(width: 48, height: 48)

                        Image(systemName: muscleGroupIcon)
                            .font(.system(size: Spacing.iconMedium, weight: .semibold))
                            .foregroundStyle(muscleGroupColor)
                    }

                    // Exercise info
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(exerciseName)
                            .font(.vitalLabel)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            .lineLimit(1)

                        HStack(spacing: Spacing.xs) {
                            Text(muscleGroup)
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(muscleGroupColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(muscleGroupColor.opacity(0.15))
                                .cornerRadius(4)

                            if let equipment = equipment {
                                Text(equipment)
                                    .font(.vitalCaptionSmall)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.vitalAdaptiveBorder.opacity(0.5))
                                    .cornerRadius(4)
                            }
                        }

                        // Workout stats (if provided)
                        if let sets = sets, let reps = reps {
                            HStack(spacing: Spacing.sm) {
                                Label("\(sets) sets", systemImage: "square.stack.3d.up")
                                    .font(.vitalBodySmall)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                                Label(reps, systemImage: "repeat")
                                    .font(.vitalBodySmall)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                                if let weight = weight {
                                    Label(weight, systemImage: "scalemass")
                                        .font(.vitalBodySmall)
                                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                }
                            }
                        }
                    }

                    Spacer()

                    // Chevron or delete button
                    if let onDelete = onDelete {
                        Button(action: {
                            HapticFeedback.medium()
                            onDelete()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: Spacing.iconSmall, weight: .medium))
                                .foregroundStyle(Color.vitalDanger)
                                .frame(width: 32, height: 32)
                        }
                        .vitalScaleButton()
                    } else if onTap != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: Spacing.iconSmall, weight: .semibold))
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var muscleGroupColor: Color {
        switch muscleGroup.lowercased() {
        case let mg where mg.contains("chest"):
            return .vitalDanger
        case let mg where mg.contains("back"):
            return .vitalInfo
        case let mg where mg.contains("shoulder"):
            return .vitalWarning
        case let mg where mg.contains("leg"):
            return .vitalSuccess
        case let mg where mg.contains("arm"), let mg where mg.contains("bicep"), let mg where mg.contains("tricep"):
            return .vitalSecondary
        case let mg where mg.contains("core"), let mg where mg.contains("abs"):
            return .vitalAccent
        default:
            return .vitalPrimary
        }
    }

    private var muscleGroupIcon: String {
        switch muscleGroup.lowercased() {
        case let mg where mg.contains("chest"):
            return "heart.fill"
        case let mg where mg.contains("back"):
            return "figure.walk"
        case let mg where mg.contains("shoulder"):
            return "arrow.up.circle.fill"
        case let mg where mg.contains("leg"):
            return "figure.run"
        case let mg where mg.contains("arm"), let mg where mg.contains("bicep"), let mg where mg.contains("tricep"):
            return "dumbbell.fill"
        case let mg where mg.contains("core"), let mg where mg.contains("abs"):
            return "figure.core.training"
        default:
            return "figure.strengthtraining.traditional"
        }
    }
}

// MARK: - Compact Exercise Row

struct ExerciseRowCompact: View {
    let exerciseName: String
    let muscleGroup: String
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            onTap()
        }) {
            HStack(spacing: Spacing.md) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: Spacing.iconLarge))
                    .foregroundStyle(Color.vitalPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(exerciseName)
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text(muscleGroup)
                        .font(.vitalBodySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
            .padding(Spacing.md)
            .background(Color.vitalAdaptiveSurface)
            .cornerRadius(Spacing.radiusMedium)
            .vitalCardShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.md) {
            ExerciseCard(
                exerciseName: "Barbell Bench Press",
                muscleGroup: "Chest",
                equipment: "Barbell",
                sets: 4,
                reps: "8-10",
                weight: "80 kg",
                onTap: {}
            )

            ExerciseCard(
                exerciseName: "Deadlift",
                muscleGroup: "Back",
                equipment: "Barbell",
                sets: 3,
                reps: "5",
                weight: "120 kg",
                onDelete: {}
            )

            ExerciseCard(
                exerciseName: "Squat",
                muscleGroup: "Legs",
                equipment: "Barbell",
                onTap: {}
            )

            ExerciseRowCompact(
                exerciseName: "Overhead Press",
                muscleGroup: "Shoulders",
                onTap: {}
            )
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
