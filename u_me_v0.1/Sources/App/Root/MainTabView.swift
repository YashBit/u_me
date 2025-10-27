//
//  MainTabView.swift
//  U&Me
//
//  Main app interface after authentication
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            // Home/Feed Tab
            NavigationView {
                VStack(spacing: 20) {
                    if let user = authViewModel.currentUser {
                        AsyncImage(url: user.profilePhotoURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        
                        Text("Hello, \(user.displayName)!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Welcome to U&Me")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Logout") {
                        authViewModel.logout()
                    }
                    .foregroundColor(.red)
                }
                .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            // Profile Tab
            NavigationView {
                Text("Profile")
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            
            // Settings Tab
            NavigationView {
                List {
                    Button("Logout") {
                        authViewModel.logout()
                    }
                    .foregroundColor(.red)
                }
                .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel.shared)
}
