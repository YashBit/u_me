# Authentication Module

## Architecture Overview

This module follows Clean Architecture principles with clear separation of concerns:

### Layers

1. **Domain Layer** (Business Logic)
   - Entities: Core models (User, AuthProvider, etc.)
   - Use Cases: Business rules (SignIn, LinkAccount)
   - Repository Protocols: Interfaces for data access

2. **Data Layer** (Data Management)
   - Repositories: Concrete implementations
   - Data Sources: Remote (API) and Local (Keychain/UserDefaults)
   - DTOs: Data Transfer Objects for API

3. **Presentation Layer** (UI)
   - ViewModels: State management and coordination
   - Views: SwiftUI views (UI only)
   - Components: Reusable UI elements

4. **Platform Layer** (External Services)
   - Apple Sign In Service
   - LINE Authentication Service
   - Firebase Integration

## Features

- ✅ Multiple authentication providers (Apple, LINE, Email, Phone)
- ✅ Account linking (connect multiple providers to one account)
- ✅ Secure token storage (Keychain)
- ✅ Automatic session management
- ✅ User state persistence

## Security Best Practices

1. **Token Storage**: All sensitive tokens stored in iOS Keychain
2. **User Data**: Non-sensitive user data in UserDefaults
3. **Nonce Generation**: Cryptographic nonce for Apple Sign In
4. **Token Refresh**: Automatic token refresh when expired
5. **Secure Communication**: All API calls over HTTPS

## Usage

```swift
// In your app initialization
let container = AuthenticationContainer()
let authViewModel = container.makeAuthViewModel()

// In your view
LoginView()
    .environmentObject(authViewModel)
```

## Testing

Each layer can be tested independently:
- Domain: Pure business logic tests
- Data: Repository tests with mock data sources
- Presentation: ViewModel tests with mock use cases
- UI: Snapshot and UI tests

## Account Tracking

Users are tracked using:
1. Universal User ID (UUID) - consistent across all providers
2. Provider-specific IDs - for authentication
3. Email matching - for account linking suggestions

## Files Structure

```
Authentication/
├── Domain/
│   ├── Entities/        # Core models
│   ├── UseCases/        # Business logic
│   └── Repositories/    # Interfaces
├── Data/
│   ├── Repositories/    # Implementations
│   ├── DataSources/     # API & Local storage
│   └── DTOs/           # API models
└── Presentation/
    ├── ViewModels/      # State management
    └── Views/           # UI components
```
