//
//  UserRepository.swift
//  U&Me
//
//  Concrete implementation of user repository
//

import Foundation
import Combine

final class UserRepository: UserRepositoryProtocol {
    @Published private var currentUser: User?
    
    var currentUserPublisher: AnyPublisher<User?, Never> {
        $currentUser.eraseToAnyPublisher()
    }
    
    private let localDataSource: LocalAuthDataSource
    
    init(localDataSource: LocalAuthDataSource) {
        self.localDataSource = localDataSource
        Task {
            self.currentUser = try? await localDataSource.getCurrentUser()
        }
    }
    
    func getCurrentUser() async throws -> User? {
        return try await localDataSource.getCurrentUser()
    }
    
    func saveCurrentUser(_ user: User) async throws {
        try await localDataSource.saveUser(user)
        await MainActor.run {
            self.currentUser = user
        }
    }
    
    func deleteCurrentUser() async throws {
        try await localDataSource.deleteCurrentUser()
        await MainActor.run {
            self.currentUser = nil
        }
    }
}
