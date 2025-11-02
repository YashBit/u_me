# Authentication Module

## Overview

Production-ready authentication system supporting multiple providers with backend integration, account linking, and secure token management. Currently configured for local development with clear path to production deployment.

---

## Architecture

Clean Architecture with three-tier separation:

**Domain Layer** (Business Logic)
- Entities: `User`, `AuthProvider`, `AuthCredentials`, `AuthResult`, `AuthError`
- Use Cases: `SignInUseCase`, `LinkAccountUseCase`
- Repository Protocols: Define data access contracts

**Data Layer** (Data Management)
- Repositories: `AuthRepository`, `UserRepository`
- Data Sources: `RemoteAuthDataSource` (API), `LocalAuthDataSource` (Keychain)
- Network: `NetworkService`, `APIConfig`

**Presentation Layer** (UI)
- ViewModels: `AuthViewModel` - state management and coordination
- Views: `LoginView`, `EmailLoginView`

**Platform Layer** (External Services)
- `GoogleAuthService` - Google Sign In integration
- `AppleSignInService` - Apple Sign In with Security
- `LINEAuthService` - LINE login for Thai market
- `EmailAuthService` - Email/password authentication

---

## Supported Providers

| Provider | Status | Notes |
|----------|--------|-------|
| Google | ✅ Production Ready | OAuth 2.0 with Google Sign In SDK |
| Apple | ✅ Production Ready | Sign in with Apple + Keychain |
| LINE | ✅ Production Ready | Thai market priority |
| Email | ✅ Production Ready | Password-based with validation |

---

## Current State: Local Development

### Active Configuration

**Backend:** Node.js + Express + Firestore
- **Local URL:** `http://localhost:3000` (Simulator)
- **Network URL:** `http://172.22.196.1:3000` (Real Device)
- **Location:** `u_me_backend_v0.1/server.js`

**iOS Configuration:**
- **File:** `Sources/Core/Data/Network/API/APIConfig.swift`
- **Debug Mode:** Uses local backend (`DEBUG` flag)
- **Info.plist:** HTTP exceptions enabled for local development

### Running Locally

**Backend:**
```bash
cd u_me_backend_v0.1
npm start
```

**iOS App:**
```swift
// APIConfig.swift automatically uses:
// - Simulator: http://localhost:3000/v1
// - Real Device: http://YOUR_MAC_IP:3000/v1
```

---

## Security Features

1. **Token Storage:** Sensitive tokens secured in iOS Keychain
2. **Cryptographic Nonce:** For Apple Sign In security
3. **Backend Validation:** All auth decisions validated server-side
4. **Error Handling:** Comprehensive error types with user-friendly messages
5. **Account Linking:** Secure multi-provider connection to single user

---

## Authentication Flow
```
1. User taps authentication provider
   ↓
2. Platform service authenticates (Google/Apple/LINE/Email)
   ↓
3. iOS receives credentials
   ↓
4. SignInUseCase checks backend for existing user
   ↓
5. If new: Create user | If exists: Update last login
   ↓
6. Save user locally (Keychain + UserDefaults)
   ↓
7. Update UI state → Authenticated
```

---

## Usage
```swift
// Initialize in your app
@StateObject var authViewModel = AuthViewModel.shared

// In your login view
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button("Continue with Google") {
            Task {
                await authViewModel.signInWithGoogleTapped()
            }
        }
    }
}
```

---

## Path to Production

### Phase 1: Deploy Backend (Week 1)

**Option A: Firebase Cloud Functions (Recommended)**
```bash
cd u_me_backend_v0.1
firebase init functions
firebase deploy --only functions

# Result: https://us-central1-u-and-me.cloudfunctions.net/api
```

**Option B: Railway/Render/Heroku**
```bash
# Choose any Node.js hosting platform
# Deploy with: git push railway main
```

**Update iOS:**
```swift
// APIConfig.swift
#if DEBUG
static let baseURL = "http://localhost:3000/v1"
#else
static let baseURL = "https://your-production-api.com/v1"  // ← Update this
#endif
```

### Phase 2: Production Security (Week 2)

**Backend:**
```javascript
// Add authentication middleware
const authenticateRequest = async (req, res, next) => {
    const token = req.headers.authorization?.replace('Bearer ', '');
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
};

// Protect endpoints
app.post('/v1/users', authenticateRequest, createUser);
```

**iOS:**
```swift
// Add auth headers to requests
headers["Authorization"] = "Bearer \(idToken)"
```

**Remove Development Exceptions:**
```xml
<!-- Info.plist - DELETE THESE -->
<key>localhost</key>
<key>172.22.196.1</key>
```

### Phase 3: Production Firestore Rules (Week 2)
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Users can only read/write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Phase 4: Monitoring & Analytics (Week 3)

**Add Firebase Crashlytics:**
```swift
// AppDelegate.swift
import FirebaseCrashlytics

func application(_ application: UIApplication, didFinishLaunchingWithOptions...) {
    FirebaseApp.configure()
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
}
```

**Backend Logging:**
```javascript
// Add structured logging
const winston = require('winston');
const logger = winston.createLogger({...});

logger.info('User created', { userId, provider });
```

### Phase 5: Rate Limiting & DDoS Protection (Week 4)

**Backend:**
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // limit each IP to 100 requests per windowMs
});

app.use('/v1/', limiter);
```

### Phase 6: CI/CD Pipeline (Week 4)

**GitHub Actions:**
```yaml
# .github/workflows/deploy.yml
name: Deploy Backend
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Firebase
        run: firebase deploy --only functions
```

---

## Production Checklist

**Backend:**
- [ ] Deploy to production hosting (Firebase/Railway/Render)
- [ ] Update API URL in `APIConfig.swift`
- [ ] Add authentication middleware
- [ ] Implement rate limiting
- [ ] Set up error monitoring (Sentry/Firebase)
- [ ] Configure production Firestore rules
- [ ] Add structured logging
- [ ] Set up backup strategy
- [ ] Configure SSL/TLS certificates
- [ ] Test load handling (1000+ req/s)

**iOS:**
- [ ] Remove local network exceptions from `Info.plist`
- [ ] Switch `APIConfig` to production URL
- [ ] Add request authentication headers
- [ ] Enable Firebase Crashlytics
- [ ] Implement offline mode handling
- [ ] Add retry logic for network failures
- [ ] Test on slow networks
- [ ] Implement biometric authentication
- [ ] Add app review prompts
- [ ] Submit to App Store review

**Security:**
- [ ] Rotate all API keys
- [ ] Enable 2FA for admin accounts
- [ ] Audit Firestore security rules
- [ ] Set up intrusion detection
- [ ] Regular security penetration testing
- [ ] GDPR compliance review
- [ ] Privacy policy implementation
- [ ] Data retention policy

---

## Testing

**Unit Tests:**
```bash
# Test use cases
XCTest -> SignInUseCaseTests
XCTest -> LinkAccountUseCaseTests
```

**Integration Tests:**
```bash
# Test full auth flow
XCTest -> AuthenticationIntegrationTests
```

**Backend Tests:**
```bash
cd u_me_backend_v0.1
npm test
```

---

## Troubleshooting

**"Cannot connect to backend"**
- Check backend is running: `curl http://localhost:3000/`
- Verify iPhone and Mac on same WiFi
- Check `Info.plist` has HTTP exceptions

**"User not found" but should exist**
- Check Firestore console for user document
- Verify `providerUserId` matches between iOS and backend
- Check backend logs for errors

**"Decoding error"**
- Verify `User` model matches backend response format
- Check date format is ISO8601
- Ensure `providerIDs` dictionary decoding is working

---

## Support

**Documentation:** `/Documentation/API/Authentication.md`  
**Backend API:** `u_me_backend_v0.1/README.md`  
**Issues:** Create ticket with logs from both iOS and backend

---

**Last Updated:** November 2, 2025  
**Version:** 0.1.0 (Local Development)  
**Production Target:** Q1 2026 - Thailand Launch