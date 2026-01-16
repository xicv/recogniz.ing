#!/bin/bash

# macOS Code Signing and Notarization Script for Recogniz.ing
# This script signs and notarizes the macOS build for distribution
#
# Prerequisites:
# 1. Run 'xcrun notarytool store-credentials' to store your Apple ID credentials
# 2. Have Developer ID Application certificate installed in Keychain Access
#
# Store credentials one-time:
#   xcrun notarytool store-credentials "recognizing" \
#     --apple-id "your@email.com" \
#     --team-id "YOUR_TEAM_ID" \
#     --password "app-specific-password"

set -e

# Configuration
NOTARY_PROFILE="recognizing"  # Keychain profile name for notarytool credentials
DEVELOPER_ID_APPLICATION=""   # Your Apple Developer ID Application certificate name

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

    if [ -z "$DEVELOPER_ID_APPLICATION" ]; then
        print_error "DEVELOPER_ID_APPLICATION not set"
        print_status "Please set this to your Developer ID Application certificate name"
        exit 1
    fi

    if security find-identity -v -p codesigning | grep "$DEVELOPER_ID_APPLICATION" > /dev/null 2>&1; then
        print_success "Developer ID certificate found: $DEVELOPER_ID_APPLICATION"
    else
        print_error "No valid Developer ID certificates found matching: $DEVELOPER_ID_APPLICATION"
        print_status "Please ensure you have:"
        print_status "1. An Apple Developer Account"
        print_status "2. Generated a Developer ID Application certificate"
        print_status "3. Downloaded and installed the certificate in Keychain Access"
        print_status ""
        print_status "Available certificates:"
        security find-identity -v -p codesigning | head -5
        exit 1
    fi
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

    # Check if notarytool profile exists (by testing history command)
    print_status "Verifying notarytool credentials..."
    if ! xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" &>/dev/null; then
        print_error "Notarytool credentials not found in keychain for profile: $NOTARY_PROFILE"
        print_status ""
        print_status "Run the following command to store credentials:"
        print_status "  xcrun notarytool store-credentials \"$NOTARY_PROFILE\" \\"
        print_status "    --apple-id \"your@email.com\" \\"
        print_status "    --team-id \"YOUR_TEAM_ID\" \\"
        print_status "    --password \"app-specific-password\""
        print_status ""
        exit 1
    fi

    # Submit for notarization (waits for completion)
    print_status "Uploading to Apple's notarization service..."
    print_status "This may take a few minutes..."

    if xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "$NOTARY_PROFILE" \
        --wait \
        --output-format json > notarization.json 2>&1; then

        # Check the result
        if grep -q '"status": "Accepted"' notarization.json; then
            print_success "Notarization completed successfully"
        else
            print_warning "Could not confirm 'Accepted' status. Check notarization.json for details."
            # Continue anyway - JSON format may vary
        fi
    else
        print_error "Notarization failed"
        cat notarization.json
        exit 1
    fi

    # Staple the notarization ticket to the DMG
    print_status "Stapling notarization ticket to DMG..."
    xcrun stapler staple "$DMG_PATH"

    print_success "Notarization ticket stapled to DMG"

    # Verify notarization
    print_status "Verifying notarization..."
    xcrun stapler validate -v "$DMG_PATH"

    print_success "DMG is properly notarized and ready for distribution"
}

# Main execution
main() {
    print_status "Starting macOS code signing and notarization process"

    # Check configuration
    if [ -z "$DEVELOPER_ID_APPLICATION" ]; then
        print_error "Please configure DEVELOPER_ID_APPLICATION at the top of this script"
        print_status "Set it to your Developer ID Application certificate name, e.g.:"
        print_status '  DEVELOPER_ID_APPLICATION="Developer ID Application: Your Name (TEAM_ID)"'
        print_status ""
        print_status "To find your certificate name, run:"
        print_status "  security find-identity -v -p codesigning"
        exit 1
    fi

    check_requirements
    check_certificates
    build_app
    sign_app
    create_dmg
    notarize_app

    print_success "Code signing and notarization completed successfully!"
    print_status "You can now distribute the signed and notarized DMG file"
}

# Run main function
main "$@"