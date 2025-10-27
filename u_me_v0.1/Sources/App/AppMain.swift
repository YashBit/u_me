//
//  AppMain.swift
//  U&Me
//
//  Application entry point
//

import SwiftUI

@main
struct UMeApp: App {
    
    // Register AppDelegate for LINE callback handling
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // App state for authentication
    @StateObject private var authViewModel = AuthViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
