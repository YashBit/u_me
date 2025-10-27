# U&Me iOS Architecture Guide

## 🏗️ Project Structure

```
u_me/
├── Sources/
│   ├── App/                           # Application Layer
│   │   ├── AppMain.swift             # @main entry point
│   │   ├── Root/
│   │   │   └── RootView.swift        # Main navigation controller
│   │   └── Navigation/
│   │       └── AppCoordinator.swift  # Navigation state management
│   │
│   ├── Core/                         # Business Logic (NO UI)
│   │   ├── Domain/
│   │   │   ├── Entities/             # Business models
│   │   │   │   ├── User.swift
│   │   │   │   ├── Creator.swift
│   │   │   │   ├── Product.swift
│   │   │   │   ├── Content.swift
│   │   │   │   └── Match.swift
│   │   │   ├── UseCases/             # Business rules
│   │   │   │   ├── MatchingAlgorithm.swift
│   │   │   │   ├── AuthenticationUseCase.swift
│   │   │   │   └── CommerceUseCase.swift
│   │   │   └── RepositoryProtocols/ # Interfaces
│   │   │       ├── UserRepositoryProtocol.swift
│   │   │       └── ProductRepositoryProtocol.swift
│   │   │
│   │   └── Data/
│   │       ├── Network/
│   │       │   ├── API/
│   │       │   │   ├── APIClient.swift
│   │       │   │   └── Endpoints.swift
│   │       │   └── DTOs/             # Data Transfer Objects
│   │       │       └── UserDTO.swift
│   │       ├── Local/
│   │       │   ├── CoreData/
│   │       │   │   └── CoreDataStack.swift
│   │       │   └── Keychain/
│   │       │       └── KeychainManager.swift
│   │       └── Repositories/         # Concrete implementations
│   │           └── UserRepository.swift
│   │
│   ├── DesignSystem/                 # UI Components (NO Business Logic)
│   │   ├── Tokens/
│   │   │   ├── Colors.swift         # Brand colors
│   │   │   ├── Typography.swift     # Font styles
│   │   │   ├── Spacing.swift        # Layout constants
│   │   │   └── Shadows.swift        # Shadow styles
│   │   ├── Atoms/                   # Basic components
│   │   │   ├── Buttons/
│   │   │   │   └── PrimaryButton.swift
│   │   │   └── Inputs/
│   │   │       └── TextField.swift
│   │   ├── Molecules/               # Composite components
│   │   │   └── Cards/
│   │   │       ├── CreatorCard.swift
│   │   │       └── ProductCard.swift
│   │   └── Organisms/              # Complex components
│   │       └── NavigationBar.swift
│   │
│   ├── Features/                   # Feature Modules
│   │   ├── Authentication/
│   │   │   ├── Domain/            # Feature-specific logic
│   │   │   ├── Data/              # Feature-specific data
│   │   │   └── Presentation/
│   │   │       ├── ViewModels/
│   │   │       │   └── AuthViewModel.swift
│   │   │       └── Views/
│   │   │           ├── LoginView.swift
│   │   │           └── LINEAuthView.swift
│   │   │
│   │   ├── Discovery/
│   │   │   └── Presentation/
│   │   │       ├── ViewModels/
│   │   │       │   └── FeedViewModel.swift
│   │   │       └── Views/
│   │   │           └── FeedView.swift
│   │   │
│   │   ├── Creation/
│   │   │   └── Presentation/
│   │   │       └── Views/
│   │   │           └── ContentCreator.swift
│   │   │
│   │   └── Commerce/
│   │       └── Presentation/
│   │           └── Views/
│   │               ├── ProductView.swift
│   │               └── CheckoutView.swift
│   │
│   ├── Infrastructure/            # Technical Infrastructure
│   │   ├── DI/
│   │   │   └── AppContainer.swift # Dependency injection
│   │   ├── Analytics/
│   │   │   └── AnalyticsManager.swift
│   │   └── Logging/
│   │       └── Logger.swift
│   │
│   └── Platform/                  # Third-party Integrations
│       ├── LINE/
│       │   └── LINEAuthService.swift
│       └── PromptPay/
│           └── PromptPayService.swift
│
├── Resources/
│   ├── Assets.xcassets           # Images, colors
│   ├── Localization/
│   │   ├── en.lproj/
│   │   │   └── Localizable.strings
│   │   └── th.lproj/             # Thai localization
│   │       └── Localizable.strings
│   └── Fonts/                    # Custom fonts
│
├── SupportingFiles/
│   ├── Info.plist
│   └── u_me.entitlements
│
├── Configuration/
│   ├── Development/
│   │   └── Config.xcconfig
│   ├── Staging/
│   │   └── Config.xcconfig
│   └── Production/
│       └── Config.xcconfig
│
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── UITests/
```

## 🎯 Architecture Principles

### 1. Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer               │
│     (Views, ViewModels, UI Logic)        │
├─────────────────────────────────────────┤
│           Domain Layer                   │
│    (Business Logic, Use Cases)           │
├─────────────────────────────────────────┤
│            Data Layer                    │
│    (API, Database, Repositories)         │
└─────────────────────────────────────────┘
```

### 2. Dependency Rules
- **Dependencies point inward** - outer layers depend on inner layers
- **Domain layer has NO dependencies** - pure business logic
- **UI never talks directly to Data layer** - always through Domain

### 3. Data Flow
```
View → ViewModel → UseCase → Repository → API/Database
     ←           ←          ←            ←
```

## 💻 Key Components

### AppMain.swift
**Purpose:** Application entry point and global configuration
```swift
@main
struct UMeApp: App {
    // Initialize global services
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
```

### RootView.swift
**Purpose:** Main navigation controller and routing logic
```swift
struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if !appState.isAuthenticated {
            AuthenticationView()
        } else {
            MainTabView()
        }
    }
}
```

### Feature Structure
Each feature follows the same pattern:
```
Feature/
├── Domain/           # Business logic specific to feature
├── Data/            # Data sources specific to feature
└── Presentation/    # UI for the feature
    ├── ViewModels/  # Bridge between UI and Domain
    └── Views/       # SwiftUI views
```

## 🏃‍♂️ Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+
- CocoaPods or Swift Package Manager

### Initial Setup
```bash
# Clone the repository
git clone https://github.com/ume/ios.git
cd ios

# Install dependencies (if using CocoaPods)
pod install

# Open the workspace
open u_me.xcworkspace

# Or if using SPM only
open u_me.xcodeproj
```

### Environment Configuration
1. Copy `Config.xcconfig.example` to `Config.xcconfig`
2. Add your API keys:
```
LINE_CHANNEL_ID = your_line_channel_id
API_BASE_URL = https://api-dev.u-me.app
```

## 🧩 Module Responsibilities

### Core Module
- **Domain/Entities**: Business models (User, Product, Creator)
- **Domain/UseCases**: Business rules (Matching algorithm)
- **Data/Network**: API communication
- **Data/Local**: Local storage (CoreData, Keychain)

### DesignSystem Module
- **Tokens**: Design constants (colors, typography, spacing)
- **Atoms**: Basic UI components (buttons, inputs)
- **Molecules**: Composite components (cards, forms)
- **Organisms**: Complex components (navigation bars)

### Features Modules
- **Authentication**: Login, registration, LINE OAuth
- **Discovery**: Feed, search, recommendations
- **Creation**: Content creation tools, AI features
- **Commerce**: Product browsing, cart, checkout

### Infrastructure Module
- **DI**: Dependency injection container
- **Analytics**: Event tracking
- **Logging**: Debug and error logging

### Platform Module
- **LINE**: LINE SDK integration
- **PromptPay**: Payment integration
- **Firebase**: Analytics and crash reporting

## 🇹🇭 Thailand-Specific Considerations

### Localization
- All strings in `Localizable.strings`
- Thai language from day 1
- Buddhist calendar support
- Thai phone format (+66)

### Payment Integration
```swift
// Platform/PromptPay/PromptPayService.swift
class PromptPayService {
    func generateQRCode(amount: Decimal) -> UIImage
    func validatePhoneNumber(_ number: String) -> Bool
}
```

### LINE Integration
```swift
// Platform/LINE/LINEAuthService.swift
class LINEAuthService {
    func authenticate() async throws -> LINEUser
    func shareToLINE(content: Content)
}
```

## 🧪 Testing Strategy

### Unit Tests
- Test business logic in Domain layer
- Test ViewModels separately from Views
- Mock all external dependencies

### Integration Tests
- Test API communication
- Test database operations
- Test third-party SDK integration

### UI Tests
- Test critical user flows
- Test Thai language display
- Test different device sizes

## 📝 Development Guidelines

### Code Style
- Use SwiftLint for consistent formatting
- Follow Swift API Design Guidelines
- Document public APIs

### Git Workflow
```bash
# Feature branch
git checkout -b feature/discovery-feed

# Make changes and commit
git add .
git commit -m "feat: implement discovery feed"

# Push and create PR
git push origin feature/discovery-feed
```

### Architecture Rules
1. **No business logic in Views** - Keep views simple
2. **No UI in Domain layer** - Domain is pure Swift
3. **Use protocols for dependencies** - Enable testing
4. **One feature, one module** - Keep features isolated

## 🚀 Build & Run

### Development
```bash
# Select scheme: u_me-Dev
# Select device: iPhone 15 Pro
# Run: Cmd+R
```

### Testing
```bash
# Run all tests
fastlane test

# Run specific tests
xcodebuild test -scheme u_me -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Release
```bash
# Build for TestFlight
fastlane beta

# Build for App Store
fastlane release
```

## 📊 Performance Guidelines

### Image Handling
- Use lazy loading for images
- Implement caching with ImageCache
- Compress images before upload

### Network Optimization
- Implement pagination (20 items per page)
- Cache API responses
- Use background queues for heavy operations

### Memory Management
- Use weak references in closures
- Clear caches on memory warning
- Profile with Instruments regularly

## 🤝 Team Collaboration

### For Designers
- Work in `DesignSystem/` folder
- Update design tokens directly
- Preview components in SwiftUI previews

### For Backend Developers
- Define API contracts in `Core/Data/Network/Endpoints.swift`
- Update DTOs when API changes
- Document API requirements

### For AI Agents
- Each agent owns specific modules
- Use feature branches for isolation
- Follow the architecture rules strictly

## 📚 Additional Resources

- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [LINE SDK Documentation](https://developers.line.biz/en/docs/ios-sdk/)
- [PromptPay Integration Guide](https://www.bot.or.th/en/financial-innovation/platforms/promptpay.html)

## 🆘 Troubleshooting

### Common Issues

**Build fails with "No such module"**
- Check target membership for files
- Clean build folder (Cmd+Shift+K)
- Reset package caches

**Thai text not displaying**
- Ensure Thai localization files exist
- Check Info.plist for supported localizations
- Test on device with Thai language

**LINE OAuth not working**
- Verify LINE Channel ID in Config.xcconfig
- Check Info.plist URL schemes
- Ensure entitlements are configured

## 📞 Support

- Technical Lead: [Your Name]
- Slack Channel: #ume-ios-dev
- Documentation: /Documentation folder
- API Documentation: https://api.u-me.app/docs
