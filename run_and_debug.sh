#!/bin/bash

echo "🚀 Building and running Dice app..."

# Build
echo "📦 Building..."
xcodebuild -project Dice.xcodeproj -scheme Dice -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build succeeded"

# Boot simulator
echo "🔄 Booting simulator..."
xcrun simctl boot "iPhone 17 Pro" 2>/dev/null || echo "Simulator already booted"
sleep 2

# Open Simulator app
open -a Simulator

# Install app
echo "📲 Installing app..."
xcrun simctl install booted /Users/kmanickavelu/Library/Developer/Xcode/DerivedData/Dice-akcmcxpelkojrwgneyjzegietaqy/Build/Products/Debug-iphonesimulator/Dice.app

# Launch app and show output
echo "🎬 Launching app..."
echo "📱 App should appear in simulator now"
echo "📋 Console output:"
echo "─────────────────────────────────────"

xcrun simctl launch --console-pty booted com.dice.app

echo "─────────────────────────────────────"
echo "✅ App launched. Check simulator window."
