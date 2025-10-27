#!/bin/bash
echo "📂 Checking feature directories..."
cd Sources/Features

for feature in Authentication Onboarding Profile Settings Discovery Search Payment Messaging MatchingAlgorithm IndirectCommerce CreatorToolkit PerformanceIntelligence CommunityValidation ContentAnalysis; do
  if [ -d "$feature" ]; then
    echo "✅ $feature exists"
  else
    echo "❌ $feature MISSING - creating now..."
    mkdir -p "$feature/Domain/"{Entities,UseCases,Repositories}
    mkdir -p "$feature/Data/"{DTOs,Repositories,DataSources}
    mkdir -p "$feature/Presentation/"{ViewModels,Views/Components}
  fi
done

cd ../..
echo ""
echo "✅ All features verified!"
echo ""
echo "📋 Feature list:"
ls -1 Sources/Features/
