#!/bin/bash

# macOS Code Signing and Notarization Script for Recogniz.ing
# This script signs and notarizes the macOS build for distribution

set -e

# Configuration
DEVELOPER_ID_APPLICATION=""  # Your Apple Developer ID Application certificate (e.g., "Developer ID Application: Your Name (TEAM_ID)")
DEVELOPER_ID_INSTALLER=""      # Your Apple Developer ID Installer certificate
TEAM_ID=""                    # Your 10-character Team ID
APPLE_ID=""                   # Your Apple ID for notarization
APPLE_ID_PASSWORD=""           # App-specific password (generate at appleid.apple.com)

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

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."

    if ! command -v codesign &> /dev/null; then
        print_error "codesign not found. Please install Xcode Command Line Tools."
        exit 1
    fi

    if ! command -v xcrun &> /dev/null; then
        print_error "xcrun not found. Please install Xcode."
        exit 1
    fi

    if ! command -v ditto &> /dev/null; then
        print_error "ditto not found."
        exit 1
    fi

    print_success "All required tools found"
}

# Check certificates
check_certificates() {
    print_status "Checking available certificates..."

    security find-identity -v -p codesigning | grep "$TEAM_ID" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        print_error "No valid Developer ID certificates found for team: $TEAM_ID"
        print_status "Please ensure you have:"
        print_status "1. An Apple Developer Account"
        print_status "2. Generated a Developer ID Application certificate"
        print_status "3. Downloaded and installed the certificate in Keychain Access"
        exit 1
    fi

    print_success "Developer ID certificates found"
}

# Build the app
build_app() {
    print_status "Building Flutter app for macOS..."
    flutter clean
    flutter pub get
    flutter build macos --release

    APP_PATH="build/macos/Build/Products/Release/recognizing.app"

    if [ ! -d "$APP_PATH" ]; then
        print_error "Build failed: app not found at $APP_PATH"
        exit 1
    fi

    print_success "Build completed"
}

# Sign the app
sign_app() {
    print_status "Signing the application..."

    APP_PATH="build/macos/Build/Products/Release/recognizing.app"

    # First, sign all frameworks and dylibs
    find "$APP_PATH/Contents/Frameworks" -name "*.framework" -exec codesign --force --options runtime --sign "$DEVELOPER_ID_APPLICATION" {} \;
    find "$APP_PATH" -name "*.dylib" -exec codesign --force --sign "$DEVELOPER_ID_APPLICATION" {} \;

    # Sign the app itself
    codesign --force --options runtime --sign "$DEVELOPER_ID_APPLICATION" --deep "$APP_PATH"

    # Verify signature
    codesign --verify --deep --strict --verbose=2 "$APP_PATH"

    print_success "Application signed successfully"
}

# Create DMG
create_dmg() {
    print_status "Creating DMG package..."

    VERSION=$(grep "version:" pubspec.yaml | cut -d: -f2 | xargs)
    DMG_NAME="recognizing-$VERSION-macos"
    DMG_PATH="$DMG_NAME.dmg"

    APP_PATH="build/macos/Build/Products/Release/recognizing.app"

    # Create DMG
    create-dmg \
        --volname "Recogniz.ing" \
        --volicon "$APP_PATH/Contents/Resources/AppIcon.icns" \
        --window-pos 200 120 \
        --window-size 600 450 \
        --icon-size 100 \
        --icon "$APP_PATH" 175 120 \
        --hide-extension "$APP_PATH" \
        --app-drop-link 425 120 \
        --background "$PWD/scripts/dmg-background.png" \
        --disk-image-size 200 \
        "$DMG_PATH" \
        "$APP_PATH" || {
        # Fallback if create-dmg is not installed
        print_warning "create-dmg not found, using hdiutil..."

        # Create temporary directory
        TMP_DIR="$DMG_NAME-tmp"
        mkdir "$TMP_DIR"

        # Copy app
        cp -R "$APP_PATH" "$TMP_DIR/"

        # Create Applications symlink
        ln -s /Applications "$TMP_DIR/Applications"

        # Create DMG
        hdiutil create -srcfolder "$TMP_DIR" -volname "Recogniz.ing" -fs HFS+ -fsargs "-c c=64,a=16,e=16" "$DMG_PATH"

        # Clean up
        rm -rf "$TMP_DIR"
    }

    print_success "DMG created: $DMG_PATH"
}

# Submit for notarization
notarize_app() {
    print_status "Submitting for notarization..."

    DMG_PATH="recognizing-$(grep "version:" pubspec.yaml | cut -d: -f2 | xargs)-macos.dmg"

    if [ ! -f "$DMG_PATH" ]; then
        print_error "DMG file not found: $DMG_PATH"
        exit 1
    fi

    # Upload for notarization
    print_status "Uploading to Apple's notarization service..."
    xcrun altool --notarize-app \
        --primary-bundle-id "recogniz.ing.recogniz.ing" \
        --username "$APPLE_ID" \
        --password "$APPLE_ID_PASSWORD" \
        --file "$DMG_PATH" \
        --output-format json > notarization.json

    # Extract request UUID
    REQUEST_UUID=$(grep -o '"RequestUUID": "[^"]*' notarization.json | cut -d'"' -f4)

    if [ -z "$REQUEST_UUID" ]; then
        print_error "Failed to submit for notarization"
        cat notarization.json
        exit 1
    fi

    print_success "Notarization submitted with UUID: $REQUEST_UUID"

    # Wait for notarization to complete
    print_status "Waiting for notarization to complete..."

    while true; do
        xcrun altool --notarization-info \
            --username "$APPLE_ID" \
            --password "$APPLE_ID_PASSWORD" \
            --request-uuid "$REQUEST_UUID" \
            --output-format json > notarization-status.json

        STATUS=$(grep -o '"Status": "[^"]*' notarization-status.json | cut -d'"' -f4)

        if [ "$STATUS" = "success" ]; then
            print_success "Notarization completed successfully"
            break
        elif [ "$STATUS" = "invalid" ]; then
            print_error "Notarization failed"
            cat notarization-status.json
            exit 1
        fi

        print_status "Status: $STATUS... waiting 30 seconds"
        sleep 30
    done

    # Staple the notarization
    print_status "Stapling notarization to DMG..."
    xcrun stapler staple "$DMG_PATH"

    print_success "Notarization stapled to DMG"

    # Verify notarization
    print_status "Verifying notarization..."
    xcrun stapler validate -v "$DMG_PATH"

    print_success "DMG is properly notarized"
}

# Main execution
main() {
    print_status "Starting macOS code signing and notarization process"

    # Check configuration
    if [ -z "$DEVELOPER_ID_APPLICATION" ] || [ -z "$TEAM_ID" ] || [ -z "$APPLE_ID" ] || [ -z "$APPLE_ID_PASSWORD" ]; then
        print_error "Please configure the following variables at the top of this script:"
        print_error "- DEVELOPER_ID_APPLICATION"
        print_error "- TEAM_ID"
        print_error "- APPLE_ID"
        print_error "- APPLE_ID_PASSWORD"
        exit 1
    fi

    check_requirements
    check_certificates
    build_app
    sign_app
    create_dmg
    notarize_app

    print_success "Code signing and notarization completed successfully!"
    print_status "You can now distribute the signed DMG file"
}

# Run main function
main "$@"