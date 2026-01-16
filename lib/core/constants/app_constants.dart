import '../services/version_service.dart';

class AppConstants {
  // Audio recording
  static const int millisecondsPerSecond = 1000;
  static const double minRecordingDurationSeconds = 0.5;
  static const double maxRecordingDurationSeconds = 300.0; // 5 minutes
  static const int audioSampleRate = 16000; // 16kHz standard for speech recognition
  static const int audioBitRate = 64000; // 64kbps optimized for voice

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

  // Get version from VersionService (call this after app initialization)
  static Future<String> getAppVersion() async {
    try {
      final version = await VersionService.getVersion();
      return version.toString();
    } catch (e) {
      return '1.0.0';
    }
  }

  // Get version with build number
  static Future<String> getAppVersionWithBuild() async {
    try {
      return await VersionService.getVersionWithBuild();
    } catch (e) {
      return '1.0.0+1';
    }
  }

  // Get version display name (cleaner version for UI)
  static Future<String> getVersionDisplayName() async {
    try {
      return await VersionService.getVersionDisplayName();
    } catch (e) {
      return '1.0.0';
    }
  }

  // Audio analysis thresholds
  static const double voiceActivityThreshold = 0.01;
  static const double minAmplitudeForVoice = 0.02;
  static const int minVoiceSamples = 5;

  // Default prompt templates
  // Optimized: concise, no redundant "CLEAN VERSION:" marker
  static const String defaultPromptTemplate = 'Fix grammar, remove fillers (um/uh/like), preserve meaning:\n\n{{text}}';

  static const String defaultPromptId = 'default-clean';
  static const String defaultVocabularyId = 'default-general';
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
