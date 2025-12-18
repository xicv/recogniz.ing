import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/constants/constants.dart';
import '../core/error/error_components.dart';
import '../core/error/enhanced_error_handler.dart';
import '../core/providers/app_providers.dart';
import 'dashboard/dashboard_page.dart';
import 'recording/recording_overlay.dart';
import 'settings/settings_page.dart';
import 'transcriptions/transcriptions_page.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);
    final recordingState = ref.watch(recordingStateProvider);
    final lastError = ref.watch(lastErrorProvider);
    final errorState = ref.watch(errorStateProvider);

    // Listen to tray recording trigger
    ref.listen(trayRecordingTriggerProvider, (prev, next) {
      if (prev != next) {
        _toggleRecording(context, ref, recordingState);
      }
    });

    // Show error snackbar if there's an error
    if (lastError != null && errorState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEnhancedErrorSnackBar(context, ref, errorState);
        ref.read(lastErrorProvider.notifier).state = null;
        ref.read(errorStateProvider.notifier).state = null;
      });
    } else if (lastError != null) {
      // Fallback for simple errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lastError),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ref.read(lastErrorProvider.notifier).state = null;
              },
            ),
          ),
        );
        ref.read(lastErrorProvider.notifier).state = null;
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentPage,
            children: const [
              TranscriptionsPage(),
              DashboardPage(),
              SettingsPage(),
            ],
          ),
          if (recordingState != RecordingState.idle) const RecordingOverlay(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPage,
        onDestinationSelected: (index) {
          ref.read(currentPageProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.fileText),
            selectedIcon: Icon(LucideIcons.fileText),
            label: 'Transcriptions',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.layoutDashboard),
            selectedIcon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.settings),
            selectedIcon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _buildRecordFab(context, ref, recordingState),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget? _buildRecordFab(
      BuildContext context, WidgetRef ref, RecordingState state) {
    final settings = ref.watch(settingsProvider);

    if (!settings.hasApiKey) return null;

    return SizedBox(
      width: UIConstants.fabSize,
      height: UIConstants.fabSize,
      child: FloatingActionButton(
        onPressed: state == RecordingState.processing
            ? null
            : () => _toggleRecording(context, ref, state),
        backgroundColor: state == RecordingState.recording
            ? Colors.red
            : Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        elevation: UIConstants.fabElevation,
        child: state == RecordingState.processing
            ? const SizedBox(
                width: UIConstants.iconMedium,
                height: UIConstants.iconMedium,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Icon(
                state == RecordingState.recording
                    ? LucideIcons.micOff
                    : LucideIcons.mic,
                size: 24,
                color: Colors.white,
              ),
      ),
    );
  }

  Future<void> _toggleRecording(
      BuildContext context, WidgetRef ref, RecordingState state) async {
    final recordingUseCase = ref.read(recordingUseCaseProvider);
    await recordingUseCase.toggleRecording(state);
  }

  void _showErrorDialog(BuildContext context, WidgetRef ref, ErrorResult errorResult) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        error: EnhancedErrorHandler.enhanceErrorResult(errorResult),
        additionalActions: [
          if (errorResult.actionHint?.contains('Settings') == true)
            ErrorAction(
              label: 'Open Settings',
              icon: LucideIcons.settings,
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(currentPageProvider.notifier).state = 1;
              },
            ),
        ],
        canShowTechnicalDetails: kDebugMode,
      ),
    );
  }

  ErrorSeverity _getErrorSeverity(ErrorResult result) {
    final message = result.message.toLowerCase();
    final icon = result.iconName;

    if (message.contains('permission_denied') || icon == 'shield-off') {
      return ErrorSeverity.critical;
    }

    if (message.contains('unauthorized') || message.contains('invalid')) {
      return ErrorSeverity.high;
    }

    if (icon == 'wifi-off' || icon == 'mic-off' || icon == 'cloud-off') {
      return ErrorSeverity.medium;
    }

    return ErrorSeverity.low;
  }

  Color _getErrorColor(ErrorResult result) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (result.iconName) {
      case 'zap-off':
        return Colors.orange[700] ?? colorScheme.error;
      case 'timer':
        return Colors.amber[700] ?? colorScheme.error;
      case 'wifi-off':
        return Colors.blue[700] ?? colorScheme.error;
      case 'shield-off':
        return Colors.red[700] ?? colorScheme.error;
      default:
        return colorScheme.error;
    }
  }

  IconData _getErrorIcon(ErrorResult result) {
    switch (result.iconName) {
      case 'cloud-off':
        return LucideIcons.cloudOff;
      case 'zap-off':
        return LucideIcons.zapOff;
      case 'timer':
        return LucideIcons.timer;
      case 'wifi-off':
        return LucideIcons.wifiOff;
      case 'shield-off':
        return LucideIcons.shieldOff;
      case 'key':
        return LucideIcons.key;
      case 'alert-triangle':
        return LucideIcons.alertTriangle;
      case 'mic-off':
        return LucideIcons.micOff;
      case 'volume-x':
        return LucideIcons.volumeX;
      case 'alert-circle':
        return LucideIcons.alertCircle;
      default:
        return LucideIcons.alertCircle;
    }
  }

  void _showEnhancedErrorSnackBar(BuildContext context, WidgetRef ref, ErrorResult errorResult) {
    // Check if this is a critical error that needs a dialog
    final severity = _getErrorSeverity(errorResult);

    if (severity.value >= ErrorSeverity.high.value) {
      _showErrorDialog(context, ref, errorResult);
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;

    // Determine color based on error category
    Color backgroundColor = _getErrorColor(errorResult);

    // Get the icon data
    IconData iconData = _getErrorIcon(errorResult);

    // Build the content
    String content = errorResult.message;
    if (errorResult.actionHint != null) {
      content += '\n\n${errorResult.actionHint}';
    }

    // Calculate duration based on retry time
    Duration duration = const Duration(seconds: 8);
    if (errorResult.retryAfter != null) {
      duration = errorResult.retryAfter! > const Duration(seconds: 10)
          ? const Duration(seconds: 10)
          : errorResult.retryAfter! + const Duration(seconds: 2);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              iconData,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: errorResult.canRetry
            ? SnackBarAction(
                label: errorResult.actionHint?.contains('Settings') == true
                    ? 'Settings'
                    : 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  if (errorResult.actionHint?.contains('Settings') == true) {
                    ref.read(currentPageProvider.notifier).state = 1;
                  }
                },
              )
            : SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
      ),
    );
  }
}
