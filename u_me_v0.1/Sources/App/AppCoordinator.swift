// Sources/App/Navigation/AppCoordinator.swift
import SwiftUI

class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    func navigateToAuthentication() {
        // Handle auth flow
    }
    
    func navigateToHome() {
        // Handle home navigation
    }
}

// Temporary User model
struct User {
    let id: String
    let name: String
}
