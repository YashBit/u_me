//
//  AppDelegate.swift
//  U&Me
//

import UIKit
import LineSDK
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // ========================================
        // LINE SDK Setup
        // ========================================
        LoginManager.shared.setup(
            channelID: "2008370224",
            universalLinkURL: nil  // nil = use web login
        )
        
        print("✅ LINE SDK initialized (In-App Web Login Mode)")
        print("   Channel ID: 2008370224")
        print("   Login Method: SFSafariViewController (in-app browser)")
        print("   Team ID: DB64J3Z396")
        print("   Bundle ID: yash-bharti.u-me-v0-1")
        
        // ========================================
        // Google Sign In Setup
        // ========================================
        if let clientID = getGoogleClientID() {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            print("✅ Google Sign In initialized")
            print("   Client ID: \(String(clientID.prefix(30)))...")
        } else {
            print("⚠️ Warning: Google Client ID not found in GoogleService-Info.plist")
        }
        
        return true
    }
    
    // Handle URL Scheme callbacks (LINE and Google)
    func application(_ app: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("📱 URL Scheme callback received")
        print("   URL: \(url.absoluteString)")
        print("   Scheme: \(url.scheme ?? "none")")
        
        // Try LINE SDK first
        if LoginManager.shared.application(app, open: url) {
            print("   ✅ Handled by LINE SDK")
            return true
        }
        
        // Try Google Sign In
        if GIDSignIn.sharedInstance.handle(url) {
            print("   ✅ Handled by Google Sign In")
            return true
        }
        
        print("   ⚠️ URL not handled by any SDK")
        return false
    }
    
    // MARK: - Helper Methods
    
    private func getGoogleClientID() -> String? {
        // Try to get from GoogleService-Info.plist
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let clientID = dict["CLIENT_ID"] as? String {
            return clientID
        }
        return nil
    }
}
