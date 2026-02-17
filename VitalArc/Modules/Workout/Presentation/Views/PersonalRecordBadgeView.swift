//
//  PersonalRecordBadgeView.swift
//  VitalArc
//
//  Badge view shown when a new personal record is set
//

import SwiftUI

struct PersonalRecordBadgeView: View {
    let records: [PersonalRecord]
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Trophy icon
            Image(systemName: "trophy.fill")
                .font(.system(size: Spacing.iconHuge))
                .foregroundStyle(Color.vitalWarning)

            Text("New Personal Record\(records.count > 1 ? "s" : "")!")
                .font(.vitalH1)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            VStack(spacing: Spacing.md) {
                ForEach(records) { record in
                    HStack(spacing: Spacing.md) {
                        Image(systemName: record.recordType.icon)
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalWarning)
                            .frame(width: Spacing.iconXLarge)

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text(record.exerciseName)
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                            Text("\(record.recordType.displayName): \(record.displayValue)")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }

                        Spacer()
                    }
                    .padding(Spacing.md)
                    .background(Color.vitalWarning.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                }
            }

            Button {
                onDismiss()
            } label: {
                Text("Continue")
                    .font(.vitalLabel)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Color.vitalPrimary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.xl)
        .background(Color.vitalAdaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
        .padding(Spacing.screenPadding)
    }
}

#Preview {
    PersonalRecordBadgeView(
        records: [
            PersonalRecord(
                exerciseId: UUID(),
                exerciseName: "Bench Press",
                recordType: .oneRepMax,
                value: 120,
                reps: 5,
                date: Date()
            ),
            PersonalRecord(
                exerciseId: UUID(),
                exerciseName: "Bench Press",
                recordType: .maxVolume,
                value: 3600,
                date: Date()
            )
        ],
        onDismiss: {}
    )
    .background(Color.vitalAdaptiveBackground)
}
