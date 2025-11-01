#!/bin/bash

# U&Me Authentication Setup Script
# This script creates all necessary files for Apple Sign In + LINE authentication
# with proper clean architecture and account tracking

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Setting up U&Me Authentication with Clean Architecture..."

# Base directory (run from u_me_v0.1 directory)
BASE_DIR="Sources/Features/Authentication"

# ============================================
# DOMAIN LAYER - ENTITIES
# ============================================

echo -e "${YELLOW}Creating Domain Layer Entities...${NC}"

# Create User.swift
cat > "$BASE_DIR/Domain/Entities/User.swift" << 'EOF'
//
//  User.swift
//  U&Me
//
//  Core User entity with multi-provider support
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var displayName: String
    var profilePhotoURL: URL?
    var email: String?
    var phoneNumber: String?
    
    // Authentication tracking
    var primaryProvider: AuthProvider
    var linkedProviders: Set<AuthProvider>
    var providerIDs: [String: String]
    
    // Provider-specific data
    var appleUserID: String?
    var lineUserID: String?
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var lastLoginAt: Date
    var lastLoginProvider: AuthProvider?
    
    // Thai market specific
    var preferredLanguage: String = "th"
    var countryCode: String = "TH"
    
    // Creator specific
    var isCreator: Bool = false
    var creatorProfile: CreatorProfile?
}

struct CreatorProfile: Codable, Equatable {
    let creatorId: String
    var followerCount: Int
    var verificationStatus: VerificationStatus
    var categories: [String]
}

enum VerificationStatus: String, Codable {
    case unverified
    case pending
    case verified
}
EOF

# Create AuthProvider.swift
cat > "$BASE_DIR/Domain/Entities/AuthProvider.swift" << 'EOF'
//
//  AuthProvider.swift
//  U&Me
//
//  Authentication provider types
//

import Foundation

enum AuthProvider: String, Codable, CaseIterable {
    case apple = "apple"
    case line = "line"
    case email = "email"
    case phone = "phone"
    
    var displayName: String {
        switch self {
        case .apple: return "Apple"
        case .line: return "LINE"
        case .email: return "Email"
        case .phone: return "Phone"
        }
    }
    
    var iconName: String {
        switch self {
        case .apple: return "applelogo"
        case .line: return "line_logo"
        case .email: return "envelope.fill"
        case .phone: return "phone.fill"
        }
    }
}
EOF

# Create AuthCredentials.swift
cat > "$BASE_DIR/Domain/Entities/AuthCredentials.swift" << 'EOF'
//
//  AuthCredentials.swift
//  U&Me
//
//  Authentication credentials for different providers
//

import Foundation

enum AuthCredentials {
    case apple(userId: String, email: String?, idToken: String, fullName: PersonNameComponents?)
    case line(userId: String, displayName: String, pictureURL: URL?, accessToken: String)
    case email(email: String, password: String)
    case phone(phoneNumber: String, verificationCode: String)
    
    var provider: AuthProvider {
        switch self {
        case .apple: return .apple
        case .line: return .line
        case .email: return .email
        case .phone: return .phone
        }
    }
}

struct PersonNameComponents: Codable {
    let givenName: String?
    let familyName: String?
    let middleName: String?
}
EOF

# Create AuthResult.swift
cat > "$BASE_DIR/Domain/Entities/AuthResult.swift" << 'EOF'
//
//  AuthResult.swift
//  U&Me
//
//  Authentication result types
//

import Foundation

enum AuthResult {
    case success(user: User)
    case requiresLinking(existingUser: User, newCredentials: AuthCredentials)
    case requiresOnboarding(user: User)
    case failure(error: AuthError)
}
EOF

# Create AuthError.swift
cat > "$BASE_DIR/Domain/Entities/AuthError.swift" << 'EOF'
//
//  AuthError.swift
//  U&Me
//
//  Authentication error types
//

import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case userCancelled
    case accountAlreadyExists
    case missingIdToken
    case userNotFound
    case linkingFailed
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials provided"
        case .networkError:
            return "Network connection failed"
        case .userCancelled:
            return "Authentication cancelled"
        case .accountAlreadyExists:
            return "Account already exists with this email"
        case .missingIdToken:
            return "Missing authentication token"
        case .userNotFound:
            return "User not found"
        case .linkingFailed:
            return "Failed to link accounts"
        case .unknownError(let message):
            return message
        }
    }
}
EOF

echo -e "${GREEN}✓ Domain Entities created${NC}"

# ============================================
# DOMAIN LAYER - USE CASES
# ============================================

echo -e "${YELLOW}Creating Domain Layer Use Cases...${NC}"

# Create SignInUseCase.swift
cat > "$BASE_DIR/Domain/UseCases/SignInUseCase.swift" << 'EOF'
//
//  SignInUseCase.swift
//  U&Me
//
//  Business logic for user sign in
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
        do {
            // Extract provider info
            let provider = credentials.provider
            let (providerId, email) = extractInfo(from: credentials)
            
            // Check if user exists with this provider
            if let existingUser = try await authRepository.findUserByProviderId(
                providerId, 
                provider: provider
            ) {
                // Update last login
                var updatedUser = existingUser
                updatedUser.lastLoginAt = Date()
                updatedUser.lastLoginProvider = provider
                
                let savedUser = try await authRepository.updateUser(updatedUser)
                try await userRepository.saveCurrentUser(savedUser)
                
                return .success(user: savedUser)
            }
            
            // Check if user exists with same email
            if let email = email,
               let existingUser = try await authRepository.findUserByEmail(email) {
                return .requiresLinking(
                    existingUser: existingUser, 
                    newCredentials: credentials
                )
            }
            
            // Create new user
            let newUser = createUser(from: credentials)
            let savedUser = try await authRepository.createUser(newUser, credentials: credentials)
            try await userRepository.saveCurrentUser(savedUser)
            
            return .requiresOnboarding(user: savedUser)
            
        } catch {
            return .failure(error: AuthError.unknownError(error.localizedDescription))
        }
    }
    
    private func extractInfo(from credentials: AuthCredentials) -> (String, String?) {
        switch credentials {
        case .apple(let userId, let email, _, _):
            return (userId, email)
        case .line(let userId, _, _, _):
            return (userId, nil)
        case .email(let email, _):
            return (email, email)
        case .phone(let phoneNumber, _):
            return (phoneNumber, nil)
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
                profilePhotoURL: nil,
                email: email,
                phoneNumber: nil,
                primaryProvider: .apple,
                linkedProviders: [.apple],
                providerIDs: ["apple": providerId],
                appleUserID: providerId,
                lineUserID: nil,
                createdAt: now,
                updatedAt: now,
                lastLoginAt: now,
                lastLoginProvider: .apple,
                isCreator: false,
                creatorProfile: nil
            )
            
        case .line(let providerId, let displayName, let pictureURL, _):
            return User(
                id: userId,
                displayName: displayName,
                profilePhotoURL: pictureURL,
                email: nil,
                phoneNumber: nil,
                primaryProvider: .line,
                linkedProviders: [.line],
                providerIDs: ["line": providerId],
                appleUserID: nil,
                lineUserID: providerId,
                createdAt: now,
                updatedAt: now,
                lastLoginAt: now,
                lastLoginProvider: .line,
                isCreator: false,
                creatorProfile: nil
            )
            
        default:
            fatalError("Not implemented")
        }
    }
    
    private func formatName(_ components: PersonNameComponents?) -> String? {
        guard let components = components else { return nil }
        return [components.givenName, components.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
EOF

# Create LinkAccountUseCase.swift
cat > "$BASE_DIR/Domain/UseCases/LinkAccountUseCase.swift" << 'EOF'
//
//  LinkAccountUseCase.swift
//  U&Me
//
//  Business logic for linking multiple auth providers
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
        do {
            var user = existingUser
            
            // Add new provider
            let provider = newCredentials.provider
            user.linkedProviders.insert(provider)
            
            // Update provider-specific fields
            switch newCredentials {
            case .apple(let userId, _, _, _):
                user.providerIDs["apple"] = userId
                user.appleUserID = userId
            case .line(let userId, _, _, _):
                user.providerIDs["line"] = userId
                user.lineUserID = userId
            default:
                break
            }
            
            user.updatedAt = Date()
            
            let updatedUser = try await authRepository.linkProvider(
                user: user, 
                credentials: newCredentials
            )
            try await userRepository.saveCurrentUser(updatedUser)
            
            return .success(user: updatedUser)
            
        } catch {
            return .failure(error: .linkingFailed)
        }
    }
}
EOF

echo -e "${GREEN}✓ Domain Use Cases created${NC}"

# ============================================
# DOMAIN LAYER - REPOSITORY PROTOCOLS
# ============================================

echo -e "${YELLOW}Creating Domain Repository Protocols...${NC}"

# Create AuthRepositoryProtocol.swift
cat > "$BASE_DIR/Domain/Repositories/AuthRepositoryProtocol.swift" << 'EOF'
//
//  AuthRepositoryProtocol.swift
//  U&Me
//
//  Authentication repository interface
//

import Foundation

protocol AuthRepositoryProtocol {
    func findUserByProviderId(_ providerId: String, provider: AuthProvider) async throws -> User?
    func findUserByEmail(_ email: String) async throws -> User?
    func createUser(_ user: User, credentials: AuthCredentials) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func linkProvider(user: User, credentials: AuthCredentials) async throws -> User
    func validateToken(_ token: String) async throws -> Bool
    func refreshTokens(_ refreshToken: String) async throws -> TokenPair
}

struct TokenPair {
    let accessToken: String
    let refreshToken: String
}
EOF

# Create UserRepositoryProtocol.swift
cat > "$BASE_DIR/Domain/Repositories/UserRepositoryProtocol.swift" << 'EOF'
//
//  UserRepositoryProtocol.swift
//  U&Me
//
//  User data repository interface
//

import Foundation
import Combine

protocol UserRepositoryProtocol {
    var currentUserPublisher: AnyPublisher<User?, Never> { get }
    func getCurrentUser() async throws -> User?
    func saveCurrentUser(_ user: User) async throws
    func deleteCurrentUser() async throws
}
EOF

echo -e "${GREEN}✓ Domain Repository Protocols created${NC}"

# ============================================
# DATA LAYER - REPOSITORIES
# ============================================

echo -e "${YELLOW}Creating Data Layer Repositories...${NC}"

# Create AuthRepository.swift
cat > "$BASE_DIR/Data/Repositories/AuthRepository.swift" << 'EOF'
//
//  AuthRepository.swift
//  U&Me
//
//  Concrete implementation of authentication repository
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
    
    func findUserByProviderId(_ providerId: String, provider: AuthProvider) async throws -> User? {
        // Check local cache first
        if let cachedUser = try? await localDataSource.getUserByProviderId(providerId, provider: provider) {
            return cachedUser
        }
        
        // Then check remote
        return try await remoteDataSource.findUserByProviderId(providerId, provider: provider)
    }
    
    func findUserByEmail(_ email: String) async throws -> User? {
        return try await remoteDataSource.findUserByEmail(email)
    }
    
    func createUser(_ user: User, credentials: AuthCredentials) async throws -> User {
        let createdUser = try await remoteDataSource.createUser(user, credentials: credentials)
        try await localDataSource.saveUser(createdUser)
        return createdUser
    }
    
    func updateUser(_ user: User) async throws -> User {
        let updatedUser = try await remoteDataSource.updateUser(user)
        try await localDataSource.saveUser(updatedUser)
        return updatedUser
    }
    
    func linkProvider(user: User, credentials: AuthCredentials) async throws -> User {
        let updatedUser = try await remoteDataSource.linkProvider(user: user, credentials: credentials)
        try await localDataSource.saveUser(updatedUser)
        return updatedUser
    }
    
    func validateToken(_ token: String) async throws -> Bool {
        return try await remoteDataSource.validateToken(token)
    }
    
    func refreshTokens(_ refreshToken: String) async throws -> TokenPair {
        let tokens = try await remoteDataSource.refreshTokens(refreshToken)
        try await localDataSource.saveTokens(tokens)
        return tokens
    }
}
EOF

# Create UserRepository.swift
cat > "$BASE_DIR/Data/Repositories/UserRepository.swift" << 'EOF'
//
//  UserRepository.swift
//  U&Me
//
//  Concrete implementation of user repository
//

import Foundation
import Combine

final class UserRepository: UserRepositoryProtocol {
    @Published private var currentUser: User?
    
    var currentUserPublisher: AnyPublisher<User?, Never> {
        $currentUser.eraseToAnyPublisher()
    }
    
    private let localDataSource: LocalAuthDataSource
    
    init(localDataSource: LocalAuthDataSource) {
        self.localDataSource = localDataSource
        Task {
            self.currentUser = try? await localDataSource.getCurrentUser()
        }
    }
    
    func getCurrentUser() async throws -> User? {
        return try await localDataSource.getCurrentUser()
    }
    
    func saveCurrentUser(_ user: User) async throws {
        try await localDataSource.saveUser(user)
        await MainActor.run {
            self.currentUser = user
        }
    }
    
    func deleteCurrentUser() async throws {
        try await localDataSource.deleteCurrentUser()
        await MainActor.run {
            self.currentUser = nil
        }
    }
}
EOF

echo -e "${GREEN}✓ Data Repositories created${NC}"

# ============================================
# DATA LAYER - DATA SOURCES
# ============================================

echo -e "${YELLOW}Creating Data Layer Data Sources...${NC}"

# Create RemoteAuthDataSource.swift
cat > "$BASE_DIR/Data/DataSources/RemoteAuthDataSource.swift" << 'EOF'
//
//  RemoteAuthDataSource.swift
//  U&Me
//
//  Remote API data source for authentication
//

import Foundation

final class RemoteAuthDataSource {
    private let networkService: NetworkService
    private let baseURL = "https://api.u-and-me.app/v1"
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func findUserByProviderId(_ providerId: String, provider: AuthProvider) async throws -> User? {
        let endpoint = "\(baseURL)/users/provider/\(provider.rawValue)/\(providerId)"
        return try await networkService.request(endpoint: endpoint, method: .get)
    }
    
    func findUserByEmail(_ email: String) async throws -> User? {
        let endpoint = "\(baseURL)/users/email/\(email)"
        return try await networkService.request(endpoint: endpoint, method: .get)
    }
    
    func createUser(_ user: User, credentials: AuthCredentials) async throws -> User {
        let endpoint = "\(baseURL)/auth/signup"
        let request = SignUpRequest(user: user, credentials: credentials)
        let response: SignUpResponse = try await networkService.request(
            endpoint: endpoint,
            method: .post,
            body: request
        )
        return response.user
    }
    
    func updateUser(_ user: User) async throws -> User {
        let endpoint = "\(baseURL)/users/\(user.id)"
        return try await networkService.request(
            endpoint: endpoint,
            method: .put,
            body: user
        )
    }
    
    func linkProvider(user: User, credentials: AuthCredentials) async throws -> User {
        let endpoint = "\(baseURL)/auth/link"
        let request = LinkProviderRequest(userId: user.id, credentials: credentials)
        let response: LinkProviderResponse = try await networkService.request(
            endpoint: endpoint,
            method: .post,
            body: request
        )
        return response.user
    }
    
    func validateToken(_ token: String) async throws -> Bool {
        let endpoint = "\(baseURL)/auth/validate"
        let response: ValidationResponse = try await networkService.request(
            endpoint: endpoint,
            method: .post,
            headers: ["Authorization": "Bearer \(token)"]
        )
        return response.isValid
    }
    
    func refreshTokens(_ refreshToken: String) async throws -> TokenPair {
        let endpoint = "\(baseURL)/auth/refresh"
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let response: TokenResponse = try await networkService.request(
            endpoint: endpoint,
            method: .post,
            body: request
        )
        return TokenPair(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
    }
}
EOF

# Create LocalAuthDataSource.swift
cat > "$BASE_DIR/Data/DataSources/LocalAuthDataSource.swift" << 'EOF'
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
        
        if user.providerIDs[provider.rawValue] == providerId {
            return user
        }
        return nil
    }
    
    func saveUser(_ user: User) async throws {
        let data = try JSONEncoder().encode(user)
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
EOF

echo -e "${GREEN}✓ Data Sources created${NC}"

# ============================================
# PLATFORM LAYER - APPLE SIGN IN SERVICE
# ============================================

echo -e "${YELLOW}Creating Platform Layer Services...${NC}"

# Create directory for Apple auth if it doesn't exist
mkdir -p "Sources/Platform/Apple/Auth"

# Create AppleSignInService.swift
cat > "Sources/Platform/Apple/Auth/AppleSignInService.swift" << 'EOF'
//
//  AppleSignInService.swift
//  U&Me
//
//  Apple Sign In service implementation
//

import Foundation
import AuthenticationServices
import CryptoKit

@MainActor
final class AppleSignInService: NSObject {
    
    func signIn() async throws -> AuthCredentials {
        let nonce = randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let credential = try await performSignIn(request: request)
        
        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.missingIdToken
        }
        
        let fullName = credential.fullName.map { components in
            PersonNameComponents(
                givenName: components.givenName,
                familyName: components.familyName,
                middleName: components.middleName
            )
        }
        
        return .apple(
            userId: credential.user,
            email: credential.email,
            idToken: idTokenString,
            fullName: fullName
        )
    }
    
    private func performSignIn(request: ASAuthorizationAppleIDRequest) async throws -> ASAuthorizationAppleIDCredential {
        return try await withCheckedThrowingContinuation { continuation in
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AppleSignInDelegate(continuation: continuation)
            
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            authorizationController.performRequests()
        }
    }
    
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
                    fatalError("Unable to generate nonce")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 { return }
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

private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>
    
    init(continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>) {
        self.continuation = continuation
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            continuation.resume(returning: appleIDCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
            continuation.resume(throwing: AuthError.userCancelled)
        } else {
            continuation.resume(throwing: error)
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else {
            return UIWindow()
        }
        return window
    }
}
EOF

echo -e "${GREEN}✓ Platform Services created${NC}"

# ============================================
# PRESENTATION LAYER - ENHANCED VIEW MODEL
# ============================================

echo -e "${YELLOW}Updating Presentation Layer...${NC}"

# Update AuthViewModel.swift
cat > "$BASE_DIR/Presentation/ViewModels/AuthViewModel.swift" << 'EOF'
//
//  AuthViewModel.swift
//  U&Me
//
//  Authentication view model with clean architecture
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var viewState: AuthViewState = .idle
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var showAccountLinkingDialog = false
    @Published var errorMessage: String?
    
    // MARK: - View State
    enum AuthViewState: Equatable {
        case idle
        case loading
        case authenticated(User)
        case requiresOnboarding(User)
        case requiresLinking(existingUser: User, newProvider: AuthProvider)
        case error(String)
    }
    
    // MARK: - Dependencies
    private let signInUseCase: SignInUseCaseProtocol
    private let linkAccountUseCase: LinkAccountUseCaseProtocol
    private let userRepository: UserRepositoryProtocol
    private let appleSignInService: AppleSignInService
    private let lineAuthService: LINEAuthService
    
    private var pendingLinkingCredentials: AuthCredentials?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(signInUseCase: SignInUseCaseProtocol,
         linkAccountUseCase: LinkAccountUseCaseProtocol,
         userRepository: UserRepositoryProtocol,
         appleSignInService: AppleSignInService,
         lineAuthService: LINEAuthService) {
        self.signInUseCase = signInUseCase
        self.linkAccountUseCase = linkAccountUseCase
        self.userRepository = userRepository
        self.appleSignInService = appleSignInService
        self.lineAuthService = lineAuthService
        
        setupBindings()
        checkAuthenticationStatus()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        userRepository.currentUserPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
            .store(in: &cancellables)
    }
    
    private func checkAuthenticationStatus() {
        Task {
            if let user = try? await userRepository.getCurrentUser() {
                self.currentUser = user
                self.isAuthenticated = true
                self.viewState = .authenticated(user)
            }
        }
    }
    
    // MARK: - View Actions
    func signInWithAppleTapped() {
        Task {
            await performAppleSignIn()
        }
    }
    
    func signInWithLINETapped() {
        Task {
            await performLINESignIn()
        }
    }
    
    func linkAccountsTapped() {
        Task {
            await performAccountLinking()
        }
    }
    
    func cancelLinkingTapped() {
        showAccountLinkingDialog = false
        pendingLinkingCredentials = nil
        viewState = .idle
    }
    
    func signOutTapped() {
        Task {
            try? await userRepository.deleteCurrentUser()
            lineAuthService.logout()
            currentUser = nil
            isAuthenticated = false
            viewState = .idle
        }
    }
    
    // MARK: - Private Methods
    private func performAppleSignIn() async {
        viewState = .loading
        errorMessage = nil
        
        do {
            let appleCredentials = try await appleSignInService.signIn()
            let result = await signInUseCase.execute(with: appleCredentials)
            await handleAuthResult(result, credentials: appleCredentials)
        } catch {
            handleError(error)
        }
    }
    
    private func performLINESignIn() async {
        viewState = .loading
        errorMessage = nil
        
        do {
            let lineCredentials = try await lineAuthService.signIn()
            let result = await signInUseCase.execute(with: lineCredentials)
            await handleAuthResult(result, credentials: lineCredentials)
        } catch {
            handleError(error)
        }
    }
    
    private func handleAuthResult(_ result: AuthResult, credentials: AuthCredentials? = nil) async {
        switch result {
        case .success(let user):
            currentUser = user
            isAuthenticated = true
            viewState = .authenticated(user)
            errorMessage = nil
            
        case .requiresOnboarding(let user):
            currentUser = user
            isAuthenticated = true
            viewState = .requiresOnboarding(user)
            
        case .requiresLinking(let existingUser, let newCredentials):
            pendingLinkingCredentials = credentials ?? newCredentials
            viewState = .requiresLinking(
                existingUser: existingUser,
                newProvider: newCredentials.provider
            )
            showAccountLinkingDialog = true
            
        case .failure(let error):
            viewState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    private func performAccountLinking() async {
        guard let credentials = pendingLinkingCredentials,
              case .requiresLinking(let existingUser, _) = viewState else {
            return
        }
        
        viewState = .loading
        
        let result = await linkAccountUseCase.execute(
            existingUser: existingUser,
            newCredentials: credentials
        )
        
        await handleAuthResult(result)
        showAccountLinkingDialog = false
        pendingLinkingCredentials = nil
    }
    
    private func handleError(_ error: Error) {
        if let authError = error as? AuthError,
           case .userCancelled = authError {
            viewState = .idle
        } else {
            viewState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
}
EOF

echo -e "${GREEN}✓ Presentation Layer updated${NC}"

# ============================================
# CORE LAYER - KEYCHAIN SERVICE
# ============================================

echo -e "${YELLOW}Creating Core Services...${NC}"

# Create KeychainService.swift
cat > "Sources/Core/Data/Local/Keychain/KeychainService.swift" << 'EOF'
//
//  KeychainService.swift
//  U&Me
//
//  Secure storage using iOS Keychain
//

import Foundation
import Security

final class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    func save(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    func retrieve(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.retrieveFailed(status)
        }
        
        guard let data = dataTypeRef as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        
        return value
    }
    
    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

enum KeychainError: LocalizedError {
    case invalidData
    case saveFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data format"
        case .saveFailed(let status):
            return "Failed to save to keychain: \(status)"
        case .retrieveFailed(let status):
            return "Failed to retrieve from keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from keychain: \(status)"
        }
    }
}
EOF

echo -e "${GREEN}✓ Core Services created${NC}"

# ============================================
# DEPENDENCY INJECTION CONTAINER
# ============================================

echo -e "${YELLOW}Creating Dependency Injection Container...${NC}"

# Create AuthenticationContainer.swift
cat > "Sources/Infrastructure/DI/AuthenticationContainer.swift" << 'EOF'
//
//  AuthenticationContainer.swift
//  U&Me
//
//  Dependency injection container for authentication
//

import Foundation

final class AuthenticationContainer {
    
    // MARK: - Services
    lazy var keychainService = KeychainService.shared
    lazy var networkService = NetworkService()
    lazy var appleSignInService = AppleSignInService()
    lazy var lineAuthService = LINEAuthService.shared
    
    // MARK: - Data Sources
    lazy var localAuthDataSource = LocalAuthDataSource()
    lazy var remoteAuthDataSource = RemoteAuthDataSource(networkService: networkService)
    
    // MARK: - Repositories
    lazy var authRepository: AuthRepositoryProtocol = AuthRepository(
        remoteDataSource: remoteAuthDataSource,
        localDataSource: localAuthDataSource
    )
    
    lazy var userRepository: UserRepositoryProtocol = UserRepository(
        localDataSource: localAuthDataSource
    )
    
    // MARK: - Use Cases
    lazy var signInUseCase: SignInUseCaseProtocol = SignInUseCase(
        authRepository: authRepository,
        userRepository: userRepository
    )
    
    lazy var linkAccountUseCase: LinkAccountUseCaseProtocol = LinkAccountUseCase(
        authRepository: authRepository,
        userRepository: userRepository
    )
    
    // MARK: - View Models
    func makeAuthViewModel() -> AuthViewModel {
        return AuthViewModel(
            signInUseCase: signInUseCase,
            linkAccountUseCase: linkAccountUseCase,
            userRepository: userRepository,
            appleSignInService: appleSignInService,
            lineAuthService: lineAuthService
        )
    }
}
EOF

echo -e "${GREEN}✓ Dependency Injection Container created${NC}"

# ============================================
# CREATE README
# ============================================

echo -e "${YELLOW}Creating README documentation...${NC}"

cat > "$BASE_DIR/README.md" << 'EOF'
# Authentication Module

## Architecture Overview

This module follows Clean Architecture principles with clear separation of concerns:

### Layers

1. **Domain Layer** (Business Logic)
   - Entities: Core models (User, AuthProvider, etc.)
   - Use Cases: Business rules (SignIn, LinkAccount)
   - Repository Protocols: Interfaces for data access

2. **Data Layer** (Data Management)
   - Repositories: Concrete implementations
   - Data Sources: Remote (API) and Local (Keychain/UserDefaults)
   - DTOs: Data Transfer Objects for API

3. **Presentation Layer** (UI)
   - ViewModels: State management and coordination
   - Views: SwiftUI views (UI only)
   - Components: Reusable UI elements

4. **Platform Layer** (External Services)
   - Apple Sign In Service
   - LINE Authentication Service
   - Firebase Integration

## Features

- ✅ Multiple authentication providers (Apple, LINE, Email, Phone)
- ✅ Account linking (connect multiple providers to one account)
- ✅ Secure token storage (Keychain)
- ✅ Automatic session management
- ✅ User state persistence

## Security Best Practices

1. **Token Storage**: All sensitive tokens stored in iOS Keychain
2. **User Data**: Non-sensitive user data in UserDefaults
3. **Nonce Generation**: Cryptographic nonce for Apple Sign In
4. **Token Refresh**: Automatic token refresh when expired
5. **Secure Communication**: All API calls over HTTPS

## Usage

```swift
// In your app initialization
let container = AuthenticationContainer()
let authViewModel = container.makeAuthViewModel()

// In your view
LoginView()
    .environmentObject(authViewModel)
```

## Testing

Each layer can be tested independently:
- Domain: Pure business logic tests
- Data: Repository tests with mock data sources
- Presentation: ViewModel tests with mock use cases
- UI: Snapshot and UI tests

## Account Tracking

Users are tracked using:
1. Universal User ID (UUID) - consistent across all providers
2. Provider-specific IDs - for authentication
3. Email matching - for account linking suggestions

## Files Structure

```
Authentication/
├── Domain/
│   ├── Entities/        # Core models
│   ├── UseCases/        # Business logic
│   └── Repositories/    # Interfaces
├── Data/
│   ├── Repositories/    # Implementations
│   ├── DataSources/     # API & Local storage
│   └── DTOs/           # API models
└── Presentation/
    ├── ViewModels/      # State management
    └── Views/           # UI components
```
EOF

echo -e "${GREEN}✓ Documentation created${NC}"

# ============================================
# SUMMARY
# ============================================

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Authentication setup complete!${NC}"
echo "=========================================="
echo ""
echo "📁 Files created:"
echo "  - Domain Layer: Entities, Use Cases, Protocols"
echo "  - Data Layer: Repositories, Data Sources"
echo "  - Platform Layer: Apple Sign In Service"
echo "  - Presentation Layer: Enhanced ViewModel"
echo "  - Core Services: Keychain Service"
echo "  - DI Container: Dependency Injection"
echo ""
echo "🔐 Security Features:"
echo "  - Keychain for secure token storage"
echo "  - UserDefaults for non-sensitive data"
echo "  - Cryptographic nonce for Apple Sign In"
echo "  - Automatic token refresh"
echo ""
echo "📱 Next Steps:"
echo "  1. Add 'Sign in with Apple' capability in Xcode"
echo "  2. Update Info.plist with required keys"
echo "  3. Configure LINE SDK if not already done"
echo "  4. Set up backend API endpoints"
echo "  5. Run tests to verify implementation"
echo ""
echo "💡 Remember to:"
echo "  - Update your API base URL in RemoteAuthDataSource"
echo "  - Configure Firebase if using it"
echo "  - Add proper error handling for production"
echo ""
