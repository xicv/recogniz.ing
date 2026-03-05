#!/bin/bash

# macOS Code Signing and Notarization Script for Recogniz.ing
#
# Usage:
#   ./scripts/sign-macos.sh              # Full pipeline: build, sign, DMG, notarize
#   ./scripts/sign-macos.sh --sign-only  # Sign an existing build (skip flutter build)
#   ./scripts/sign-macos.sh --dmg-only   # Create DMG from signed build (skip build+sign)
#
# Prerequisites:
# 1. Copy scripts/codesign-config.sh.template to scripts/codesign-config.sh
# 2. Fill in scripts/codesign-config.sh with your Apple Developer credentials
# 3. Run: source scripts/codesign-config.sh && setup_notarytool_credentials
# 4. Have Developer ID Application certificate installed in Keychain Access

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source configuration
if [ -f "$SCRIPT_DIR/codesign-config.sh" ]; then
    source "$SCRIPT_DIR/codesign-config.sh"
else
    echo "ERROR: scripts/codesign-config.sh not found"
    echo ""
    echo "Create it by copying the template:"
    echo "  cp scripts/codesign-config.sh.template scripts/codesign-config.sh"
    echo "  # Then fill in your Apple Developer credentials"
    exit 1
fi

# Paths
APP_NAME="recognizing"
APP_PATH="$PROJECT_DIR/build/macos/Build/Products/Release/$APP_NAME.app"
ENTITLEMENTS="$PROJECT_DIR/macos/Runner/Release.entitlements"
VERSION=$(grep "^version:" "$PROJECT_DIR/pubspec.yaml" | head -1 | cut -d: -f2 | xargs)
VERSION_NAME="${VERSION%%+*}"
DMG_NAME="recognizing-$VERSION_NAME-macos.dmg"
DMG_PATH="$PROJECT_DIR/$DMG_NAME"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ── Preflight checks ─────────────────────────────────────────────

preflight() {
    info "Preflight checks..."

    # Verify required tools
    for tool in codesign xcrun hdiutil; do
        if ! command -v "$tool" &>/dev/null; then
            error "$tool not found. Install Xcode Command Line Tools."
            exit 1
        fi
    done

    # Verify config is filled in
    verify_codesign_config || exit 1

    # Verify certificate exists in keychain
    if ! security find-identity -v -p codesigning | grep -qF "$DEVELOPER_ID_APPLICATION_NAME"; then
        error "Certificate not found: $DEVELOPER_ID_APPLICATION_NAME"
        echo ""
        echo "Available signing identities:"
        security find-identity -v -p codesigning
        echo ""
        echo "To fix: download your Developer ID Application certificate from"
        echo "https://developer.apple.com/account/resources/certificates/list"
        echo "and double-click to install in Keychain Access."
        exit 1
    fi
    success "Certificate found: $DEVELOPER_ID_APPLICATION_NAME"

    # Verify entitlements file exists
    if [ ! -f "$ENTITLEMENTS" ]; then
        error "Entitlements file not found: $ENTITLEMENTS"
        exit 1
    fi
    success "Entitlements file found"

    # Verify notarytool credentials
    if ! xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" &>/dev/null; then
        error "Notarytool credentials not found for profile: $NOTARY_PROFILE"
        echo ""
        echo "Run: source scripts/codesign-config.sh && setup_notarytool_credentials"
        exit 1
    fi
    success "Notarytool credentials verified"
}

# ── Build ─────────────────────────────────────────────────────────

build_app() {
    info "Building Flutter app for macOS (release)..."

    cd "$PROJECT_DIR"
    flutter clean
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    flutter build macos --release

    if [ ! -d "$APP_PATH" ]; then
        error "Build failed: $APP_PATH not found"
        exit 1
    fi
    success "Build completed: $APP_PATH"
}

# ── Sign ──────────────────────────────────────────────────────────

sign_app() {
    info "Signing application bundle..."

    local identity="$DEVELOPER_ID_APPLICATION_NAME"

    # Step 1: Sign all nested frameworks (deepest first)
    info "Signing frameworks..."
    if [ -d "$APP_PATH/Contents/Frameworks" ]; then
        while IFS= read -r -d '' fw; do
            # Sign the framework's executable inside, then the framework itself
            local fw_name
            fw_name=$(basename "$fw" .framework)
            if [ -f "$fw/Versions/A/$fw_name" ]; then
                codesign --force --options runtime --sign "$identity" "$fw/Versions/A/$fw_name"
            fi
            codesign --force --options runtime --sign "$identity" "$fw"
            success "  Signed: $(basename "$fw")"
        done < <(find "$APP_PATH/Contents/Frameworks" -name "*.framework" -print0)
    fi

    # Step 2: Sign all dylibs
    info "Signing dynamic libraries..."
    while IFS= read -r -d '' dylib; do
        codesign --force --options runtime --sign "$identity" "$dylib"
        success "  Signed: $(basename "$dylib")"
    done < <(find "$APP_PATH" -name "*.dylib" -print0)

    # Step 3: Sign all .so files (if any, e.g., from Dart plugins)
    while IFS= read -r -d '' so; do
        codesign --force --options runtime --sign "$identity" "$so"
        success "  Signed: $(basename "$so")"
    done < <(find "$APP_PATH" -name "*.so" -print0)

    # Step 4: Sign any helper executables
    if [ -d "$APP_PATH/Contents/MacOS" ]; then
        while IFS= read -r -d '' helper; do
            codesign --force --options runtime --entitlements "$ENTITLEMENTS" --sign "$identity" "$helper"
            success "  Signed helper: $(basename "$helper")"
        done < <(find "$APP_PATH/Contents/MacOS" -type f -perm +111 ! -name "$APP_NAME" -print0)
    fi

    # Step 5: Sign the main app bundle (with entitlements)
    info "Signing main app bundle with entitlements..."
    codesign --force --options runtime --entitlements "$ENTITLEMENTS" --sign "$identity" "$APP_PATH"
    success "App bundle signed"

    # Step 6: Verify
    info "Verifying signature..."
    if ! codesign --verify --deep --strict --verbose=2 "$APP_PATH"; then
        error "Signature verification failed for $APP_PATH"
        exit 1
    fi

    # Gatekeeper assessment
    if spctl --assess --type execute "$APP_PATH" 2>&1; then
        success "Gatekeeper assessment: PASSED"
    else
        warn "Gatekeeper assessment failed (expected before notarization)"
    fi

    success "Signing complete"
}

# ── DMG ───────────────────────────────────────────────────────────

create_dmg() {
    info "Creating DMG: $DMG_NAME"

    # Remove existing DMG if present
    [ -f "$DMG_PATH" ] && rm "$DMG_PATH"

    # Try create-dmg first (prettier result), fall back to hdiutil
    if command -v create-dmg &>/dev/null; then
        info "Using create-dmg for styled DMG..."

        local create_dmg_args=(
            --volname "Recogniz.ing"
            --window-pos 200 120
            --window-size 600 450
            --icon-size 100
            --icon "recognizing.app" 175 190
            --hide-extension "recognizing.app"
            --app-drop-link 425 190
        )

        # Add icon if it exists
        if [ -f "$APP_PATH/Contents/Resources/AppIcon.icns" ]; then
            create_dmg_args+=(--volicon "$APP_PATH/Contents/Resources/AppIcon.icns")
        fi

        create-dmg "${create_dmg_args[@]}" "$DMG_PATH" "$APP_PATH" || {
            warn "create-dmg failed, falling back to hdiutil..."
            _create_dmg_hdiutil
        }
    else
        info "create-dmg not installed, using hdiutil..."
        _create_dmg_hdiutil
    fi

    if [ ! -f "$DMG_PATH" ]; then
        error "DMG creation failed"
        exit 1
    fi

    success "DMG created: $DMG_PATH"
}

_create_dmg_hdiutil() {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' RETURN

    cp -R "$APP_PATH" "$tmp_dir/"
    ln -s /Applications "$tmp_dir/Applications"

    hdiutil create \
        -srcfolder "$tmp_dir" \
        -volname "Recogniz.ing" \
        -fs HFS+ \
        -fsargs "-c c=64,a=16,e=16" \
        -format UDZO \
        "$DMG_PATH"
}

# ── Notarize ──────────────────────────────────────────────────────

notarize_dmg() {
    info "Submitting for notarization (this may take 2-10 minutes)..."

    if [ ! -f "$DMG_PATH" ]; then
        error "DMG not found: $DMG_PATH"
        exit 1
    fi

    # Submit and wait
    local result_json
    result_json=$(mktemp)
    trap 'rm -f "$result_json"' RETURN

    local exit_code=0
    xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "$NOTARY_PROFILE" \
        --wait \
        --output-format json > "$result_json" 2>&1 || exit_code=$?

    cat "$result_json"

    if [ $exit_code -ne 0 ]; then
        error "Notarization submission failed (exit code: $exit_code)"
        exit 1
    fi

    if grep -q '"status"' "$result_json" && grep -q '"Accepted"' "$result_json"; then
        success "Notarization accepted"
    elif grep -q '"Invalid"' "$result_json"; then
        error "Notarization REJECTED"
        echo ""
        # Extract submission ID for log retrieval
        local submission_id
        submission_id=$(grep -o '"id":"[^"]*"' "$result_json" | head -1 | cut -d'"' -f4)
        if [ -n "$submission_id" ]; then
            echo "Fetching rejection details..."
            xcrun notarytool log "$submission_id" --keychain-profile "$NOTARY_PROFILE" || true
        fi
        exit 1
    else
        warn "Notarization status unclear. Check output above."
    fi

    # Staple the ticket
    info "Stapling notarization ticket to DMG..."
    xcrun stapler staple "$DMG_PATH"
    success "Ticket stapled"

    # Final verification
    info "Verifying notarized DMG..."
    xcrun stapler validate "$DMG_PATH"
    success "DMG is notarized and ready for distribution"
}

# ── Main ──────────────────────────────────────────────────────────

main() {
    echo ""
    echo "=========================================="
    echo "  Recogniz.ing macOS Signing & Notarization"
    echo "  Version: $VERSION_NAME"
    echo "=========================================="
    echo ""

    local mode="${1:-full}"

    preflight

    case "$mode" in
        --sign-only)
            if [ ! -d "$APP_PATH" ]; then
                error "No build found at $APP_PATH. Run without --sign-only first."
                exit 1
            fi
            sign_app
            ;;
        --dmg-only)
            if [ ! -d "$APP_PATH" ]; then
                error "No build found at $APP_PATH."
                exit 1
            fi
            if ! codesign --verify --deep --strict "$APP_PATH" &>/dev/null; then
                error "App at $APP_PATH is not properly signed. Run --sign-only first."
                exit 1
            fi
            create_dmg
            notarize_dmg
            ;;
        full)
            build_app
            sign_app
            create_dmg
            notarize_dmg
            ;;
        *)
            error "Unknown option: $mode"
            echo "Usage: $0 [--sign-only | --dmg-only | full]"
            exit 1
            ;;
    esac

    echo ""
    success "Done! Distribute: $DMG_PATH"
    echo ""
    echo "To install: Open DMG -> Drag to Applications -> Launch normally"
    echo ""
}

main "$@"
