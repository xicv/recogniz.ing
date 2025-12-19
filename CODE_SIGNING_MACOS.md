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

### 2. Generate App-Specific Password

1. Go to: https://appleid.apple.com/account/manage/security/apps
2. Click "Generate Password..."
3. Label: "Recogniz.ing Codesign"
4. Select the app: "Other" (or "None")
5. Copy the generated password to `scripts/codesign-config.sh`

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

Notarization involves:
1. Uploading the app to Apple's notarization service
2. Apple scans for malware
3. Apple returns a notarization ticket
4. Ticket is "stapled" to the application
5. macOS verifies the notarization on first run

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

**Hardened Runtime**:
```xml
<!-- Add to macos/Runner/DebugProfile.entitlements -->
<key>com.apple.security.cs.disable-jit</key>
<true/>
```

**Missing Entitlements**:
- Ensure mic permission is requested
- Add any other required permissions

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
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Setup Code Signing
        env:
          DEVELOPER_TEAM_ID: ${{ secrets.DEVELOPER_TEAM_ID }}
          APPLE_DEVELOPER_ID: ${{ secrets.APPLE_DEVELOPER_ID }}
          APPLE_APP_PASSWORD: ${{ secrets.APPLE_APP_PASSWORD }}
        run: |
          echo "DEVELOPER_TEAM_ID=$DEVELOPER_TEAM_ID" >> scripts/codesign-config.sh
          echo "APPLE_DEVELOPER_ID=$APPLE_DEVELOPER_ID" >> scripts/codesign-config.sh
          echo "APPLE_APP_PASSWORD=$APPLE_APP_PASSWORD" >> scripts/codesign-config.sh

      - name: Build and Notarize
        run: |
          make notarize-macos

      - name: Upload Release
        uses: actions/upload-release-asset@v3
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: recognizing-*.dmg
```

## Best Practices

### Security
- Never commit certificates or passwords to git
- Use environment variables or secrets
- Restrict access to signing certificates
- Use different certificates for different apps

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
codesign --verify --deep --strict path/to/app.app

# Check notarization status
spctl -a -v -t exec open path/to/app.app

# Check Gatekeeper assessment
xattr -l path/to/app.app
```

## Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Notarizing Your App Before Distribution](https://developer.apple.com/documentation/xcode/notarizing_macos_software_before_distribution)
- [Code Signing Guide](https://developer.apple.com/library/archive/technotes/tn2206/_index.html)
- [Hardened Runtime](https://developer.apple.com/documentation/security/hardened_runtime)

## Support

For code signing issues:
1. Check Apple Developer documentation
2. Review Xcode logs
3. Verify certificate validity
4. Test with a clean build environment

Remember: Proper code signing is essential for professional macOS distribution!