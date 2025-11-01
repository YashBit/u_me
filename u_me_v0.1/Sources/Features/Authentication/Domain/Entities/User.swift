//
//  User.swift
//  U&Me
//
//  Core User entity with multi-provider support
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var displayName: String
    var profilePhotoURL: URL?
    var email: String?
    var phoneNumber: String?
    
    // Authentication tracking
    var primaryProvider: AuthProvider
    var linkedProviders: [AuthProvider]
    var providerIDs: [AuthProvider: String]
    
    // Provider-specific data
    var appleUserID: String?
    var lineUserID: String?
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var lastLoginAt: Date
    var lastLoginProvider: AuthProvider?
    
    // Onboarding
    var onboardingCompleted: Bool
    
    // Thai market specific
    var preferredLanguage: String
    var countryCode: String
    
    // Creator specific
    var isCreator: Bool
    var creatorProfile: CreatorProfile?
    
    // Computed property for backward compatibility
    var profileImageURL: URL? {
        get { profilePhotoURL }
        set { profilePhotoURL = newValue }
    }
    
    // Custom initializer to provide defaults
    init(
        id: String,
        displayName: String,
        email: String? = nil,
        profilePhotoURL: URL? = nil,
        phoneNumber: String? = nil,
        primaryProvider: AuthProvider,
        linkedProviders: [AuthProvider],
        providerIDs: [AuthProvider: String],
        appleUserID: String? = nil,
        lineUserID: String? = nil,
        createdAt: Date,
        updatedAt: Date,
        lastLoginAt: Date,
        lastLoginProvider: AuthProvider? = nil,
        onboardingCompleted: Bool = false,
        preferredLanguage: String = "th",
        countryCode: String = "TH",
        isCreator: Bool = false,
        creatorProfile: CreatorProfile? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.profilePhotoURL = profilePhotoURL
        self.phoneNumber = phoneNumber
        self.primaryProvider = primaryProvider
        self.linkedProviders = linkedProviders
        self.providerIDs = providerIDs
        self.appleUserID = appleUserID
        self.lineUserID = lineUserID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastLoginAt = lastLoginAt
        self.lastLoginProvider = lastLoginProvider
        self.onboardingCompleted = onboardingCompleted
        self.preferredLanguage = preferredLanguage
        self.countryCode = countryCode
        self.isCreator = isCreator
        self.creatorProfile = creatorProfile
    }
}

struct CreatorProfile: Codable, Equatable {
    let creatorId: String
    var followerCount: Int
    var verificationStatus: VerificationStatus
    var categories: [String]
}

enum VerificationStatus: String, Codable {
    case unverified
    case pending
    case verified
}
