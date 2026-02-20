//
//  WaterTrackingCard.swift
//  VitalArc
//
//  Card view for tracking daily water intake with progress ring and quick-add buttons
//

import SwiftUI

struct WaterTrackingCard: View {
    @State private var waterEntries: [WaterEntry] = []
    @State private var customAmount = ""
    @State private var showingCustomInput = false
    @Environment(\.scenePhase) private var scenePhase

    private let logWaterUseCase: LogWaterUseCaseProtocol
    private let getWaterEntriesUseCase: GetWaterEntriesUseCaseProtocol
    private let deleteWaterEntryUseCase: DeleteWaterEntryUseCaseProtocol?
    private let date: Date
    private let dailyGoal: Double

    private static let maxEntryAmount: Double = 5000

    init(
        logWaterUseCase: LogWaterUseCaseProtocol,
        getWaterEntriesUseCase: GetWaterEntriesUseCaseProtocol,
        deleteWaterEntryUseCase: DeleteWaterEntryUseCaseProtocol? = nil,
        date: Date,
        dailyGoal: Double = 2500
    ) {
        self.logWaterUseCase = logWaterUseCase
        self.getWaterEntriesUseCase = getWaterEntriesUseCase
        self.deleteWaterEntryUseCase = deleteWaterEntryUseCase
        self.date = date
        self.dailyGoal = dailyGoal
    }

    private var totalIntake: Double {
        waterEntries.reduce(0) { $0 + $1.amount }
    }

    private var progress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(totalIntake / dailyGoal, 1.0)
    }

    var body: some View {
        VitalCard {
            VStack(spacing: Spacing.md) {
                // Header
                HStack {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(Color.vitalInfo)
                        Text("Water Intake")
                            .font(.vitalLabel)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    }
                    Spacer()
                    Text("\(Int(totalIntake))ml / \(Int(dailyGoal))ml")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                // Progress ring
                HStack(spacing: Spacing.lg) {
                    WaterProgressRing(progress: progress)
                        .frame(width: Spacing.illustrationSmall, height: Spacing.illustrationSmall)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("\(Int(totalIntake))")
                            .font(.vitalH1)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        + Text(" ml")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                        if totalIntake < dailyGoal {
                            Text("\(Int(dailyGoal - totalIntake))ml remaining")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        } else {
                            Text("Goal reached!")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalSuccess)
                        }
                    }

                    Spacer()
                }

                Divider()
                    .background(Color.vitalAdaptiveBorder)

                // Quick-add buttons
                HStack(spacing: Spacing.sm) {
                    QuickAddWaterButton(amount: 250, unit: "ml") {
                        Task { await addWater(amount: 250) }
                    }

                    QuickAddWaterButton(amount: 500, unit: "ml") {
                        Task { await addWater(amount: 500) }
                    }

                    Button {
                        showingCustomInput.toggle()
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "pencil")
                                .font(.vitalCaption)
                            Text("Custom")
                                .font(.vitalLabelSmall)
                        }
                        .foregroundStyle(Color.vitalPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.vitalPrimary.opacity(0.1))
                        .cornerRadius(Spacing.radiusSmall)
                    }
                    .buttonStyle(.plain)
                }

                // Custom amount input
                if showingCustomInput {
                    HStack(spacing: Spacing.sm) {
                        TextField("Amount (ml)", text: $customAmount)
                            .keyboardType(.numberPad)
                            .font(.vitalBody)
                            .padding(Spacing.sm)
                            .background(Color.vitalAdaptiveSurface)
                            .cornerRadius(Spacing.radiusSmall)
                            .overlay(
                                RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                                    .stroke(Color.vitalAdaptiveBorder, lineWidth: Spacing.borderThin)
                            )

                        Button {
                            if let amount = Double(customAmount), amount > 0 {
                                let capped = min(amount, Self.maxEntryAmount)
                                Task { await addWater(amount: capped) }
                                customAmount = ""
                                showingCustomInput = false
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.vitalH2)
                                .foregroundStyle(Color.vitalPrimary)
                        }
                        .buttonStyle(.plain)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Today's entries with swipe-to-delete
                if !waterEntries.isEmpty {
                    Divider()
                        .background(Color.vitalAdaptiveBorder)

                    ForEach(waterEntries) { entry in
                        HStack {
                            Image(systemName: "drop")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalInfo)
                            Text("\(Int(entry.amount))ml")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            Spacer()
                            Text(entry.date, format: .dateTime.hour().minute())
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                            if deleteWaterEntryUseCase != nil {
                                Button {
                                    Task { await deleteWaterEntry(id: entry.id) }
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.vitalCaption)
                                        .foregroundStyle(Color.vitalDanger)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, Spacing.xxs)
                    }
                }
            }
        }
        .animation(.vitalSpring, value: showingCustomInput)
        .animation(.vitalSpring, value: totalIntake)
        .task {
            await loadWaterEntries()
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Refresh water entries when app returns to foreground
            // to handle timezone-aware day boundary changes
            if newPhase == .active {
                Task { await loadWaterEntries() }
            }
        }
    }

    private func loadWaterEntries() async {
        do {
            // Use timezone-aware day boundary for consistent water tracking
            let normalizedDate = Calendar.current.startOfDay(for: date)
            waterEntries = try await getWaterEntriesUseCase.execute(for: normalizedDate)
        } catch {
            // Non-critical
        }
    }

    private func addWater(amount: Double) async {
        do {
            _ = try await logWaterUseCase.execute(amount: amount, date: date)
            HapticFeedback.light()
            await loadWaterEntries()
        } catch {
            // Non-critical
        }
    }

    private func deleteWaterEntry(id: UUID) async {
        guard let deleteUseCase = deleteWaterEntryUseCase else { return }
        do {
            try await deleteUseCase.execute(id: id)
            HapticFeedback.light()
            await loadWaterEntries()
        } catch {
            // Non-critical
        }
    }
}

// MARK: - Water Progress Ring

private struct WaterProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.vitalInfo.opacity(0.2), lineWidth: 8)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.vitalInfo,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Image(systemName: "drop.fill")
                .font(.vitalH2)
                .foregroundStyle(Color.vitalInfo)
        }
    }
}

// MARK: - Quick Add Button

private struct QuickAddWaterButton: View {
    let amount: Int
    let unit: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "plus")
                    .font(.vitalCaption)
                Text("\(amount)\(unit)")
                    .font(.vitalLabelSmall)
            }
            .foregroundStyle(Color.vitalInfo)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(Color.vitalInfo.opacity(0.1))
            .cornerRadius(Spacing.radiusSmall)
        }
        .buttonStyle(.plain)
    }
}
