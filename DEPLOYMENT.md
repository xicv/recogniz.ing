# Deployment Guide for Recogniz.ing

This guide explains how to build and deploy Recogniz.ing applications to the landing page for distribution.

## Overview

The deployment system automatically:
- Builds Flutter applications for all platforms
- Packages them into appropriate formats (ZIP, TAR, APK, AAB)
- Copies them to the landing page's public downloads directory
- Generates a manifest.json with version information
- Creates versioned download links

## Prerequisites

1. Flutter SDK installed and configured
2. Access to build tools for target platforms
3. Landing page project set up (in `landing/` directory)

## Quick Start

### Using the Makefile

```bash
# Deploy all platforms
make deploy-all

# Deploy specific platform
make deploy-macos
make deploy-windows
make deploy-linux
make deploy-android
make deploy-web
```

### Using the Deploy Script

```bash
# Deploy all platforms
./scripts/deploy.sh

# Deploy specific platform
./scripts/deploy.sh macos
./scripts/deploy.sh windows
./scripts/deploy.sh linux
./scripts/deploy.sh android
./scripts/deploy.sh web
```

## Deployment Structure

After deployment, files are organized as follows:

```
landing/public/downloads/
├── manifest.json              # Version manifest
├── downloads.html             # Download page (standalone)
├── 1.0.0/                    # Version directory
│   ├── macos/
│   │   └── recognizing-1.0.0-macos.zip
│   ├── windows/
│   │   └── recognizing-1.0.0-windows.zip
│   ├── linux/
│   │   └── recognizing-1.0.0-linux.tar.gz
│   ├── android/
│   │   ├── recognizing-1.0.0.apk
│   │   └── recognizing-1.0.0.aab
│   └── web/
│       └── recognizing-1.0.0-web.zip
```

## Platform-Specific Requirements

### macOS
- macOS 10.14 Mojave or later
- Xcode Command Line Tools
- Apple Developer ID (for distribution)

### Windows
- Windows 10 (1903) or later
- Visual Studio 2019 or later
- Windows SDK

### Linux
- 64-bit Linux distribution
- GCC toolchain
- GTK development libraries

### Android
- Android SDK
- Java Development Kit (JDK)
- Signing keys (for release)

## Automating with CI/CD

### GitHub Actions Example

```yaml
name: Build and Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Deploy to Landing Page
        run: |
          ./scripts/deploy.sh all

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./landing/public
```

## Customizing the Download Page

The download page (`landing/public/downloads.html`) can be customized:

1. **Styling**: Edit the CSS within the file
2. **Platform Information**: Update platform descriptions and requirements
3. **Analytics**: Add your analytics tracking code
4. **Version Display**: The page automatically loads version info from `manifest.json`

## Security Considerations

1. **Code Signing**: Sign macOS and Windows binaries before distribution
2. **Checksums**: Generate SHA256 checksums for download verification
3. **HTTPS**: Serve downloads over HTTPS
4. **Rate Limiting**: Implement download rate limiting if needed

## Generating Checksums

To generate checksums for all downloads:

```bash
cd landing/public/downloads
find . -type f -name "*.zip" -o -name "*.tar.gz" -o -name "*.apk" -o -name "*.aab" | \
xargs sha256sum > checksums.txt
```

## Version Management

- Version is automatically read from `pubspec.yaml`
- Each version creates its own directory
- Old versions remain available for rollback
- Use semantic versioning (MAJOR.MINOR.PATCH)

## Troubleshooting

### Build Failures
- Check Flutter doctor: `flutter doctor -v`
- Ensure all platform dependencies are installed
- Clean and rebuild: `flutter clean && flutter pub get`

### Missing Platforms
- Some platforms can only be built on their native OS
- Use cross-compilation tools if needed
- Consider using CI/CD with multiple runners

### Large File Sizes
- Consider splitting downloads
- Use differential updates for web
- Implement CDN for better distribution

## Support

For deployment issues:
1. Check the Flutter documentation
2. Review platform-specific build guides
3. Open an issue in the project repository

## Advanced Configuration

### Custom Build Flavors

To build different flavors:

```makefile
# In Makefile
build-macos-dev:
	flutter build macos --release --flavor dev

package-macos-dev:
	$(MAKE) build-macos-dev
	# Package dev build...
```

### Environment Variables

Set environment variables for builds:

```bash
export FLUTTER_BUILD_NUMBER=$(date +%s)
export FLUTTER_BUILD_NAME=$(git describe --tags --abbrev=0)
./scripts/deploy.sh
```

### Custom Packaging

Create custom packaging scripts in `scripts/`:

```bash
scripts/
├── deploy.sh           # Main deployment script
├── package-macos.sh     # macOS specific packaging
├── sign-windows.bat     # Windows signing script
└── generate-checksums.sh # Checksum generation
```