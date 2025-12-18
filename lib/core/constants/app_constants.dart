import 'package:package_info_plus/package_info_plus.dart';

class AppConstants {
  // Audio recording
  static const int millisecondsPerSecond = 1000;
  static const double minRecordingDurationSeconds = 0.5;
  static const double maxRecordingDurationSeconds = 300.0; // 5 minutes
  static const int audioSampleRate = 44100;
  static const int audioBitRate = 128000;

  // Transcription
  static const int maxTranscriptionLength = 10000;
  static const int transcriptionTitleMaxLength = 50;
  static const int transcriptionContentPreviewLength = 100;

  // File sizes and limits
  static const int minFileSizeBytes = 1000;
  static const int maxFileSizeBytes = 25000000; // 25MB
  static const int maxHistoryEntries = 1000;

  // Number formatting
  static const int thousand = 1000;
  static const int million = 1000000;

  // Animation timings
  static const int debounceDelayMs = 300;
  static const int snackbarDurationMs = 3000;
  static const int overlayFadeMs = 150;

  // Retry attempts
  static const int maxRetryAttempts = 3;
  static const int retryDelayMs = 1000;

  // Storage keys
  static const String settingsBox = 'settings';
  static const String transcriptionsBox = 'transcriptions';
  static const String promptsBox = 'prompts';
  static const String vocabularyBox = 'vocabulary';

  // Application info
  static const String appName = 'Recogniz.ing';

  // Default version - fallback if package info fails
  static const String appVersion = '1.0.0';
  static const String appVersionWithBuild = '1.0.0+1';

  // Get version from package info (call this after app initialization)
  static Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return appVersion;
    }
  }

  // Get version with build number
  static Future<String> getAppVersionWithBuild() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      return appVersionWithBuild;
    }
  }

  // Audio analysis thresholds
  static const double voiceActivityThreshold = 0.01;
  static const double minAmplitudeForVoice = 0.02;
  static const int minVoiceSamples = 5;
}

class ApiConstants {
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Headers
  static const String contentTypeHeader = 'Content-Type';
  static const String jsonContentType = 'application/json';
  static const String authHeader = 'Authorization';

  // Status codes
  static const int successCode = 200;
  static const int unauthorizedCode = 401;
  static const int rateLimitCode = 429;
  static const int serverErrorCode = 500;
}