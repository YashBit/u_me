//
//  LinkAccountUseCase.swift
//  U&Me
//
//  Use case for linking authentication providers
//

import Foundation

protocol LinkAccountUseCaseProtocol {
    func execute(existingUser: User, newCredentials: AuthCredentials) async -> AuthResult
}

final class LinkAccountUseCase: LinkAccountUseCaseProtocol {
    
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol,
         userRepository: UserRepositoryProtocol) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    func execute(existingUser: User, newCredentials: AuthCredentials) async -> AuthResult {
        print("🔗 LinkAccountUseCase.execute() called")
        print("   Existing user: \(existingUser.id)")
        print("   Linking provider: \(newCredentials.provider)")
        
        do {
            // Check if provider is already linked
            if existingUser.linkedProviders.contains(newCredentials.provider) {
                print("ℹ️ Provider already linked")
                try await userRepository.saveCurrentUser(existingUser)
                return .success(existingUser)  // ✅ NO label
            }
            
            // Add new provider to linked providers
            var updatedUser = existingUser
            updatedUser.linkedProviders.append(newCredentials.provider)
            
            // Update provider IDs dictionary
            var updatedProviderIDs = updatedUser.providerIDs
            updatedProviderIDs[newCredentials.provider] = newCredentials.userId
            updatedUser.providerIDs = updatedProviderIDs
            
            updatedUser.updatedAt = Date()
            updatedUser.lastLoginAt = Date()
            updatedUser.lastLoginProvider = newCredentials.provider
            
            // Update in backend
            let linkedUser = try await authRepository.linkProvider(updatedUser, credentials: newCredentials)  // ✅ NO 'user:' label
            
            print("✅ Provider linked successfully")
            try await userRepository.saveCurrentUser(linkedUser)
            
            return .success(linkedUser)  // ✅ NO label
            
        } catch let error as AuthError {
            print("❌ LinkAccountUseCase AuthError: \(error)")
            return .failure(error)  // ✅ NO label
        } catch {
            print("❌ LinkAccountUseCase error: \(error)")
            return .failure(AuthError.unknown(error))  // ✅ NO label
        }
    }
}
