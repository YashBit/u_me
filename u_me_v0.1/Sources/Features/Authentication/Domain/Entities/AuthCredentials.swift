//
//  AuthCredentials.swift
//  U&Me
//

import Foundation

enum AuthCredentials {
    case apple(userId: String, email: String?, idToken: String, fullName: PersonNameComponents?)
    case line(userId: String, displayName: String, pictureURL: URL?, accessToken: String)
    case email(email: String, password: String)
    case google(userId: String, email: String?, idToken: String, displayName: String?)
    
    var provider: AuthProvider {
        switch self {
        case .apple:
            return .apple
        case .line:
            return .line
        case .email:
            return .email
        case .google:
            return .google
        }
    }
    
    var userId: String {
        switch self {
        case .apple(let userId, _, _, _):
            return userId
        case .line(let userId, _, _, _):
            return userId
        case .email(let email, _):
            return email
        case .google(let userId, _, _, _):
            return userId
        }
    }
    
    var email: String? {
        switch self {
        case .apple(_, let email, _, _):
            return email
        case .line:
            return nil
        case .email(let email, _):
            return email
        case .google(_, let email, _, _):
            return email
        }
    }
    
    var displayName: String? {
        switch self {
        case .apple(_, _, _, let fullName):
            if let givenName = fullName?.givenName {
                return givenName + (fullName?.familyName.map { " " + $0 } ?? "")
            }
            return nil
        case .line(_, let displayName, _, _):
            return displayName
        case .email:
            return nil
        case .google(_, _, _, let displayName):
            return displayName
        }
    }
}
