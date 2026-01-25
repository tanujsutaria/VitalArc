//
//  MainTabView.swift
//  VitalArc
//
//  Created by Claude on 2026-01-25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Health Tab
            HealthDashboardView()
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }
                .tag(0)

            // Workout Tab
            WorkoutTabView()
                .tabItem {
                    Label("Workout", systemImage: "dumbbell.fill")
                }
                .tag(1)

            // Nutrition Tab
            NutritionTabView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }
                .tag(2)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.accentColor)
    }
}

// Placeholder views for tabs (will be implemented by respective streams)
struct HealthDashboardView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Health Dashboard")
                    .font(.largeTitle)
                Text("Stream 2: HealthKit Integration")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Health")
        }
    }
}

struct WorkoutTabView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Workout Tracker")
                    .font(.largeTitle)
                Text("Stream 3: Workout Module")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Workout")
        }
    }
}

struct NutritionTabView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Nutrition Tracker")
                    .font(.largeTitle)
                Text("Stream 4: Nutrition Module")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Nutrition")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Profile")
                    .font(.largeTitle)
                Text("Stream 5: User Profile & Settings")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainTabView()
}
