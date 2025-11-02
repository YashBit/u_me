//
//  RemoteAuthDataSource.swift
//  U&Me
//
//  Remote API data source for authentication
//

import Foundation

final class RemoteAuthDataSource {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    // MARK: - Find User by Provider ID
    
    func findUserByProviderId(_ providerId: String, provider: AuthProvider) async throws -> User? {
        print("🌐 RemoteAuthDataSource.findUserByProviderId()")
        print("   Provider: \(provider.rawValue)")
        print("   Provider ID: \(providerId)")
        
        let endpoint = APIConfig.Endpoint.findUserByProvider(
            provider: provider.rawValue,
            providerId: providerId
        ).url.absoluteString
        
        print("   URL: \(endpoint)")
        
        do {
            let user: User = try await networkService.request(
                endpoint: endpoint,
                method: .get
            )
            
            print("✅ User found remotely: \(user.id)")
            return user
            
        } catch NetworkError.notFound {
            // ✅ 404 is expected for new users - return nil so SignInUseCase can create user
            print("ℹ️ User not found (404) - will create new user")
            return nil
            
        } catch let error as NetworkError {
            print("❌ Network error: \(error.localizedDescription)")
            throw AuthError.networkError(error)
            
        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Find User by Email
    
    func findUserByEmail(_ email: String) async throws -> User? {
        print("🌐 RemoteAuthDataSource.findUserByEmail()")
        print("   Email: \(email)")
        
        let endpoint = APIConfig.Endpoint.findUserByEmail(email: email).url.absoluteString
        print("   URL: \(endpoint)")
        
        do {
            let user: User = try await networkService.request(
                endpoint: endpoint,
                method: .get
            )
            
            print("✅ User found by email: \(user.id)")
            return user
            
        } catch NetworkError.notFound {
            print("ℹ️ User not found by email (404)")
            return nil
            
        } catch {
            print("❌ Error finding user by email: \(error.localizedDescription)")
            // Return nil instead of throwing for email lookups
            return nil
        }
    }
    
    // MARK: - Create User
    
    func createUser(_ user: User, credentials: AuthCredentials) async throws -> User {
        print("🌐 RemoteAuthDataSource.createUser()")
        print("   Email: \(user.email ?? "N/A")")
        print("   Display Name: \(user.displayName)")
        print("   Provider: \(credentials.provider.rawValue)")
        
        let endpoint = APIConfig.Endpoint.createUser.url.absoluteString
        print("   URL: \(endpoint)")
        
        // Create request body matching User model property names
        var requestBody: [String: Any] = [
            "email": user.email ?? "",
            "displayName": user.displayName,
            "authProvider": credentials.provider.rawValue,
            "providerUserId": credentials.userId,
            "preferredLanguage": user.preferredLanguage,
            "countryCode": user.countryCode
        ]
        
        // Add optional profile photo URL if present
        if let profilePhotoURL = user.profilePhotoURL {
            requestBody["profilePhotoURL"] = profilePhotoURL.absoluteString
        }
        
        // Add phone number if present
        if let phoneNumber = user.phoneNumber {
            requestBody["phoneNumber"] = phoneNumber
        }
        
        if let bodyData = try? JSONSerialization.data(withJSONObject: requestBody),
           let bodyString = String(data: bodyData, encoding: .utf8) {
            print("   Request body: \(bodyString)")
        }
        
        do {
            let createdUser: User = try await networkService.request(
                endpoint: endpoint,
                method: .post,
                body: requestBody
            )
            
            print("✅ User created remotely: \(createdUser.id)")
            return createdUser
            
        } catch let error as NetworkError {
            print("❌ Network error creating user: \(error.localizedDescription)")
            throw AuthError.networkError(error)
            
        } catch {
            print("❌ Error creating user: \(error.localizedDescription)")
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Update User
    
    func updateUser(_ user: User) async throws -> User {
        print("🌐 RemoteAuthDataSource.updateUser()")
        print("   User ID: \(user.id)")
        
        let endpoint = APIConfig.Endpoint.updateUser(userId: user.id).url.absoluteString
        print("   URL: \(endpoint)")
        
        // Create request body with updatable fields
        var requestBody: [String: Any] = [:]
        
        requestBody["displayName"] = user.displayName
        
        if let profilePhotoURL = user.profilePhotoURL {
            requestBody["profilePhotoURL"] = profilePhotoURL.absoluteString
        }
        
        if let phoneNumber = user.phoneNumber {
            requestBody["phoneNumber"] = phoneNumber
        }
        
        requestBody["preferredLanguage"] = user.preferredLanguage
        requestBody["countryCode"] = user.countryCode
        requestBody["isCreator"] = user.isCreator
        
        do {
            let updatedUser: User = try await networkService.request(
                endpoint: endpoint,
                method: .patch,
                body: requestBody
            )
            
            print("✅ User updated remotely")
            return updatedUser
            
        } catch let error as NetworkError {
            print("❌ Network error updating user: \(error.localizedDescription)")
            throw AuthError.networkError(error)
            
        } catch {
            print("❌ Error updating user: \(error.localizedDescription)")
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Link Provider
    
    func linkProvider(user: User, credentials: AuthCredentials) async throws -> User {
        print("🌐 RemoteAuthDataSource.linkProvider()")
        print("   User ID: \(user.id)")
        print("   Provider: \(credentials.provider.rawValue)")
        
        let endpoint = APIConfig.Endpoint.linkProvider(userId: user.id).url.absoluteString
        print("   URL: \(endpoint)")
        
        let requestBody: [String: Any] = [
            "provider": credentials.provider.rawValue,
            "providerId": credentials.userId
        ]
        
        do {
            // Link the provider
            let _: [String: Bool] = try await networkService.request(
                endpoint: endpoint,
                method: .post,
                body: requestBody
            )
            
            print("✅ Provider linked")
            
            // Fetch the updated user
            if let linkedUser = try await findUserByProviderId(credentials.userId, provider: credentials.provider) {
                return linkedUser
            } else {
                // If we can't fetch, return the original user
                print("⚠️ Couldn't fetch updated user after linking")
                return user
            }
            
        } catch let error as NetworkError {
            print("❌ Network error linking provider: \(error.localizedDescription)")
            throw AuthError.networkError(error)
            
        } catch {
            print("❌ Error linking provider: \(error.localizedDescription)")
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Validate Token (Optional - can be removed if not used)
    
    func validateToken(_ token: String) async throws -> Bool {
        print("🌐 RemoteAuthDataSource.validateToken() - Not implemented")
        // This can be implemented later when you have token validation
        return true
    }
    
    // MARK: - Refresh Tokens (Optional - can be removed if not used)
    
    func refreshTokens(_ refreshToken: String) async throws -> TokenPair {
        print("🌐 RemoteAuthDataSource.refreshTokens() - Not implemented")
        // This can be implemented later when you have token refresh
        throw AuthError.notImplemented
    }
}
