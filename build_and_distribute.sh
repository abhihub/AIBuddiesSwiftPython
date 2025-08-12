#!/bin/bash

# AIBuddies Build and Distribution Script

echo "🐕 Building AIBuddies..."

# Clean previous builds
rm -rf build/
rm -rf DerivedData/

# Create build directory
mkdir -p build

# Build the app
echo "📦 Building macOS app..."
xcodebuild -project AIBuddies.xcodeproj \
    -scheme AIBuddies \
    -configuration Release \
    -derivedDataPath DerivedData \
    -archivePath build/AIBuddies.xcarchive \
    archive

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Export the app
echo "📱 Exporting app..."
xcodebuild -exportArchive \
    -archivePath build/AIBuddies.xcarchive \
    -exportPath build/Export \
    -exportOptionsPlist exportOptions.plist

if [ $? -ne 0 ]; then
    echo "❌ Export failed!"
    exit 1
fi

# Create distribution folder
echo "📁 Creating distribution package..."
mkdir -p build/AIBuddies-Distribution

# Copy app to distribution folder
cp -r "build/Export/AIBuddies.app" build/AIBuddies-Distribution/

# Create installation instructions
cat > build/AIBuddies-Distribution/INSTALL.md << EOF
# AIBuddies Installation Guide

## Prerequisites
1. macOS 13.0 or later
2. OpenAI API key (get one at https://platform.openai.com/)

## Installation Steps
1. Drag AIBuddies.app to your Applications folder
2. Double-click to open AIBuddies
3. When prompted, enter your OpenAI API key
4. The floating icon will appear in the bottom-right corner
5. Click the icon to start chatting!

## Features
- 🐕 Leo Pet: Your friendly AI companion
- 💬 Chat with AI using OpenAI's GPT
- 🔔 Notifications when AI responds
- 🪟 Native macOS experience

## Troubleshooting
- If the app doesn't open: Right-click > Open (first time only)
- If Python errors occur: Install Python 3 and openai library
- For API issues: Check your OpenAI API key and credit balance

Enjoy chatting with Leo Pet! 🐕
EOF

# Create DMG (optional - requires create-dmg tool)
if command -v create-dmg &> /dev/null; then
    echo "💿 Creating DMG installer..."
    create-dmg \
        --volname "AIBuddies" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "AIBuddies.app" 200 190 \
        --hide-extension "AIBuddies.app" \
        --app-drop-link 400 190 \
        "build/AIBuddies-v1.0.dmg" \
        "build/AIBuddies-Distribution/"
else
    echo "📦 Creating ZIP distribution..."
    cd build/AIBuddies-Distribution
    zip -r ../AIBuddies-v1.0.zip .
    cd ../..
fi

echo "✅ AIBuddies build complete!"
echo "📦 Distribution files available in: build/"