# Recogniz.ing Makefile
# AI-powered voice typing application development helper

.PHONY: help get deps run run-macos run-ios run-android run-web run-windows run-linux
.PHONY: build build-macos build-ios build-apk build-web build-windows build-linux
.PHONY: test test-coverage test-single analyze format clean upgrade deps-tree
.PHONY: generate debug-release install-release logs

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
	flutter build windows --release

build-linux: ## Build for Linux release
	@echo "🔨 Building for Linux..."
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

quick-run: get run-macos ## Quick start for macOS development

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