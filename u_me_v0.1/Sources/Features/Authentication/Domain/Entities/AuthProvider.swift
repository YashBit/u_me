//
//  AuthProvider.swift
//  U&Me
//

import Foundation

enum AuthProvider: String, Codable, CaseIterable {
    case apple = "apple"
    case line = "line"
    case email = "email"
    case google = "google"
    case phone = "phone"
    
    var displayName: String {
        switch self {
        case .apple: return "Apple"
        case .line: return "LINE"
        case .email: return "Email"
        case .google: return "Google"
        case .phone: return "Phone"
        }
    }
    
    var iconName: String {
        switch self {
        case .apple: return "applelogo"
        case .line: return "message.fill"
        case .email: return "envelope.fill"
        case .google: return "g.circle.fill"
        case .phone: return "phone.fill"
        }
    }
}
