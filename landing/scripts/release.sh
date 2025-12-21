#!/bin/bash

# Release script for Recogniz.ing
# This script helps upload new builds to the repository with proper LFS tracking

set -e

echo "🚀 Recogniz.ing Release Script"
echo "================================"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Please run this script from the root of the landing directory"
    exit 1
fi

# Parse command line arguments
PLATFORM=${1:-"all"}
VERSION=${2:-"1.0.3"}

echo "📦 Platform: $PLATFORM"
echo "📋 Version: $VERSION"

# Create downloads directory if it doesn't exist
mkdir -p public/downloads/macos
mkdir -p public/downloads/windows
mkdir -public/downloads/linux
mkdir -p public/downloads/android

# Function to copy build file to downloads directory
copy_build() {
    local platform=$1
    local source_path="../../recogniz/build/$platform/*.zip"
    local dest_path="public/downloads/$platform/$VERSION"

    echo "🔍 Looking for $platform build in: $source_path"

    # Find the build file
    local build_file=$(find ../../recogniz/build/$platform -name "*.zip" -type f | head -1)

    if [ -n "$build_file" ]; then
        mkdir -p "$dest_path"
        local filename=$(basename "$build_file")
        cp "$build_file" "$dest_path/$filename"
        echo "✅ Copied $filename to $dest_path"

        # Add to Git if it's a new file
        git add "$dest_path/$filename"
    else
        echo "⚠️  Warning: No $platform build found. Skipping."
    fi
}

# Copy builds based on platform argument
case $PLATFORM in
    "macos")
        copy_build "macos"
        ;;
    "windows")
        copy_build "windows"
        ;;
    "linux")
        copy_build "linux"
        ;;
    "android")
        copy_build "android"
        ;;
    "all")
        copy_build "macos"
        copy_build "windows"
        copy_build "linux"
        copy_build "android"
        ;;
    *)
        echo "❌ Error: Unknown platform '$PLATFORM'"
        echo "Usage: $0 [platform|all] [version]"
        echo "Platforms: macos, windows, linux, android, all"
        exit 1
        ;;
esac

# Update manifest.json with new version
echo ""
echo "📝 Updating manifest.json..."
cat > public/downloads/manifest.json << EOF
{
  "version": "$VERSION",
  "build_date": "$(date +%Y-%m-%d)",
  "platforms": {
    "macos": "macos/$VERSION/$(find public/downloads/macos -name "*.zip" -type f -exec basename {} \; | head -1)",
    "windows": "#",
    "linux": "#",
    "android_aab": "#"
  }
}
EOF

git add public/downloads/manifest.json
echo "✅ Updated manifest.json"

# Commit changes
echo ""
echo "💾 Committing changes..."
git commit -m "Release $VERSION

- Update builds for: $PLATFORM
- Update manifest.json to version $VERSION
- Built on $(date +%Y-%m-%d)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"

# Push to GitHub
echo ""
echo "🚀 Pushing to GitHub..."
git push origin main

echo ""
echo "✅ Release $VERSION completed successfully!"
echo ""
echo "📊 Repository Info:"
echo "   - Platform: $PLATFORM"
echo "   - Version: $VERSION"
echo "   - LFS Status: $(git lfs ls-files | wc -l | tr -d ' ') files tracked"
echo ""
echo "🔗 Your site will be available at:"
echo "   - GitHub Pages: https://xicv.github.io/recogniz.ing"
echo "   - Custom Domain: https://recogniz.ing (once DNS is configured)"