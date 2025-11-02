//
//  APIConfig.swift
//  U&Me
//

import Foundation

struct APIConfig {
    
    // MARK: - Base URLs
    
    #if DEBUG
    // For Simulator: Use localhost
    // For Real iPhone: Use your Mac's IP address
    private static let host = "172.22.196.1"  // Your Mac's IP
    static let baseURL = "http://\(host):3000/v1"
    #else
    static let baseURL = "https://api.u-and-me.app/v1"
    #endif
    
    // MARK: - Endpoints
    
    enum Endpoint {
        case findUserByProvider(provider: String, providerId: String)
        case findUserByEmail(email: String)
        case createUser
        case updateUser(userId: String)
        case linkProvider(userId: String)
        case validateToken
        case refreshToken
        
        var path: String {
            switch self {
            case .findUserByProvider(let provider, let providerId):
                return "/users/provider/\(provider)/\(providerId)"
            case .findUserByEmail(let email):
                return "/users/email/\(email)"
            case .createUser:
                return "/users"
            case .updateUser(let userId):
                return "/users/\(userId)"
            case .linkProvider(let userId):
                return "/users/\(userId)/link"
            case .validateToken:
                return "/auth/validate"
            case .refreshToken:
                return "/auth/refresh"
            }
        }
        
        var url: URL {
            URL(string: baseURL + path)!
        }
    }
    
    // MARK: - Configuration
    
    static var isLocalhost: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var timeout: TimeInterval {
        return 30.0
    }
}