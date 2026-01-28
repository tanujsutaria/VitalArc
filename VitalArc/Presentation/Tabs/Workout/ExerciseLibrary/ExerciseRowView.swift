//
//  ExerciseRowView.swift
//  VitalArc
//
//  Row view for displaying an exercise
//

import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                categoryIcon
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(categoryColor)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(exercise.name)
                    .font(.vitalLabel)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    .lineLimit(1)

                HStack(spacing: Spacing.xs) {
                    // Equipment badge
                    HStack(spacing: 4) {
                        Image(systemName: equipmentIcon)
                            .font(.system(size: 10))
                        Text(exercise.equipment.rawValue)
                            .font(.vitalCaptionSmall)
                    }
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.vitalAdaptiveBorder.opacity(0.5))
                    .cornerRadius(4)

                    // Primary Muscles
                    if let firstMuscle = exercise.primaryMuscles.first {
                        Text(firstMuscle.rawValue)
                            .font(.vitalCaptionSmall)
                            .foregroundStyle(categoryColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(categoryColor.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
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

    // MARK: - Computed Properties

    private var categoryIcon: Image {
        Image(systemName: categoryIconName)
    }

    private var categoryIconName: String {
        switch exercise.category {
        case .push: return "arrow.up.circle.fill"
        case .pull: return "arrow.down.circle.fill"
        case .legs: return "figure.walk"
        case .core: return "circle.grid.cross.fill"
        case .cardio: return "heart.fill"
        case .olympic: return "figure.strengthtraining.traditional"
        case .strongman: return "figure.strengthtraining.functional"
        case .calisthenics: return "figure.gymnastics"
        case .plyometrics: return "figure.jumprope"
        case .mobility: return "figure.flexibility"
        case .custom: return "star.fill"
        }
    }

    private var categoryColor: Color {
        switch exercise.category {
        case .push: return .vitalDanger
        case .pull: return .vitalInfo
        case .legs: return .vitalSuccess
        case .core: return .vitalWarning
        case .cardio: return .vitalSecondary
        case .olympic: return .vitalAccent
        case .strongman: return .vitalPrimary
        case .calisthenics: return .vitalInfo
        case .plyometrics: return .vitalWarning
        case .mobility: return .vitalSuccess
        case .custom: return .vitalAdaptiveTextSecondary
        }
    }

    private var equipmentIcon: String {
        switch exercise.equipment {
        case .barbell: return "figure.strengthtraining.traditional"
        case .dumbbell: return "dumbbell.fill"
        case .machine: return "gearshape.fill"
        case .cable: return "cable.connector"
        case .bodyweight: return "figure.arms.open"
        case .resistance: return "bandage"
        case .kettlebell: return "figure.strengthtraining.functional"
        case .ezBar: return "figure.strengthtraining.traditional"
        case .trapBar: return "figure.strengthtraining.traditional"
        case .medicineBall: return "circle.fill"
        case .suspensionTrainer: return "figure.climbing"
        case .sled: return "figure.cooldown"
        case .tireFlip: return "car.circle"
        case .yoke: return "figure.walk"
        case .logPress: return "tree.fill"
        case .smithMachine: return "gearshape.2.fill"
        case .safetyBar: return "figure.strengthtraining.traditional"
        }
    }
}

#Preview {
    List {
        ExerciseRowView(exercise: Exercise(
            name: "Barbell Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .barbell
        ))
    }
}
