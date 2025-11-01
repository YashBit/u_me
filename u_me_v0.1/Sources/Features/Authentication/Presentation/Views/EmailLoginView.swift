//
//  EmailLoginView.swift
//  U&Me
//

import SwiftUI

struct EmailLoginView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpMode = false
    @State private var displayName = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "envelope.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                        
                        Text(isSignUpMode ? "Create Account" : "Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(isSignUpMode ? "Sign up with email to get started" : "Sign in with email to continue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 16) {
                        
                        // Display Name (Sign Up only)
                        if isSignUpMode {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Display Name")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                TextField("Your name (optional)", text: $displayName)
                                    .textContentType(.name)
                                    .autocapitalization(.words)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField("your.email@example.com", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            SecureField("Enter your password", text: $password)
                                .textContentType(isSignUpMode ? .newPassword : .password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            
                            if isSignUpMode {
                                Text("• At least 6 characters")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Submit Button
                    Button {
                        Task {
                            if isSignUpMode {
                                await authViewModel.signUpWithEmail(
                                    email: email,
                                    password: password,
                                    displayName: displayName.isEmpty ? nil : displayName
                                )
                            } else {
                                await authViewModel.signInWithEmail(
                                    email: email,
                                    password: password
                                )
                            }
                        }
                    } label: {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(isSignUpMode ? "Create Account" : "Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || authViewModel.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // Toggle Sign In/Sign Up
                    Button {
                        withAnimation {
                            isSignUpMode.toggle()
                            // Clear form when switching modes
                            password = ""
                        }
                    } label: {
                        Text(isSignUpMode ? "Already have an account? **Sign In**" : "Don't have an account? **Sign Up**")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                    
                    // Error message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && password.count >= 6
    }
}

#Preview {
    EmailLoginView()
        .environmentObject(AuthViewModel.shared)
}
