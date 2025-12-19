#!/bin/bash

# Deployment script for Recogniz.ing
# This script builds the Flutter app and deploys it to the landing page

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Get version from pubspec.yaml
VERSION=$(grep "version:" pubspec.yaml | cut -d: -f2 | xargs)
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')

print_status "Starting deployment for Recogniz.ing v$VERSION"

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
rm -rf build/
rm -rf .dart_tool/

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Build and deploy for specified platforms
if [ "$1" = "all" ] || [ "$1" = "" ]; then
    # Build all platforms
    print_status "Building and deploying all platforms..."

    # macOS
    print_status "Building for macOS..."
    flutter build macos --release

    # Create download directory
    mkdir -p landing/public/downloads/macos/$VERSION
    cp -R build/macos/Build/Products/Release/recognizing.app landing/public/downloads/macos/$VERSION/
    cd landing/public/downloads/macos/$VERSION
    zip -r recognizing-$VERSION-macos.zip recognizing.app
    rm -rf recognizing.app
    cd ../../../../../
    print_success "macOS package created"

    # Windows (only if on Windows or cross-compilation is set up)
    if [ "$PLATFORM" = "windows" ] || command -v cmd.exe &> /dev/null; then
        print_status "Building for Windows..."
        flutter build windows --release
        mkdir -p landing/public/downloads/windows/$VERSION
        cp -R build/windows/runner/Release/* landing/public/downloads/windows/$VERSION/
        cd landing/public/downloads/windows/$VERSION
        zip -r recognizing-$VERSION-windows.zip .
        cd ../../../../../
        print_success "Windows package created"
    else
        print_warning "Skipping Windows build (not on Windows platform)"
    fi

    # Linux (only if on Linux)
    if [ "$PLATFORM" = "linux" ]; then
        print_status "Building for Linux..."
        flutter build linux --release
        mkdir -p landing/public/downloads/linux/$VERSION
        cp -R build/linux/x64/release/bundle/* landing/public/downloads/linux/$VERSION/
        cd landing/public/downloads/linux/$VERSION
        tar -czf recognizing-$VERSION-linux.tar.gz .
        cd ../../../../../
        print_success "Linux package created"
    else
        print_warning "Skipping Linux build (not on Linux platform)"
    fi

    # Android
    print_status "Building for Android..."
    flutter build apk --release
    flutter build appbundle --release
    mkdir -p landing/public/downloads/android/$VERSION
    cp build/app/outputs/flutter-apk/app-release.apk landing/public/downloads/android/$VERSION/recognizing-$VERSION.apk
    cp build/app/outputs/bundle/release/app-release.aab landing/public/downloads/android/$VERSION/recognizing-$VERSION.aab
    print_success "Android packages created"

    # Web
    print_status "Building for Web..."
    flutter build web --release
    mkdir -p landing/public/downloads/web/$VERSION
    cp -R build/web/* landing/public/downloads/web/$VERSION/
    cd landing/public/downloads/web/$VERSION
    zip -r recognizing-$VERSION-web.zip .
    cd ../../../../../
    print_success "Web package created"

else
    # Build specific platform
    case $1 in
        macos)
            print_status "Building and deploying macOS..."
            make deploy-macos
            ;;
        windows)
            print_status "Building and deploying Windows..."
            make deploy-windows
            ;;
        linux)
            print_status "Building and deploying Linux..."
            make deploy-linux
            ;;
        android)
            print_status "Building and deploying Android..."
            make deploy-android
            ;;
        web)
            print_status "Building and deploying Web..."
            make deploy-web
            ;;
        *)
            print_error "Unknown platform: $1"
            echo "Available platforms: macos, windows, linux, android, web, all"
            exit 1
            ;;
    esac
fi

# Generate manifest
print_status "Generating download manifest..."
cat > landing/public/downloads/manifest.json << EOF
{
  "version": "$VERSION",
  "platforms": {
    "macos": "downloads/macos/$VERSION/recognizing-$VERSION-macos.zip",
    "windows": "downloads/windows/$VERSION/recognizing-$VERSION-windows.zip",
    "linux": "downloads/linux/$VERSION/recognizing-$VERSION-linux.tar.gz",
    "android_apk": "downloads/android/$VERSION/recognizing-$VERSION.apk",
    "android_aab": "downloads/android/$VERSION/recognizing-$VERSION.aab",
    "web": "downloads/web/$VERSION/recognizing-$VERSION-web.zip"
  },
  "build_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

# Create a simple index file for downloads directory
cp landing/public/downloads.html landing/public/index.html 2>/dev/null || true

print_success "Deployment complete!"
echo ""
echo "Download locations:"
echo "- macOS: landing/public/downloads/macos/$VERSION/"
echo "- Windows: landing/public/downloads/windows/$VERSION/"
echo "- Linux: landing/public/downloads/linux/$VERSION/"
echo "- Android: landing/public/downloads/android/$VERSION/"
echo "- Web: landing/public/downloads/web/$VERSION/"
echo ""
echo "Manifest file: landing/public/downloads/manifest.json"
echo ""
print_status "To serve the landing page, run:"
echo "cd landing && npm run dev"