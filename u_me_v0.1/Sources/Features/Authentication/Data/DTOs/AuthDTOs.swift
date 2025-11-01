//
//  AuthDTOs.swift
//  U&Me
//
//  Data Transfer Objects for Authentication
//

import Foundation

// MARK: - Sign Up

struct SignUpRequest: Codable {
    let user: User
    let provider: String
    let providerId: String
    let providerToken: String
    
    init(user: User, credentials: AuthCredentials) {
        self.user = user
        self.provider = credentials.provider.rawValue
        
        switch credentials {
        case .apple(let userId, _, let idToken, _):
            self.providerId = userId
            self.providerToken = idToken
        case .line(let userId, _, _, let accessToken):
            self.providerId = userId
            self.providerToken = accessToken
        case .email(let email, let password):
            self.providerId = email
            self.providerToken = password
        case .google(let userId, _, let idToken, _):
            self.providerId = userId
            self.providerToken = idToken
        }
    }
}

struct SignUpResponse: Codable {
    let user: User
}

// MARK: - Link Provider

struct LinkProviderRequest: Codable {
    let userId: String
    let provider: String
    let providerId: String
    let providerToken: String
    
    init(userId: String, credentials: AuthCredentials) {
        self.userId = userId
        self.provider = credentials.provider.rawValue
        
        switch credentials {
        case .apple(let userId, _, let idToken, _):
            self.providerId = userId
            self.providerToken = idToken
        case .line(let userId, _, _, let accessToken):
            self.providerId = userId
            self.providerToken = accessToken
        case .email(let email, let password):
            self.providerId = email
            self.providerToken = password
        case .google(let userId, _, let idToken, _):
            self.providerId = userId
            self.providerToken = idToken
        }
    }
}

struct LinkProviderResponse: Codable {
    let user: User
}

// MARK: - Token Management

struct ValidationResponse: Codable {
    let isValid: Bool
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

struct TokenPair {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Sign In

struct SignInRequest: Codable {
    let provider: String
    let providerId: String
    let providerToken: String
    
    init(credentials: AuthCredentials) {
        self.provider = credentials.provider.rawValue
        
        switch credentials {
        case .apple(let userId, _, let idToken, _):
            self.providerId = userId
            self.providerToken = idToken
        case .line(let userId, _, _, let accessToken):
            self.providerId = userId
            self.providerToken = accessToken
        case .email(let email, let password):
            self.providerId = email
            self.providerToken = password
        case .google(let userId, _, let idToken, _):
            self.providerId = userId
            self.providerToken = idToken
        }
    }
}

struct SignInResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
}
