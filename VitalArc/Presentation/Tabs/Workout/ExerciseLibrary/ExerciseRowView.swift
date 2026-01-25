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
        HStack(spacing: 12) {
            // Category Icon
            categoryIcon
                .frame(width: 44, height: 44)
                .background(categoryColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    // Equipment
                    Label(exercise.equipment.rawValue, systemImage: equipmentIcon)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // Primary Muscles
                    if let firstMuscle = exercise.primaryMuscles.first {
                        Text(firstMuscle.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Computed Properties

    private var categoryIcon: some View {
        Image(systemName: categoryIconName)
            .font(.title3)
            .foregroundStyle(categoryColor)
    }

    private var categoryIconName: String {
        switch exercise.category {
        case .push: return "arrow.up.circle.fill"
        case .pull: return "arrow.down.circle.fill"
        case .legs: return "figure.walk"
        case .core: return "circle.grid.cross.fill"
        case .cardio: return "heart.fill"
        }
    }

    private var categoryColor: Color {
        switch exercise.category {
        case .push: return .red
        case .pull: return .blue
        case .legs: return .green
        case .core: return .orange
        case .cardio: return .purple
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
