//
//  LoginView.swift
//  U&Me
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showEmailLogin = false
    
    var body: some View {
        VStack(spacing: 32) {
            
            Spacer()
            
            // Logo
            VStack(spacing: 16) {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.pink)
                
                Text("Welcome to U&Me")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("ยินดีต้อนรับสู่ U&Me")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                
                // Google Sign In Button
                Button {
                    Task {
                        await authViewModel.signInWithGoogleTapped()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "g.circle.fill")
                            .font(.title3)
                        Text("Continue with Google")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .disabled(authViewModel.isLoading)
                
                // Email Sign In Button
                Button {
                    showEmailLogin = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .font(.title3)
                        Text("Continue with Email")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(authViewModel.isLoading)
                
                // OR Divider
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    
                    Text("or")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.vertical, 8)
                
                // LINE Login Button
                Button {
                    Task {
                        await authViewModel.loginWithLINE()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "message.fill")
                            .font(.title3)
                        Text("Continue with LINE")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "00B900"))  // ← This still works because Colors.swift has the extension
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(authViewModel.isLoading)
                .opacity(authViewModel.isLoading ? 0.6 : 1.0)
            }
            .padding(.horizontal, 24)
            
            // Loading indicator
            if authViewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.pink)
                    .padding(.top)
            }
            
            // Error message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Terms
            Text("By continuing, you agree to our Terms & Privacy Policy")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 24)
        .sheet(isPresented: $showEmailLogin) {
            EmailLoginView()
        }
        .alert("Link Account?", isPresented: $authViewModel.showAccountLinkingDialog) {
            Button("Link Accounts") {
                authViewModel.linkAccountsTapped()
            }
            Button("Cancel", role: .cancel) {
                authViewModel.cancelLinkingTapped()
            }
        } message: {
            Text("An account with this email already exists. Would you like to link your accounts?")
        }
    }
}

// REMOVE THIS ENTIRE SECTION - IT'S A DUPLICATE!
/*
extension Color {
    init(hex: String) {
        // ... duplicate code ...
    }
}
*/

#Preview {
    LoginView()
        .environmentObject(AuthViewModel.shared)
}
