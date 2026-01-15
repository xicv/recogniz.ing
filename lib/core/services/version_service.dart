import 'package:package_info_plus/package_info_plus.dart';

/// Semantic Version information
class SemVer {
  final int major;
  final int minor;
  final int patch;
  final String? preRelease;
  final String? build;

  const SemVer({
    required this.major,
    required this.minor,
    required this.patch,
    this.preRelease,
    this.build,
  });

  factory SemVer.parse(String version) {
    // Remove build number if present (e.g., "1.0.0+1")
    final versionWithoutBuild = version.split('+').first;

    // Split version parts
    final parts = versionWithoutBuild.split('-');
    final versionPart = parts[0];
    final preReleasePart = parts.length > 1 ? parts[1] : null;

    final versionNumbers = versionPart.split('.');
    if (versionNumbers.length != 3) {
      throw FormatException('Invalid version format: $version');
    }

    return SemVer(
      major: int.parse(versionNumbers[0]),
      minor: int.parse(versionNumbers[1]),
      patch: int.parse(versionNumbers[2]),
      preRelease: preReleasePart,
    );
  }

  @override
  String toString() {
    var result = '$major.$minor.$patch';
    if (preRelease != null && preRelease!.isNotEmpty) {
      result += '-$preRelease';
    }
    if (build != null && build!.isNotEmpty) {
      result += '+$build';
    }
    return result;
  }

  /// Compare two versions
  int compareTo(SemVer other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    return 0;
  }

  bool operator >(SemVer other) => compareTo(other) > 0;
  bool operator <(SemVer other) => compareTo(other) < 0;
  bool operator >=(SemVer other) => compareTo(other) >= 0;
  bool operator <=(SemVer other) => compareTo(other) <= 0;

  SemVer copyWith({
    int? major,
    int? minor,
    int? patch,
    String? preRelease,
    String? build,
  }) {
    return SemVer(
      major: major ?? this.major,
      minor: minor ?? this.minor,
      patch: patch ?? this.patch,
      preRelease: preRelease ?? this.preRelease,
      build: build ?? this.build,
    );
  }
}

/// Version management service
class VersionService {
  static PackageInfo? _cachedPackageInfo;

  /// Get current package information
  static Future<PackageInfo> getPackageInfo() async {
    _cachedPackageInfo ??= await PackageInfo.fromPlatform();
    return _cachedPackageInfo!;
  }

  /// Get current semantic version
  static Future<SemVer> getVersion() async {
    final packageInfo = await getPackageInfo();
    return SemVer.parse(packageInfo.version);
  }

  /// Get current build number
  static Future<int> getBuildNumber() async {
    final packageInfo = await getPackageInfo();
    return int.tryParse(packageInfo.buildNumber) ?? 1;
  }

  /// Get full version string with build number
  static Future<String> getVersionWithBuild() async {
    final packageInfo = await getPackageInfo();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  /// Get version display name (without build number for production)
  static Future<String> getVersionDisplayName() async {
    final packageInfo = await getPackageInfo();

    // For pre-release versions, show pre-release identifier
    if (packageInfo.version.contains('-')) {
      return packageInfo.version;
    }

    // For stable releases, just show version without build number
    return packageInfo.version;
  }

  /// Check if this is a pre-release version
  static Future<bool> isPreRelease() async {
    final version = await getVersion();
    return version.preRelease != null && version.preRelease!.isNotEmpty;
  }

  /// Get app name
  static Future<String> getAppName() async {
    final packageInfo = await getPackageInfo();
    return packageInfo.appName;
  }

  /// Get package name
  static Future<String> getPackageName() async {
    final packageInfo = await getPackageInfo();
    return packageInfo.packageName;
  }

  /// Clear cached package info (useful for testing)
  static void clearCache() {
    _cachedPackageInfo = null;
  }

  /// Version bumping utilities
  static SemVer bumpMajor(SemVer version) {
    return version.copyWith(
      major: version.major + 1,
      minor: 0,
      patch: 0,
      preRelease: null,
      build: null,
    );
  }

  static SemVer bumpMinor(SemVer version) {
    return version.copyWith(
      minor: version.minor + 1,
      patch: 0,
      preRelease: null,
      build: null,
    );
  }

  static SemVer bumpPatch(SemVer version) {
    return version.copyWith(
      patch: version.patch + 1,
      preRelease: null,
      build: null,
    );
  }

  static SemVer createPreRelease(SemVer version, String preReleaseId) {
    return version.copyWith(
      preRelease: preReleaseId,
      build: null,
    );
  }

  /// Increment build number for next release
  static int incrementBuildNumber(int currentBuild) {
    return currentBuild + 1;
  }

  /// Generate build number from git commit count
  static Future<int> generateBuildNumberFromGit() async {
    try {
      // This would require running a shell command
      // For now, return a timestamp-based build number
      return DateTime.now().millisecondsSinceEpoch ~/ 1000;
    } catch (e) {
      return 1;
    }
  }
}
