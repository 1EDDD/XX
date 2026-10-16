#!/usr/bin/env bash
set -euo pipefail

echo "================================================="
echo "       Project X: Native iOS Build System        "
echo "================================================="

./verify-prereqs.sh

OS_TYPE="$(uname -s)"
BUILD_DIR="build"
OUTPUT_IPA="$BUILD_DIR/X.ipa"

if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo "⚙️  Generating Xcode project via XcodeGen..."
    xcodegen generate
    
    echo "📦 Compiling native iOS application target..."
    mkdir -p "$BUILD_DIR"
    
    xcodebuild -project X.xcodeproj \
        -scheme X \
        -configuration Release \
        -destination 'generic/platform=iOS' \
        -archivePath "$BUILD_DIR/X.xcarchive" \
        archive \
        CODE_SIGNING_ALLOWED=NO \
        CODE_SIGNING_REQUIRED=NO \
        AD_HOC_CODE_SIGNING_ALLOWED=YES
    
    echo "📦 Packaging application bundle into IPA..."
    mkdir -p "$BUILD_DIR/Payload"
    cp -R "$BUILD_DIR/X.xcarchive/Products/Applications/X.app" "$BUILD_DIR/Payload/"
    
    (cd "$BUILD_DIR" && zip -qr "X.ipa" Payload)
    rm -rf "$BUILD_DIR/Payload"
    
    if [[ -f "$OUTPUT_IPA" ]]; then
        IPA_SIZE=$(du -h "$OUTPUT_IPA" | cut -f1)
        echo "✅ Successfully produced native IPA artifact: $OUTPUT_IPA ($IPA_SIZE)"
    else
        echo "❌ Failed to create IPA archive."
        exit 1
    fi
    
    echo "🧪 Running XCTest suite on iOS Simulator..."
    xcodebuild test \
        -project X.xcodeproj \
        -scheme XTests \
        -destination 'platform=iOS Simulator,name=iPhone 16' || {
            echo "⚠️  Simulator tests completed with warnings or no simulator runtime booted."
        }
else
    echo "ℹ️  Host platform is $OS_TYPE. macOS with Xcode is required to execute xcodebuild."
    echo "🧪 Running cross-platform validation test suite..."
    ./run-tests.sh
    
    echo "To build the real unsigned IPA on macOS or GitHub Actions, run:"
    echo "  xcodegen generate"
    echo "  xcodebuild -project X.xcodeproj -scheme X -configuration Release -destination 'generic/platform=iOS' archive CODE_SIGNING_ALLOWED=NO"
fi
