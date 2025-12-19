import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ui_providers.dart';
import 'error_handler.dart';

/// Error state provider
final errorStateProvider = StateProvider<ErrorResult?>((ref) => null);

/// Error handler provider for easy access throughout the app
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler(
    showError: (message) {
      ref.read(lastErrorProvider.notifier).state = message;
    },
    showErrorDetails: (errorResult) {
      ref.read(errorStateProvider.notifier).state = errorResult;
      // Also set the simple error message for backward compatibility
      ref.read(lastErrorProvider.notifier).state = errorResult.message;
    },
  );
});

/// Wrapper class for error handler with provider access
class ErrorHandler {
  final Function(String) showError;
  final Function(ErrorResult) showErrorDetails;

  ErrorHandler({
    required this.showError,
    required this.showErrorDetails,
  });

  /// Handle and show an error
  void handleError(Object error, [StackTrace? stackTrace]) {
    final errorResult = AppErrorHandler.getErrorResult(error, stackTrace);
    showErrorDetails(errorResult);
  }

  /// Handle and show simple error message (backward compatibility)
  void handleSimpleError(Object error, [StackTrace? stackTrace]) {
    final message = AppErrorHandler.getUserMessage(error, stackTrace);
    showError(message);
  }

  /// Log error without showing to user
  void logError(Object error, [StackTrace? stackTrace]) {
    AppErrorHandler.logError(error, stackTrace);
  }
}
