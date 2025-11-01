//
//  AuthRepositoryProtocol.swift
//  U&Me
//
//
//  AuthRepositoryProtocol.swift
//  U&Me
//

import Foundation

protocol AuthRepositoryProtocol {
    func findUser(byProviderId providerId: String, provider: AuthProvider) async throws -> User?
    func findUser(byEmail email: String) async throws -> User?
    func createUser(_ user: User, with credentials: AuthCredentials) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func linkProvider(_ user: User, credentials: AuthCredentials) async throws -> User
    //               ↑ ADDED UNDERSCORE - no label needed
}
