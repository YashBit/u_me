//
//  AuthViewModel.swift
//  U&Me
//
//  Manages authentication state
//

import Foundation
import SwiftUI

// MARK: - Simple User Model

struct SimpleUser: Identifiable, Codable {
    let id: String
    let displayName: String
    let profilePhotoURL: URL?
}

// MARK: - Auth ViewModel

@MainActor
final class AuthViewModel: ObservableObject {
    
    static let shared = AuthViewModel()
    
    // MARK: - Published State
    @Published var isAuthenticated = false
    @Published var currentUser: SimpleUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let lineAuthService = LINEAuthService.shared
    
    private init() {
        checkAuthStatus()
    }
    
    // MARK: - Public Methods
    
    /// Login with LINE
    func loginWithLINE() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let lineProfile = try await lineAuthService.login()
            
            // Convert LINE profile to our User model
            self.currentUser = SimpleUser(
                id: lineProfile.userID,
                displayName: lineProfile.displayName,
                profilePhotoURL: lineProfile.pictureURL
            )
            self.isAuthenticated = true
            
        } catch let error as LINEAuthError {
            if case .userCancelled = error {
                // User cancelled - don't show error
                print("User cancelled LINE login")
            } else {
                self.errorMessage = error.localizedDescription
            }
        } catch {
            self.errorMessage = "Login failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Logout
    func logout() {
        lineAuthService.logout()
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    /// Check if already logged in
    private func checkAuthStatus() {
        self.isAuthenticated = lineAuthService.isLoggedIn
    }
}
