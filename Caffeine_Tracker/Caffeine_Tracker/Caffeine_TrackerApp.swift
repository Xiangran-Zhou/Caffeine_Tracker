//
//  Caffeine_TrackerApp.swift
//  Caffeine_Tracker
//
//  Created by kevin zhou on 2/24/26.
//

import SwiftUI

@main
struct Caffeine_TrackerApp: App {
    var body: some Scene {
        MenuBarExtra("Caffeine Tracker", systemImage: "cup.and.saucer.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
