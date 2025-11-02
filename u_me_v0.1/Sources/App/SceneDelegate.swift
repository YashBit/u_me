//
//  SceneDelegate.swift
//  U&Me
//

import UIKit
import SwiftUI
import LineSDK
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // CRITICAL: This handles URL callbacks from LINE and Google
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
        
        // Try LINE SDK first
        if LoginManager.shared.application(.shared, open: url) {
            print("   ✅ Handled by LINE SDK")
            return
        }
        
        // Try Google Sign In
        if GIDSignIn.sharedInstance.handle(url) {
            print("   ✅ Handled by Google Sign In")
            return
        }
        
        print("   ⚠️ URL was not handled by any SDK")
    }
    
    // Handle URLs passed during app launch
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let urlContext = connectionOptions.urlContexts.first {
            print("🔗 SceneDelegate: URL received during launch")
            print("   URL: \(urlContext.url.absoluteString)")
            
            // Try LINE
            if LoginManager.shared.application(.shared, open: urlContext.url) {
                print("   ✅ Handled by LINE SDK")
                return
            }
            
            // Try Google
            if GIDSignIn.sharedInstance.handle(urlContext.url) {
                print("   ✅ Handled by Google Sign In")
                return
            }
        }
    }
}
