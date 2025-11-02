//
//  AuthError.swift
//  U&Me
//

import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case networkError(Error)
    case unknownProvider
    case cancelled
    case userCancelled
    case accountLinkingRequired(existingUser: User, newCredentials: AuthCredentials)
    case notImplemented
    case unknown(Error)
    
    // Apple Sign In specific errors
    case appleSignInFailed(Error)
    case missingIdToken
    
    // Email/Password specific errors
    case weakPassword  // ← ADD THIS
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials provided"
        case .userNotFound:
            return "User not found"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknownProvider:
            return "Unknown authentication provider"
        case .cancelled:
            return "Authentication was cancelled"
        case .userCancelled:
            return "User cancelled authentication"
        case .accountLinkingRequired:
            return "Account linking required"
        case .notImplemented:
            return "This feature is not yet implemented"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        case .appleSignInFailed(let error):
            return "Apple Sign In failed: \(error.localizedDescription)"
        case .missingIdToken:
            return "Unable to retrieve identity token from Apple"
        case .weakPassword:  // ← ADD THIS
            return "Password must be at least 6 characters long"
        }
    }
}