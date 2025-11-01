//
//  AppleSignInService.swift
//  U&Me
//

import Foundation
import AuthenticationServices
import CryptoKit
import UIKit

@MainActor
final class AppleSignInService: NSObject {
    
    static let shared = AppleSignInService()
    
    private var currentNonce: String?
    private var continuation: CheckedContinuation<AuthCredentials, Error>?
    
    private override init() {
        super.init()
    }
    
    func signIn() async throws -> AuthCredentials {
        print("🍎 ========================================")
        print("🍎 AppleSignInService.signIn() called")
        print("🍎 ========================================")
        
        // Generate nonce for security
        let nonce = randomNonceString()
        currentNonce = nonce
        
        print("🍎 Generated nonce: \(String(nonce.prefix(10)))...")
        print("🍎 Creating Apple ID request...")
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            
            print("🍎 Presenting Apple Sign In sheet...")
            authorizationController.performRequests()
        }
    }
    
    // MARK: - Helper Methods
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInService: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("🍎 ========================================")
        print("🍎 Apple Sign In - Authorization Completed")
        print("🍎 ========================================")
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ Failed to get Apple ID credential")
            continuation?.resume(throwing: AuthError.appleSignInFailed(NSError(domain: "AppleSignIn", code: -1)))
            continuation = nil
            return
        }
        
        guard let nonce = currentNonce else {
            print("❌ Invalid state: no nonce available")
            continuation?.resume(throwing: AuthError.appleSignInFailed(NSError(domain: "AppleSignIn", code: -2)))
            continuation = nil
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("❌ Unable to fetch identity token")
            continuation?.resume(throwing: AuthError.missingIdToken)
            continuation = nil
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("❌ Unable to serialize token string from data")
            continuation?.resume(throwing: AuthError.missingIdToken)
            continuation = nil
            return
        }
        
        print("✅ Apple Sign In successful!")
        print("   User ID: \(appleIDCredential.user)")
        print("   Email: \(appleIDCredential.email ?? "not provided")")
        
        let givenName = appleIDCredential.fullName?.givenName
        let familyName = appleIDCredential.fullName?.familyName
        print("   Name: \(givenName ?? "") \(familyName ?? "")")
        print("   Identity Token: \(String(idTokenString.prefix(20)))...")
        
        // Create PersonNameComponents if we have name data
        var fullName: PersonNameComponents? = nil
        if let components = appleIDCredential.fullName {
            fullName = PersonNameComponents(
                givenName: components.givenName,
                middleName: components.middleName,  // ← middleName BEFORE familyName
                familyName: components.familyName
            )
        }
        
        let credentials = AuthCredentials.apple(
            userId: appleIDCredential.user,
            email: appleIDCredential.email,
            idToken: idTokenString,
            fullName: fullName
        )
        
        print("✅ Returning Apple credentials to AuthViewModel")
        continuation?.resume(returning: credentials)
        continuation = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ ========================================")
        print("❌ Apple Sign In - Error")
        print("❌ ========================================")
        print("   Error: \(error.localizedDescription)")
        
        let nsError = error as NSError
        print("   Error Domain: \(nsError.domain)")
        print("   Error Code: \(nsError.code)")
        
        // Check if user cancelled
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                print("ℹ️ User cancelled Apple Sign In")
                continuation?.resume(throwing: AuthError.userCancelled)
            case .failed:
                print("❌ Apple Sign In failed")
                continuation?.resume(throwing: AuthError.appleSignInFailed(error))
            case .invalidResponse:
                print("❌ Invalid response from Apple")
                continuation?.resume(throwing: AuthError.invalidCredentials)
            case .notHandled:
                print("❌ Request not handled")
                continuation?.resume(throwing: AuthError.appleSignInFailed(error))
            case .unknown:
                print("❌ Unknown error")
                continuation?.resume(throwing: AuthError.unknown(error))
            @unknown default:
                print("❌ Unknown error type")
                continuation?.resume(throwing: AuthError.unknown(error))
            }
        } else {
            continuation?.resume(throwing: AuthError.appleSignInFailed(error))
        }
        
        continuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        print("🍎 Providing presentation anchor (window)")
        
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            print("⚠️ Warning: Could not find key window, using first available")
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow } ?? UIWindow()
        }
        
        print("✅ Found key window for Apple Sign In")
        return window
    }
}
