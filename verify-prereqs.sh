#!/usr/bin/env bash
set -euo pipefail

echo "=== Project X Prerequisite Verification ==="

OS_TYPE="$(uname -s)"
echo "Operating System: $OS_TYPE ($(uname -m))"

ERRORS=0

# 1. Check macOS
if [[ "$OS_TYPE" != "Darwin" ]]; then
    echo "⚠️  Non-macOS environment detected ($OS_TYPE)."
    echo "    Compiling the native iOS application bundle and running XCTest requires macOS with Xcode."
    echo "    This environment can generate project files, validate plist schemas, and run cross-platform tests."
else
    echo "✅ macOS environment confirmed."
    
    # 2. Check Xcode
    if command -v xcodebuild >/dev/null 2>&1; then
        XCODE_VER=$(xcodebuild -version | head -n 1)
        echo "✅ Xcode detected: $XCODE_VER"
    else
        echo "❌ xcodebuild not found. Install Xcode 16.0+ from the Mac App Store."
        ERRORS=$((ERRORS + 1))
    fi

    # 3. Check XcodeGen
    if command -v xcodegen >/dev/null 2>&1; then
        echo "✅ xcodegen detected: $(xcodegen --version 2>/dev/null || echo 'available')"
    else
        echo "⚠️  xcodegen not found. Install via: brew install xcodegen"
        ERRORS=$((ERRORS + 1))
    fi
fi

# 4. Check Python 3 & plistlib for local verification
if command -v python3 >/dev/null 2>&1; then
    if python3 -c "import plistlib" 2>/dev/null; then
        echo "✅ python3 with plistlib available for local schema validation."
    fi
fi

if [[ $ERRORS -eq 0 && "$OS_TYPE" == "Darwin" ]]; then
    echo "✅ All prerequisites satisfied for native iOS build."
    exit 0
elif [[ "$OS_TYPE" != "Darwin" ]]; then
    echo "ℹ️  Prerequisites verified for Linux development & schema validation. Use GitHub Actions for macOS build."
    exit 0
else
    echo "❌ Some prerequisites are missing."
    exit 1
fi
