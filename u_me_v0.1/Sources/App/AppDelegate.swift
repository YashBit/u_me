//
//  AppDelegate.swift
//  U&Me
//

import UIKit
import LineSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // Web-based login (works without paid Apple Developer account)
        // Using in-app browser (SFSafariViewController) for better UX
        LoginManager.shared.setup(
            channelID: "2008370224",
            universalLinkURL: nil  // nil = use web login
        )
        
        print("✅ LINE SDK initialized (In-App Web Login Mode)")
        print("   Channel ID: 2008370224")
        print("   Login Method: SFSafariViewController (in-app browser)")
        print("   Team ID: DB64J3Z396")
        print("   Bundle ID: yash-bharti.u-me-v0-1")
        
        return true
    }
    
    // Handle URL Scheme callbacks (web login returns via this)
    func application(_ app: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("📱 URL Scheme callback received (Web Login Return)")
        print("   URL: \(url.absoluteString)")
        print("   Scheme: \(url.scheme ?? "none")")
        
        let handled = LoginManager.shared.application(app, open: url)
        print("   ✅ Handled by LINE SDK: \(handled)")
        
        return handled
    }
}
