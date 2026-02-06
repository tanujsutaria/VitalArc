//
//  MainTabView.swift
//  VitalArc
//
//  Main tab navigation for the VitalArc app (5-tab structure)
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Today Tab (Daily Dashboard)
            TodayDashboardView()
                .tabItem {
                    Label("Today", systemImage: "calendar.circle.fill")
                }
                .tag(0)

            // Workout Tab
            WorkoutTabContentView()
                .tabItem {
                    Label("Workout", systemImage: "dumbbell.fill")
                }
                .tag(1)

            // Nutrition Tab
            NutritionTabContentView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }
                .tag(2)

            // Progress Tab (Analytics)
            ProgressTabView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(Color.vitalPrimaryV2)
    }
}

#Preview {
    MainTabView()
}
