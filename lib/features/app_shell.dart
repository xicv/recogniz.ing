import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/constants/constants.dart';
import '../core/providers/app_providers.dart';
import 'dashboard/dashboard_page.dart';
import 'recording/recording_overlay.dart';
import 'settings/settings_page.dart';

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

  void _showEnhancedErrorSnackBar(BuildContext context, WidgetRef ref, ErrorResult errorResult) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine color based on error type
    Color backgroundColor = colorScheme.error;
    switch (errorResult.iconName) {
      case 'zap-off':
        backgroundColor = Colors.orange[700] ?? colorScheme.error;
        break;
      case 'timer':
        backgroundColor = Colors.amber[700] ?? colorScheme.error;
        break;
      case 'wifi-off':
        backgroundColor = Colors.blue[700] ?? colorScheme.error;
        break;
      case 'shield-off':
        backgroundColor = Colors.red[700] ?? colorScheme.error;
        break;
      default:
        backgroundColor = colorScheme.error;
    }

    // Get the icon data
    IconData iconData;
    switch (errorResult.iconName) {
      case 'cloud-off':
        iconData = LucideIcons.cloudOff;
        break;
      case 'zap-off':
        iconData = LucideIcons.zapOff;
        break;
      case 'timer':
        iconData = LucideIcons.timer;
        break;
      case 'wifi-off':
        iconData = LucideIcons.wifiOff;
        break;
      case 'shield-off':
        iconData = LucideIcons.shieldOff;
        break;
      case 'key':
        iconData = LucideIcons.key;
        break;
      case 'alert-triangle':
        iconData = LucideIcons.alertTriangle;
        break;
      case 'mic-off':
        iconData = LucideIcons.micOff;
        break;
      case 'volume-x':
        iconData = LucideIcons.volumeX;
        break;
      case 'alert-circle':
        iconData = LucideIcons.alertCircle;
        break;
      default:
        iconData = LucideIcons.alertCircle;
    }

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
