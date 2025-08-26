//
//  LeftoversApp.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-18.
//

// LeftoversApp.swift
import SwiftUI

@main
struct LeftoversApp: App {
    // This is needed to get scene notifications
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ItemListView()
                .onAppear { NotificationScheduler.requestAuthorizationIfNeeded() }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // You can also trigger a reload here if needed, but the NotificationCenter approach is cleaner
                print("App became active.")
                // The NotificationCenter observer in the ViewModel will handle this
            }
        }
    }
}
