# macOS Notarized Distribution Design

**Date**: 2026-03-05
**Status**: Approved
**Goal**: Sign and notarize the macOS build so users get a clean install experience (no Gatekeeper warnings) while keeping all features (global hotkeys, system tray, start-at-login).

## Context

Currently the app distributes unsigned `.zip` files via GitHub Releases. Users must right-click and select "Open" to bypass Gatekeeper — this hurts trust and credibility. Apple's notarization service scans the app and issues a ticket that Gatekeeper trusts, giving a clean install experience without requiring the Mac App Store.

### Why Not the Mac App Store?

The Mac App Store requires **App Sandbox**, which is incompatible with 5 core features:

| Feature | Package | Root Cause |
|---------|---------|------------|
| Global hotkeys | `hotkey_manager` | Carbon API (`RegisterEventHotKey`) |
| System tray | `tray_manager` | `NSStatusBar` limitations |
| Start at login | `launch_at_startup` | Can't write to Launch Services DB |
| Audio recording | `record` | Needs `disable-library-validation` for Audio Units |
| Clipboard | Flutter `Clipboard` | Reduced reliability |

**Decision**: Notarized direct distribution (Developer ID) preserves all features while solving the trust problem.

## Architecture

### Two-Phase Approach

**Phase 1: Local Signing** — Sign and notarize on the developer's Mac, upload signed `.dmg` to GitHub Releases manually.

**Phase 2: CI/CD Automation** — GitHub Actions signs and notarizes automatically on tag push, producing a notarized `.dmg` in releases.

### Signing Pipeline

```
flutter build macos --release
    -> Sign nested frameworks (deepest first)
    -> Sign dylibs
    -> Sign .app bundle (with hardened runtime + entitlements)
    -> Verify signature
    -> Create .dmg
    -> Submit .dmg to notarytool (--wait)
    -> Staple notarization ticket to .dmg
    -> Verify notarization
```

### Entitlements (Developer ID — No Changes to Current Set)

For Developer ID distribution, all current entitlements are **allowed**:

```xml
com.apple.security.app-sandbox = false              <!-- OK for Developer ID -->
com.apple.security.cs.allow-jit = true              <!-- Required by Dart VM -->
com.apple.security.cs.disable-library-validation    <!-- Required for Audio Units -->
com.apple.security.network.server/client            <!-- API calls -->
com.apple.security.device.audio-input               <!-- Microphone -->
com.apple.security.device.microphone                <!-- Microphone alias -->
com.apple.security.device.camera                    <!-- AVFoundation requirement -->
```

Additional entitlement needed for hardened runtime:
```xml
com.apple.security.cs.allow-unsigned-executable-memory = true  <!-- Dart VM JIT -->
```

## Phase 1: Local Signing

### Prerequisites (One-Time Manual Setup)

1. **Apple Developer Program** enrollment ($99/year) at https://developer.apple.com/programs/
2. **Developer ID Application** certificate created in Apple Developer portal
3. Certificate `.cer` downloaded and installed in Keychain Access
4. **App-specific password** generated at https://appleid.apple.com/account/manage/security/apps
5. `scripts/codesign-config.sh` filled in with credentials
6. `notarytool` credentials stored in keychain via `setup_notarytool_credentials`

### Code Changes

#### 1. Update `scripts/sign-macos.sh`

Current issues to fix:
- Source `codesign-config.sh` for credentials (instead of hardcoded empty variable)
- Add `--entitlements` flag when signing the `.app` bundle (critical for hardened runtime)
- Sign nested binaries in correct dependency order
- Add `--options runtime` to framework signing (required for notarization)
- Better error handling and logging

#### 2. Update `Release.entitlements`

Add one entitlement for Dart VM compatibility with hardened runtime:
```xml
<key>com.apple.security.cs.allow-unsigned-executable-memory</key>
<true/>
```

#### 3. Update `Makefile`

Fix `distribute-macos` target to:
- Source config automatically
- Run the full pipeline as a single command
- Output the final `.dmg` path

#### 4. Landing page installation instructions

Update release notes template in `release-matrix.yml` to remove "Right-click and Open" instruction for notarized builds.

### Release Flow (Phase 1)

```bash
# One-time setup
make codesign-setup              # Edit config with credentials
source scripts/codesign-config.sh
setup_notarytool_credentials     # Store in keychain

# Each release
make distribute-macos            # Build -> Sign -> DMG -> Notarize -> Staple
# Upload .dmg to GitHub Release manually
```

## Phase 2: CI/CD Automation (Future)

### GitHub Secrets

| Secret | Value |
|--------|-------|
| `MACOS_CERTIFICATE` | Base64-encoded `.p12` of Developer ID Application cert |
| `MACOS_CERTIFICATE_PWD` | Password for the `.p12` file |
| `APPLE_ID` | Apple Developer email |
| `APPLE_APP_PASSWORD` | App-specific password |
| `APPLE_TEAM_ID` | 10-character team ID |

### Workflow Changes (`release-matrix.yml`)

Add a `sign-and-notarize` step after the macOS build:

1. Import certificate from secret into temporary keychain
2. Sign all binaries with hardened runtime + entitlements
3. Create `.dmg` (with Applications symlink)
4. Submit to `notarytool --wait`
5. Staple ticket to `.dmg`
6. Upload notarized `.dmg` as release artifact (replaces unsigned `.zip`)
7. Clean up temporary keychain

### Updated Release Notes

Replace:
```
4. Right-click and Open (to bypass Gatekeeper)
```
With:
```
4. Open normally (app is signed and notarized by Apple)
```

## Files Affected

### Phase 1
- `scripts/sign-macos.sh` — Rewrite signing pipeline
- `scripts/codesign-config.sh` — No code changes (user fills in credentials)
- `macos/Runner/Release.entitlements` — Add `allow-unsigned-executable-memory`
- `Makefile` — Fix `distribute-macos` target

### Phase 2
- `.github/workflows/release-matrix.yml` — Add signing + notarization steps
- Landing page installation instructions (in workflow release body)

## Testing Strategy

### Phase 1 Verification
1. Run `make verify-codesign` to confirm certificate setup
2. Run `make distribute-macos` to produce signed `.dmg`
3. Verify with `codesign --verify --deep --strict recognizing.app`
4. Verify with `spctl --assess --type execute recognizing.app` (Gatekeeper check)
5. Verify notarization with `xcrun stapler validate recognizing.dmg`
6. Test on a different Mac (or new user account) to confirm clean install

### Phase 2 Verification
1. Push a test tag to trigger the workflow
2. Download the `.dmg` from GitHub Releases
3. Run the same verification commands as Phase 1
4. Test on a clean Mac
