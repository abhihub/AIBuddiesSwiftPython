#!/bin/bash

echo "🐕 Copying built AIBuddies app..."

# Create distribution folder
mkdir -p dist

# Remove old app first
if [ -d "dist/AIBuddies.app" ]; then
    echo "🗑️  Removing old AIBuddies.app..."
    rm -rf dist/AIBuddies.app
fi

# Find the most recent build
BUILD_DIR="/Users/abhishekarora/Library/Developer/Xcode/DerivedData/AIBuddies-*/Build/Products/Debug"
LATEST_BUILD=$(ls -td $BUILD_DIR 2>/dev/null | head -n 1)

if [ -z "$LATEST_BUILD" ]; then
    echo "❌ No built app found. Run the build first."
    exit 1
fi

echo "📂 Using build from: $LATEST_BUILD"

# Copy the app
if [ -d "$LATEST_BUILD/AIBuddies.app" ]; then
    # Show timestamp of source app
    echo "📅 Source app timestamp: $(stat -f "%Sm" "$LATEST_BUILD/AIBuddies.app")"
    
    cp -R "$LATEST_BUILD/AIBuddies.app" dist/
    
    # Show timestamp of copied app
    echo "📅 Copied app timestamp: $(stat -f "%Sm" "dist/AIBuddies.app")"
    
    echo "✅ AIBuddies.app copied to dist/ folder"
    echo "📦 App ready for distribution!"
    echo ""
    echo "To install:"
    echo "1. Open the dist/ folder"
    echo "2. Drag AIBuddies.app to your Applications folder"
    echo "3. Right-click and select 'Open' (first time only)"
    echo "4. Enter your OpenAI API key when prompted"
    echo "5. Look for the floating dog icon in the bottom-right!"
else
    echo "❌ AIBuddies.app not found in build directory"
    exit 1
fi