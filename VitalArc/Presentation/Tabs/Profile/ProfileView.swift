//
//  ProfileView.swift
//  VitalArc
//
//  User profile view displaying profile information and settings
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var viewModel: ProfileViewModel?
    @State private var showSettings = false
    @State private var showAbout = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    if viewModel.isEditMode {
                        editProfileView(viewModel: viewModel)
                    } else {
                        profileContentView(viewModel: viewModel)
                    }
                } else {
                    ProgressView("Loading profile...")
                        .onAppear {
                            setupViewModel()
                        }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                if let viewModel = viewModel, !viewModel.isEditMode {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { viewModel.startEditing() }) {
                            Text("Edit")
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                if let container = container {
                    SettingsView(userRepository: container.userRepository)
                }
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }

    @ViewBuilder
    private func profileContentView(viewModel: ProfileViewModel) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                if let profile = viewModel.profile {
                    // Profile Header
                    VStack(spacing: 12) {
                        // Avatar
                        Circle()
                            .fill(LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 100, height: 100)
                            .overlay {
                                Text(profile.name.prefix(1).uppercased())
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            }

                        Text(profile.name)
                            .font(.title)
                            .fontWeight(.bold)

                        Text("\(profile.age) years old")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)

                    // Stats Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Health Stats")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(
                                title: "Height",
                                value: String(format: "%.0f cm", profile.height),
                                icon: "ruler",
                                color: .blue
                            )

                            StatCard(
                                title: "Weight",
                                value: String(format: "%.1f kg", profile.weight),
                                icon: "scalemass",
                                color: .green
                            )

                            StatCard(
                                title: "BMI",
                                value: String(format: "%.1f", profile.bmi),
                                icon: "chart.bar",
                                color: .orange
                            )

                            StatCard(
                                title: "Calorie Goal",
                                value: String(format: "%.0f", profile.estimatedCalorieGoal),
                                icon: "flame",
                                color: .red
                            )
                        }
                        .padding(.horizontal)
                    }

                    // Goals Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Goals")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            InfoRow(label: "Activity Level", value: profile.activityLevel.rawValue)
                            Divider()
                            InfoRow(label: "Weight Goal", value: profile.weightGoal.rawValue)
                            Divider()
                            InfoRow(label: "Biological Sex", value: profile.biologicalSex.rawValue)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Settings Section
                    VStack(spacing: 12) {
                        Button(action: { showSettings = true }) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Settings")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.primary)

                        Button(action: { showAbout = true }) {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("About")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                } else {
                    ContentUnavailableView(
                        "No Profile Found",
                        systemImage: "person.crop.circle.badge.exclamationmark",
                        description: Text("Please complete onboarding to create your profile.")
                    )
                }
            }
            .padding(.bottom)
        }
        .refreshable {
            await viewModel.loadProfile()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    @ViewBuilder
    private func editProfileView(viewModel: ProfileViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Edit Profile")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.headline)
                        TextField("Name", text: $viewModel.editName)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Birth Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birth Date")
                            .font(.headline)
                        DatePicker(
                            "Birth Date",
                            selection: $viewModel.editBirthDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }

                    // Biological Sex
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Biological Sex")
                            .font(.headline)
                        Picker("Sex", selection: $viewModel.editSex) {
                            ForEach(BiologicalSex.allCases, id: \.self) { sex in
                                Text(sex.rawValue).tag(sex)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Height
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height")
                            .font(.headline)
                        HStack {
                            TextField("Height", value: $viewModel.editHeight, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            Text("cm")
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Weight
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight")
                            .font(.headline)
                        HStack {
                            TextField("Weight", value: $viewModel.editWeight, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Activity Level
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity Level")
                            .font(.headline)
                        Picker("Activity Level", selection: $viewModel.editActivityLevel) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    // Weight Goal
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight Goal")
                            .font(.headline)
                        Picker("Weight Goal", selection: $viewModel.editWeightGoal) {
                            ForEach(WeightGoal.allCases, id: \.self) { goal in
                                Text(goal.rawValue).tag(goal)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal)

                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: { viewModel.cancelEditing() }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }

                    Button(action: {
                        Task {
                            await viewModel.saveProfile()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Save")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canSave ? Color.accentColor : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.canSave || viewModel.isLoading)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding(.vertical)
        }
    }

    private func setupViewModel() {
        guard let container = container else { return }
        let vm = ProfileViewModel(userRepository: container.userRepository)
        viewModel = vm
        Task {
            await vm.loadProfile()
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ProfileView()
}
