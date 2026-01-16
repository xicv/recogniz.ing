# Version Management Guide

This document explains how versioning works in Recogniz.ing and how to manage releases.

## Version Format

We use Semantic Versioning (SemVer) without unnecessary build numbers:
```
MAJOR.MINOR.PATCH
```

- **MAJOR**: Breaking changes that require migration
- **MINOR**: New features that are backward compatible
- **PATCH**: Bug fixes that are backward compatible

### Examples
- `1.0.0` - First stable release
- `1.0.1` - Patch release with bug fixes
- `1.1.0` - Minor release with new features
- `2.0.0` - Major release with breaking changes
- `1.2.0-alpha` - Pre-release version

## Version Management Tools

### Using the Makefile (Recommended)

```bash
# Show current version
make version

# Bump versions (automatically updates pubspec.yaml)
make bump-patch    # 1.0.0 → 1.0.1
make bump-minor    # 1.0.0 → 1.1.0
make bump-major    # 1.0.0 → 2.0.0
make bump-prerelease PRE=alpha  # 1.0.0 → 1.0.0-alpha

# Create a complete release (bump patch + deploy)
make release
```

### Using the Dart Script

```bash
# Check current version
dart scripts/version_manager.dart --current

# Bump versions
dart scripts/version_manager.dart --bump patch
dart scripts/version_manager.dart --bump minor
dart scripts/version_manager.dart --bump major
dart scripts/version_manager.dart --bump prerelease beta

# Bump and update dependencies
dart scripts/version_manager.dart --bump patch --pub-get
```

### Using the Shell Script

```bash
# Interactive version bumping
./scripts/version-bump.sh patch
./scripts/version-bump.sh minor
./scripts/version-bump.sh major
./scripts/version-bump.sh prerelease alpha
```

## Automated Releases

### GitHub Actions

The project includes a GitHub Actions workflow that:
1. Automatically detects version changes
2. Builds for all platforms
3. Creates GitHub releases
4. Generates changelogs

To trigger a release:
1. Push a tag: `git tag v1.0.1 && git push --tags`
2. Or manually trigger the "Release" workflow in GitHub Actions

### CI/CD Version Bumping

The workflow supports manual version bumping:
1. Go to Actions → Release
2. Click "Run workflow"
3. Choose version bump type
4. Workflow automatically bumps, builds, and releases

## Version Display in App

The app displays version information dynamically:

- **Settings Page**: Shows clean version (e.g., "1.0.1")
- **No Hardcoded Versions**: All version info comes from `package_info_plus`
- **Simple & Clean**: No confusing build numbers in the UI
- **Fallbacks**: Proper fallbacks if package info fails to load

## Release Process

### Quick Release (Patch)

```bash
make release
```

This will:
1. Bump patch version
2. Build for all platforms
3. Package builds
4. Create deployment files
5. Prompt for git commit and tagging

### Manual Release Process

```bash
# 1. Bump version
make bump-patch

# 2. Commit changes
git add pubspec.yaml
git commit -m "chore: bump version to 1.0.1"

# 3. Create tag
git tag v1.0.1

# 4. Push to remote
git push && git push --tags

# 5. Build and deploy
make deploy-all
```

## Best Practices

### When to Bump

- **PATCH**: Bug fixes, minor improvements, documentation updates
- **MINOR**: New features, enhancements, new platform support
- **MAJOR**: Breaking changes, major architectural changes
- **PRERELEASE**: Alpha/beta releases for testing


### Git Tags

- Always tag releases: `v1.0.1`, `v1.2.0-alpha`
- Use semantic version tags for releases

## Version Service in Code

The `VersionService` provides utilities for version management:

```dart
import '../services/version_service.dart';

// Get semantic version
final version = await VersionService.getVersion();

// Check if pre-release
final isPreRelease = await VersionService.isPreRelease();

// Get display name (clean version for UI)
final displayName = await VersionService.getVersionDisplayName();
```

## Troubleshooting

### Version Not Updating

1. Ensure you're running commands from project root
2. Check `pubspec.yaml` has correct format
3. Run `flutter pub get` after version changes


### Package Info Issues

If version doesn't display correctly:
1. Check `package_info_plus` is installed
2. Ensure app is rebuilt after version changes
3. Check platform-specific build configurations

## Migration from Old System

Previously used hardcoded versions with build numbers (e.g., 1.0.0+1). New system:
- Uses clean semantic versions (e.g., 1.0.0)
- Dynamically reads from `package_info_plus`
- Supports semantic versioning
- Includes automated tooling
- Better separation of concerns
- No confusing build numbers in UI