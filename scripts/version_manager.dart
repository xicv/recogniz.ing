#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Version Manager Utility
///
/// This script helps manage app version and changelog programmatically.
/// Usage:
///   dart scripts/version_manager.dart --help
///   dart scripts/version_manager.dart --current
///   dart scripts/version_manager.dart --bump patch
///   dart scripts/version_manager.dart --bump patch --add-entry
///   dart scripts/version_manager.dart --changelog
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

  /// Compare two version strings
  /// Returns: negative if this < other, 0 if equal, positive if this > other
  static int compare(String v1, String v2) {
    final cleanV1 = v1.split('-').first.split('+').first;
    final cleanV2 = v2.split('-').first.split('+').first;
    final parts1 = cleanV1.split('.').map(int.parse).toList();
    final parts2 = cleanV2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 != p2) return p1 - p2;
    }
    return 0;
  }
}

/// Changelog entry model
class ChangelogChange {
  final String category;
  final String title;
  final String description;

  ChangelogChange({
    required this.category,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'description': description,
    };
  }

  factory ChangelogChange.fromJson(Map<String, dynamic> json) {
    return ChangelogChange(
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

/// Changelog version entry
class ChangelogVersion {
  final String version;
  final String date;
  final bool stable;
  final List<String> highlights;
  final List<ChangelogChange> changes;

  ChangelogVersion({
    required this.version,
    required this.date,
    this.stable = true,
    List<String>? highlights,
    List<ChangelogChange>? changes,
  })  : highlights = highlights ?? [],
        changes = changes ?? [];

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'date': date,
      'stable': stable,
      'highlights': highlights,
      'changes': changes.map((c) => c.toJson()).toList(),
    };
  }

  factory ChangelogVersion.fromJson(Map<String, dynamic> json) {
    return ChangelogVersion(
      version: json['version'] as String,
      date: json['date'] as String,
      stable: json['stable'] as bool? ?? true,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      changes: (json['changes'] as List<dynamic>?)
              ?.map((e) => ChangelogChange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Create a template entry for a new version
  factory ChangelogVersion.template(String version, String date) {
    return ChangelogVersion(
      version: version,
      date: date,
      stable: true,
      highlights: [
        'TODO: Add highlight 1',
        'TODO: Add highlight 2',
      ],
      changes: [
        ChangelogChange(
          category: 'added',
          title: 'Feature Name',
          description: 'TODO: Describe the new feature',
        ),
      ],
    );
  }

  /// Convert to Markdown format
  String toMarkdown() {
    final buffer = StringBuffer();

    // Version header
    final stability = stable ? '' : ' [Unstable]';
    buffer.writeln('## [$version]$stability - $date');
    buffer.writeln();

    // Group changes by category
    final grouped = <String, List<ChangelogChange>>{};
    for (final change in changes) {
      grouped.putIfAbsent(change.category, () => []).add(change);
    }

    // Write each category
    for (final category in ['added', 'changed', 'fixed', 'removed', 'security']) {
      if (grouped.containsKey(category)) {
        final label = _categoryLabel(category);
        buffer.writeln('### $label');
        buffer.writeln();
        for (final change in grouped[category]!) {
          buffer.writeln('- **${change.title}** - ${change.description}');
        }
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'added':
        return 'Added';
      case 'changed':
        return 'Changed';
      case 'fixed':
        return 'Fixed';
      case 'removed':
        return 'Removed';
      case 'security':
        return 'Security';
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }
}

/// Full changelog model
class Changelog {
  final String title;
  final String description;
  final Map<String, dynamic> categories;
  final List<ChangelogVersion> versions;

  Changelog({
    required this.title,
    required this.description,
    required this.categories,
    required this.versions,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'categories': categories,
      'versions': versions.map((v) => v.toJson()).toList(),
    };
  }

  factory Changelog.fromJson(Map<String, dynamic> json) {
    return Changelog(
      title: json['title'] as String? ?? 'Changelog',
      description: json['description'] as String? ?? '',
      categories: Map<String, dynamic>.from(
        json['categories'] as Map? ?? _defaultCategories(),
      ),
      versions: (json['versions'] as List<dynamic>?)
              ?.map((e) => ChangelogVersion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static Map<String, dynamic> _defaultCategories() {
    return {
      'added': {'label': 'Added', 'icon': 'plus-circle', 'color': 'bg-emerald-500'},
      'changed': {'label': 'Changed', 'icon': 'refresh-cw', 'color': 'bg-blue-500'},
      'fixed': {'label': 'Fixed', 'icon': 'bug', 'color': 'bg-amber-500'},
      'removed': {'label': 'Removed', 'icon': 'trash-2', 'color': 'bg-red-500'},
      'security': {'label': 'Security', 'icon': 'shield', 'color': 'bg-purple-500'},
    };
  }

  /// Convert to Markdown format (Keep a Changelog format)
  String toMarkdown() {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('# $title');
    buffer.writeln();
    buffer.writeln(description);
    buffer.writeln();
    buffer.writeln('The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),');
    buffer.writeln('and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    // Versions (reverse order - newest first)
    for (final version in versions.reversed) {
      buffer.write(version.toMarkdown());
      buffer.writeln('---');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Add a new version entry
  Changelog addVersion(ChangelogVersion version) {
    return Changelog(
      title: title,
      description: description,
      categories: categories,
      versions: [...versions, version],
    );
  }

  /// Check if version already exists
  bool hasVersion(String version) {
    return versions.any((v) => v.version == version);
  }

  /// Get version by version string
  ChangelogVersion? getVersion(String version) {
    for (final v in versions) {
      if (v.version == version) return v;
    }
    return null;
  }
}

/// Changelog file manager
class ChangelogManager {
  final String projectRoot;
  late final String jsonPath;
  late final String mdPath;

  ChangelogManager(this.projectRoot) {
    jsonPath = path.join(projectRoot, 'CHANGELOG.json');
    mdPath = path.join(projectRoot, 'CHANGELOG.md');
  }

  /// Load changelog from JSON file
  Future<Changelog> loadJson() async {
    final file = File(jsonPath);
    if (!await file.exists()) {
      // Create default changelog
      return Changelog(
        title: 'Recogniz.ing Changelog',
        description: 'AI-powered voice typing with real-time transcription.',
        categories: Changelog._defaultCategories(),
        versions: [],
      );
    }

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return Changelog.fromJson(json);
  }

  /// Save changelog to JSON file
  Future<void> saveJson(Changelog changelog) async {
    final file = File(jsonPath);
    const encoder = JsonEncoder.withIndent('  ');
    final content = encoder.convert(changelog.toJson());
    await file.writeAsString(content);
  }

  /// Generate Markdown from JSON and save
  Future<void> generateMarkdown() async {
    final changelog = await loadJson();
    final markdown = changelog.toMarkdown();
    await File(mdPath).writeAsString(markdown);
    print('✅ Generated $mdPath from $jsonPath');
  }

  /// Add a new version entry to the changelog
  Future<void> addVersionEntry(String version, String date) async {
    final changelog = await loadJson();

    if (changelog.hasVersion(version)) {
      print('⚠️  Version $version already exists in changelog');
      print('   Edit $jsonPath to update the entry');
      return;
    }

    final newEntry = ChangelogVersion.template(version, date);
    final updated = changelog.addVersion(newEntry);
    await saveJson(updated);

    print('✅ Added version entry for $version to $jsonPath');
    print('   Please edit the file to add actual changes:');
    print('   - Add highlights');
    print('   - Add/modify change entries');
    print('');
    print('   Run: dart scripts/version_manager.dart --changelog');
    print('   to generate the Markdown file.');
  }

  /// Verify JSON and Markdown are in sync
  Future<bool> verifySync() async {
    final jsonFile = File(jsonPath);
    final mdFile = File(mdPath);

    if (!await jsonFile.exists()) {
      print('❌ $jsonPath does not exist');
      return false;
    }

    if (!await mdFile.exists()) {
      print('❌ $mdPath does not exist');
      return false;
    }

    // Check if JSON is newer than MD
    final jsonStats = await jsonFile.stat();
    final mdStats = await mdFile.stat();

    if (jsonStats.modified.isAfter(mdStats.modified)) {
      print('⚠️  $jsonPath is newer than $mdPath');
      print('   Run: dart scripts/version_manager.dart --changelog');
      return false;
    }

    print('✅ Changelogs appear to be in sync');
    return true;
  }
}

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help')) {
    _printUsage();
    return;
  }

  final projectRoot = Directory.current.path;
  final changelogManager = ChangelogManager(projectRoot);

  // Handle changelog-only commands
  if (args.contains('--changelog')) {
    await changelogManager.generateMarkdown();
    return;
  }

  if (args.contains('--verify-changelog')) {
    await changelogManager.verifySync();
    return;
  }

  // Version management
  final pubspecPath = path.join(projectRoot, 'pubspec.yaml');
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

  final currentVersionString =
      versionLine.replaceFirst('version: ', '').trim();
  final currentVersion = VersionInfo.parse(currentVersionString);

  if (args.contains('--current')) {
    print('Current version: $currentVersionString');
    return;
  }

  VersionInfo newVersion = currentVersion;
  bool shouldAddChangelogEntry = args.contains('--add-entry');

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
    int patch = int.parse(versionParts[2].split('-').first); // Handle pre-release

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

    // Add changelog entry if requested
    if (shouldAddChangelogEntry) {
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await changelogManager.addVersionEntry(newVersion.toString(), dateStr);
    }

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
Version Manager & Changelog Tool for Recogniz.ing

USAGE:
  dart scripts/version_manager.dart [OPTIONS]

VERSION OPTIONS:
  --help                    Show this help message
  --current                 Show current version
  --bump <type>            Bump version (patch, minor, major, prerelease)
  --add-entry              Add changelog entry template when bumping
  --pub-get                Run 'flutter pub get' after updating version

CHANGELOG OPTIONS:
  --changelog              Generate CHANGELOG.md from CHANGELOG.json
  --verify-changelog       Verify JSON and Markdown are in sync

EXAMPLES:
  # Show current version
  dart scripts/version_manager.dart --current

  # Bump patch version (1.0.0 → 1.0.1)
  dart scripts/version_manager.dart --bump patch

  # Bump patch and add changelog entry
  dart scripts/version_manager.dart --bump patch --add-entry

  # Bump minor version (1.0.0 → 1.1.0) with changelog
  dart scripts/version_manager.dart --bump minor --add-entry --pub-get

  # Generate Markdown from JSON
  dart scripts/version_manager.dart --changelog

  # Verify changelogs are in sync
  dart scripts/version_manager.dart --verify-changelog

WORKFLOW:
  1. Bump version with entry: make bump-patch-entry (or manually)
  2. Edit CHANGELOG.json with actual changes
  3. Generate Markdown: dart scripts/version_manager.dart --changelog
  4. Commit both changelogs together

CHANGELOG FORMAT:
  JSON is the Single Source of Truth (SSOT).
  - Edit CHANGELOG.json to add changes
  - Run --changelog to generate CHANGELOG.md
  - Categories: added, changed, fixed, removed, security
''');
}
