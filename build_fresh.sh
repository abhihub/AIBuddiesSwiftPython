#!/bin/bash

echo "🏗️  Building AIBuddies (Fresh Build)..."

# Clean any previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild clean -project AIBuddies.xcodeproj -quiet

# Remove derived data
echo "🗑️  Removing derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/AIBuddies-*

# Build fresh
echo "🔨 Building fresh..."
xcodebuild -project AIBuddies.xcodeproj -scheme AIBuddies -configuration Debug build

if [ $? -eq 0 ]; then
    echo "✅ Build succeeded!"
    echo "📦 Copying to distribution..."
    ./copy_built_app.sh
else
    echo "❌ Build failed!"
    exit 1
fi