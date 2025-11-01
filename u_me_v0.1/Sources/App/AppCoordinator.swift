// Sources/App/Navigation/AppCoordinator.swift
import SwiftUI

class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?  // This will now use the real User from Authentication
    
    func navigateToAuthentication() {
        // Handle auth flow
    }
    
    func navigateToHome() {
        // Handle home navigation
    }
}

// DELETE THESE LINES - Remove the temporary User model
// struct User {
//     let id: String
//     let name: String
// }
