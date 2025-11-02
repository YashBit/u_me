//
//  GoogleAuthService.swift
//  U&Me
//

import Foundation
import GoogleSignIn
import UIKit

@MainActor
final class GoogleAuthService {
    
    static let shared = GoogleAuthService()
    
    private init() {}
    
    func signIn() async throws -> AuthCredentials {
        print("🔴 ========================================")
        print("🔴 GoogleAuthService.signIn() called")
        print("🔴 ========================================")
        
        // Test network connectivity first
        await testNetworkConnectivity()
        
        // Verify Google Sign In is configured (done in AppDelegate)
        guard GIDSignIn.sharedInstance.configuration != nil else {
            print("❌ Google Sign In not configured. Make sure AppDelegate initializes it.")
            throw AuthError.invalidCredentials
        }
        
        print("🔴 Google Sign In is configured")
        
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ Could not find root view controller")
            throw AuthError.invalidCredentials
        }
        
        print("🔴 Found root view controller")
        print("🔴 Presenting Google Sign In...")
        
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    print("❌ ========================================")
                    print("❌ Google Sign In error")
                    print("❌ ========================================")
                    print("   Error: \(error.localizedDescription)")
                    
                    // Check if user cancelled
                    let nsError = error as NSError
                    print("   Error Domain: \(nsError.domain)")
                    print("   Error Code: \(nsError.code)")
                    print("   User Info: \(nsError.userInfo)")
                    
                    if nsError.code == -5 { // GIDSignInErrorCode.canceled
                        print("   ℹ️ User cancelled Google Sign In")
                        continuation.resume(throwing: AuthError.userCancelled)
                    } else {
                        print("   ❌ Google Sign In failed")
                        continuation.resume(throwing: AuthError.unknown(error))
                    }
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    print("❌ Failed to get user data or ID token")
                    continuation.resume(throwing: AuthError.missingIdToken)
                    return
                }
                
                print("✅ ========================================")
                print("✅ Google Sign In successful!")
                print("✅ ========================================")
                print("   User ID: \(user.userID ?? "unknown")")
                print("   Email: \(user.profile?.email ?? "not provided")")
                print("   Name: \(user.profile?.name ?? "not provided")")
                print("   Given Name: \(user.profile?.givenName ?? "not provided")")
                print("   Family Name: \(user.profile?.familyName ?? "not provided")")
                print("   Profile Image: \(user.profile?.imageURL(withDimension: 200)?.absoluteString ?? "none")")
                print("   ID Token: \(String(idToken.prefix(20)))...")
                
                let credentials = AuthCredentials.google(
                    userId: user.userID ?? UUID().uuidString,
                    email: user.profile?.email,
                    idToken: idToken,
                    displayName: user.profile?.name
                )
                
                print("✅ Returning Google credentials to AuthViewModel")
                continuation.resume(returning: credentials)
            }
        }
    }
    
    func signOut() {
        print("🔴 ========================================")
        print("🔴 GoogleAuthService.signOut() called")
        print("🔴 ========================================")
        
        GIDSignIn.sharedInstance.signOut()
        
        print("✅ Google Sign Out complete")
    }
    
    // MARK: - Network Diagnostics
    
    func testNetworkConnectivity() async {
        print("🔍 ========================================")
        print("🔍 Testing network connectivity to Google servers...")
        print("🔍 ========================================")
        
        let urls = [
            "https://accounts.google.com",
            "https://oauth2.googleapis.com",
            "https://www.googleapis.com",
            "https://www.google.com"
        ]
        
        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            
            do {
                let (_, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse {
                    print("   ✅ \(urlString): HTTP \(httpResponse.statusCode)")
                }
            } catch {
                print("   ❌ \(urlString): \(error.localizedDescription)")
                
                let nsError = error as NSError
                print("      Domain: \(nsError.domain)")
                print("      Code: \(nsError.code)")
            }
        }
        
        print("🔍 Network test complete")
        print("🔍 ========================================")
    }
    
    // MARK: - Helper Methods
    
    private func getClientID() -> String? {
        // Try to get from GoogleService-Info.plist
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let clientID = dict["CLIENT_ID"] as? String {
            return clientID
        }
        
        // Fallback: Try to get from Info.plist
        if let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String {
            return clientID
        }
        
        return nil
    }
    
    // Check if user is currently signed in
    func isSignedIn() -> Bool {
        return GIDSignIn.sharedInstance.currentUser != nil
    }
    
    // Get current signed in user (if any)
    func getCurrentUser() -> GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    // Restore previous sign in (call on app launch if needed)
    func restorePreviousSignIn() async throws -> AuthCredentials? {
        print("🔴 Attempting to restore previous Google Sign In...")
        
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let error = error {
                    print("⚠️ Could not restore previous sign in: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let user = user,
                      let idToken = user.idToken?.tokenString else {
                    print("ℹ️ No previous sign in to restore")
                    continuation.resume(returning: nil)
                    return
                }
                
                print("✅ Restored previous Google Sign In")
                print("   User: \(user.profile?.email ?? "unknown")")
                
                let credentials = AuthCredentials.google(
                    userId: user.userID ?? UUID().uuidString,
                    email: user.profile?.email,
                    idToken: idToken,
                    displayName: user.profile?.name
                )
                
                continuation.resume(returning: credentials)
            }
        }
    }
}
