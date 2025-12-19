#!/bin/bash

# Code Signing Configuration for Recogniz.ing
# Source this file to set up environment variables for signing

# Apple Developer Information
# IMPORTANT: Fill these values with your actual Apple Developer account information

# Your Apple Developer Team ID (10 characters, e.g., "ABCD123456")
export DEVELOPER_TEAM_ID=""

# Your Apple Developer ID (email address)
export APPLE_DEVELOPER_ID=""

# Application-specific password for Apple ID
# Generate at: https://appleid.apple.com/account/manage/security/apps
export APPLE_APP_PASSWORD=""

# Certificate Common Name (as it appears in Keychain Access)
export DEVELOPER_ID_APPLICATION_NAME="Developer ID Application: Your Name ($DEVELOPER_TEAM_ID)"

# Optional: For installer distribution
export DEVELOPER_ID_INSTALLER_NAME="Developer ID Installer: Your Name ($DEVELOPER_TEAM_ID)"

# Bundle ID of your app
export APP_BUNDLE_ID="recogniz.ing.recogniz.ing"

# Helper function to verify configuration
verify_codesign_config() {
    local missing_vars=()

    if [ -z "$DEVELOPER_TEAM_ID" ]; then
        missing_vars+=("DEVELOPER_TEAM_ID")
    fi

    if [ -z "$APPLE_DEVELOPER_ID" ]; then
        missing_vars+=("APPLE_DEVELOPER_ID")
    fi

    if [ -z "$APPLE_APP_PASSWORD" ]; then
        missing_vars+=("APPLE_APP_PASSWORD")
    fi

    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "❌ Missing required code signing configuration:"
        for var in "${missing_vars[@]}"; do
            echo "   - $var"
        done
        echo ""
        echo "Please edit scripts/codesign-config.sh and fill in your credentials."
        return 1
    fi

    echo "✅ Code signing configuration verified"
    return 0
}

# Function to check for installed certificates
check_codesign_certificates() {
    echo "🔍 Checking for Developer ID certificates..."

    if security find-identity -v -p codesigning | grep "$DEVELOPER_TEAM_ID" > /dev/null 2>&1; then
        echo "✅ Developer ID certificates found"
        return 0
    else
        echo "❌ No valid Developer ID certificates found for team: $DEVELOPER_TEAM_ID"
        echo ""
        echo "To fix this:"
        echo "1. Go to https://developer.apple.com/account/"
        echo "2. Go to Certificates, Identifiers & Profiles"
        echo "3. Create a 'Developer ID Application' certificate"
        echo "4. Download the certificate (.cer file)"
        echo "5. Double-click to install it in Keychain Access"
        echo "6. Ensure it's trusted for code signing"
        return 1
    fi
}