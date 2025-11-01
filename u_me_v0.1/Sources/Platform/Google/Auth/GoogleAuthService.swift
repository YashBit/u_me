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
        
        // Get the client ID from GoogleService-Info.plist
        guard let clientID = getClientID() else {
            print("❌ No Google Client ID found in GoogleService-Info.plist")
            throw AuthError.invalidCredentials
        }
        
        print("🔴 Client ID found: \(String(clientID.prefix(20)))...")
        
        // Configure Google Sign In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ Could not find root view controller")
            throw AuthError.invalidCredentials
        }
        
        print("🔴 Presenting Google Sign In...")
        
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    print("❌ Google Sign In error: \(error.localizedDescription)")
                    
                    // Check if user cancelled
                    let nsError = error as NSError
                    if nsError.code == -5 { // GIDSignInErrorCode.canceled
                        continuation.resume(throwing: AuthError.userCancelled)
                    } else {
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
                
                print("✅ Google Sign In successful!")
                print("   User ID: \(user.userID ?? "unknown")")
                print("   Email: \(user.profile?.email ?? "not provided")")
                print("   Name: \(user.profile?.name ?? "not provided")")
                
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
        print("🔴 Signing out from Google...")
        GIDSignIn.sharedInstance.signOut()
        print("✅ Google sign out complete")
    }
    
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
}
