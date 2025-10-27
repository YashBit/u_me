//
//  LoginView.swift
//  U&Me
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
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
            
            // LINE Login Button
            Button {
                Task {
                    await authViewModel.loginWithLINE()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "message.fill")
                        .font(.title3)
                    Text("Sign in with LINE")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(hex: "00B900"))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(authViewModel.isLoading)
            .opacity(authViewModel.isLoading ? 0.6 : 1.0)
            
            // Loading indicator
            if authViewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.green)
            }
            
            // Error message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Terms
            Text("By signing in, you agree to our Terms & Privacy Policy")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(24)
    }
}

