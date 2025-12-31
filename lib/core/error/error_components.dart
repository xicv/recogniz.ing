import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'error_handler.dart';

/// Error categories for better error organization
enum ErrorCategory {
  network('Network Issues', LucideIcons.wifiOff, Colors.red),
  api('API Error', LucideIcons.cloudOff, Colors.orange),
  permission('Permission Required', LucideIcons.shieldOff, Colors.amber),
  audio('Audio Problem', LucideIcons.micOff, Colors.blue),
  validation('Validation Failed', LucideIcons.alertTriangle, Colors.purple),
  storage('Storage Error', LucideIcons.hardDrive, Colors.brown),
  configuration('Configuration Error', LucideIcons.settings, Colors.grey),
  platform('Platform Error', LucideIcons.smartphone, Colors.teal);

  const ErrorCategory(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

/// Enhanced error result with category and technical details
class EnhancedErrorResult extends ErrorResult {
  final ErrorCategory category;
  final String? technicalDetails;
  final List<ErrorAction> actions;
  final DateTime? timestamp;

  const EnhancedErrorResult({
    required super.message,
    required this.category,
    this.technicalDetails,
    this.actions = const [],
    super.retryAfter,
    super.canRetry = true,
    super.actionHint,
    required super.iconName,
  }) : timestamp = null;

  factory EnhancedErrorResult.fromErrorResult(
    ErrorResult result,
    ErrorCategory category, {
    String? technicalDetails,
    List<ErrorAction> actions = const [],
  }) {
    return EnhancedErrorResult._(
      message: result.message,
      category: category,
      technicalDetails: technicalDetails,
      actions: actions,
      retryAfter: result.retryAfter,
      canRetry: result.canRetry,
      actionHint: result.actionHint,
      iconName: result.iconName,
    );
  }

  EnhancedErrorResult._({
    required super.message,
    required this.category,
    this.technicalDetails,
    this.actions = const [],
    super.retryAfter,
    super.canRetry = true,
    super.actionHint,
    required super.iconName,
  }) : timestamp = DateTime.now();
}

/// Error action for user interaction
class ErrorAction {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;

  const ErrorAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
  });
}

/// Error severity levels
enum ErrorSeverity {
  low('Low', Colors.green, 0),
  medium('Medium', Colors.orange, 1),
  high('High', Colors.red, 2),
  critical('Critical', Colors.purple, 3);

  const ErrorSeverity(this.displayName, this.color, this.value);
  final String displayName;
  final Color color;
  final int value;
}

/// Error banner widget for inline error display
class ErrorBanner extends StatelessWidget {
  final EnhancedErrorResult error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showDetails;
  final EdgeInsetsGeometry? margin;

  const ErrorBanner({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showDetails = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: error.category.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: error.category.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            dense: true,
            leading: Icon(
              error.category.icon,
              color: error.category.color,
              size: 20,
            ),
            title: Text(
              error.category.displayName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: error.category.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: onDismiss != null
                ? IconButton(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close, size: 18),
                    visualDensity: VisualDensity.compact,
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              error.message,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (error.actionHint != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error.actionHint!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (error.actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: error.actions.map((action) {
                  return OutlinedButton.icon(
                    onPressed: action.onPressed,
                    icon: action.icon != null
                        ? Icon(action.icon!, size: 16)
                        : SizedBox.shrink(),
                    label: Text(action.label),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: action.isPrimary
                          ? error.category.color.withValues(alpha: 0.1)
                          : null,
                      foregroundColor:
                          action.isPrimary ? error.category.color : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (error.canRetry && onRetry != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(error.retryAfter != null
                      ? 'Retry (${error.retryAfter!.inSeconds}s)'
                      : 'Retry'),
                ),
              ),
            ),
          ],
          if (showDetails && error.technicalDetails != null) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              title: Text(
                'Technical Details',
                style: theme.textTheme.labelSmall,
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error.technicalDetails!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Error dialog for critical errors
class ErrorDialog extends StatelessWidget {
  final EnhancedErrorResult error;
  final List<ErrorAction>? additionalActions;
  final bool canShowTechnicalDetails;

  const ErrorDialog({
    super.key,
    required this.error,
    this.additionalActions,
    this.canShowTechnicalDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        error.category.icon,
        color: error.category.color,
        size: 32,
      ),
      title: Text(error.category.displayName),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error.message),
            if (error.actionHint != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        error.actionHint!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (canShowTechnicalDetails && error.technicalDetails != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => TechnicalDetailsDialog(
                      title: 'Technical Details',
                      content: error.technicalDetails!,
                    ),
                  );
                },
                icon: const Icon(Icons.code, size: 16),
                label: const Text('View Technical Details'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (additionalActions != null)
          ...additionalActions!.map((action) => TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  action.onPressed();
                },
                child: Text(action.label),
              )),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Dialog for showing technical details
class TechnicalDetailsDialog extends StatelessWidget {
  final String title;
  final String content;

  const TechnicalDetailsDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            content,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            // Copy to clipboard
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard')),
            );
          },
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Error recovery helper with retry logic
class ErrorRecovery {
  static int getRetryCount(ErrorResult error) {
    // Extract retry count from error message or use default
    return 3; // Default to 3 retries
  }

  static Duration getRetryDelay(int attempt) {
    // Exponential backoff with jitter
    final baseDelay = Duration(milliseconds: 1000 * (1 << attempt));
    final jitter = (baseDelay.inMilliseconds * 0.1).toInt();
    return Duration(
      milliseconds: baseDelay.inMilliseconds +
          (jitter * (DateTime.now().millisecond % 2 == 0 ? 1 : -1)),
    );
  }

  static bool shouldRetry(ErrorResult error, int attemptCount) {
    if (!error.canRetry || attemptCount >= getRetryCount(error)) {
      return false;
    }

    // Don't retry certain error types
    final nonRetryableErrors = ['permission_denied', 'api_key', 'unauthorized'];
    return !nonRetryableErrors
        .any((e) => error.message.toLowerCase().contains(e));
  }
}

/// Error analytics helper (placeholder for future implementation)
class ErrorAnalytics {
  static void logError(EnhancedErrorResult error) {
    // TODO: Implement error logging service
    // Consider user privacy and consent
  }

  static Map<String, dynamic> getErrorStats() {
    // TODO: Return error statistics
    return {};
  }
}
