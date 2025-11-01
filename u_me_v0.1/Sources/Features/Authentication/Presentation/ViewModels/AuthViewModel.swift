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
    
    // MARK: - Singleton
    static let shared: AuthViewModel = {
        let container = AuthenticationContainer()
        return AuthViewModel(
            signInUseCase: container.signInUseCase,
            linkAccountUseCase: container.linkAccountUseCase,
            userRepository: container.userRepository,
            appleSignInService: container.appleSignInService,
            lineAuthService: container.lineAuthService,
            emailAuthService: container.emailAuthService,
            googleAuthService: container.googleAuthService
        )
    }()
    
    // MARK: - Published State
    @Published var viewState: AuthViewState = .idle
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var showAccountLinkingDialog = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // MARK: - View State
    enum AuthViewState: Equatable {
        case idle
        case loading
        case authenticated(User)
        case requiresOnboarding(User)
        case requiresLinking(existingUser: User, newProvider: AuthProvider)
        case error(String)
        
        static func == (lhs: AuthViewState, rhs: AuthViewState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading):
                return true
            case (.authenticated(let user1), .authenticated(let user2)):
                return user1.id == user2.id
            case (.requiresOnboarding(let user1), .requiresOnboarding(let user2)):
                return user1.id == user2.id
            case (.requiresLinking(let user1, let provider1), .requiresLinking(let user2, let provider2)):
                return user1.id == user2.id && provider1 == provider2
            case (.error(let msg1), .error(let msg2)):
                return msg1 == msg2
            default:
                return false
            }
        }
    }
    
    // MARK: - Dependencies
    private let signInUseCase: SignInUseCaseProtocol
    private let linkAccountUseCase: LinkAccountUseCaseProtocol
    private let userRepository: UserRepositoryProtocol
    private let appleSignInService: AppleSignInService
    private let lineAuthService: LINEAuthService
    private let emailAuthService: EmailAuthService
    private let googleAuthService: GoogleAuthService
    
    private var pendingLinkingCredentials: AuthCredentials?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(signInUseCase: SignInUseCaseProtocol,
         linkAccountUseCase: LinkAccountUseCaseProtocol,
         userRepository: UserRepositoryProtocol,
         appleSignInService: AppleSignInService,
         lineAuthService: LINEAuthService,
         emailAuthService: EmailAuthService,
         googleAuthService: GoogleAuthService) {
        self.signInUseCase = signInUseCase
        self.linkAccountUseCase = linkAccountUseCase
        self.userRepository = userRepository
        self.appleSignInService = appleSignInService
        self.lineAuthService = lineAuthService
        self.emailAuthService = emailAuthService
        self.googleAuthService = googleAuthService
        
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
        
        // Update isLoading based on viewState
        $viewState
            .map { state in
                if case .loading = state {
                    return true
                }
                return false
            }
            .assign(to: &$isLoading)
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
    
    // MARK: - View Actions - Apple
    func signInWithAppleTapped() {
        Task {
            await performAppleSignIn()
        }
    }
    
    // MARK: - View Actions - LINE
    func signInWithLINETapped() {
        Task {
            await performLINESignIn()
        }
    }
    
    func loginWithLINE() async {
        await performLINESignIn()
    }
    
    // MARK: - View Actions - Email
    func signInWithEmail(email: String, password: String) async {
        print("📧 AuthViewModel.signInWithEmail() called")
        viewState = .loading
        errorMessage = nil
        
        do {
            let emailCredentials = try await emailAuthService.signIn(email: email, password: password)
            let result = await signInUseCase.execute(with: emailCredentials)
            await handleAuthResult(result, credentials: emailCredentials)
        } catch {
            handleError(error)
        }
    }
    
    func signUpWithEmail(email: String, password: String, displayName: String?) async {
        print("📧 AuthViewModel.signUpWithEmail() called")
        viewState = .loading
        errorMessage = nil
        
        do {
            let emailCredentials = try await emailAuthService.signUp(email: email, password: password, displayName: displayName)
            let result = await signInUseCase.execute(with: emailCredentials)
            await handleAuthResult(result, credentials: emailCredentials)
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - View Actions - Google
    func signInWithGoogleTapped() {
        Task {
            await performGoogleSignIn()
        }
    }
    
    // MARK: - View Actions - Account Management
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
            googleAuthService.signOut()
            currentUser = nil
            isAuthenticated = false
            viewState = .idle
        }
    }
    
    func logout() {
        signOutTapped()
    }
    
    // MARK: - Private Methods - Apple
    private func performAppleSignIn() async {
        print("🍎 AuthViewModel.performAppleSignIn() called")
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
    
    // MARK: - Private Methods - LINE
    private func performLINESignIn() async {
        print("📱 AuthViewModel.performLINESignIn() called")
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
    
    // MARK: - Private Methods - Google
    private func performGoogleSignIn() async {
        print("🔴 AuthViewModel.performGoogleSignIn() called")
        viewState = .loading
        errorMessage = nil
        
        do {
            let googleCredentials = try await googleAuthService.signIn()
            let result = await signInUseCase.execute(with: googleCredentials)
            await handleAuthResult(result, credentials: googleCredentials)
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Methods - Common
    private func handleAuthResult(_ result: AuthResult, credentials: AuthCredentials? = nil) async {
        switch result {
        case .success(let user):
            print("✅ Auth successful - User authenticated")
            currentUser = user
            isAuthenticated = true
            viewState = .authenticated(user)
            errorMessage = nil
            
        case .requiresOnboarding(let user):
            print("ℹ️ Auth successful - Requires onboarding")
            currentUser = user
            isAuthenticated = true
            viewState = .requiresOnboarding(user)
            
        case .requiresLinking(let existingUser, let newCredentials):
            print("⚠️ Auth requires account linking")
            pendingLinkingCredentials = credentials ?? newCredentials
            viewState = .requiresLinking(
                existingUser: existingUser,
                newProvider: newCredentials.provider
            )
            showAccountLinkingDialog = true
            
        case .failure(let error):
            print("❌ Auth failed: \(error.localizedDescription)")
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
        print("⚠️ AuthViewModel.handleError() called")
        print("   Error: \(error.localizedDescription)")
        
        if let authError = error as? AuthError,
           case .userCancelled = authError {
            print("   → User cancelled, returning to idle state")
            viewState = .idle
        } else {
            print("   → Setting error state")
            viewState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
}
