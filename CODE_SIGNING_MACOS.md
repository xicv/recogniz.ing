# macOS Code Signing Guide for Recogniz.ing

This guide explains how to set up code signing and notarization for your macOS builds to ensure smooth distribution and avoid security warnings.

## Why Code Signing Matters

Without proper code signing:
- macOS will show "unidentified developer" warnings
- Users must manually bypass Gatekeeper to run the app
- App distribution outside the App Store is severely limited
- Users may not trust unsigned applications

With code signing and notarization:
- App is immediately recognized as trusted
- No Gatekeeper warnings for users
- Distribution through any channel works seamlessly
- Professional appearance and user confidence

## Prerequisites

1. **Apple Developer Account**
   - Enroll at https://developer.apple.com/programs/
   - Annual fee: $99/year
   - Required for generating certificates

2. **Required Tools**
   - Xcode (latest version)
   - Command Line Tools for Xcode
   - Apple Developer ID certificates

## Step-by-Step Setup

### 1. Configure Code Signing

```bash
# Initialize code signing configuration
make codesign-setup
```

This will show you the configuration file you need to edit. Open `scripts/codesign-config.sh`:

```bash
# Fill in your Apple Developer information
export DEVELOPER_TEAM_ID="ABCD123456"  # Your 10-character Team ID
export APPLE_DEVELOPER_ID="your@email.com"
export APPLE_APP_PASSWORD="your-app-specific-password"
```

### 2. Store Notarytool Credentials

**IMPORTANT**: Apple has deprecated `altool`. Use `notarytool` which stores credentials securely in your keychain.

1. Generate an app-specific password at: https://appleid.apple.com/account/manage/security/apps
   - Click "Generate Password..."
   - Label: "Recogniz.ing Notarytool"
2. Store credentials using `notarytool` (one-time setup):

```bash
xcrun notarytool store-credentials "recognizing" \
  --apple-id "your@email.com" \
  --team-id "ABCD123456" \
  --password "xxxx-xxxx-xxxx-xxxx"
```

Your Team ID is a 10-character identifier found at:
- Apple Developer Portal → Account → Membership
- Or by running: `security find-identity -v -p codesigning`

The credentials are stored securely in your macOS keychain. You won't need to enter them again.

### 3. Create Developer ID Certificate

1. Go to: https://developer.apple.com/account/resources/
2. Click "Certificates, Identifiers & Profiles"
3. Click the "+" button → "Certificate"
4. Select "Developer ID Application"
5. Upload CSR (Certificate Signing Request)
   - Generate with: `openssl req -new -newkey rsa:2048 -keyout private.key -out CertificateSigningRequest.certSigningRequest -subj "/CN=Your Name"`
6. Download the `.cer` file
7. Double-click to install in Keychain Access

### 4. Verify Setup

```bash
# Check your configuration and certificates
make verify-codesign

# Verify notarytool credentials are stored
xcrun notarytool history --keychain-profile "recognizing"
```

## Building and Signing

### Simple Signing

```bash
# Build and sign only (no notarization)
make sign-macos
```

### Full Distribution with Notarization

```bash
# Build, sign, and notarize (recommended for distribution)
make notarize-macos
```

### Create Distribution Package

```bash
# Create signed DMG for distribution
make distribute-macos
```

## Understanding the Process

### Code Signing

The signing process:
1. Signs all frameworks and dynamic libraries
2. Signs the main application bundle
3. Verifies the signature
4. Creates a trusted application

### Notarization

Notarization involves (using `notarytool`):
1. Uploading the app to Apple's notarization service via `notarytool submit`
2. Apple scans for malware
3. Apple returns a notarization ticket (with `--wait` flag, this happens synchronously)
4. Ticket is "stapled" to the application with `stapler staple`
5. macOS verifies the notarization on first run

**Note**: Apple deprecated `altool` in 2023. Use `notarytool` for all notarization workflows. See [TN3147](https://developer.apple.com/documentation/technotes/tn3147-migrating-to-the-latest-notarization-tool) for migration details.

## Common Issues and Solutions

### "Certificate not found" Error

**Problem**: Security find-identity doesn't find your certificate

**Solution**:
1. Check Team ID matches exactly
2. Ensure certificate is in "login" keychain, not "system"
3. Verify certificate is not expired
4. Check certificate is trusted for code signing

### "Unable to locate executable" Error

**Problem**: App structure issues after signing

**Solution**:
- Ensure Info.plist has correct bundle ID
- Check CFBundleExecutable points to correct binary
- Verify all resources are properly included

### Notarization Failure

**Problem**: Notarization rejected due to:

**"Must provide credentials" Error**:
```bash
# Credentials not stored in keychain - run:
xcrun notarytool store-credentials "recognizing" \
  --apple-id "your@email.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "app-specific-password"
```

**"Invalid team ID" Error**:
- Verify Team ID matches exactly (10 characters)
- Check at: Apple Developer Portal → Account → Membership

**Hardened Runtime Issues**:
- Enable Hardened Runtime in Xcode: Signing & Capabilities → "Enable Hardened Runtime"
- Required for distribution outside App Store

**Missing Entitlements**:
- Ensure microphone permission is requested (for this app)
- Add both App Sandbox AND Hardened Runtime entitlements when both are enabled:
```xml
<!-- For App Sandbox -->
<key>com.apple.security.device.microphone</key>
<true/>
<!-- For Hardened Runtime -->
<key>com.apple.security.device.audio-input</key>
<true/>
```

**Malware Detection**:
- Ensure app doesn't use private APIs
- Check for malicious code patterns
- Review all dependencies

## Automation with GitHub Actions

Create `.github/workflows/release-macos.yml`:

```yaml
name: Release macOS

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Setup Notarytool Credentials
        env:
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APPLE_ID_PASSWORD: ${{ secrets.APPLE_ID_PASSWORD }}
          TEAM_ID: ${{ secrets.TEAM_ID }}
        run: |
          xcrun notarytool store-credentials "recognizing" \
            --apple-id "$APPLE_ID" \
            --team-id "$TEAM_ID" \
            --password "$APPLE_ID_PASSWORD"

      - name: Import Code Signing Certificate
        env:
          CERTIFICATE_BASE64: ${{ secrets.MACOS_CERTIFICATE_BASE64 }}
          CERTIFICATE_PASSWORD: ${{ secrets.MACOS_CERTIFICATE_PASSWORD }}
        run: |
          # Create temporary keychain
          security create-keychain -p "temp" build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p "temp" build.keychain

          # Import certificate
          echo "$CERTIFICATE_BASE64" | base64 --decode > certificate.p12
          security import certificate.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple: -s -k "temp" build.keychain

          # Enable code signing from the keychain
          security set-keychain-settings -lut 21600 build.keychain

      - name: Build and Notarize
        env:
          DEVELOPER_ID_APPLICATION: ${{ secrets.DEVELOPER_ID_APPLICATION }}
        run: |
          # Build the app
          flutter build macos --release

          # Sign the app
          APP_PATH="build/macos/Build/Products/Release/recognizing.app"
          find "$APP_PATH/Contents/Frameworks" -name "*.framework" -exec codesign --force --options runtime --sign "$DEVELOPER_ID_APPLICATION" {} \;
          codesign --force --options runtime --sign "$DEVELOPER_ID_APPLICATION" --deep "$APP_PATH"

          # Create DMG
          hdiutil create -srcfolder "$APP_PATH" -volname "Recogniz.ing" recognizing.dmg

          # Notarize with notarytool
          xcrun notarytool submit recognizing.dmg \
            --keychain-profile "recognizing" \
            --wait

          # Staple
          xcrun stapler staple recognizing.dmg
          xcrun stapler validate -v recognizing.dmg

      - name: Upload Release
        uses: actions/upload-release-asset@v3
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: recognizing-*.dmg
```

Required GitHub Secrets:
- `APPLE_ID`: Your Apple ID email
- `APPLE_ID_PASSWORD`: App-specific password
- `TEAM_ID`: Your 10-character Team ID
- `MACOS_CERTIFICATE_BASE64`: Base64-encoded `.p12` certificate
- `MACOS_CERTIFICATE_PASSWORD`: Certificate export password
- `DEVELOPER_ID_APPLICATION`: Certificate name

## Best Practices

### Security
- Never commit certificates or passwords to git
- Use `notarytool` keychain profiles instead of environment variables for credentials
- Restrict access to signing certificates
- Use different certificates for different apps
- Store app-specific passwords in macOS keychain, not in plain text files

### Versioning
- Update version in `pubspec.yaml` before building
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Tag releases in git

### Testing
- Always test on a clean machine
- Verify Gatekeeper allows the app to run
- Test notarization with different macOS versions

### Distribution
- Keep both signed and unsigned versions
- Provide clear installation instructions
- Include system requirements

## Alternative Tools

### App Transportation

- Use macOS App Transporter for App Store
- Upload .pkg or .dmg
- Apple handles notarization

### Third-party Tools
- [Electron-builder](https://electron.build/) (if using Electron)
- [create-dmg](https://github.com/create-dmg/create-dmg) for DMG creation
- [Sparkle](https://sparkle-project.org/) for updates

## Troubleshooting Commands

```bash
# Check certificates
security find-identity -v -p codesigning

# Verify signature
codesign --verify --deep --strict --verbose=2 path/to/app.app

# Display code signing information
codesign -dv --verbose=4 path/to/app.app

# Check notarytool credential history
xcrun notarytool history --keychain-profile "recognizing"

# Check notarization status (after submission)
xcrun notarytool info <submission-id> --keychain-profile "recognizing"

# Check Gatekeeper assessment
spctl -a -v -t exec open path/to/app.app

# Check extended attributes (quarantine flag)
xattr -l path/to/app.app

# Remove quarantine flag if needed (for testing)
xattr -d com.apple.quarantine path/to/app.app

# Validate stapled notarization ticket
xcrun stapler validate -v path/to/app.dmg
```

## Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Notarizing macOS Software Before Distribution](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [TN3147: Migrating to the Latest Notarization Tool](https://developer.apple.com/documentation/technotes/tn3147-migrating-to-the-latest-notarization-tool)
- [Customizing the Notarization Workflow](https://developer.apple.com/documentation/security/customizing_the_notarization_workflow)
- [Flutter: Building macOS Apps](https://docs.flutter.dev/platform-integration/macos/building)
- [Hardened Runtime](https://developer.apple.com/documentation/security/hardened_runtime)
- [App Sandbox](https://developer.apple.com/documentation/security/app_sandbox)

## Support

For code signing issues:
1. Check Apple Developer documentation
2. Review Xcode logs
3. Verify certificate validity
4. Test with a clean build environment

Remember: Proper code signing is essential for professional macOS distribution!