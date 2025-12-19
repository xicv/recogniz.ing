#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;

/// Version Manager Utility
///
/// This script helps manage app version programmatically.
/// Usage:
///   dart scripts/version_manager.dart --help
///   dart scripts/version_manager.dart --current
///   dart scripts/version_manager.dart --bump patch
///   dart scripts/version_manager.dart --bump minor
///   dart scripts/version_manager.dart --bump major
///   dart scripts/version_manager.dart --bump prerelease alpha
///   dart scripts/version_manager.dart --build

class VersionInfo {
  final String version;

  VersionInfo({required this.version});

  factory VersionInfo.parse(String versionString) {
    // Remove build number if present
    final version = versionString.split('+').first;
    return VersionInfo(version: version);
  }

  @override
  String toString() {
    return version;
  }
}

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help')) {
    _printUsage();
    return;
  }

  final pubspecPath = path.join(Directory.current.path, 'pubspec.yaml');
  if (!await File(pubspecPath).exists()) {
    print('Error: pubspec.yaml not found!');
    exit(1);
  }

  final content = await File(pubspecPath).readAsString();
  final versionLine = content.split('\n').firstWhere(
    (line) => line.startsWith('version:'),
    orElse: () => '',
  );

  if (versionLine.isEmpty) {
    print('Error: Version line not found in pubspec.yaml!');
    exit(1);
  }

  final currentVersionString = versionLine.replaceFirst('version: ', '').trim();
  final currentVersion = VersionInfo.parse(currentVersionString);

  if (args.contains('--current')) {
    print('Current version: $currentVersionString');
    return;
  }

  VersionInfo newVersion = currentVersion;

  if (args.contains('--bump')) {
    final bumpIndex = args.indexOf('--bump');
    if (bumpIndex + 1 >= args.length) {
      print('Error: Please specify bump type (patch, minor, major, prerelease)');
      exit(1);
    }

    final bumpType = args[bumpIndex + 1];
    final versionParts = currentVersion.version.split('.');

    if (versionParts.length < 3) {
      print('Error: Invalid version format!');
      exit(1);
    }

    int major = int.parse(versionParts[0]);
    int minor = int.parse(versionParts[1]);
    int patch = int.parse(versionParts[2]);

    switch (bumpType) {
      case 'patch':
        patch++;
        newVersion = VersionInfo(version: '$major.$minor.$patch');
        break;
      case 'minor':
        minor++;
        patch = 0;
        newVersion = VersionInfo(version: '$major.$minor.$patch');
        break;
      case 'major':
        major++;
        minor = 0;
        patch = 0;
        newVersion = VersionInfo(version: '$major.$minor.$patch');
        break;
      case 'prerelease':
        if (bumpIndex + 2 >= args.length) {
          print('Error: Please specify pre-release identifier');
          exit(1);
        }
        final preReleaseId = args[bumpIndex + 2];
        newVersion = VersionInfo(version: '$major.$minor.$patch-$preReleaseId');
        break;
      default:
        print('Error: Invalid bump type! Use patch, minor, major, or prerelease');
        exit(1);
    }
  }

  if (newVersion.toString() != currentVersionString) {
    print('Updating version: $currentVersionString → ${newVersion.toString()}');

    // Update pubspec.yaml
    final updatedContent = content.replaceFirst(
      'version: $currentVersionString',
      'version: ${newVersion.toString()}',
    );

    await File(pubspecPath).writeAsString(updatedContent);
    print('✅ Version updated successfully!');

    // Optionally run flutter pub get
    if (args.contains('--pub-get')) {
      print('Running flutter pub get...');
      final result = await Process.run('flutter', ['pub', 'get']);
      if (result.exitCode == 0) {
        print('✅ Dependencies updated!');
      } else {
        print('❌ Failed to update dependencies');
        print(result.stderr);
      }
    }
  } else {
    print('No version changes needed');
  }
}

void _printUsage() {
  print('''
Version Manager for Recogniz.ing

USAGE:
  dart scripts/version_manager.dart [OPTIONS]

OPTIONS:
  --help                    Show this help message
  --current                 Show current version
  --bump <type>            Bump version (patch, minor, major, prerelease)
  --pub-get                Run 'flutter pub get' after updating version

EXAMPLES:
  # Show current version
  dart scripts/version_manager.dart --current

  # Bump patch version (1.0.0 → 1.0.1)
  dart scripts/version_manager.dart --bump patch

  # Bump minor version (1.0.0 → 1.1.0)
  dart scripts/version_manager.dart --bump minor

  # Bump major version (1.0.0 → 2.0.0)
  dart scripts/version_manager.dart --bump major

  # Create pre-release (1.0.0 → 1.0.0-alpha)
  dart scripts/version_manager.dart --bump prerelease alpha

  # Bump patch and update dependencies
  dart scripts/version_manager.dart --bump patch --pub-get
''');
}