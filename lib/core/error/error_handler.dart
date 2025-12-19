import 'package:flutter/foundation.dart';

/// Error result with additional metadata
class ErrorResult {
  final String message;
  final Duration? retryAfter;
  final bool canRetry;
  final String? actionHint;
  final String iconName; // Lucide icon name

  const ErrorResult({
    required this.message,
    this.retryAfter,
    this.canRetry = true,
    this.actionHint,
    required this.iconName,
  });
}

/// Centralized error handler for consistent error management
class AppErrorHandler {
  /// Extract retry time from error message
  static Duration? _extractRetryTime(String errorString) {
    final retryMatch =
        RegExp(r'Please retry in (\d+\.?\d*)s').firstMatch(errorString);
    if (retryMatch != null) {
      final seconds = double.tryParse(retryMatch.group(1) ?? '');
      if (seconds != null) {
        return Duration(seconds: seconds.ceil());
      }
    }
    return null;
  }

  /// Handle an error and return user-friendly message
  static ErrorResult getErrorResult(Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('=== ERROR ===');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace:\n$stackTrace');
      }
      debugPrint('============');
    }

    final errorString = error.toString().toLowerCase();

    // Network related errors
    if (errorString.contains('503') || errorString.contains('unavailable')) {
      return const ErrorResult(
        message: 'Service temporarily unavailable\n'
            'The AI service is experiencing high demand. Please try again in a few moments.',
        canRetry: true,
        iconName: 'cloud-off',
      );
    }

    if (errorString.contains('quota exceeded') ||
        errorString.contains('current quota')) {
      final retryTime = _extractRetryTime(error.toString());
      if (retryTime != null) {
        final minutes = retryTime.inMinutes;
        final seconds = retryTime.inSeconds % 60;
        if (minutes > 0) {
          return ErrorResult(
            message: 'API quota exceeded\n'
                'You\'ve reached the free tier limit.\n'
                'Please retry in ${minutes}m ${seconds}s.',
            retryAfter: retryTime,
            actionHint: 'Add your own API key in Settings for unlimited usage.',
            iconName: 'zap-off',
          );
        } else {
          return ErrorResult(
            message: 'API quota exceeded\n'
                'You\'ve reached the free tier limit.\n'
                'Please retry in $seconds seconds.',
            retryAfter: retryTime,
            actionHint: 'Add your own API key in Settings for unlimited usage.',
            iconName: 'zap-off',
          );
        }
      }
      return const ErrorResult(
        message: 'API quota exceeded\n'
            'You\'ve reached the free tier limit.\n'
            'Please try again later.',
        actionHint: 'Add your own API key in Settings for unlimited usage.',
        iconName: 'zap-off',
      );
    }

    if (errorString.contains('429') ||
        errorString.contains('rate limit') ||
        errorString.contains('resource_exhausted')) {
      return const ErrorResult(
        message: 'Rate limit exceeded\n'
            'Too many requests. Please wait a moment before trying again.',
        canRetry: true,
        iconName: 'timer',
      );
    }

    if (errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('timeout')) {
      return const ErrorResult(
        message: 'Network error\n'
            'Please check your internet connection and try again.',
        canRetry: true,
        actionHint: 'Check your Wi-Fi or mobile data connection',
        iconName: 'wifi-off',
      );
    }

    // Permission related errors
    if (errorString.contains('permission_denied') ||
        errorString.contains('permission')) {
      return const ErrorResult(
        message: 'Permission denied\n'
            'Please grant the necessary permissions and try again.',
        actionHint: 'Go to System Settings to enable microphone access',
        iconName: 'shield-off',
      );
    }

    // API related errors
    if (errorString.contains('api_key') ||
        errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return const ErrorResult(
        message: 'Authentication error\n'
            'Please check your API key in Settings.',
        actionHint: 'Add a valid API key in Settings',
        iconName: 'key',
      );
    }

    if (errorString.contains('invalid_argument') ||
        errorString.contains('400')) {
      return const ErrorResult(
        message: 'Invalid request\n'
            'The request was invalid. Please try again.',
        canRetry: true,
        iconName: 'alert-triangle',
      );
    }

    // Audio related errors
    if (errorString.contains('audio') || errorString.contains('recording')) {
      return const ErrorResult(
        message: 'Audio error\n'
            'Failed to process audio. Please ensure your microphone is working.',
        actionHint: 'Check your microphone connection and permissions',
        iconName: 'mic-off',
      );
    }

    if (errorString.contains('no speech') ||
        errorString.contains('empty transcription')) {
      return const ErrorResult(
        message: 'No speech detected\n'
            'Please speak clearly and ensure your microphone is working.',
        canRetry: true,
        actionHint: 'Speak louder or reduce background noise',
        iconName: 'volume-x',
      );
    }

    // Default error message
    return const ErrorResult(
      message: 'An unexpected error occurred\n'
          'Please try again. If the problem persists, contact support.',
      canRetry: true,
      iconName: 'alert-circle',
    );
  }

  /// Handle an error and return user-friendly message (backward compatibility)
  static String getUserMessage(Object error, [StackTrace? stackTrace]) {
    return getErrorResult(error, stackTrace).message;
  }

  /// Handle and show error to user through provider
  static void showError({
    required Object error,
    StackTrace? stackTrace,
    required Function(String) setError,
  }) {
    final userMessage = getUserMessage(error, stackTrace);
    setError(userMessage);
  }

  /// Handle and show error with full details
  static void showErrorWithDetails({
    required Object error,
    StackTrace? stackTrace,
    required Function(ErrorResult) setError,
  }) {
    final errorResult = getErrorResult(error, stackTrace);
    setError(errorResult);
  }

  /// Log error without showing to user
  static void logError(Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('=== LOGGED ERROR ===');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace:\n$stackTrace');
      }
      debugPrint('==================');
    }
  }
}

/// Custom exception types for better error handling
class AppException implements Exception {
  final String message;
  final String? userMessage;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.userMessage,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.stackTrace});
}

class ApiException extends AppException {
  const ApiException(super.message, {super.stackTrace});
}

class AudioException extends AppException {
  const AudioException(super.message, {super.stackTrace});
}
