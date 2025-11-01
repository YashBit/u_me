//
//  SceneDelegate.swift
//  U&Me
//

import UIKit
import SwiftUI
import LineSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // CRITICAL: This handles URL callbacks from LINE
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("🔗 SceneDelegate: URL callback received")
        
        guard let url = URLContexts.first?.url else {
            print("   ❌ No URL found in contexts")
            return
        }
        
        print("   📱 URL: \(url.absoluteString)")
        print("   📱 Scheme: \(url.scheme ?? "none")")
        print("   📱 Host: \(url.host ?? "none")")
        print("   📱 Path: \(url.path)")
        
        // Let LINE SDK handle the callback
        let handled = LoginManager.shared.application(.shared, open: url)
        print("   ✅ Handled by LINE SDK: \(handled)")
        
        if !handled {
            print("   ⚠️ URL was not handled by LINE SDK")
        }
    }
    
    // Additional scene lifecycle methods (optional but good practice)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Handle any URLs that were passed during app launch
        if let urlContext = connectionOptions.urlContexts.first {
            print("🔗 SceneDelegate: URL received during launch")
            _ = LoginManager.shared.application(.shared, open: urlContext.url)
        }
    }
}
