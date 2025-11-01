//
//  EmailAuthService.swift
//  U&Me
//

import Foundation

@MainActor
final class EmailAuthService {
    
    static let shared = EmailAuthService()
    
    private init() {}
    
    // Sign in with email/password
    func signIn(email: String, password: String) async throws -> AuthCredentials {
        print("📧 ========================================")
        print("📧 EmailAuthService.signIn() called")
        print("📧 ========================================")
        print("📧 Email: \(email)")
        
        // Validate email format
        guard isValidEmail(email) else {
            print("❌ Invalid email format")
            throw AuthError.invalidCredentials
        }
        
        // Validate password length
        guard password.count >= 6 else {
            print("❌ Password too short (minimum 6 characters)")
            throw AuthError.weakPassword
        }
        
        // TODO: Replace with real backend API call
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // TODO: Call your backend
        // let response = try await networkService.post("/auth/login", body: [
        //     "email": email,
        //     "password": password
        // ])
        
        print("✅ Email sign in successful")
        
        return AuthCredentials.email(email: email, password: password)
    }
    
    // Sign up with email/password
    func signUp(email: String, password: String, displayName: String?) async throws -> AuthCredentials {
        print("📧 ========================================")
        print("📧 EmailAuthService.signUp() called")
        print("📧 ========================================")
        print("📧 Email: \(email)")
        print("📧 Display Name: \(displayName ?? "not provided")")
        
        // Validate email format
        guard isValidEmail(email) else {
            print("❌ Invalid email format")
            throw AuthError.invalidCredentials
        }
        
        // Validate password length
        guard password.count >= 6 else {
            print("❌ Password too short (minimum 6 characters)")
            throw AuthError.weakPassword
        }
        
        // TODO: Replace with real backend API call
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // TODO: Call your backend
        // let response = try await networkService.post("/auth/signup", body: [
        //     "email": email,
        //     "password": password,
        //     "displayName": displayName
        // ])
        
        print("✅ Email sign up successful")
        
        return AuthCredentials.email(email: email, password: password)
    }
    
    // Email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
