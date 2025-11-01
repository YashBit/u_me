//
//  LINEAuthService.swift
//  U&Me
//

import Foundation
import LineSDK
import UIKit

enum LINEAuthError: Error {
    case userCancelled
    case noActiveWindow
    case profileRetrievalFailed
    case accessTokenMissing
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .userCancelled:
            return "User cancelled LINE login"
        case .noActiveWindow:
            return "No active window found"
        case .profileRetrievalFailed:
            return "Failed to retrieve LINE profile"
        case .accessTokenMissing:
            return "Failed to get access token from LINE"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

@MainActor
final class LINEAuthService {
    
    static let shared = LINEAuthService()
    
    private init() {}
    
    // Method that AuthViewModel expects
    func signIn() async throws -> AuthCredentials {
        print("🟢 LINEAuthService.signIn() called")
        let (profile, accessToken) = try await loginWithToken()
        
        print("✅ Creating AuthCredentials with LINE profile")
        return AuthCredentials.line(
            userId: profile.userID,
            displayName: profile.displayName,
            pictureURL: profile.pictureURL,
            accessToken: accessToken
        )
    }
    
    // Combined method to get both profile and token atomically
    private func loginWithToken() async throws -> (LINEUserProfile, String) {
        print("🟢 Starting LINE login process (In-App Browser)...")
        
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                // Find the root view controller
                guard let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first,
                      let window = windowScene.windows.first,
                      let rootViewController = window.rootViewController else {
                    print("❌ Could not find root view controller")
                    continuation.resume(throwing: LINEAuthError.noActiveWindow)
                    return
                }
                
                print("📱 Found root view controller: \(type(of: rootViewController))")
                print("📱 LINE SDK - Is Authorized: \(LoginManager.shared.isAuthorized)")
                
                // Check if LINE app is installed (for informational purposes)
                let hasLINEApp = UIApplication.shared.canOpenURL(URL(string: "line://")!)
                if hasLINEApp {
                    print("ℹ️ LINE app is installed (but using web login for free account)")
                } else {
                    print("ℹ️ LINE app not detected, will use web login")
                }
                
                print("📱 Starting LINE LoginManager.login() with in-app browser")
                print("📱 Callback will be handled by AppDelegate or SceneDelegate")
                
                // Add a timeout mechanism to detect callback issues
                var hasResumed = false
                let timeoutTask = Task {
                    try? await Task.sleep(nanoseconds: 60_000_000_000) // 60 seconds
                    if !hasResumed {
                        print("⏰ ========================================")
                        print("⏰ LOGIN TIMEOUT - No callback received after 60 seconds")
                        print("⏰ ========================================")
                        print("⏰ This means the URL scheme callback is NOT working!")
                        print("⏰ Possible causes:")
                        print("⏰   1. Info.plist URL Scheme incorrect or missing")
                        print("⏰   2. SceneDelegate not receiving URL callbacks")
                        print("⏰   3. AppDelegate not receiving URL callbacks")
                        print("⏰   4. Bundle ID mismatch")
                        print("⏰ ========================================")
                    }
                }
                
                // LINE SDK's login with web-only option
                LoginManager.shared.login(
                    permissions: [.profile],
                    in: rootViewController,
                    options: [.onlyWebLogin]  // Force web login, but in-app
                ) { result in
                    hasResumed = true
                    timeoutTask.cancel()
                    
                    print("📢 ========================================")
                    print("📢 LINE login callback received in LINEAuthService")
                    print("📢 ========================================")
                    print("   Callback thread: \(Thread.isMainThread ? "Main" : "Background")")
                    print("   Time: \(Date())")
                    
                    switch result {
                    case .success(let loginResult):
                        print("✅ ========================================")
                        print("✅ LINE Login Success (Web Flow)!")
                        print("✅ ========================================")
                        
                        // Extract access token immediately from login result
                        let accessToken = loginResult.accessToken.value
                        print("   Access Token Present: \(!accessToken.isEmpty)")
                        print("   Access Token Length: \(accessToken.count) characters")
                        print("   Access Token (first 10 chars): \(String(accessToken.prefix(10)))...")
                        print("   User Profile Present: \(loginResult.userProfile != nil)")
                        
                        if let profile = loginResult.userProfile {
                            print("   ✅ Profile data available in login result:")
                            print("      User ID: \(profile.userID)")
                            print("      Display Name: \(profile.displayName)")
                            print("      Picture URL: \(profile.pictureURL?.absoluteString ?? "none")")
                            
                            let userProfile = LINEUserProfile(
                                userID: profile.userID,
                                displayName: profile.displayName,
                                pictureURL: profile.pictureURL
                            )
                            
                            print("✅ Returning profile and token to AuthViewModel")
                            continuation.resume(returning: (userProfile, accessToken))
                        } else {
                            print("⚠️ No profile in login result, fetching via API...")
                            self.getProfile(with: accessToken) { profileResult in
                                switch profileResult {
                                case .success(let profile):
                                    print("✅ Profile fetched via API successfully")
                                    print("   User ID: \(profile.userID)")
                                    print("   Display Name: \(profile.displayName)")
                                    continuation.resume(returning: (profile, accessToken))
                                case .failure(let error):
                                    print("❌ Failed to fetch profile via API: \(error)")
                                    continuation.resume(throwing: LINEAuthError.profileRetrievalFailed)
                                }
                            }
                        }
                        
                    case .failure(let error):
                        print("❌ ========================================")
                        print("❌ LINE Login Failed!")
                        print("❌ ========================================")
                        print("   Error: \(error)")
                        print("   Error Domain: \((error as NSError).domain)")
                        print("   Error Code: \((error as NSError).code)")
                        print("   Error Description: \(error.localizedDescription)")
                        print("   Error UserInfo: \((error as NSError).userInfo)")
                        
                        let nsError = error as NSError
                        
                        // Check for various error conditions
                        if nsError.code == 3 ||
                           nsError.code == 3003 ||  // User cancelled
                           nsError.domain.contains("Cancel") ||
                           error.localizedDescription.lowercased().contains("cancel") {
                            print("ℹ️ User cancelled LINE login (tapped Cancel/Done)")
                            continuation.resume(throwing: LINEAuthError.userCancelled)
                        } else if nsError.code == 3002 {  // Configuration error
                            print("❌ LINE SDK Configuration Error")
                            print("   Check that your Channel ID matches LINE Developers Console")
                            print("   Current Channel ID: 2008370224")
                            continuation.resume(throwing: LINEAuthError.unknown(error))
                        } else if nsError.code == 3001 {  // Network error
                            print("❌ LINE SDK Network Error")
                            print("   Check internet connection")
                            continuation.resume(throwing: LINEAuthError.unknown(error))
                        } else {
                            print("❌ Unknown LINE error - Code: \(nsError.code)")
                            continuation.resume(throwing: LINEAuthError.unknown(error))
                        }
                    }
                }
                
                print("📱 LoginManager.login() called")
                print("📱 Waiting for user to complete login in browser...")
                print("📱 Browser should open now (SFSafariViewController)")
            }
        }
    }
    
    // Legacy method for backward compatibility
    func login() async throws -> LINEUserProfile {
        let (profile, _) = try await loginWithToken()
        return profile
    }
    
    private func getProfile(with accessToken: String, completion: @escaping (Result<LINEUserProfile, Error>) -> Void) {
        print("📱 Fetching LINE profile via API.getProfile()...")
        print("   Using access token (first 10 chars): \(String(accessToken.prefix(10)))...")
        
        API.getProfile { result in
            switch result {
            case .success(let profile):
                print("✅ API.getProfile() succeeded")
                print("   User ID: \(profile.userID)")
                print("   Display Name: \(profile.displayName)")
                print("   Picture URL: \(profile.pictureURL?.absoluteString ?? "none")")
                
                let userProfile = LINEUserProfile(
                    userID: profile.userID,
                    displayName: profile.displayName,
                    pictureURL: profile.pictureURL
                )
                completion(.success(userProfile))
                
            case .failure(let error):
                print("❌ API.getProfile() failed")
                print("   Error: \(error)")
                print("   Error description: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func logout() {
        print("🔴 ========================================")
        print("🔴 Logging out from LINE...")
        print("🔴 ========================================")
        
        LoginManager.shared.logout { result in
            switch result {
            case .success:
                print("✅ LINE Logout successful")
            case .failure(let error):
                print("❌ LINE Logout failed: \(error)")
            }
        }
    }
    
    var isLoggedIn: Bool {
        let loggedIn = LoginManager.shared.isAuthorized
        print("📱 LINE isLoggedIn check: \(loggedIn)")
        return loggedIn
    }
}

struct LINEUserProfile {
    let userID: String
    let displayName: String
    let pictureURL: URL?
}
