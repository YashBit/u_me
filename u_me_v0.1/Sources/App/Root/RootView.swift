//
//  RootView.swift
//  U&Me
//
//  Root view handling authentication routing
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel.shared)
}
