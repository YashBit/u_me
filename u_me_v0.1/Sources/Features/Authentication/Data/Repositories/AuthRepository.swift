//
//  AuthRepository.swift
//  U&Me
//

import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    
    private let remoteDataSource: RemoteAuthDataSource
    private let localDataSource: LocalAuthDataSource
    
    init(remoteDataSource: RemoteAuthDataSource,
         localDataSource: LocalAuthDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func findUser(byProviderId providerId: String, provider: AuthProvider) async throws -> User? {
        print("🔍 AuthRepository.findUser(byProviderId:)")
        print("   Provider ID: \(providerId)")
        print("   Provider: \(provider)")
        
        // Try remote first
        if let user = try await remoteDataSource.findUserByProviderId(providerId, provider: provider) {
            print("✅ Found user remotely: \(user.id)")
            return user
        }
        
        // Fallback to local
        if let user = try? await localDataSource.getCurrentUser(),
           user.providerIDs[provider] == providerId {
            print("✅ Found user locally: \(user.id)")
            return user
        }
        
        print("ℹ️ User not found")
        return nil
    }
    
    func findUser(byEmail email: String) async throws -> User? {
        print("🔍 AuthRepository.findUser(byEmail:)")
        print("   Email: \(email)")
        
        // Try remote first
        if let user = try await remoteDataSource.findUserByEmail(email) {
            print("✅ Found user remotely: \(user.id)")
            return user
        }
        
        // Fallback to local
        if let user = try? await localDataSource.getCurrentUser(),
           user.email?.lowercased() == email.lowercased() {
            print("✅ Found user locally: \(user.id)")
            return user
        }
        
        print("ℹ️ User not found")
        return nil
    }
    
    func createUser(_ user: User, with credentials: AuthCredentials) async throws -> User {
        print("➕ AuthRepository.createUser()")
        print("   User ID: \(user.id)")
        print("   Provider: \(credentials.provider)")
        
        // Create remotely
        let createdUser = try await remoteDataSource.createUser(user, credentials: credentials)
        
        // Save locally
        try await localDataSource.saveUser(createdUser)
        
        print("✅ User created and saved locally")
        return createdUser
    }
    
    func updateUser(_ user: User) async throws -> User {
        print("📝 AuthRepository.updateUser()")
        print("   User ID: \(user.id)")
        
        // Update remotely
        let updatedUser = try await remoteDataSource.updateUser(user)
        
        // Update locally
        try await localDataSource.saveUser(updatedUser)
        
        print("✅ User updated")
        return updatedUser
    }
    
    func linkProvider(_ user: User, credentials: AuthCredentials) async throws -> User {
        print("🔗 AuthRepository.linkProvider()")
        print("   User ID: \(user.id)")
        print("   Linking provider: \(credentials.provider)")
        
        // Link remotely
        let linkedUser = try await remoteDataSource.linkProvider(user: user, credentials: credentials)
        
        // Update locally
        try await localDataSource.saveUser(linkedUser)
        
        print("✅ Provider linked")
        return linkedUser
    }
}
