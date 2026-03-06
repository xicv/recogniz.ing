# macOS Notarized Distribution Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Sign and notarize the macOS build with a Developer ID certificate so users get a clean Gatekeeper experience — no more "this app can't be verified" warnings.

**Architecture:** Two-phase hybrid approach. Phase 1 rewrites the local signing script (`scripts/sign-macos.sh`) to properly sign nested binaries, create a DMG, submit for notarization, and staple the ticket. Phase 2 (future) adds this pipeline to GitHub Actions. No app functionality changes — all features (global hotkeys, tray, etc.) remain intact.

**Tech Stack:** macOS codesign, xcrun notarytool, hdiutil, Hardened Runtime entitlements

**Design Doc:** `docs/plans/2026-03-05-macos-notarized-distribution-design.md`

---

## Prerequisites (Manual — User Must Do Before Starting)

These cannot be automated. The user must complete these steps:

1. **Enroll in Apple Developer Program** at https://developer.apple.com/programs/ ($99/year)
2. **Create a "Developer ID Application" certificate** in the Apple Developer portal:
   - Go to Certificates, Identifiers & Profiles
   - Click "+" to create a new certificate
   - Select "Developer ID Application"
   - Follow the CSR (Certificate Signing Request) flow using Keychain Access
   - Download the `.cer` file and double-click to install in Keychain Access
3. **Generate an app-specific password** at https://appleid.apple.com/account/manage/security/apps
4. **Note your Team ID** — visible at https://developer.apple.com/account/#/membership/ (10-character alphanumeric string)

---

## Task 1: Update Release Entitlements

**Files:**
- Modify: `macos/Runner/Release.entitlements`

The Dart VM needs `allow-unsigned-executable-memory` to work with Hardened Runtime (which notarization requires). Without this, the app will crash on launch after signing.

**Step 1: Add the missing entitlement**

Add `com.apple.security.cs.allow-unsigned-executable-memory` to `Release.entitlements`. The full file should be:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<!-- App Sandbox DISABLED for direct distribution (Developer ID) -->
	<!-- Notarized via Apple's notarytool for clean Gatekeeper experience -->
	<!-- NOTE: Cannot distribute to Mac App Store with sandbox disabled -->
	<key>com.apple.security.app-sandbox</key>
	<false/>
	<!-- Required by Dart VM for JIT compilation -->
	<key>com.apple.security.cs.allow-jit</key>
	<true/>
	<!-- Required by Dart VM for hardened runtime compatibility -->
	<key>com.apple.security.cs.allow-unsigned-executable-memory</key>
	<true/>
	<key>com.apple.security.network.server</key>
	<true/>
	<key>com.apple.security.network.client</key>
	<true/>
	<key>com.apple.security.device.audio-input</key>
	<true/>
	<!-- Allow access to microphone (alias for audio-input, ensures compatibility) -->
	<key>com.apple.security.device.microphone</key>
	<true/>
	<!-- Allow access to camera devices (required by AVFoundation even for audio-only capture) -->
	<key>com.apple.security.device.camera</key>
	<true/>
	<!-- Allow loading system libraries and plugins (Audio Units) not signed with same certificate -->
	<key>com.apple.security.cs.disable-library-validation</key>
	<true/>
</dict>
</plist>
```

**Step 2: Verify the entitlements file is valid XML**

Run: `plutil -lint macos/Runner/Release.entitlements`
Expected: `macos/Runner/Release.entitlements: OK`

**Step 3: Commit**

```bash
git add macos/Runner/Release.entitlements
git commit -m "feat(macos): add unsigned-executable-memory entitlement for notarization"
```

---

## Task 2: Rewrite the Signing Script

**Files:**
- Modify: `scripts/sign-macos.sh`

The current script has several issues:
- Hardcodes an empty `DEVELOPER_ID_APPLICATION` instead of sourcing from config
- Missing `--entitlements` flag (critical — without this, hardened runtime won't know about the entitlements)
- Missing `--options runtime` on dylib signing
- Uses `--deep` flag (unreliable — Apple recommends signing each binary individually)
- `create-dmg` fallback error handling is fragile
- References a non-existent `scripts/dmg-background.png`

**Step 1: Rewrite `scripts/sign-macos.sh`**

Replace the entire file with:

```bash
#!/bin/bash

# macOS Code Signing and Notarization Script for Recogniz.ing
#
# Usage:
#   ./scripts/sign-macos.sh              # Full pipeline: build, sign, DMG, notarize
#   ./scripts/sign-macos.sh --sign-only  # Sign an existing build (skip flutter build)
#   ./scripts/sign-macos.sh --dmg-only   # Create DMG from signed build (skip build+sign)
#
# Prerequisites:
# 1. Fill in scripts/codesign-config.sh with your Apple Developer credentials
# 2. Run: source scripts/codesign-config.sh && setup_notarytool_credentials
# 3. Have Developer ID Application certificate installed in Keychain Access

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source configuration
if [ -f "$SCRIPT_DIR/codesign-config.sh" ]; then
    source "$SCRIPT_DIR/codesign-config.sh"
else
    echo "ERROR: scripts/codesign-config.sh not found"
    exit 1
fi

# Paths
APP_NAME="recognizing"
APP_PATH="$PROJECT_DIR/build/macos/Build/Products/Release/$APP_NAME.app"
ENTITLEMENTS="$PROJECT_DIR/macos/Runner/Release.entitlements"
VERSION=$(grep "version:" "$PROJECT_DIR/pubspec.yaml" | head -1 | cut -d: -f2 | xargs)
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
    for tool in codesign xcrun hdiutil ditto; do
        if ! command -v "$tool" &>/dev/null; then
            error "$tool not found. Install Xcode Command Line Tools."
            exit 1
        fi
    done

    # Verify config is filled in
    verify_codesign_config || exit 1

    # Verify certificate exists in keychain
    if ! security find-identity -v -p codesigning | grep -q "$DEVELOPER_ID_APPLICATION_NAME"; then
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
        find "$APP_PATH/Contents/Frameworks" -name "*.framework" -print0 | while IFS= read -r -d '' fw; do
            # Sign the framework's executable inside, then the framework itself
            local fw_name
            fw_name=$(basename "$fw" .framework)
            if [ -f "$fw/Versions/A/$fw_name" ]; then
                codesign --force --options runtime --sign "$identity" "$fw/Versions/A/$fw_name"
            fi
            codesign --force --options runtime --sign "$identity" "$fw"
            success "  Signed: $(basename "$fw")"
        done
    fi

    # Step 2: Sign all dylibs
    info "Signing dynamic libraries..."
    find "$APP_PATH" -name "*.dylib" -print0 | while IFS= read -r -d '' dylib; do
        codesign --force --options runtime --sign "$identity" "$dylib"
        success "  Signed: $(basename "$dylib")"
    done

    # Step 3: Sign all .so files (if any, e.g., from Dart plugins)
    find "$APP_PATH" -name "*.so" -print0 | while IFS= read -r -d '' so; do
        codesign --force --options runtime --sign "$identity" "$so"
        success "  Signed: $(basename "$so")"
    done

    # Step 4: Sign any helper executables
    if [ -d "$APP_PATH/Contents/MacOS" ]; then
        find "$APP_PATH/Contents/MacOS" -type f -perm +111 ! -name "$APP_NAME" -print0 | while IFS= read -r -d '' helper; do
            codesign --force --options runtime --entitlements "$ENTITLEMENTS" --sign "$identity" "$helper"
            success "  Signed helper: $(basename "$helper")"
        done
    fi

    # Step 5: Sign the main app bundle (with entitlements)
    info "Signing main app bundle with entitlements..."
    codesign --force --options runtime --entitlements "$ENTITLEMENTS" --sign "$identity" "$APP_PATH"
    success "App bundle signed"

    # Step 6: Verify
    info "Verifying signature..."
    codesign --verify --deep --strict --verbose=2 "$APP_PATH" 2>&1

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

    cp -R "$APP_PATH" "$tmp_dir/"
    ln -s /Applications "$tmp_dir/Applications"

    hdiutil create \
        -srcfolder "$tmp_dir" \
        -volname "Recogniz.ing" \
        -fs HFS+ \
        -fsargs "-c c=64,a=16,e=16" \
        -format UDZO \
        "$DMG_PATH"

    rm -rf "$tmp_dir"
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

    if xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "$NOTARY_PROFILE" \
        --wait \
        --output-format json 2>&1 | tee "$result_json"; then

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
            rm -f "$result_json"
            exit 1
        else
            warn "Notarization status unclear. Check output above."
        fi
    else
        error "Notarization submission failed"
        cat "$result_json"
        rm -f "$result_json"
        exit 1
    fi

    rm -f "$result_json"

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
            create_dmg
            notarize_dmg
            ;;
        full|*)
            build_app
            sign_app
            create_dmg
            notarize_dmg
            ;;
    esac

    echo ""
    success "Done! Distribute: $DMG_PATH"
    echo ""
    echo "To install: Open DMG -> Drag to Applications -> Launch normally"
    echo ""
}

main "$@"
```

**Step 2: Make the script executable**

Run: `chmod +x scripts/sign-macos.sh`
Expected: No output, exit code 0

**Step 3: Verify syntax**

Run: `bash -n scripts/sign-macos.sh`
Expected: No output (no syntax errors)

**Step 4: Commit**

```bash
git add scripts/sign-macos.sh
git commit -m "feat(macos): rewrite signing script with proper entitlements and notarization"
```

---

## Task 3: Update the Makefile Targets

**Files:**
- Modify: `Makefile` (lines ~273-329, the code signing section)

The current Makefile targets have issues:
- `sign-macos` duplicates logic from `sign-macos.sh` (poorly)
- `distribute-macos` creates an unsigned DMG alongside the signed one (confusing)
- `notarize-macos` just calls the script (redundant indirection)

**Step 1: Replace the code signing section in the Makefile**

Replace everything from `# Code Signing & Notarization` through `distribute-macos` target (lines 273-329) with:

```makefile
# Code Signing & Notarization
codesign-setup: ## Set up code signing configuration
	@echo "Setting up code signing configuration..."
	@if [ ! -f scripts/codesign-config.sh ]; then \
		echo "ERROR: scripts/codesign-config.sh not found!"; \
		exit 1; \
	fi
	@echo ""
	@echo "Step 1: Edit scripts/codesign-config.sh with your Apple Developer credentials:"
	@echo "  - DEVELOPER_TEAM_ID: Your 10-character Apple Developer Team ID"
	@echo "  - APPLE_DEVELOPER_ID: Your Apple ID email"
	@echo "  - APPLE_APP_PASSWORD: App-specific password from appleid.apple.com"
	@echo ""
	@echo "Step 2: Store notarytool credentials in keychain:"
	@echo "  source scripts/codesign-config.sh"
	@echo "  setup_notarytool_credentials"
	@echo ""
	@echo "Step 3: Verify setup:"
	@echo "  make verify-codesign"

verify-codesign: ## Verify code signing setup and certificates
	@echo "Verifying code signing configuration..."
	@source scripts/codesign-config.sh && verify_codesign_config
	@source scripts/codesign-config.sh && check_codesign_certificates
	@source scripts/codesign-config.sh && check_notarytool_credentials
	@echo ""
	@echo "All checks passed. Ready to sign with: make distribute-macos"

sign-macos: ## Build and sign macOS release (no notarization)
	@./scripts/sign-macos.sh --sign-only

distribute-macos: ## Build, sign, create DMG, and notarize for distribution
	@./scripts/sign-macos.sh
```

**Step 2: Verify Makefile syntax**

Run: `make -n distribute-macos` (dry run)
Expected: Shows `./scripts/sign-macos.sh` (doesn't actually run it)

**Step 3: Commit**

```bash
git add Makefile
git commit -m "refactor(macos): simplify Makefile signing targets to use sign-macos.sh"
```

---

## Task 4: Update Release Workflow Installation Instructions

**Files:**
- Modify: `.github/workflows/release-matrix.yml` (line ~426-429)

The release notes currently tell users to "Right-click and Open (to bypass Gatekeeper)". Once we're notarizing, this is no longer needed. Update the instructions to handle both cases gracefully.

**Step 1: Update the macOS installation instructions in the release body**

In `.github/workflows/release-matrix.yml`, find the installation section (around line 424-430) and replace:

```yaml
            **macOS:**
            1. Download the ZIP file
            2. Extract `recognizing.app`
            3. Move to Applications folder
            4. Right-click and Open (to bypass Gatekeeper)
```

With:

```yaml
            **macOS:**
            1. Download the DMG (or ZIP) file
            2. Open the DMG and drag `Recogniz.ing` to Applications
            3. Launch from Applications
            4. If you see a Gatekeeper warning, right-click and select Open
```

**Step 2: Commit**

```bash
git add .github/workflows/release-matrix.yml
git commit -m "docs: update macOS install instructions for notarized distribution"
```

---

## Task 5: Add CI/CD Signing to Release Workflow (Phase 2 Prep)

**Files:**
- Modify: `.github/workflows/release-matrix.yml`

This adds the signing and notarization steps to the macOS CI build. It uses GitHub Secrets for credentials and a temporary keychain for the certificate.

**Step 1: Add signing steps after the macOS build step**

In the `build` job, after the `Build ${{ matrix.platform }}` step (line ~131), add macOS-specific signing steps. Replace the existing `Create macOS archive` step (lines 133-138) with:

```yaml
      - name: Import signing certificate
        if: matrix.platform == 'macos' && env.MACOS_CERTIFICATE != ''
        env:
          MACOS_CERTIFICATE: ${{ secrets.MACOS_CERTIFICATE }}
          MACOS_CERTIFICATE_PWD: ${{ secrets.MACOS_CERTIFICATE_PWD }}
        run: |
          # Create temporary keychain
          KEYCHAIN_PATH=$RUNNER_TEMP/signing.keychain-db
          KEYCHAIN_PWD=$(openssl rand -base64 32)

          security create-keychain -p "$KEYCHAIN_PWD" "$KEYCHAIN_PATH"
          security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
          security unlock-keychain -p "$KEYCHAIN_PWD" "$KEYCHAIN_PATH"

          # Import certificate
          echo "$MACOS_CERTIFICATE" | base64 --decode > $RUNNER_TEMP/certificate.p12
          security import $RUNNER_TEMP/certificate.p12 \
            -k "$KEYCHAIN_PATH" \
            -P "$MACOS_CERTIFICATE_PWD" \
            -T /usr/bin/codesign \
            -T /usr/bin/productsign

          security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PWD" "$KEYCHAIN_PATH"
          security list-keychains -d user -s "$KEYCHAIN_PATH" login.keychain-db

          # Store keychain path for later steps
          echo "KEYCHAIN_PATH=$KEYCHAIN_PATH" >> $GITHUB_ENV
          echo "KEYCHAIN_PWD=$KEYCHAIN_PWD" >> $GITHUB_ENV

          # Find the signing identity
          IDENTITY=$(security find-identity -v -p codesigning "$KEYCHAIN_PATH" | grep "Developer ID Application" | head -1 | sed 's/.*"\(.*\)"/\1/')
          echo "SIGNING_IDENTITY=$IDENTITY" >> $GITHUB_ENV
          echo "Found signing identity: $IDENTITY"

      - name: Sign macOS app
        if: matrix.platform == 'macos' && env.SIGNING_IDENTITY != ''
        run: |
          APP_PATH="${{ matrix.artifact_source }}/recognizing.app"
          ENTITLEMENTS="macos/Runner/Release.entitlements"
          IDENTITY="${{ env.SIGNING_IDENTITY }}"

          echo "Signing with identity: $IDENTITY"

          # Sign frameworks
          find "$APP_PATH/Contents/Frameworks" -name "*.framework" -print0 | while IFS= read -r -d '' fw; do
            fw_name=$(basename "$fw" .framework)
            [ -f "$fw/Versions/A/$fw_name" ] && codesign --force --options runtime --sign "$IDENTITY" "$fw/Versions/A/$fw_name"
            codesign --force --options runtime --sign "$IDENTITY" "$fw"
          done

          # Sign dylibs and shared objects
          find "$APP_PATH" \( -name "*.dylib" -o -name "*.so" \) -print0 | while IFS= read -r -d '' lib; do
            codesign --force --options runtime --sign "$IDENTITY" "$lib"
          done

          # Sign helper executables
          find "$APP_PATH/Contents/MacOS" -type f -perm +111 ! -name "recognizing" -print0 | while IFS= read -r -d '' helper; do
            codesign --force --options runtime --entitlements "$ENTITLEMENTS" --sign "$IDENTITY" "$helper"
          done

          # Sign main bundle
          codesign --force --options runtime --entitlements "$ENTITLEMENTS" --sign "$IDENTITY" "$APP_PATH"

          # Verify
          codesign --verify --deep --strict --verbose=2 "$APP_PATH"
          echo "Signing complete"

      - name: Create macOS DMG
        if: matrix.platform == 'macos'
        run: |
          VERSION="${{ needs.version.outputs.version_name }}"
          APP_PATH="${{ matrix.artifact_source }}/recognizing.app"
          DMG_PATH="${{ matrix.artifact_source }}/recognizing-${VERSION}-macos.dmg"

          TMP_DIR=$(mktemp -d)
          cp -R "$APP_PATH" "$TMP_DIR/"
          ln -s /Applications "$TMP_DIR/Applications"

          hdiutil create \
            -srcfolder "$TMP_DIR" \
            -volname "Recogniz.ing" \
            -fs HFS+ \
            -fsargs "-c c=64,a=16,e=16" \
            -format UDZO \
            "$DMG_PATH"

          rm -rf "$TMP_DIR"

          # Also create ZIP for backwards compatibility
          cd ${{ matrix.artifact_source }}
          zip -r recognizing-${VERSION}-macos.zip recognizing.app
          cd -

      - name: Notarize macOS DMG
        if: matrix.platform == 'macos' && env.SIGNING_IDENTITY != ''
        env:
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APPLE_APP_PASSWORD: ${{ secrets.APPLE_APP_PASSWORD }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
        run: |
          VERSION="${{ needs.version.outputs.version_name }}"
          DMG_PATH="${{ matrix.artifact_source }}/recognizing-${VERSION}-macos.dmg"

          echo "Submitting for notarization..."
          xcrun notarytool submit "$DMG_PATH" \
            --apple-id "$APPLE_ID" \
            --password "$APPLE_APP_PASSWORD" \
            --team-id "$APPLE_TEAM_ID" \
            --wait

          echo "Stapling ticket..."
          xcrun stapler staple "$DMG_PATH"
          xcrun stapler validate "$DMG_PATH"

          echo "Notarization complete"

      - name: Create macOS archive (unsigned fallback)
        if: matrix.platform == 'macos' && env.SIGNING_IDENTITY == ''
        run: |
          cd ${{ matrix.artifact_source }}
          zip -r ${{ matrix.artifact_zip_name }} ${{ matrix.app_bundle_name }}.app
          cd ../../../../../

      - name: Cleanup keychain
        if: matrix.platform == 'macos' && always()
        run: |
          if [ -n "${{ env.KEYCHAIN_PATH }}" ]; then
            security delete-keychain "${{ env.KEYCHAIN_PATH }}" 2>/dev/null || true
          fi
```

**Step 2: Update artifact upload to include DMG**

Find the `Upload build artifacts` step and update the path to include `.dmg`:

```yaml
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-${{ matrix.platform }}-${{ needs.version.outputs.version_name }}
          path: |
            ${{ matrix.artifact_source }}/${{ matrix.artifact_zip_name }}
            ${{ matrix.artifact_source }}/*.dmg
            ${{ matrix.artifact_exe_name }}
          retention-days: 7
          if-no-files-found: warn
```

**Step 3: Update the release job to upload DMG files**

In the `release` job, update the `Prepare release files` step to also copy `.dmg` files:

After the existing macOS ZIP copy block, add:

```bash
          # Copy macOS DMG (signed/notarized)
          if [ -f "artifacts/build-macos-${VERSION}/recognizing-${VERSION}-macos.dmg" ]; then
            cp artifacts/build-macos-${VERSION}/recognizing-${VERSION}-macos.dmg \
              landing/public/downloads/${VERSION}/macos/recognizing-${VERSION}-macos.dmg
          fi
```

And in the `Create GitHub Release` step, update the `files` glob to include `.dmg`:

```yaml
          files: |
            landing/public/downloads/${{ needs.version.outputs.version_name }}/**/*.zip
            landing/public/downloads/${{ needs.version.outputs.version_name }}/**/*.dmg
            landing/public/downloads/${{ needs.version.outputs.version_name }}/**/*.exe
            CHANGELOG.md
```

**Step 4: Commit**

```bash
git add .github/workflows/release-matrix.yml
git commit -m "feat(ci): add macOS code signing and notarization to release workflow"
```

---

## Task 6: Test the Full Local Pipeline

This task is manual — it requires the Apple Developer credentials to be set up.

**Step 1: Verify codesign setup**

Run: `make verify-codesign`
Expected: All three checks pass (config, certificate, notarytool credentials)

**Step 2: Run the full distribution pipeline**

Run: `make distribute-macos`
Expected:
1. Flutter builds successfully
2. All binaries signed (no errors)
3. DMG created
4. Notarization submitted and accepted (takes 2-10 minutes)
5. Ticket stapled to DMG
6. Final output: `recognizing-X.Y.Z-macos.dmg`

**Step 3: Verify the signed app**

Run these verification commands on the built app:
```bash
# Verify code signature
codesign --verify --deep --strict --verbose=2 build/macos/Build/Products/Release/recognizing.app

# Gatekeeper assessment (should pass after notarization)
spctl --assess --type execute build/macos/Build/Products/Release/recognizing.app

# Verify DMG notarization
xcrun stapler validate recognizing-*.dmg
```

**Step 4: Test on a clean account**

1. Create a new macOS user account (or use a different Mac)
2. Copy the `.dmg` to that account
3. Open the DMG, drag to Applications, launch
4. Expected: No Gatekeeper warning, app opens cleanly

**Step 5: Commit any fixes**

If any fixes were needed during testing, commit them:
```bash
git add -A
git commit -m "fix(macos): address signing issues found during testing"
```

---

## Summary

| Task | What | Files |
|------|------|-------|
| 1 | Add unsigned-executable-memory entitlement | `Release.entitlements` |
| 2 | Rewrite signing script | `scripts/sign-macos.sh` |
| 3 | Simplify Makefile targets | `Makefile` |
| 4 | Update release install instructions | `release-matrix.yml` |
| 5 | Add CI/CD signing pipeline | `release-matrix.yml` |
| 6 | Test full local pipeline | Manual verification |

**Required GitHub Secrets (for Task 5):**

| Secret | How to get it |
|--------|---------------|
| `MACOS_CERTIFICATE` | Export cert from Keychain Access as `.p12`, then `base64 -i cert.p12` |
| `MACOS_CERTIFICATE_PWD` | Password you set when exporting the `.p12` |
| `APPLE_ID` | Your Apple Developer email |
| `APPLE_APP_PASSWORD` | App-specific password from appleid.apple.com |
| `APPLE_TEAM_ID` | 10-char ID from developer.apple.com/account |
