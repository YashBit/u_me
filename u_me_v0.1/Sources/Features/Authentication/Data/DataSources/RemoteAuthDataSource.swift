//
//  RemoteAuthDataSource.swift
//  U&Me
//
//  Remote API data source for authentication
//

import Foundation

final class RemoteAuthDataSource {
    private let networkService: NetworkService
    private let baseURL = "https://api.u-and-me.app/v1"
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func findUserByProviderId(_ providerId: String, provider: AuthProvider) async throws -> User? {
        let endpoint = "\(baseURL)/users/provider/\(provider.rawValue)/\(providerId)"
        return try await networkService.request(endpoint: endpoint, method: .get)
    }
    
    func findUserByEmail(_ email: String) async throws -> User? {
        let endpoint = "\(baseURL)/users/email/\(email)"
        return try await networkService.request(endpoint: endpoint, method: .get)
    }
    
    func createUser(_ user: User, credentials: AuthCredentials) async throws -> User {
        let endpoint = "\(baseURL)/auth/signup"
        let request = SignUpRequest(user: user, credentials: credentials)
        let response: SignUpResponse = try await networkService.request(
            endpoint: endpoint,
            method: .post,
            body: request
        )
        return response.user
    }
    
    func updateUser(_ user: User) async throws -> User {
        let endpoint = "\(baseURL)/users/\(user.id)"
        return try await networkService.request(
            endpoint: endpoint,
            method: .put,
            body: user
        )
    }
    
    func linkProvider(user: User, credentials: AuthCredentials) async throws -> User {
        let endpoint = "\(baseURL)/auth/link"
        let request = LinkProviderRequest(userId: user.id, credentials: credentials)
        let response: LinkProviderResponse = try await networkService.request(
            endpoint: endpoint,
            method: .post,
            body: request
        )
        return response.user
    }
    
    func validateToken(_ token: String) async throws -> Bool {
        let endpoint = "\(baseURL)/auth/validate"
        let response: ValidationResponse = try await networkService.request(
            endpoint: endpoint,
            method: .post,
            headers: ["Authorization": "Bearer \(token)"]
        )
        return response.isValid
    }
    
    func refreshTokens(_ refreshToken: String) async throws -> TokenPair {
        let endpoint = "\(baseURL)/auth/refresh"
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let response: TokenResponse = try await networkService.request(
            endpoint: endpoint,
            method: .post,
            body: request
        )
        return TokenPair(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
    }
}
