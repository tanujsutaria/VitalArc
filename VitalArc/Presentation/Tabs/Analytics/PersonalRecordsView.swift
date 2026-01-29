//
//  PersonalRecordsView.swift
//  VitalArc
//
//  View for displaying personal records
//

import SwiftUI

struct PersonalRecordsView: View {
    let records: [PersonalRecord]
    @State private var selectedRecordType: RecordType?
    @State private var searchText = ""

    var filteredRecords: [PersonalRecord] {
        var filtered = records

        if let selectedType = selectedRecordType {
            filtered = filtered.filter { $0.recordType == selectedType }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.exerciseName.localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered.sorted { $0.date > $1.date }
    }

    var groupedRecords: [String: [PersonalRecord]] {
        Dictionary(grouping: filteredRecords) { $0.exerciseName }
    }

    var body: some View {
        VStack(spacing: 0) {
            if !records.isEmpty {
                // Record type filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedRecordType == nil
                        ) {
                            selectedRecordType = nil
                        }

                        ForEach(RecordType.allCases, id: \.self) { type in
                            FilterChip(
                                title: type.displayName,
                                isSelected: selectedRecordType == type
                            ) {
                                selectedRecordType = type
                            }
                        }
                    }
                    .padding(Spacing.lg)
                }

                // Records list
                List {
                    ForEach(groupedRecords.keys.sorted(), id: \.self) { exerciseName in
                        Section(exerciseName) {
                            ForEach(groupedRecords[exerciseName] ?? []) { record in
                                PersonalRecordRow(record: record)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search exercises")
                .listStyle(.insetGrouped)
            } else {
                ContentUnavailableView(
                    "No Personal Records",
                    systemImage: "trophy",
                    description: Text("Set new PRs as you train")
                )
            }
        }
    }
}

struct PersonalRecordRow: View {
    let record: PersonalRecord

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            Image(systemName: record.recordType.icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 40)

            // Details
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(record.recordType.displayName)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    if record.isRecent {
                        Text("NEW")
                            .font(.vitalCaptionSmall)
                            .fontWeight(.bold)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xxs)
                            .background(Color.vitalDanger)
                            .foregroundStyle(.white)
                            .cornerRadius(Spacing.xs)
                    }
                }

                Text(record.displayValue)
                    .font(.vitalH3)

                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }

            Spacer()

            // Days since
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                Text("\(record.daysSince)")
                    .font(.vitalH2)
                Text("days ago")
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    private var iconColor: Color {
        switch record.recordType {
        case .oneRepMax:
            return Color.vitalWarning
        case .threeRepMax:
            return Color.vitalWarning.opacity(0.8)
        case .fiveRepMax:
            return Color.vitalDanger
        case .tenRepMax:
            return Color.vitalAccent
        case .maxVolume:
            return Color.vitalInfo
        case .maxReps:
            return Color.vitalSuccess
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.vitalCaption)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.vitalPrimary : Color.vitalAdaptiveSurface)
                .foregroundStyle(isSelected ? .white : Color.vitalAdaptiveTextPrimary)
                .cornerRadius(Spacing.radiusSmall)
        }
    }
}

#Preview("Empty State") {
    NavigationStack {
        PersonalRecordsView(records: [])
            .navigationTitle("Personal Records")
    }
}
