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
                    HStack(spacing: 8) {
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
                    .padding()
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
        HStack(spacing: 12) {
            // Icon
            Image(systemName: record.recordType.icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 40)

            // Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(record.recordType.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if record.isRecent {
                        Text("NEW")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundStyle(.white)
                            .cornerRadius(4)
                    }
                }

                Text(record.displayValue)
                    .font(.headline)

                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Days since
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(record.daysSince)")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("days ago")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var iconColor: Color {
        switch record.recordType {
        case .oneRepMax:
            return .yellow
        case .threeRepMax:
            return .orange
        case .fiveRepMax:
            return .red
        case .tenRepMax:
            return .purple
        case .maxVolume:
            return .blue
        case .maxReps:
            return .green
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
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}
