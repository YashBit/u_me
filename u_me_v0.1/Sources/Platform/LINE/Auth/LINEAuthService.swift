//
//  LINEAuthService.swift
//  U&Me
//

import Foundation
import LineSDK
import UIKit

enum LINEAuthError: Error {
    case userCancelled
    case noActiveWindow
    case profileRetrievalFailed
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .userCancelled:
            return "User cancelled LINE login"
        case .noActiveWindow:
            return "No active window found"
        case .profileRetrievalFailed:
            return "Failed to retrieve LINE profile"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

final class LINEAuthService {
    
    static let shared = LINEAuthService()
    
    private init() {}
    
    func login() async throws -> LINEUserProfile {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = windowScene.windows.first?.rootViewController else {
                    continuation.resume(throwing: LINEAuthError.noActiveWindow)
                    return
                }
                
                LoginManager.shared.login(
                    permissions: [.profile],
                    in: rootViewController
                ) { result in
                    switch result {
                    case .success:
                        // Login successful, get profile
                        self.getProfile { profileResult in
                            switch profileResult {
                            case .success(let profile):
                                continuation.resume(returning: profile)
                            case .failure(let error):
                                continuation.resume(throwing: LINEAuthError.unknown(error))
                            }
                        }
                        
                    case .failure(let error):
                        // Handle LINE SDK errors
                        let errorDescription = error.localizedDescription.lowercased()
                        
                        if errorDescription.contains("cancel") ||
                           errorDescription.contains("cancelled") {
                            continuation.resume(throwing: LINEAuthError.userCancelled)
                        } else {
                            continuation.resume(throwing: LINEAuthError.unknown(error))
                        }
                    }
                }
            }
        }
    }
    
    private func getProfile(completion: @escaping (Result<LINEUserProfile, Error>) -> Void) {
        API.getProfile { result in
            switch result {
            case .success(let profile):
                let userProfile = LINEUserProfile(
                    userID: profile.userID,
                    displayName: profile.displayName,
                    pictureURL: profile.pictureURL
                )
                completion(.success(userProfile))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout() {
        LoginManager.shared.logout { _ in }
    }
    
    var isLoggedIn: Bool {
        return LoginManager.shared.isAuthorized
    }
}

struct LINEUserProfile {
    let userID: String
    let displayName: String
    let pictureURL: URL?
}
