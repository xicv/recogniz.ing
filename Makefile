# Recogniz.ing Makefile
# AI-powered voice typing application development helper

.PHONY: help get deps run run-macos run-ios run-android run-web run-windows run-linux
.PHONY: build build-macos build-ios build-apk build-web build-windows build-linux
.PHONY: test test-coverage test-single analyze format clean upgrade deps-tree
.PHONY: generate debug-release install-release logs deploy deploy-all
.PHONY: package-macos package-windows package-linux package-android package-web
.PHONY: sign-macos notarize-macos codesign-setup
.PHONY: version sync-version sync-landing changelog verify-changelog
.PHONY: bump-patch bump-minor bump-major bump-prerelease
.PHONY: bump-patch-entry bump-minor-entry bump-major-entry

# Default target
help: ## Show this help message
	@echo "Recogniz.ing Development Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# Dependencies Management
get: ## Install Flutter dependencies
	@echo "📦 Installing dependencies..."
	flutter pub get

deps: get ## Alias for get

upgrade: ## Upgrade Flutter dependencies
	@echo "⬆️  Upgrading dependencies..."
	flutter pub upgrade

deps-tree: ## Show dependency tree
	@echo "🌳 Showing dependency tree..."
	flutter pub deps

# Development Commands
run: ## Run the app on default platform
	@echo "🚀 Running app..."
	flutter run

run-macos: ## Run the app on macOS
	@echo "🍎 Running on macOS..."
	flutter run -d macos

run-ios: ## Run the app on iOS Simulator
	@echo "📱 Running on iOS..."
	flutter run -d ios

run-android: ## Run the app on Android
	@echo "🤖 Running on Android..."
	flutter run -d android

run-web: ## Run the app on Web
	@echo "🌐 Running on Web..."
	flutter run -d web

run-windows: ## Run the app on Windows
	@echo "🪟 Running on Windows..."
	flutter run -d windows

run-linux: ## Run the app on Linux
	@echo "🐧 Running on Linux..."
	flutter run -d linux

# Build Commands
build: build-macos ## Build for release (defaults to macOS)

build-macos: ## Build for macOS release
	@echo "🔨 Building for macOS..."
	@if [ "$(PLATFORM)" != "darwin" ]; then \
		echo "❌ macOS builds can only be built on macOS host"; \
		echo "📊 Current platform: $(PLATFORM)"; \
		echo "💡 Use GitHub Actions to build macOS releases"; \
		exit 1; \
	fi
	flutter build macos --release

build-ios: ## Build for iOS release
	@echo "🔨 Building for iOS..."
	flutter build ios --release

build-apk: ## Build for Android APK
	@echo "🔨 Building Android APK..."
	flutter build apk --release

build-aab: ## Build for Android App Bundle
	@echo "🔨 Building Android App Bundle..."
	flutter build appbundle --release

build-web: ## Build for Web release
	@echo "🔨 Building for Web..."
	flutter build web --release

build-windows: ## Build for Windows release
	@echo "🔨 Building for Windows..."
	@case "$(PLATFORM)" in \
		*mingw*|*msys*|*windows_nt*) ;; \
		*) echo "❌ Windows builds can only be built on Windows host"; \
		   echo "📊 Current platform: $(PLATFORM)"; \
		   echo "💡 Use GitHub Actions to build Windows releases"; \
		   exit 1 ;; \
	esac
	flutter build windows --release

build-linux: ## Build for Linux release
	@echo "🔨 Building for Linux..."
	@if [ "$(PLATFORM)" != "linux" ]; then \
		echo "❌ Linux builds can only be built on Linux host"; \
		echo "📊 Current platform: $(PLATFORM)"; \
		echo "💡 Use GitHub Actions to build Linux releases"; \
		exit 1; \
	fi
	flutter build linux --release

# Code Quality
analyze: ## Analyze code for issues
	@echo "🔍 Analyzing code..."
	flutter analyze

format: ## Format code
	@echo "✨ Formatting code..."
	flutter format .

clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	flutter clean
	flutter pub get

# Testing
test: ## Run all tests
	@echo "🧪 Running tests..."
	flutter test

test-coverage: ## Run tests with coverage
	@echo "📊 Running tests with coverage..."
	flutter test --coverage
	@echo "Coverage report generated: lcov.info"

test-single: ## Run a specific test file (usage: make test-single TEST=path/to/test.dart)
	@if [ -z "$(TEST)" ]; then \
		echo "❌ Please specify a test file: make test-single TEST=test/widget_test.dart"; \
		exit 1; \
	fi
	@echo "🧪 Running test: $(TEST)"
	flutter test $(TEST)

test-watch: ## Run tests in watch mode
	@echo "👀 Running tests in watch mode..."
	flutter test --watch

# Code Generation
generate: ## Generate code (Hive adapters, Riverpod generators)
	@echo "⚙️  Generating code..."
	flutter packages pub run build_runner build --delete-conflicting-outputs

generate-watch: ## Run code generator in watch mode
	@echo "👀 Running code generator in watch mode..."
	flutter packages pub run build_runner watch --delete-conflicting-outputs

# Debugging
debug: ## Show Flutter doctor and environment info
	@echo "🩺 Flutter Doctor:"
	flutter doctor -v
	@echo ""
	@echo "📱 Connected Devices:"
	flutter devices

logs: ## Show Flutter logs
	@echo "📋 Following Flutter logs..."
	flutter logs

# Quick Development Workflow
dev: get analyze format test ## Full development workflow (get, analyze, format, test)

quick-run: ## Quick start for macOS development
	@echo "⚡ Quick start for macOS..."
	@echo "📦 Installing dependencies..."
	@flutter pub get
	@echo "🧹 Cleaning build directory to prevent code signing issues..."
	@rm -rf build/macos
	@echo "🍎 Running on macOS..."
	@flutter run -d macos

# Release Management
install-release: build-macos ## Build and install macOS release
	@echo "📦 Installing macOS release..."
	open build/macos/Build/Products/Release/recognizing.app

# Special Commands
clean-all: clean ## Deep clean including generated files
	@echo "🧹 Deep cleaning..."
	rm -rf .dart_tool/
	rm -rf build/
	rm -f *.lock
	rm -f .packages
	flutter pub get

check-version: ## Check current Flutter and app version
	@echo "🔢 Flutter Version:"
	flutter --version
	@echo ""
	@echo "📱 App Version:"
	grep "version:" pubspec.yaml

# Hot Reload Development
dev-hotkey: run-macos ## Run with hotkey development setup
	@echo "🔥 Starting development with hotkey support..."
	@echo "💡 Use Cmd+Shift+Space to test global hotkey"

# Version Management
VERSION := $(shell grep "version:" pubspec.yaml | cut -d: -f2 | xargs)
PLATFORM := $(shell uname -s | tr '[:upper:]' '[:lower:]')

# Packaging & Deployment
package-macos: ## Build and package macOS release
	@echo "📦 Building and packaging for macOS..."
	$(MAKE) build-macos
	@echo "📋 Creating macOS package..."
	@mkdir -p landing/public/downloads/macos/$(VERSION)
	@cp -R build/macos/Build/Products/Release/recognizing.app landing/public/downloads/macos/$(VERSION)/
	@cd landing/public/downloads/macos/$(VERSION) && zip -r recognizing-$(VERSION)-macos.zip recognizing.app && rm -rf recognizing.app
	@echo "✅ macOS package created: landing/public/downloads/macos/$(VERSION)/recognizing-$(VERSION)-macos.zip"

package-windows: ## Build and package Windows release
	@echo "📦 Building and packaging for Windows..."
	$(MAKE) build-windows
	@echo "📋 Creating Windows package..."
	@mkdir -p landing/public/downloads/windows/$(VERSION)
	@cp -R build/windows/runner/Release/* landing/public/downloads/windows/$(VERSION)/
	@cd landing/public/downloads/windows/$(VERSION) && zip -r recognizing-$(VERSION)-windows.zip .
	@echo "✅ Windows package created: landing/public/downloads/windows/$(VERSION)/recognizing-$(VERSION)-windows.zip"

package-linux: ## Build and package Linux release
	@echo "📦 Building and packaging for Linux..."
	$(MAKE) build-linux
	@echo "📋 Creating Linux package..."
	@mkdir -p landing/public/downloads/linux/$(VERSION)
	@cp -R build/linux/x64/release/bundle/* landing/public/downloads/linux/$(VERSION)/
	@cd landing/public/downloads/linux/$(VERSION) && tar -czf recognizing-$(VERSION)-linux.tar.gz .
	@echo "✅ Linux package created: landing/public/downloads/linux/$(VERSION)/recognizing-$(VERSION)-linux.tar.gz"

package-android: ## Build and package Android releases
	@echo "📦 Building and packaging for Android..."
	$(MAKE) build-apk
	$(MAKE) build-aab
	@echo "📋 Creating Android packages..."
	@mkdir -p landing/public/downloads/android/$(VERSION)
	@cp build/app/outputs/flutter-apk/app-release.apk landing/public/downloads/android/$(VERSION)/recognizing-$(VERSION).apk
	@cp build/app/outputs/bundle/release/app-release.aab landing/public/downloads/android/$(VERSION)/recognizing-$(VERSION).aab
	@echo "✅ Android packages created:"
	@echo "   - APK: landing/public/downloads/android/$(VERSION)/recognizing-$(VERSION).apk"
	@echo "   - AAB: landing/public/downloads/android/$(VERSION)/recognizing-$(VERSION).aab"

package-web: ## Build and package Web release
	@echo "📦 Building and packaging for Web..."
	$(MAKE) build-web
	@echo "📋 Creating Web package..."
	@mkdir -p landing/public/downloads/web/$(VERSION)
	@cp -R build/web/* landing/public/downloads/web/$(VERSION)/
	@cd landing/public/downloads/web/$(VERSION) && zip -r recognizing-$(VERSION)-web.zip .
	@echo "✅ Web package created: landing/public/downloads/web/$(VERSION)/recognizing-$(VERSION)-web.zip"

# Deploy single platform
deploy-macos: package-macos ## Deploy macOS release to landing page

deploy-windows: package-windows ## Deploy Windows release to landing page

deploy-linux: package-linux ## Deploy Linux release to landing page

deploy-android: package-android ## Deploy Android releases to landing page

deploy-web: package-web ## Deploy Web release to landing page

# Deploy all platforms (builds only platforms supported on current host)
deploy-all: ## Build and deploy all platform releases (host-aware)
	@echo "🚀 Building and deploying all platforms..."
	@echo "📊 Detected platform: $(PLATFORM)"
	@echo "📦 Building macOS (will skip if not on macOS)..."
	@$(MAKE) package-macos || true
	@echo "📦 Building Windows (will skip if not on Windows)..."
	@$(MAKE) package-windows || true
	@echo "📦 Building Linux (will skip if not on Linux)..."
	@$(MAKE) package-linux || true
	@echo "📦 Building Android..."
	@$(MAKE) package-android
	@echo "📦 Building Web..."
	@$(MAKE) package-web
	@echo "📋 Generating download manifest..."
	@echo '{"version": "$(VERSION)", "platforms": {"macos": "downloads/macos/$(VERSION)/recognizing-$(VERSION)-macos.zip", "windows": "downloads/windows/$(VERSION)/recognizing-$(VERSION)-windows.zip", "linux": "downloads/linux/$(VERSION)/recognizing-$(VERSION)-linux.tar.gz", "android_apk": "downloads/android/$(VERSION)/recognizing-$(VERSION).apk", "android_aab": "downloads/android/$(VERSION)/recognizing-$(VERSION).aab", "web": "downloads/web/$(VERSION)/recognizing-$(VERSION)-web.zip"}, "build_date": "'$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")'"}' > landing/public/downloads/manifest.json
	@echo "✅ Supported platforms deployed successfully!"
	@echo "📋 Download manifest created: landing/public/downloads/manifest.json"
	@echo ""
	@echo "💡 For full multi-platform releases, use GitHub Actions:"

# Code Signing & Notarization
codesign-setup: ## Set up code signing configuration
	@echo "📋 Setting up code signing configuration..."
	@if [ ! -f scripts/codesign-config.sh ]; then \
		echo "❌ scripts/codesign-config.sh not found!"; \
		exit 1; \
	fi
	@echo "Please edit scripts/codesign-config.sh with your Apple Developer credentials:"
	@echo "  - DEVELOPER_TEAM_ID: Your 10-character Apple Developer Team ID"
	@echo "  - APPLE_DEVELOPER_ID: Your Apple ID email"
	@echo "  - APPLE_APP_PASSWORD: App-specific password from Apple ID"
	@echo ""
	@echo "Then run the following to store notarytool credentials in keychain:"
	@echo "  source scripts/codesign-config.sh"
	@echo "  setup_notarytool_credentials"
	@echo ""
	@echo "After setup, verify with: make verify-codesign"

verify-codesign: ## Verify code signing setup and certificates
	@echo "🔍 Verifying code signing configuration..."
	@source scripts/codesign-config.sh && verify_codesign_config
	@source scripts/codesign-config.sh && check_codesign_certificates
	@source scripts/codesign-config.sh && check_notarytool_credentials

sign-macos: ## Sign macOS build (requires codesign-setup)
	@echo "🔐 Signing macOS build..."
	@source scripts/codesign-config.sh && verify_codesign_config
	@flutter clean
	@flutter pub get
	@flutter build macos --release
	@echo "📋 Signing application..."
	@find build/macos/Build/Products/Release/recognizing.app/Contents/Frameworks -name "*.framework" -exec codesign --force --options runtime --sign "$$DEVELOPER_ID_APPLICATION_NAME" {} \;
	@find build/macos/Build/Products/Release/recognizing.app -name "*.dylib" -exec codesign --force --sign "$$DEVELOPER_ID_APPLICATION_NAME" {} \;
	@codesign --force --options runtime --sign "$$DEVELOPER_ID_APPLICATION_NAME" --deep build/macos/Build/Products/Release/recognizing.app
	@codesign --verify --deep --strict --verbose=2 build/macos/Build/Products/Release/recognizing.app
	@echo "✅ macOS build signed successfully"

notarize-macos: ## Notarize signed macOS build (requires Apple Developer account)
	@echo "📬 Notarizing macOS build..."
	@source scripts/codesign-config.sh && verify_codesign_config
	@if [ ! -f scripts/sign-macos.sh ]; then \
		echo "❌ scripts/sign-macos.sh not found!"; \
		exit 1; \
	fi
	@./scripts/sign-macos.sh

distribute-macos: ## Build, sign, and notarize macOS distribution
	@echo "📦 Creating macOS distribution package..."
	@$(MAKE) sign-macos
	@mkdir -p landing/public/downloads/macos/$(VERSION)
	@hdiutil create -srcfolder build/macos/Build/Products/Release/recognizing.app -volname "Recogniz.ing" -fs HFS+ -fsargs "-c c=64,a=16,e=16" landing/public/downloads/macos/$(VERSION)/recognizing-$(VERSION)-macos-unsigned.dmg
	@if [ -n "$$DEVELOPER_TEAM_ID" ] && [ -n "$$APPLE_DEVELOPER_ID" ]; then \
		echo "🔐 Code signing configured - creating signed distribution..."; \
		$(MAKE) notarize-macos; \
		cp recognizing-$(VERSION)-macos.dmg landing/public/downloads/macos/$(VERSION)/; \
	fi
	@echo "✅ macOS distribution package ready"

# Version Management
version: ## Show current version
	@echo "📋 Current version:"
	@dart scripts/version_manager.dart --current

sync-version: ## Sync pubspec.yaml and landing version from CHANGELOG.json (SSOT)
	@echo "Syncing version from CHANGELOG.json..."
	@dart scripts/version_manager.dart --sync-from-changelog

sync-landing: ## Sync landing/package.json version from pubspec.yaml
	@echo "Syncing landing version..."
	@dart scripts/version_manager.dart --sync-landing

changelog: ## Generate CHANGELOG.md from CHANGELOG.json
	@echo "📝 Generating changelog..."
	@dart scripts/version_manager.dart --changelog

verify-changelog: ## Verify JSON and Markdown changelogs are in sync
	@echo "🔍 Verifying changelogs..."
	@dart scripts/version_manager.dart --verify-changelog

bump-patch: ## Bump patch version (e.g., 1.0.0 → 1.0.1)
	@echo "🔖 Bumping patch version..."
	@dart scripts/version_manager.dart --bump patch --pub-get
	@echo "✅ Patch version bumped"
	@echo "💡 Use 'make bump-patch-entry' to also add a changelog entry"

bump-minor: ## Bump minor version (e.g., 1.0.0 → 1.1.0)
	@echo "🔖 Bumping minor version..."
	@dart scripts/version_manager.dart --bump minor --pub-get
	@echo "✅ Minor version bumped"
	@echo "💡 Use 'make bump-minor-entry' to also add a changelog entry"

bump-major: ## Bump major version (e.g., 1.0.0 → 2.0.0)
	@echo "🔖 Bumping major version..."
	@dart scripts/version_manager.dart --bump major --pub-get
	@echo "✅ Major version bumped"
	@echo "💡 Use 'make bump-major-entry' to also add a changelog entry"

bump-prerelease: ## Create pre-release version (usage: make bump-prerelease PRE=alpha)
	@echo "🔖 Creating pre-release version..."
	@if [ -z "$(PRE)" ]; then \
		echo "❌ Please specify pre-release identifier: make bump-prerelease PRE=alpha|beta|rc"; \
		exit 1; \
	fi
	@dart scripts/version_manager.dart --bump prerelease $(PRE) --pub-get
	@echo "✅ Pre-release version created: $(PRE)"

bump-patch-entry: ## Bump patch version and add changelog entry template
	@echo "🔖 Bumping patch version with changelog entry..."
	@dart scripts/version_manager.dart --bump patch --add-entry --pub-get
	@echo "✅ Patch version bumped with changelog entry"
	@echo "📝 Edit CHANGELOG.json to add actual changes"
	@echo "   Then run: make changelog"

bump-minor-entry: ## Bump minor version and add changelog entry template
	@echo "🔖 Bumping minor version with changelog entry..."
	@dart scripts/version_manager.dart --bump minor --add-entry --pub-get
	@echo "✅ Minor version bumped with changelog entry"
	@echo "📝 Edit CHANGELOG.json to add actual changes"
	@echo "   Then run: make changelog"

bump-major-entry: ## Bump major version and add changelog entry template
	@echo "🔖 Bumping major version with changelog entry..."
	@dart scripts/version_manager.dart --bump major --add-entry --pub-get
	@echo "✅ Major version bumped with changelog entry"
	@echo "📝 Edit CHANGELOG.json to add actual changes"
	@echo "   Then run: make changelog"

release: ## Create a release (bump patch, update changelog, commit, tag, and push)
	@echo "Creating release..."
	@$(MAKE) bump-patch-entry
	@echo ""
	@echo "====================================================================="
	@echo "STOP: Edit CHANGELOG.json to add actual changes before continuing"
	@echo "====================================================================="
	@echo ""
	@read -r
	@$(MAKE) changelog
	@git add pubspec.yaml landing/package.json CHANGELOG.json CHANGELOG.md
	@VERSION=$$(dart scripts/version_manager.dart --current | sed 's/.*: //' | sed 's/+.*//'); \
	git commit -m "chore: bump version to $$VERSION"; \
	git tag -a "$$VERSION" -m "Release $$VERSION"; \
	git push && git push --tags
	@echo ""
	@echo "Release tagged and pushed! GitHub Actions will build and create release."
	@echo "Monitor at: https://github.com/xicv/recogniz.ing/actions"

release-minor: ## Create a minor release (same as release but bumps minor version)
	@echo "Creating minor release..."
	@$(MAKE) bump-minor-entry
	@echo ""
	@echo "====================================================================="
	@echo "STOP: Edit CHANGELOG.json to add actual changes before continuing"
	@echo "====================================================================="
	@echo ""
	@read -r
	@$(MAKE) changelog
	@git add pubspec.yaml landing/package.json CHANGELOG.json CHANGELOG.md
	@VERSION=$$(dart scripts/version_manager.dart --current | sed 's/.*: //' | sed 's/+.*//'); \
	git commit -m "chore: bump version to $$VERSION"; \
	git tag -a "$$VERSION" -m "Release $$VERSION"; \
	git push && git push --tags
	@echo ""
	@echo "Release tagged and pushed! GitHub Actions will build and create release."
	@echo "Monitor at: https://github.com/xicv/recogniz.ing/actions"