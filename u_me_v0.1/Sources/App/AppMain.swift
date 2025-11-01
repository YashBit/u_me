import SwiftUI

@main
struct UMeApp: App {
    // THIS LINE IS CRITICAL - Make sure it exists
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var authViewModel = AuthViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
