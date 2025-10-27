//
//  AppDelegate.swift
//  U&Me
//
//  Handles LINE SDK initialization and callbacks
//

import UIKit
import LineSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // Initialize LINE SDK with Channel ID
        // Try this format instead
        do {
            try LoginManager.shared.setup(channelID: "2008370224", universalLinkURL: nil)
            print("✅ LINE SDK initialized")
        } catch {
            print("❌ LINE SDK setup failed: \(error)")
        }
        
        return true
    }
    
    /// Handle URL callback from LINE app
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        print("📱 Received URL callback: \(url)")
        return LoginManager.shared.application(app, open: url)
    }
}
