//
//  AuthResult.swift
//  U&Me
//

import Foundation

enum AuthResult {
    case success(User)
    case requiresOnboarding(User)
    case requiresLinking(existingUser: User, newCredentials: AuthCredentials)
    case failure(AuthError)
    
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    var user: User? {
        switch self {
        case .success(let user), .requiresOnboarding(let user):
            return user
        case .requiresLinking(let existingUser, _):
            return existingUser
        case .failure:
            return nil
        }
    }
}
