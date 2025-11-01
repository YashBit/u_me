//
//  UserRepositoryProtocol.swift
//  U&Me
//
//  User data repository interface
//

import Foundation
import Combine

protocol UserRepositoryProtocol {
    var currentUserPublisher: AnyPublisher<User?, Never> { get }
    func getCurrentUser() async throws -> User?
    func saveCurrentUser(_ user: User) async throws
    func deleteCurrentUser() async throws
}
