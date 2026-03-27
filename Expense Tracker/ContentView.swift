//
//  ContentView.swift
//  Expense Tracker
//
//  Created by Mister Sky on 23.03.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ExpenseViewModel()
    @AppStorage("colorScheme") private var colorSchemeRaw: String = "system"

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            HistoryView()
                .tabItem { Label("History", systemImage: "clock.fill") }

            StatisticsView()
                .tabItem { Label("Statistics", systemImage: "chart.pie.fill") }

            BudgetView()
                .tabItem { Label("Budget", systemImage: "banknote.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .environmentObject(vm)
        .preferredColorScheme(preferredColorScheme)
    }

    private var preferredColorScheme: ColorScheme? {
        switch colorSchemeRaw {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

#Preview {
    ContentView()
}
