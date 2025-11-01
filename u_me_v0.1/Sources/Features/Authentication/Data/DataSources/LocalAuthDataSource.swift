//
//  LocalAuthDataSource.swift
//  U&Me
//
//  Local storage data source using Keychain and UserDefaults
//

import Foundation
import Security

final class LocalAuthDataSource {
    private let userDefaults = UserDefaults.standard
    private let keychainService = KeychainService.shared
    
    private let userKey = "com.ume.currentUser"
    private let accessTokenKey = "com.ume.accessToken"
    private let refreshTokenKey = "com.ume.refreshToken"
    
    func getCurrentUser() async throws -> User? {
        guard let data = userDefaults.data(forKey: userKey) else { return nil }
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    func getUserByProviderId(_ providerId: String, provider: AuthProvider) async throws -> User? {
        guard let user = try await getCurrentUser() else { return nil }
        
        // FIXED: Use AuthProvider as key, not String
        if user.providerIDs[provider] == providerId {
            return user
        }
        return nil
    }
    
    func saveUser(_ user: User) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(user)
        userDefaults.set(data, forKey: userKey)
    }
    
    func deleteCurrentUser() async throws {
        userDefaults.removeObject(forKey: userKey)
        try keychainService.delete(key: accessTokenKey)
        try keychainService.delete(key: refreshTokenKey)
    }
    
    func saveTokens(_ tokens: TokenPair) async throws {
        try keychainService.save(tokens.accessToken, for: accessTokenKey)
        try keychainService.save(tokens.refreshToken, for: refreshTokenKey)
    }
    
    func getAccessToken() async throws -> String? {
        return try keychainService.retrieve(key: accessTokenKey)
    }
    
    func getRefreshToken() async throws -> String? {
        return try keychainService.retrieve(key: refreshTokenKey)
    }
}
