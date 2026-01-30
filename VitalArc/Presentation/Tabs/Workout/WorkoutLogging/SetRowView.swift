//
//  SetRowView.swift
//  VitalArc
//
//  Row view for logging a single set
//

import SwiftUI

struct SetRowView: View {
    @Binding var setData: WorkoutSetData
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Set Number
            Text("\(setData.setNumber)")
                .font(.vitalH4)
                .foregroundStyle(.secondary)
                .frame(width: 30)

            // Weight Input
            VStack(alignment: .leading, spacing: 2) {
                Text("Weight")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                TextField("kg", value: $setData.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
            }

            // Reps Input
            VStack(alignment: .leading, spacing: 2) {
                Text("Reps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                TextField("reps", value: $setData.reps, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
            }

            // RIR Input (Optional)
            VStack(alignment: .leading, spacing: 2) {
                Text("RIR")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                TextField("0", value: $setData.rir, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 50)
            }

            Spacer()

            // Completed Checkbox
            Button {
                setData.completed.toggle()
            } label: {
                Image(systemName: setData.completed ? "checkmark.circle.fill" : "circle")
                    .font(.vitalH2)
                    .foregroundStyle(setData.completed ? Color.vitalSuccess : .secondary)
            }
            .buttonStyle(.plain)

            // Delete Button
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalDanger)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    @Previewable @State var setData = WorkoutSetData(
        exerciseId: UUID(),
        weight: 100,
        reps: 10,
        rir: 2,
        setNumber: 1,
        completed: false
    )

    SetRowView(setData: $setData) {
        print("Delete")
    }
    .padding()
}
