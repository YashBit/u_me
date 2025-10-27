#!/bin/bash

# U&Me iOS - Complete Directory Structure Setup
# This script creates all necessary directories for basic features + placeholders for Core USP & Market Competitive features

set -e  # Exit on error

echo "🚀 Setting up U&Me iOS directory structure..."

# Base directory (run from project root)
BASE_DIR="Sources"

# ============================================
# CORE - Shared Business Logic
# ============================================
echo "📦 Creating Core directories..."

# Core Domain
mkdir -p "$BASE_DIR/Core/Domain/Entities"
mkdir -p "$BASE_DIR/Core/Domain/Repositories"
mkdir -p "$BASE_DIR/Core/Domain/UseCases"

# Core Data
mkdir -p "$BASE_DIR/Core/Data/Network/API"
mkdir -p "$BASE_DIR/Core/Data/Network/DTOs"
mkdir -p "$BASE_DIR/Core/Data/Local/Keychain"
mkdir -p "$BASE_DIR/Core/Data/Local/CoreData"
mkdir -p "$BASE_DIR/Core/Data/Local/UserDefaults"
mkdir -p "$BASE_DIR/Core/Data/Repositories"

# Core Extensions
mkdir -p "$BASE_DIR/Core/Extensions"

# ============================================
# DESIGN SYSTEM - UI Components (No Business Logic)
# ============================================
echo "🎨 Creating Design System directories..."

mkdir -p "$BASE_DIR/DesignSystem/Tokens"
mkdir -p "$BASE_DIR/DesignSystem/Atoms/Buttons"
mkdir -p "$BASE_DIR/DesignSystem/Atoms/Inputs"
mkdir -p "$BASE_DIR/DesignSystem/Atoms/Loading"
mkdir -p "$BASE_DIR/DesignSystem/Molecules/Cards"
mkdir -p "$BASE_DIR/DesignSystem/Molecules/Forms"
mkdir -p "$BASE_DIR/DesignSystem/Organisms/Navigation"
mkdir -p "$BASE_DIR/DesignSystem/Organisms/Headers"

# ============================================
# BASIC/OPERATIONAL FEATURES
# ============================================
echo "⚙️  Creating Basic Operational Features..."

# 1. Authentication
mkdir -p "$BASE_DIR/Features/Authentication/Domain/Entities"
mkdir -p "$BASE_DIR/Features/Authentication/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/Authentication/Domain/Repositories"
mkdir -p "$BASE_DIR/Features/Authentication/Data/DTOs"
mkdir -p "$BASE_DIR/Features/Authentication/Data/Repositories"
mkdir -p "$BASE_DIR/Features/Authentication/Data/DataSources"
mkdir -p "$BASE_DIR/Features/Authentication/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/Authentication/Presentation/Views"
mkdir -p "$BASE_DIR/Features/Authentication/Presentation/Views/Components"

# 2. Onboarding (Profile Setup, Terms, Welcome Flow)
mkdir -p "$BASE_DIR/Features/Onboarding/Domain/Entities"
mkdir -p "$BASE_DIR/Features/Onboarding/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/Onboarding/Data/DTOs"
mkdir -p "$BASE_DIR/Features/Onboarding/Data/Repositories"
mkdir -p "$BASE_DIR/Features/Onboarding/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/Onboarding/Presentation/Views"
mkdir -p "$BASE_DIR/Features/Onboarding/Presentation/Views/Components"

# 3. Profile
mkdir -p "$BASE_DIR/Features/Profile/Domain/Entities"
mkdir -p "$BASE_DIR/Features/Profile/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/Profile/Domain/Repositories"
mkdir -p "$BASE_DIR/Features/Profile/Data/DTOs"
mkdir -p "$BASE_DIR/Features/Profile/Data/Repositories"
mkdir -p "$BASE_DIR/Features/Profile/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/Profile/Presentation/Views"
mkdir -p "$BASE_DIR/Features/Profile/Presentation/Views/Components"

# 4. Settings
mkdir -p "$BASE_DIR/Features/Settings/Domain/Entities"
mkdir -p "$BASE_DIR/Features/Settings/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/Settings/Data/DTOs"
mkdir -p "$BASE_DIR/Features/Settings/Data/Repositories"
mkdir -p "$BASE_DIR/Features/Settings/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/Settings/Presentation/Views"

# 5. Discovery (Feed)
mkdir -p "$BASE_DIR/Features/Discovery/Domain/Entities"
mkdir -p "$BASE_DIR/Features/Discovery/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/Discovery/Domain/Repositories"
mkdir -p "$BASE_DIR/Features/Discovery/Data/DTOs"
mkdir -p "$BASE_DIR/Features/Discovery/Data/Repositories"
mkdir -p "$BASE_DIR/Features/Discovery/Data/DataSources"
mkdir -p "$BASE_DIR/Features/Discovery/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/Discovery/Presentation/Views"
mkdir -p "$BASE_DIR/Features/Discovery/Presentation/Views/Components"

# 6. Search
mkdir -p "$BASE_DIR/Features/Search/Domain/Entities"
mkdir -p "$BASE_DIR/Features/Search/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/Search/Domain/Repositories"
mkdir -p "$BASE_DIR/Features/Search/Data/DTOs"
mkdir -p "$BASE_DIR/Features/Search/Data/Repositories"
mkdir -p "$BASE_DIR/Features/Search/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/Search/Presentation/Views"

# 7. Payment
mkdir -p "$BASE_DIR/Features/Payment/Domain/Entities"
mkdir -p "$BASE_DIR/Features/Payment/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/Payment/Domain/Repositories"
mkdir -p "$BASE_DIR/Features/Payment/Data/DTOs"
mkdir -p "$BASE_DIR/Features/Payment/Data/Repositories"
mkdir -p "$BASE_DIR/Features/Payment/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/Payment/Presentation/Views"

# 8. Messaging
mkdir -p "$BASE_DIR/Features/Messaging/Domain/Entities"
mkdir -p "$BASE_DIR/Features/Messaging/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/Messaging/Domain/Repositories"
mkdir -p "$BASE_DIR/Features/Messaging/Data/DTOs"
mkdir -p "$BASE_DIR/Features/Messaging/Data/Repositories"
mkdir -p "$BASE_DIR/Features/Messaging/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/Messaging/Presentation/Views"

# ============================================
# CORE USP FEATURES (Placeholder for Future)
# ============================================
echo "🎯 Creating Core USP Feature Placeholders..."

# 1. Matching Algorithm
mkdir -p "$BASE_DIR/Features/MatchingAlgorithm/Domain/Entities"
mkdir -p "$BASE_DIR/Features/MatchingAlgorithm/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/MatchingAlgorithm/Domain/Repositories"
mkdir -p "$BASE_DIR/Features/MatchingAlgorithm/Data/DTOs"
mkdir -p "$BASE_DIR/Features/MatchingAlgorithm/Data/Repositories"
mkdir -p "$BASE_DIR/Features/MatchingAlgorithm/Data/ML"
mkdir -p "$BASE_DIR/Features/MatchingAlgorithm/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/MatchingAlgorithm/Presentation/Views"

# Create README placeholder
cat > "$BASE_DIR/Features/MatchingAlgorithm/README.md" << 'EOF'
# Matching Algorithm Feature

## Status: 🚧 PLACEHOLDER - Not Yet Implemented

## Purpose
Proprietary creator-product affinity matching using:
- Semantic content analysis
- Engagement pattern recognition
- Psychographic mapping
- Network effects integration

## Future Implementation
- Multi-dimensional scoring algorithm
- ML model training pipeline
- Real-time matching engine
- A/B testing framework

## Dependencies
- Core/Domain/Entities (User, Product, Creator)
- Discovery feature (content data)
- Analytics (engagement metrics)
EOF

# 2. Indirect Commerce
mkdir -p "$BASE_DIR/Features/IndirectCommerce/Domain/Entities"
mkdir -p "$BASE_DIR/Features/IndirectCommerce/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/IndirectCommerce/Data/Repositories"
mkdir -p "$BASE_DIR/Features/IndirectCommerce/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/IndirectCommerce/Presentation/Views"

cat > "$BASE_DIR/Features/IndirectCommerce/README.md" << 'EOF'
# Indirect Commerce Feature

## Status: 🚧 PLACEHOLDER - Not Yet Implemented

## Purpose
Authentic content → organic product discovery → purchase
- Attribution tracking (complex multi-touchpoint)
- Influence measurement (not just last-click)
- Commission calculation
- Creator earnings dashboard

## Future Implementation
- Attribution algorithm
- Influence scoring
- Revenue sharing logic
- Performance analytics
EOF

# ============================================
# MARKET COMPETITIVE FEATURES (Placeholder)
# ============================================
echo "🏆 Creating Market Competitive Feature Placeholders..."

# 1. Creator Toolkit
mkdir -p "$BASE_DIR/Features/CreatorToolkit/Domain/Entities"
mkdir -p "$BASE_DIR/Features/CreatorToolkit/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/CreatorToolkit/Data/Repositories"
mkdir -p "$BASE_DIR/Features/CreatorToolkit/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/CreatorToolkit/Presentation/Views/BackgroundGeneration"
mkdir -p "$BASE_DIR/Features/CreatorToolkit/Presentation/Views/NarrativePrompts"
mkdir -p "$BASE_DIR/Features/CreatorToolkit/Presentation/Views/VideoEditor"

cat > "$BASE_DIR/Features/CreatorToolkit/README.md" << 'EOF'
# Creator Toolkit Feature

## Status: 🚧 PLACEHOLDER - Not Yet Implemented

## Purpose
AI-enhanced content creation tools:
- Contextual background generation
- Narrative prompt engineering
- Video editing suite
- Trend prediction

## Future Implementation
- AI model integrations
- Real-time rendering
- Template library
- Export functionality
EOF

# 2. Performance Intelligence
mkdir -p "$BASE_DIR/Features/PerformanceIntelligence/Domain/Entities"
mkdir -p "$BASE_DIR/Features/PerformanceIntelligence/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/PerformanceIntelligence/Data/Repositories"
mkdir -p "$BASE_DIR/Features/PerformanceIntelligence/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/PerformanceIntelligence/Presentation/Views"

cat > "$BASE_DIR/Features/PerformanceIntelligence/README.md" << 'EOF'
# Performance Intelligence & Analytics Feature

## Status: 🚧 PLACEHOLDER - Not Yet Implemented

## Purpose
Real-time creator analytics:
- Content performance metrics
- Engagement rate analysis
- Audience demographics
- Earnings forecasting
- Optimization recommendations

## Future Implementation
- Analytics dashboard
- Real-time charts (Recharts integration)
- Export reports
- Predictive insights
EOF

# 3. Community Validation
mkdir -p "$BASE_DIR/Features/CommunityValidation/Domain/Entities"
mkdir -p "$BASE_DIR/Features/CommunityValidation/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/CommunityValidation/Data/Repositories"
mkdir -p "$BASE_DIR/Features/CommunityValidation/Presentation/ViewModels"
mkdir -p "$BASE_DIR/Features/CommunityValidation/Presentation/Views"

cat > "$BASE_DIR/Features/CommunityValidation/README.md" << 'EOF'
# Community Validation Architecture Feature

## Status: 🚧 PLACEHOLDER - Not Yet Implemented

## Purpose
Trust-building through community:
- Peer review mechanisms
- Product rating system
- Discussion forums
- Reputation scoring
- Quality filters

## Future Implementation
- Voting system
- Moderation tools
- Trust scores
- Community guidelines enforcement
EOF

# 4. Content Analysis (AI)
mkdir -p "$BASE_DIR/Features/ContentAnalysis/Domain/Entities"
mkdir -p "$BASE_DIR/Features/ContentAnalysis/Domain/UseCases"
mkdir -p "$BASE_DIR/Features/ContentAnalysis/Data/Repositories"
mkdir -p "$BASE_DIR/Features/ContentAnalysis/Data/ML"
mkdir -p "$BASE_DIR/Features/ContentAnalysis/Presentation/ViewModels"

cat > "$BASE_DIR/Features/ContentAnalysis/README.md" << 'EOF'
# Content Analysis & Reels Feature

## Status: 🚧 PLACEHOLDER - Not Yet Implemented

## Purpose
AI-powered content understanding:
- Semantic video analysis
- Object detection (products in videos)
- Sentiment analysis
- Thai language NLP
- Hashtag extraction
- Trend identification

## Future Implementation
- Vision API integration
- CoreML models
- Natural language processing
- Automatic tagging
EOF

# ============================================
# PLATFORM INTEGRATIONS
# ============================================
echo "🔌 Creating Platform Integration directories..."

mkdir -p "$BASE_DIR/Platform/LINE/Auth"
mkdir -p "$BASE_DIR/Platform/LINE/Messaging"
mkdir -p "$BASE_DIR/Platform/LINE/Models"

mkdir -p "$BASE_DIR/Platform/Firebase/Auth"
mkdir -p "$BASE_DIR/Platform/Firebase/Analytics"
mkdir -p "$BASE_DIR/Platform/Firebase/Storage"

mkdir -p "$BASE_DIR/Platform/PromptPay/QRCode"
mkdir -p "$BASE_DIR/Platform/PromptPay/Verification"
mkdir -p "$BASE_DIR/Platform/PromptPay/Models"

# ============================================
# SHARED UTILITIES
# ============================================
echo "🛠️  Creating Shared utilities..."

mkdir -p "$BASE_DIR/Shared/Constants"
mkdir -p "$BASE_DIR/Shared/Extensions"
mkdir -p "$BASE_DIR/Shared/Utilities/Validators"
mkdir -p "$BASE_DIR/Shared/Utilities/Formatters"
mkdir -p "$BASE_DIR/Shared/Utilities/VideoPlayer"
mkdir -p "$BASE_DIR/Shared/Models"

# ============================================
# INFRASTRUCTURE
# ============================================
echo "🏗️  Creating Infrastructure directories..."

mkdir -p "$BASE_DIR/Infrastructure/DI"
mkdir -p "$BASE_DIR/Infrastructure/Analytics"
mkdir -p "$BASE_DIR/Infrastructure/Logging"
mkdir -p "$BASE_DIR/Infrastructure/Navigation"

# ============================================
# CREATE PLACEHOLDER FILES
# ============================================
echo "📝 Creating placeholder README files..."

# Core README
cat > "$BASE_DIR/Core/README.md" << 'EOF'
# Core Module

## Purpose
Shared business logic and infrastructure used across ALL features.

## Structure
- **Domain**: Shared entities, use cases, repository protocols
- **Data**: API client, networking, storage (Keychain, CoreData)
- **Extensions**: Swift extensions used app-wide

## Rules
- NO UI code in Core
- NO feature-specific logic
- Only reusable, generic implementations
- Features depend on Core, Core does NOT depend on Features
EOF

# Design System README
cat > "$BASE_DIR/DesignSystem/README.md" << 'EOF'
# Design System

## Purpose
Reusable UI components with NO business logic.

## Structure
- **Tokens**: Colors, Typography, Spacing (design constants)
- **Atoms**: Basic components (Buttons, Inputs, Loading)
- **Molecules**: Composite components (Cards, Forms)
- **Organisms**: Complex components (Navigation, Headers)

## Rules
- NO business logic (no API calls, no data models)
- Only presentational components
- Accept data via parameters
- Emit actions via closures/bindings
- Preview-ready (SwiftUI Previews)
EOF

# Features README
cat > "$BASE_DIR/Features/README.md" << 'EOF'
# Features Module

## Purpose
Self-contained feature modules following Clean Architecture.

## Structure (per feature)
- **Domain**: Feature-specific entities, use cases, repository protocols
- **Data**: Feature-specific repositories, data sources, DTOs
- **Presentation**: ViewModels (business logic) + Views (UI)

## Feature Categories

### ✅ Basic/Operational Features (Active Development)
- Authentication
- Onboarding
- Profile
- Settings
- Discovery (Feed)
- Search
- Payment
- Messaging

### 🚧 Core USP Features (Placeholders - Future)
- MatchingAlgorithm
- IndirectCommerce

### 🚧 Market Competitive Features (Placeholders - Future)
- CreatorToolkit
- PerformanceIntelligence
- CommunityValidation
- ContentAnalysis

## Rules
- Each feature is independent (no inter-feature dependencies)
- Features depend on Core, NOT on other Features
- Communication between features through Core domain models
EOF

# Platform README
cat > "$BASE_DIR/Platform/README.md" << 'EOF'
# Platform Integrations

## Purpose
Third-party service integrations and adapters.

## Integrations
- **LINE**: OAuth, messaging, sharing
- **Firebase**: Auth, analytics, storage
- **PromptPay**: QR generation, payment verification

## Rules
- Wrap external SDKs with internal interfaces
- Keep platform-specific code isolated
- Provide protocol-based abstractions for testing
EOF

# ============================================
# CREATE .gitkeep FILES
# ============================================
echo "📌 Creating .gitkeep files for empty directories..."

find "$BASE_DIR" -type d -empty -exec touch {}/.gitkeep \;

# ============================================
# SUMMARY
# ============================================
echo ""
echo "✅ Directory structure created successfully!"
echo ""
echo "📊 Summary:"
echo "   - Core: Shared business logic (app-wide)"
echo "   - DesignSystem: UI components (no business logic)"
echo "   - Features: Self-contained feature modules"
echo "     ✅ 8 Basic/Operational features (ready for development)"
echo "     🚧 2 Core USP features (placeholders)"
echo "     🚧 4 Market Competitive features (placeholders)"
echo "   - Platform: Third-party integrations"
echo "   - Shared: Utilities and constants"
echo ""
echo "🎯 Next Steps:"
echo "   1. Review the structure: tree Sources/"
echo "   2. Read README files in each directory"
echo "   3. Start implementing: Features/Authentication"
echo ""
echo "🚀 Happy coding!"
