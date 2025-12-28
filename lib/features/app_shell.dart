import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/constants/constants.dart';
import '../core/error/error_components.dart';
import '../core/error/enhanced_error_handler.dart';
import '../core/providers/app_providers.dart';
import '../core/services/haptic_service.dart';
import '../widgets/navigation/navigation_drawer.dart' show AppNavigationDrawer;
import 'dashboard/dashboard_page.dart';
import 'dictionaries/dictionaries_page.dart';
import 'prompts/prompts_page.dart';
import 'settings/settings_page_refactored.dart';
import 'transcriptions/transcriptions_page.dart';
import '../features/recording/vad_recording_overlay.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

// Global key for the inner Scaffold (main content area)
final GlobalKey<ScaffoldState> mainContentScaffoldKey =
    GlobalKey<ScaffoldState>();

class _AppShellState extends ConsumerState<AppShell> {
  BuildContext? _mainContentContext;
  @override
  void initState() {
    super.initState();
    // Set the main content scaffold key for notification service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService = ref.read(notificationServiceProvider);
      notificationService.setScaffoldKey(mainContentScaffoldKey);
    });
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
        ScaffoldMessenger.of(_mainContentContext ?? context).showSnackBar(
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

    // Define keyboard shortcuts
    final Map<LogicalKeySet, VoidCallback> shortcuts = {
      // Ctrl/Cmd + 1-5 for navigation
      if (kIsWeb)
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1):
            () => ref.read(currentPageProvider.notifier).state = 0,
      if (kIsWeb)
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2):
            () => ref.read(currentPageProvider.notifier).state = 1,
      if (kIsWeb)
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3):
            () => ref.read(currentPageProvider.notifier).state = 2,
      if (kIsWeb)
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit4):
            () => ref.read(currentPageProvider.notifier).state = 3,
      if (kIsWeb)
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit5):
            () => ref.read(currentPageProvider.notifier).state = 4,
      // Meta(Cmd) + 1-5 for macOS
      if (!kIsWeb && Platform.isMacOS)
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.digit1): () =>
            ref.read(currentPageProvider.notifier).state = 0,
      if (!kIsWeb && Platform.isMacOS)
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.digit2): () =>
            ref.read(currentPageProvider.notifier).state = 1,
      if (!kIsWeb && Platform.isMacOS)
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.digit3): () =>
            ref.read(currentPageProvider.notifier).state = 2,
      if (!kIsWeb && Platform.isMacOS)
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.digit4): () =>
            ref.read(currentPageProvider.notifier).state = 3,
      if (!kIsWeb && Platform.isMacOS)
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.digit5): () =>
            ref.read(currentPageProvider.notifier).state = 4,
      // Ctrl + 1-5 for Windows/Linux
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux))
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1):
            () => ref.read(currentPageProvider.notifier).state = 0,
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux))
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2):
            () => ref.read(currentPageProvider.notifier).state = 1,
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux))
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3):
            () => ref.read(currentPageProvider.notifier).state = 2,
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux))
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit4):
            () => ref.read(currentPageProvider.notifier).state = 3,
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux))
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit5):
            () => ref.read(currentPageProvider.notifier).state = 4,
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Scaffold(
        floatingActionButton: _buildRecordFab(context, ref, recordingState),
        body: Row(
          children: [
            // Navigation Drawer (V2 with keyboard shortcut hints)
            const AppNavigationDrawer(),

            // Main Content with separate Scaffold for SnackBar isolation
            Expanded(
              child: Scaffold(
                key: mainContentScaffoldKey,
                backgroundColor: Colors.transparent,
                body: Builder(
                  builder: (mainContentContext) => Stack(
                    children: [
                      IndexedStack(
                        index: currentPage,
                        children: const [
                          TranscriptionsPage(),
                          DashboardPage(),
                          DictionariesPage(),
                          PromptsPage(),
                          SettingsPageRefactored(),
                        ],
                      ),
                      // VAD Recording Overlay (V2 with multi-channel state indication)
                      if (recordingState != RecordingState.idle)
                        VadRecordingOverlay(),
                      // Store context reference for notifications
                      Builder(
                        builder: (context) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _mainContentContext = mainContentContext;
                          });
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildRecordFab(
      BuildContext context, WidgetRef ref, RecordingState state) {
    final settings = ref.watch(settingsProvider);

    if (!settings.hasApiKey) return null;

    return SizedBox(
      width: UIConstants.fabSize,
      height: UIConstants.fabSize,
      child: FloatingActionButton.extended(
        onPressed: state == RecordingState.processing
            ? null
            : () => _toggleRecording(context, ref, state),
        backgroundColor: state == RecordingState.recording
            ? Colors.red[400]
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation:
            state == RecordingState.recording ? 8 : UIConstants.fabElevation,
        hoverElevation: 12,
        hoverColor: state == RecordingState.recording
            ? Colors.red[300]
            : Theme.of(context).colorScheme.primaryContainer,
        isExtended: false,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state == RecordingState.processing
              ? const SizedBox(
                  key: ValueKey('processing'),
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
                  key: ValueKey(
                      state == RecordingState.recording ? 'off' : 'on'),
                  size: 24,
                  color: Colors.white,
                ),
        ),
        label: const SizedBox.shrink(),
      ),
    );
  }

  Future<void> _toggleRecording(
      BuildContext context, WidgetRef ref, RecordingState state) async {
    final voiceRecordingUseCase = ref.read(voiceRecordingUseCaseProvider);

    if (state == RecordingState.idle) {
      await HapticService.startRecording();
      await voiceRecordingUseCase.startRecording();
    } else if (state == RecordingState.recording) {
      await HapticService.mediumImpact();
      await voiceRecordingUseCase.stopRecording();
    }
  }

  void _showErrorDialog(
      BuildContext context, WidgetRef ref, ErrorResult errorResult) {
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
                ref.read(currentPageProvider.notifier).state = 4; // Settings
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

  void _showEnhancedErrorSnackBar(
      BuildContext context, WidgetRef ref, ErrorResult errorResult) {
    final severity = _getErrorSeverity(errorResult);

    if (severity.value >= ErrorSeverity.high.value) {
      _showErrorDialog(context, ref, errorResult);
      return;
    }

    final snackBar = _buildErrorSnackBar(context, ref, errorResult);
    ScaffoldMessenger.of(_mainContentContext ?? context).showSnackBar(snackBar);
  }

  SnackBar _buildErrorSnackBar(
      BuildContext context, WidgetRef ref, ErrorResult errorResult) {
    return SnackBar(
      content: _buildSnackBarContent(errorResult),
      backgroundColor: _getErrorColor(errorResult),
      duration: _calculateSnackBarDuration(errorResult),
      action: _buildSnackBarAction(context, ref, errorResult),
    );
  }

  Widget _buildSnackBarContent(ErrorResult errorResult) {
    return Row(
      children: [
        Icon(
          _getErrorIcon(errorResult),
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _formatErrorContent(errorResult),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _formatErrorContent(ErrorResult errorResult) {
    String content = errorResult.message;
    if (errorResult.actionHint != null) {
      content += '\n\n${errorResult.actionHint}';
    }
    return content;
  }

  Duration _calculateSnackBarDuration(ErrorResult errorResult) {
    const baseDuration = Duration(seconds: 8);
    if (errorResult.retryAfter == null) return baseDuration;

    final maxDuration = Duration(seconds: 10);
    final adjustedDuration =
        errorResult.retryAfter! + const Duration(seconds: 2);
    return adjustedDuration > maxDuration ? maxDuration : adjustedDuration;
  }

  SnackBarAction? _buildSnackBarAction(
      BuildContext context, WidgetRef ref, ErrorResult errorResult) {
    if (!errorResult.canRetry) {
      return SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      );
    }

    final isSettingsAction =
        errorResult.actionHint?.contains('Settings') == true;
    return SnackBarAction(
      label: isSettingsAction ? 'Settings' : 'Retry',
      textColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (isSettingsAction) {
          ref.read(currentPageProvider.notifier).state = 4; // Settings
        }
      },
    );
  }
}
