#!/bin/bash

# Script to create a GitHub Release with build assets

set -e

echo "🚀 Creating GitHub Release for Recogniz.ing"
echo "=========================================="

# Configuration
VERSION=${1:-"1.0.2"}
REPO="xicv/recogniz.ing"
GITHUB_API="https://api.github.com"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first."
    echo "   Visit: https://cli.github.com/"
    exit 1
fi

# Check if we're authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub. Run: gh auth login"
    exit 1
fi

echo "📋 Version: $VERSION"
echo "📦 Repository: $REPO"

# Create release notes
RELEASE_NOTES="## Recogniz.ing v$VERSION

### What's New
- AI-powered voice typing with Gemini API integration
- Customizable prompts and vocabulary
- Real-time transcription
- Cross-platform support (macOS, Windows, Linux, Android)

### Installation
1. Download the appropriate file for your platform
2. Extract the archive
3. Install the application
4. Configure your Gemini API key in settings

### Requirements
- Gemini API key (free at https://aistudio.google.com/app/apikey)
- Microphone access

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)"

# Create the release
echo ""
echo "📝 Creating release..."

# Check if release already exists
if gh release view v$VERSION &> /dev/null; then
    echo "⚠️  Release v$VERSION already exists. Deleting it first..."
    gh release delete v$VERSION --yes
fi

# Create new release
gh release create v$VERSION \
    --title "Recogniz.ing v$VERSION" \
    --notes "$RELEASE_NOTES" \
    --latest

echo "✅ Release v$VERSION created successfully!"
echo ""
echo "📎 Now add your build assets to the release:"
echo "   gh release upload v$VERSION path/to/your/build.zip"

# Add common platform examples
echo ""
echo "💡 Example commands to upload builds:"
echo "   gh release upload v$VERSION ../recogniz/build/macos/*.zip --clobber"
echo "   gh release upload v$VERSION ../recogniz/build/windows/*.zip --clobber"
echo "   gh release upload v$VERSION ../recogniz/build/linux/*.zip --clobber"