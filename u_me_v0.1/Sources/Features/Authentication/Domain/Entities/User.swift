//
//  User.swift
//  U&Me
//
//  Core User entity with multi-provider support
//

import Foundation

struct User: Identifiable, Equatable {
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
    
    // MARK: - Regular Initializer
    
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

// MARK: - Codable Conformance

extension User: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case profilePhotoURL
        case email
        case phoneNumber
        case primaryProvider
        case linkedProviders
        case providerIDs
        case appleUserID
        case lineUserID
        case createdAt
        case updatedAt
        case lastLoginAt
        case lastLoginProvider
        case onboardingCompleted
        case preferredLanguage
        case countryCode
        case isCreator
        case creatorProfile
    }
    
    // MARK: - Custom Decoding
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        displayName = try container.decode(String.self, forKey: .displayName)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        
        // Decode URL from string
        if let urlString = try container.decodeIfPresent(String.self, forKey: .profilePhotoURL),
           !urlString.isEmpty {
            profilePhotoURL = URL(string: urlString)
        } else {
            profilePhotoURL = nil
        }
        
        primaryProvider = try container.decode(AuthProvider.self, forKey: .primaryProvider)
        linkedProviders = try container.decode([AuthProvider].self, forKey: .linkedProviders)
        
        // ✅ FIX: Decode providerIDs from [String: String] to [AuthProvider: String]
        let providerIDsDict = try container.decode([String: String].self, forKey: .providerIDs)
        var convertedProviderIDs: [AuthProvider: String] = [:]
        for (key, value) in providerIDsDict {
            if let provider = AuthProvider(rawValue: key) {
                convertedProviderIDs[provider] = value
            }
        }
        providerIDs = convertedProviderIDs
        
        appleUserID = try container.decodeIfPresent(String.self, forKey: .appleUserID)
        lineUserID = try container.decodeIfPresent(String.self, forKey: .lineUserID)
        
        // Decode dates from ISO8601 strings
        let dateFormatter = ISO8601DateFormatter()
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt),
           let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = Date()
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt),
           let date = dateFormatter.date(from: updatedAtString) {
            updatedAt = date
        } else {
            updatedAt = Date()
        }
        
        if let lastLoginString = try? container.decode(String.self, forKey: .lastLoginAt),
           let date = dateFormatter.date(from: lastLoginString) {
            lastLoginAt = date
        } else {
            lastLoginAt = Date()
        }
        
        lastLoginProvider = try container.decodeIfPresent(AuthProvider.self, forKey: .lastLoginProvider)
        onboardingCompleted = try container.decode(Bool.self, forKey: .onboardingCompleted)
        preferredLanguage = try container.decode(String.self, forKey: .preferredLanguage)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        isCreator = try container.decode(Bool.self, forKey: .isCreator)
        creatorProfile = try container.decodeIfPresent(CreatorProfile.self, forKey: .creatorProfile)
    }
    
    // MARK: - Custom Encoding
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(displayName, forKey: .displayName)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(profilePhotoURL?.absoluteString, forKey: .profilePhotoURL)
        try container.encode(primaryProvider, forKey: .primaryProvider)
        try container.encode(linkedProviders, forKey: .linkedProviders)
        
        // ✅ FIX: Encode providerIDs from [AuthProvider: String] to [String: String]
        var providerIDsDict: [String: String] = [:]
        for (provider, id) in providerIDs {
            providerIDsDict[provider.rawValue] = id
        }
        try container.encode(providerIDsDict, forKey: .providerIDs)
        
        try container.encodeIfPresent(appleUserID, forKey: .appleUserID)
        try container.encodeIfPresent(lineUserID, forKey: .lineUserID)
        
        // Encode dates as ISO8601 strings
        let dateFormatter = ISO8601DateFormatter()
        try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(dateFormatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(dateFormatter.string(from: lastLoginAt), forKey: .lastLoginAt)
        
        try container.encodeIfPresent(lastLoginProvider, forKey: .lastLoginProvider)
        try container.encode(onboardingCompleted, forKey: .onboardingCompleted)
        try container.encode(preferredLanguage, forKey: .preferredLanguage)
        try container.encode(countryCode, forKey: .countryCode)
        try container.encode(isCreator, forKey: .isCreator)
        try container.encodeIfPresent(creatorProfile, forKey: .creatorProfile)
    }
}

// MARK: - Supporting Types

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