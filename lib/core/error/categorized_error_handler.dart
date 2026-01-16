import 'package:lucide_icons/lucide_icons.dart';
import 'error_handler.dart';
import 'error_components.dart';

/// Categorized error handler with error categorization and recovery options
class CategorizedErrorHandler {
  /// Convert ErrorResult to EnhancedErrorResult with proper category
  static EnhancedErrorResult categorizeErrorResult(
    ErrorResult result, {
    String? technicalDetails,
    StackTrace? stackTrace,
  }) {
    final category = _categorizeError(result);
    final actions = _getActionsForError(category, result);

    return EnhancedErrorResult.fromErrorResult(
      result,
      category,
      technicalDetails: technicalDetails ?? stackTrace?.toString(),
      actions: actions,
    );
  }

  /// Handle an error with full categorization
  static EnhancedErrorResult handleError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    // Get base error result
    final baseResult = AppErrorHandler.getErrorResult(error, stackTrace);

    // Add technical context if provided
    String? technicalDetails;
    if (context != null) {
      technicalDetails =
          'Error Context:\n${context.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
    }

    return categorizeErrorResult(
      baseResult,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
    );
  }

  /// Categorize error based on error result
  static ErrorCategory _categorizeError(ErrorResult result) {
    final message = result.message.toLowerCase();
    final icon = result.iconName;

    // Check by icon name first (most reliable)
    switch (icon) {
      case 'wifi-off':
      case 'cloud-off':
        return ErrorCategory.network;
      case 'zap-off':
      case 'timer':
        return ErrorCategory.api;
      case 'shield-off':
      case 'key':
        return ErrorCategory.permission;
      case 'mic-off':
      case 'volume-x':
        return ErrorCategory.audio;
      case 'alert-triangle':
        return ErrorCategory.validation;
      case 'hard-drive':
        return ErrorCategory.storage;
      case 'settings':
        return ErrorCategory.configuration;
      case 'smartphone':
        return ErrorCategory.platform;
    }

    // Fallback to message analysis
    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return ErrorCategory.network;
    }
    if (message.contains('api') ||
        message.contains('quota') ||
        message.contains('rate')) {
      return ErrorCategory.api;
    }
    if (message.contains('permission') || message.contains('unauthorized')) {
      return ErrorCategory.permission;
    }
    if (message.contains('audio') ||
        message.contains('recording') ||
        message.contains('speech')) {
      return ErrorCategory.audio;
    }
    if (message.contains('validation') || message.contains('invalid')) {
      return ErrorCategory.validation;
    }
    if (message.contains('storage') || message.contains('database')) {
      return ErrorCategory.storage;
    }

    return ErrorCategory.platform; // Default category
  }

  /// Get appropriate actions for error
  static List<ErrorAction> _getActionsForError(
      ErrorCategory category, ErrorResult result) {
    final actions = <ErrorAction>[];

    switch (category) {
      case ErrorCategory.network:
        actions.add(ErrorAction(
          label: 'Check Connection',
          icon: LucideIcons.wifi,
          onPressed: () {
            // TODO: Open network settings or run connection test
          },
        ));
        break;

      case ErrorCategory.api:
        if (result.actionHint?.contains('API key') == true) {
          actions.add(ErrorAction(
            label: 'Add API Key',
            icon: LucideIcons.key,
            isPrimary: true,
            onPressed: () {
              // TODO: Navigate to settings
            },
          ));
        }
        actions.add(ErrorAction(
          label: 'Check Usage',
          icon: LucideIcons.barChart,
          onPressed: () {
            // TODO: Show usage dashboard
          },
        ));
        break;

      case ErrorCategory.permission:
        actions.add(ErrorAction(
          label: 'Open Settings',
          icon: LucideIcons.settings,
          isPrimary: true,
          onPressed: () {
            // TODO: Open app settings
          },
        ));
        actions.add(ErrorAction(
          label: 'Help',
          icon: LucideIcons.helpCircle,
          onPressed: () {
            // TODO: Show permission help
          },
        ));
        break;

      case ErrorCategory.audio:
        actions.add(ErrorAction(
          label: 'Test Microphone',
          icon: LucideIcons.mic,
          onPressed: () {
            // TODO: Run microphone test
          },
        ));
        actions.add(ErrorAction(
          label: 'Audio Settings',
          icon: LucideIcons.settings,
          onPressed: () {
            // TODO: Open audio settings
          },
        ));
        break;

      case ErrorCategory.validation:
        actions.add(ErrorAction(
          label: 'Learn More',
          icon: LucideIcons.info,
          onPressed: () {
            // TODO: Show validation guide
          },
        ));
        break;

      case ErrorCategory.storage:
        actions.add(ErrorAction(
          label: 'Clear Cache',
          icon: LucideIcons.trash2,
          onPressed: () {
            // TODO: Clear cache
          },
        ));
        break;

      case ErrorCategory.configuration:
        actions.add(ErrorAction(
          label: 'Fix Configuration',
          icon: LucideIcons.settings,
          isPrimary: true,
          onPressed: () {
            // TODO: Open configuration wizard
          },
        ));
        break;

      case ErrorCategory.platform:
        actions.add(ErrorAction(
          label: 'Report Issue',
          icon: LucideIcons.bug,
          onPressed: () {
            // TODO: Open issue reporter
          },
        ));
        break;
    }

    return actions;
  }

  /// Create user-friendly message with retry information
  static String formatRetryMessage(ErrorResult result) {
    if (!result.canRetry) {
      return result.message;
    }

    if (result.retryAfter != null) {
      final duration = result.retryAfter!;
      if (duration.inMinutes > 0) {
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds % 60;
        return '${result.message}\n\nRetry available in ${minutes}m ${seconds}s';
      } else {
        return '${result.message}\n\nRetry available in ${duration.inSeconds}s';
      }
    }

    return '${result.message}\n\nTap to retry';
  }

  /// Get error severity based on category and message
  static ErrorSeverity getSeverity(ErrorCategory category, String message) {
    // Critical errors that prevent app usage
    if (category == ErrorCategory.permission &&
        message.toLowerCase().contains('permission_denied')) {
      return ErrorSeverity.critical;
    }

    // High severity errors
    if (category == ErrorCategory.api &&
        (message.toLowerCase().contains('unauthorized') ||
            message.toLowerCase().contains('invalid'))) {
      return ErrorSeverity.high;
    }

    // Medium severity errors
    if (category == ErrorCategory.network || category == ErrorCategory.audio) {
      return ErrorSeverity.medium;
    }

    // Default to low severity
    return ErrorSeverity.low;
  }

  /// Check if error is recoverable without user action
  static bool isAutoRecoverable(ErrorResult result) {
    // Only auto-retry network and temporary API errors
    final message = result.message.toLowerCase();
    return result.canRetry &&
        (message.contains('503') ||
            message.contains('timeout') ||
            message.contains('connection') ||
            message.contains('rate limit'));
  }

  /// Get suggested wait time for retry
  static Duration getRetryWaitTime(ErrorResult result, int attempt) {
    if (result.retryAfter != null) {
      return result.retryAfter!;
    }

    // Exponential backoff: 1s, 2s, 4s, 8s, max 30s
    final waitTime = Duration(seconds: (1 << attempt).clamp(1, 30));
    return waitTime;
  }
}

/// Error context builder for collecting additional error information
class ErrorContextBuilder {
  final Map<String, dynamic> _context = {};

  ErrorContextBuilder add(String key, dynamic value) {
    _context[key] = value;
    return this;
  }

  ErrorContextBuilder addRecordingContext({
    required double duration,
    required bool hasPermission,
    required String audioFormat,
  }) {
    return add('recording_duration', duration)
        .add('has_permission', hasPermission)
        .add('audio_format', audioFormat);
  }

  ErrorContextBuilder addApiContext({
    required String? apiKey,
    required String model,
    required Map<String, dynamic> parameters,
  }) {
    return add('api_key_set', apiKey != null && apiKey.isNotEmpty)
        .add('model', model)
        .add('parameters', parameters);
  }

  ErrorContextBuilder addSystemContext({
    required String platform,
    required String version,
    required bool isOnline,
  }) {
    return add('platform', platform)
        .add('app_version', version)
        .add('is_online', isOnline);
  }

  Map<String, dynamic> build() => Map.from(_context);
}
