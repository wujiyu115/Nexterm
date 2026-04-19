#!/bin/bash
set -e

echo "🍎 Building Nexterm iOS (release, no-codesign)..."
echo ""

cd "$(dirname "$0")"

# Clean previous build artifacts
echo "🧹 Cleaning previous build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build iOS release without code signing
echo "🔨 Building iOS release (no-codesign)..."
flutter build ios --release --no-codesign

echo ""
echo "✅ Build completed successfully!"
echo ""
echo "📂 Output: build/ios/iphoneos/Runner.app"
echo ""
echo "Next steps:"
echo "  1. Open Xcode:  open ios/Runner.xcworkspace"
echo "  2. Product → Archive"
echo "  3. Distribute App → Development"
echo "  4. Export .ipa"
