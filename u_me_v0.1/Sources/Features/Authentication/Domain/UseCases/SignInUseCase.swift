//
//  SignInUseCase.swift
//  U&Me
//
//  Sign in use case with provider linking logic
//

import Foundation

protocol SignInUseCaseProtocol {
    func execute(with credentials: AuthCredentials) async -> AuthResult
}

final class SignInUseCase: SignInUseCaseProtocol {
    
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol,
         userRepository: UserRepositoryProtocol) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    func execute(with credentials: AuthCredentials) async -> AuthResult {
        print("🔐 SignInUseCase.execute() called")
        print("   Provider: \(credentials.provider)")
        print("   User ID: \(credentials.userId)")
        
        do {
            // Extract provider ID and email from credentials
            let (providerId, email) = extractInfo(from: credentials)
            
            // Check if user exists by provider ID
            if let existingUser = try await authRepository.findUser(
                byProviderId: providerId,
                provider: credentials.provider
            ) {
                print("✅ Found existing user by provider ID: \(existingUser.id)")
                
                // Update last login
                var updatedUser = existingUser
                updatedUser.lastLoginAt = Date()
                updatedUser.lastLoginProvider = credentials.provider
                
                try await userRepository.saveCurrentUser(updatedUser)
                return .success(updatedUser)
            }
            
            // Check if user exists by email (for linking)
            if let email = email,
               let existingUser = try await authRepository.findUser(byEmail: email) {
                print("⚠️ Found existing user by email: \(existingUser.id)")
                print("   Existing provider: \(existingUser.primaryProvider)")
                print("   New provider: \(credentials.provider)")
                
                // Check if already linked
                if existingUser.linkedProviders.contains(credentials.provider) {
                    print("ℹ️ Provider already linked, signing in")
                    
                    // Update last login
                    var updatedUser = existingUser
                    updatedUser.lastLoginAt = Date()
                    updatedUser.lastLoginProvider = credentials.provider
                    
                    try await userRepository.saveCurrentUser(updatedUser)
                    return .success(updatedUser)
                }
                
                // Require linking confirmation
                return .requiresLinking(
                    existingUser: existingUser,
                    newCredentials: credentials
                )
            }
            
            // New user - create account
            print("➕ Creating new user")
            let newUser = createUser(from: credentials)
            let createdUser = try await authRepository.createUser(newUser, with: credentials)
            
            print("✅ User created successfully: \(createdUser.id)")
            try await userRepository.saveCurrentUser(createdUser)
            
            // Check if onboarding is needed
            if !createdUser.onboardingCompleted {
                return .requiresOnboarding(createdUser)
            }
            
            return .success(createdUser)
            
        } catch let error as AuthError {
            print("❌ SignInUseCase AuthError: \(error)")
            return .failure(error)
        } catch {
            print("❌ SignInUseCase error: \(error)")
            return .failure(AuthError.unknown(error))
        }
    }
    
    // MARK: - Private Helpers
    
    private func extractInfo(from credentials: AuthCredentials) -> (String, String?) {
        switch credentials {
        case .apple(let userId, let email, _, _):
            return (userId, email)
        case .line(let userId, _, _, _):
            return (userId, nil)
        case .email(let email, _):
            return (email, email)
        case .google(let userId, let email, _, _):
            return (userId, email)
        }
    }
    
    private func createUser(from credentials: AuthCredentials) -> User {
        let userId = UUID().uuidString
        let now = Date()
        
        switch credentials {
        case .apple(let providerId, let email, _, let fullName):
            let displayName = formatName(fullName) ?? "User"
            
            return User(
                id: userId,
                displayName: displayName,
                email: email,
                profilePhotoURL: nil,
                phoneNumber: nil,
                primaryProvider: .apple,
                linkedProviders: [.apple],
                providerIDs: [.apple: providerId],
                appleUserID: providerId,
                lineUserID: nil,
                createdAt: now,
                updatedAt: now,
                lastLoginAt: now,
                lastLoginProvider: .apple,
                onboardingCompleted: false
            )
            
        case .line(let providerId, let displayName, let pictureURL, _):
            return User(
                id: userId,
                displayName: displayName,
                email: nil,
                profilePhotoURL: pictureURL,
                phoneNumber: nil,
                primaryProvider: .line,
                linkedProviders: [.line],
                providerIDs: [.line: providerId],
                appleUserID: nil,
                lineUserID: providerId,
                createdAt: now,
                updatedAt: now,
                lastLoginAt: now,
                lastLoginProvider: .line,
                onboardingCompleted: false
            )
            
        case .email(let email, _):
            let displayName = email.components(separatedBy: "@").first ?? "User"
            
            return User(
                id: userId,
                displayName: displayName,
                email: email,
                profilePhotoURL: nil,
                phoneNumber: nil,
                primaryProvider: .email,
                linkedProviders: [.email],
                providerIDs: [.email: email],
                appleUserID: nil,
                lineUserID: nil,
                createdAt: now,
                updatedAt: now,
                lastLoginAt: now,
                lastLoginProvider: .email,
                onboardingCompleted: false
            )
            
        case .google(let providerId, let email, _, let displayName):
            let name = displayName ?? email?.components(separatedBy: "@").first ?? "User"
            
            return User(
                id: userId,
                displayName: name,
                email: email,
                profilePhotoURL: nil,
                phoneNumber: nil,
                primaryProvider: .google,
                linkedProviders: [.google],
                providerIDs: [.google: providerId],
                appleUserID: nil,
                lineUserID: nil,
                createdAt: now,
                updatedAt: now,
                lastLoginAt: now,
                lastLoginProvider: .google,
                onboardingCompleted: false
            )
        }
    }
    
    private func formatName(_ nameComponents: PersonNameComponents?) -> String? {
        guard let components = nameComponents else { return nil }
        
        var parts: [String] = []
        
        if let givenName = components.givenName {
            parts.append(givenName)
        }
        
        if let middleName = components.middleName {
            parts.append(middleName)
        }
        
        if let familyName = components.familyName {
            parts.append(familyName)
        }
        
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }
}
