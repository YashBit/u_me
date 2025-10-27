#!/bin/bash
set -e
echo "🚀 U&Me iOS Complete Setup Starting..."
BASE="Sources"
echo "🧹 Cleaning old Features..."
[ -d "$BASE/Features/Commerce" ] && rm -rf "$BASE/Features/Commerce" && echo "  ✅ Removed Commerce"
[ -d "$BASE/Features/Creation" ] && rm -rf "$BASE/Features/Creation" && echo "  ✅ Removed Creation"
echo "📦 Creating Core..."
mkdir -p "$BASE/Core/Domain/"{Entities,Repositories,UseCases}
mkdir -p "$BASE/Core/Data/Network/"{API,DTOs}
mkdir -p "$BASE/Core/Data/Local/"{Keychain,CoreData,UserDefaults}
mkdir -p "$BASE/Core/Data/Repositories"
mkdir -p "$BASE/Core/Extensions"
cat > "$BASE/Core/README.md" << 'CORE_README'
# Core Module
Shared business logic and infrastructure used across ALL features.
CORE_README
echo "  ✅ Core created"
echo "🎨 Creating DesignSystem..."
mkdir -p "$BASE/DesignSystem/Tokens"
mkdir -p "$BASE/DesignSystem/Atoms/"{Buttons,Inputs,Loading}
mkdir -p "$BASE/DesignSystem/Molecules/"{Cards,Forms}
mkdir -p "$BASE/DesignSystem/Organisms/"{Navigation,Headers}
cat > "$BASE/DesignSystem/README.md" << 'DESIGN_README'
# Design System
Reusable UI components with NO business logic.
DESIGN_README
echo "  ✅ DesignSystem created"
echo "⚙️  Creating Basic Features..."
for feature in Authentication Onboarding Profile Settings Discovery Search Payment Messaging; do
  echo "  📁 $feature"
  mkdir -p "$BASE/Features/$feature/Domain/"{Entities,UseCases,Repositories}
  mkdir -p "$BASE/Features/$feature/Data/"{DTOs,Repositories,DataSources}
  mkdir -p "$BASE/Features/$feature/Presentation/"{ViewModels,Views/Components}
done
echo "  ✅ Basic features created"
echo "🎯 Creating Core USP Placeholders..."
mkdir -p "$BASE/Features/MatchingAlgorithm/Domain/"{Entities,UseCases,Repositories}
mkdir -p "$BASE/Features/MatchingAlgorithm/Data/"{DTOs,Repositories,ML}
mkdir -p "$BASE/Features/MatchingAlgorithm/Presentation/"{ViewModels,Views}
cat > "$BASE/Features/MatchingAlgorithm/README.md" << 'MATCH_README'
# Matching Algorithm - Core USP
Status: 🚧 PLACEHOLDER
Creator-product affinity matching algorithm.
MATCH_README
mkdir -p "$BASE/Features/IndirectCommerce/Domain/"{Entities,UseCases}
mkdir -p "$BASE/Features/IndirectCommerce/Data/Repositories"
mkdir -p "$BASE/Features/IndirectCommerce/Presentation/"{ViewModels,Views}
cat > "$BASE/Features/IndirectCommerce/README.md" << 'COMMERCE_README'
# Indirect Commerce - Core USP
Status: 🚧 PLACEHOLDER
Multi-touchpoint attribution tracking.
COMMERCE_README
echo "  ✅ Core USP placeholders created"
echo "🏆 Creating Market Competitive Placeholders..."
mkdir -p "$BASE/Features/CreatorToolkit/Domain/"{Entities,UseCases}
mkdir -p "$BASE/Features/CreatorToolkit/Data/Repositories"
mkdir -p "$BASE/Features/CreatorToolkit/Presentation/ViewModels"
mkdir -p "$BASE/Features/CreatorToolkit/Presentation/Views/"{BackgroundGeneration,NarrativePrompts,VideoEditor}
cat > "$BASE/Features/CreatorToolkit/README.md" << 'TOOLKIT_README'
# Creator Toolkit - Market Competitive
Status: 🚧 PLACEHOLDER
AI-enhanced content creation tools.
TOOLKIT_README
mkdir -p "$BASE/Features/PerformanceIntelligence/Domain/"{Entities,UseCases}
mkdir -p "$BASE/Features/PerformanceIntelligence/Data/Repositories"
mkdir -p "$BASE/Features/PerformanceIntelligence/Presentation/"{ViewModels,Views}
cat > "$BASE/Features/PerformanceIntelligence/README.md" << 'PERF_README'
# Performance Intelligence - Market Competitive
Status: 🚧 PLACEHOLDER
Real-time creator analytics.
PERF_README
mkdir -p "$BASE/Features/CommunityValidation/Domain/"{Entities,UseCases}
mkdir -p "$BASE/Features/CommunityValidation/Data/Repositories"
mkdir -p "$BASE/Features/CommunityValidation/Presentation/"{ViewModels,Views}
cat > "$BASE/Features/CommunityValidation/README.md" << 'COMMUNITY_README'
# Community Validation - Market Competitive
Status: 🚧 PLACEHOLDER
Peer review and trust building.
COMMUNITY_README
mkdir -p "$BASE/Features/ContentAnalysis/Domain/"{Entities,UseCases}
mkdir -p "$BASE/Features/ContentAnalysis/Data/"{Repositories,ML}
mkdir -p "$BASE/Features/ContentAnalysis/Presentation/ViewModels"
cat > "$BASE/Features/ContentAnalysis/README.md" << 'ANALYSIS_README'
# Content Analysis - Market Competitive
Status: 🚧 PLACEHOLDER
AI video analysis and Thai NLP.
ANALYSIS_README
echo "  ✅ Market Competitive placeholders created"
echo "🔌 Creating Platform integrations..."
mkdir -p "$BASE/Platform/LINE/"{Auth,Messaging,Models}
mkdir -p "$BASE/Platform/Firebase/"{Auth,Analytics,Storage}
mkdir -p "$BASE/Platform/PromptPay/"{QRCode,Verification,Models}
cat > "$BASE/Platform/README.md" << 'PLATFORM_README'
# Platform Integrations
Third-party SDK wrappers (LINE, Firebase, PromptPay).
PLATFORM_README
echo "  ✅ Platform integrations created"
echo "🛠️  Creating Shared utilities..."
mkdir -p "$BASE/Shared/"{Constants,Extensions,Models}
mkdir -p "$BASE/Shared/Utilities/"{Validators,Formatters,VideoPlayer}
cat > "$BASE/Shared/README.md" << 'SHARED_README'
# Shared Module
Reusable utilities and extensions.
SHARED_README
echo "  ✅ Shared utilities created"
echo "📝 Creating Features README..."
cat > "$BASE/Features/README.md" << 'FEATURES_README'
# Features Module

## Basic/Operational (Phase 1 - Active)
1. Authentication - LINE OAuth, Apple Sign-In
2. Onboarding - Profile setup, Terms
3. Profile - View/edit profile
4. Settings - Notifications, Privacy
5. Discovery - Video feed
6. Search - Search & filters
7. Payment - PromptPay
8. Messaging - Direct messages

## Core USP (Phase 2 - Placeholder)
1. MatchingAlgorithm
2. IndirectCommerce

## Market Competitive (Phase 3 - Placeholder)
1. CreatorToolkit
2. PerformanceIntelligence
3. CommunityValidation
4. ContentAnalysis

## Rules
- Features are independent
- Depend on Core, NOT other Features
- Follow Clean Architecture
FEATURES_README
echo "  ✅ Features README created"
echo ""
echo "✅ Setup Complete!"
echo ""
echo "📊 Summary:"
echo "   ✅ Core module (shared business logic)"
echo "   ✅ DesignSystem (UI components)"
echo "   ✅ 8 Basic/Operational features"
echo "   ✅ 2 Core USP placeholders"
echo "   ✅ 4 Market Competitive placeholders"
echo "   ✅ Platform integrations (LINE, Firebase, PromptPay)"
echo "   ✅ Shared utilities"
echo ""
echo "🎯 Next Steps:"
echo "   1. Review structure: tree Sources/"
echo "   2. Read: cat Sources/Features/README.md"
echo "   3. Start coding: Authentication feature"
echo ""
echo "🚀 Ready to build!"
