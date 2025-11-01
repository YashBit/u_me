//
//  AuthError.swift
//  U&Me
//
//  Authentication error types
//

import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case userCancelled
    case missingIdToken
    case linkingFailed
    case appleSignInFailed(Error)  // ← ADDED
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "No account found with this email"
        case .emailAlreadyInUse:
            return "An account already exists with this email"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .networkError:
            return "Network error. Please check your connection"
        case .userCancelled:
            return "Sign in was cancelled"
        case .missingIdToken:
            return "Failed to get identity token from Apple"
        case .linkingFailed:
            return "Failed to link accounts"
        case .appleSignInFailed(let error):  // ← ADDED
            return "Apple Sign In failed: \(error.localizedDescription)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
