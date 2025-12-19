#!/bin/bash

# Version Bumping Script for Recogniz.ing
# Usage: ./scripts/version-bump.sh [major|minor|patch|prerelease] [pre-release-id]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found! Please run this script from the project root."
    exit 1
fi

# Parse current version from pubspec.yaml
CURRENT_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
VERSION_PART=$(echo $CURRENT_VERSION | cut -d'+' -f1)
BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)

print_status "Current version: $CURRENT_VERSION"
print_status "Version part: $VERSION_PART"
print_status "Build number: $BUILD_NUMBER"

# Parse version numbers
MAJOR=$(echo $VERSION_PART | cut -d'.' -f1)
MINOR=$(echo $VERSION_PART | cut -d'.' -f2)
PATCH=$(echo $VERSION_PART | cut -d'.' -f3)

# Determine bump type
BUMP_TYPE=$1
PRE_RELEASE_ID=$2

# Calculate new version
case $BUMP_TYPE in
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_MINOR=0
        NEW_PATCH=0
        PRE_RELEASE=""
        print_status "Bumping MAJOR version: $MAJOR -> $NEW_MAJOR"
        ;;
    minor)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$((MINOR + 1))
        NEW_PATCH=0
        PRE_RELEASE=""
        print_status "Bumping MINOR version: $MINOR -> $NEW_MINOR"
        ;;
    patch)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$MINOR
        NEW_PATCH=$((PATCH + 1))
        PRE_RELEASE=""
        print_status "Bumping PATCH version: $PATCH -> $NEW_PATCH"
        ;;
    prerelease)
        if [ -z "$PRE_RELEASE_ID" ]; then
            print_error "Pre-release ID required for prerelease bump"
            echo "Usage: ./scripts/version-bump.sh prerelease <pre-release-id>"
            exit 1
        fi
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$MINOR
        NEW_PATCH=$PATCH
        PRE_RELEASE="-$PRE_RELEASE_ID"
        print_status "Creating PRE-RELEASE: $PRE_RELEASE_ID"
        ;;
    build)
        # Only increment build number
        NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
        NEW_VERSION="$VERSION_PART+$NEW_BUILD_NUMBER"

        print_status "Incrementing build number: $BUILD_NUMBER -> $NEW_BUILD_NUMBER"

        # Update pubspec.yaml
        if command -v gsed &> /dev/null; then
            gsed -i "s/version: .*/version: $NEW_VERSION/" pubspec.yaml
        else
            sed -i '' "s/version: .*/version: $NEW_VERSION/" pubspec.yaml
        fi

        print_success "Version updated to: $NEW_VERSION"

        # Commit if git is available
        if command -v git &> /dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
            read -p "Commit this version bump? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git add pubspec.yaml
                git commit -m "chore: bump build number to $NEW_VERSION"
                print_success "Committed version bump"
            fi
        fi

        exit 0
        ;;
    *)
        print_error "Invalid bump type: $BUMP_TYPE"
        echo "Usage: ./scripts/version-bump.sh [major|minor|patch|prerelease|build] [pre-release-id]"
        exit 1
        ;;
esac

# Construct new version
NEW_VERSION_PART="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH$PRE_RELEASE"
NEW_BUILD_NUMBER=1  # Reset build number for version changes
NEW_VERSION="$NEW_VERSION_PART+$NEW_BUILD_NUMBER"

print_status "New version will be: $NEW_VERSION"

# Confirm the change
read -p "Do you want to update version from $CURRENT_VERSION to $NEW_VERSION? [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Version bump cancelled"
    exit 0
fi

# Update pubspec.yaml
if command -v gsed &> /dev/null; then
    gsed -i "s/version: .*/version: $NEW_VERSION/" pubspec.yaml
else
    sed -i '' "s/version: .*/version: $NEW_VERSION/" pubspec.yaml
fi

print_success "Version updated to: $NEW_VERSION"

# Create git tag if requested
if command -v git &> /dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
    read -p "Create and push git tag v$NEW_VERSION_PART? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add pubspec.yaml
        git commit -m "chore: bump version to $NEW_VERSION"
        git tag -a "v$NEW_VERSION_PART" -m "Release v$NEW_VERSION_PART"

        read -p "Push tag to remote? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push origin "v$NEW_VERSION_PART"
            print_success "Tag pushed to remote"
        fi

        print_success "Created git tag v$NEW_VERSION_PART"
    fi
fi

# Show next steps
echo
print_status "Next steps:"
echo "  1. Run 'flutter pub get' to update dependencies"
echo "  2. Test the app with the new version"
echo "  3. Build release packages with: make deploy-all"
echo
print_success "Version bump complete!"