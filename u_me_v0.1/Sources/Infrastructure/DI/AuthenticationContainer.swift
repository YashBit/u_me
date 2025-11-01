//
//  AuthenticationContainer.swift
//  U&Me
//
//  Dependency injection container for authentication
//

import Foundation

@MainActor
final class AuthenticationContainer {
    
    // MARK: - Services
    lazy var keychainService = KeychainService.shared
    lazy var networkService = NetworkService()
    lazy var appleSignInService = AppleSignInService.shared
    lazy var lineAuthService = LINEAuthService.shared
    lazy var emailAuthService = EmailAuthService.shared      // ← ADDED
    lazy var googleAuthService = GoogleAuthService.shared    // ← ADDED
    
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
            lineAuthService: lineAuthService,
            emailAuthService: emailAuthService,      // ← ADDED
            googleAuthService: googleAuthService     // ← ADDED
        )
    }
}
