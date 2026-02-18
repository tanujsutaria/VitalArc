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
    var onComplete: (() -> Void)? = nil

    @State private var showNotes = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.md) {
                // Set Number
                Text("\(setData.setNumber)")
                    .font(.vitalH4)
                    .foregroundStyle(.secondary)
                    .frame(width: Spacing.xl)

                // Weight Input
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Weight")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(.secondary)

                    TextField("kg", value: $setData.weight, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: Spacing.illustrationSmall)
                }

                // Reps Input
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Reps")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(.secondary)

                    TextField("reps", value: $setData.reps, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: Spacing.iconGiant)
                }

                // RIR Input (Optional)
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("RIR")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(.secondary)

                    TextField("0", value: $setData.rir, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 50)
                }

                Spacer()

                // Notes Toggle
                Button {
                    showNotes.toggle()
                } label: {
                    Image(systemName: setData.notes?.isEmpty == false ? "note.text" : "note.text.badge.plus")
                        .font(.vitalBody)
                        .foregroundStyle(setData.notes?.isEmpty == false ? Color.vitalPrimary : .secondary)
                }
                .buttonStyle(.plain)

                // Completed Checkbox
                Button {
                    let wasCompleted = setData.completed
                    setData.completed.toggle()
                    if !wasCompleted && setData.completed {
                        onComplete?()
                    }
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

            // Notes Field (shown when toggled or has content)
            if showNotes || setData.notes?.isEmpty == false {
                TextField("Set notes...", text: Binding(
                    get: { setData.notes ?? "" },
                    set: { setData.notes = $0.isEmpty ? nil : $0 }
                ))
                .font(.vitalCaption)
                .textFieldStyle(.roundedBorder)
                .padding(.leading, Spacing.xl + Spacing.md)
            }
        }
        .padding(.vertical, Spacing.sm)
        .onAppear {
            if setData.notes?.isEmpty == false {
                showNotes = true
            }
        }
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
