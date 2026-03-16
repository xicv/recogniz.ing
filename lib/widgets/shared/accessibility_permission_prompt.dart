import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/accessibility_permission_providers.dart';

/// A widget that informs users about Accessibility permissions on macOS
///
/// Global hotkeys require Accessibility permissions on macOS. This widget
/// provides clear instructions and a button to open System Settings directly.
/// Automatically disappears when permission is granted (polled every 3s).
///
/// Includes a dismiss option for cases where AXIsProcessTrusted() returns
/// false despite permission being granted (common with ad-hoc signed builds).
class AccessibilityPermissionPrompt extends ConsumerWidget {
  const AccessibilityPermissionPrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(accessibilityPermissionProvider);

    if (hasPermission) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.shieldAlert,
                color: colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Accessibility Permission Required',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              // Dismiss button
              IconButton(
                onPressed: () {
                  ref
                      .read(accessibilityPermissionProvider.notifier)
                      .dismiss();
                },
                icon: Icon(
                  LucideIcons.x,
                  size: 16,
                  color: colorScheme.outline,
                ),
                tooltip: 'Dismiss (I already granted permission)',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Global hotkeys and push-to-talk require Accessibility permissions.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _buildStep(context, '1',
              'Click the button below to open System Settings'),
          const SizedBox(height: 4),
          _buildStep(
              context, '2', 'Find "recognizing" and enable the toggle'),
          const SizedBox(height: 4),
          _buildStep(context, '3',
              'Quit and relaunch the app (macOS caches permissions)'),
          const SizedBox(height: 8),
          Text(
            'Still seeing this after granting permission? You can dismiss this banner — it can appear incorrectly on some macOS configurations.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () {
                  ref
                      .read(accessibilityPermissionProvider.notifier)
                      .openSettings();
                },
                icon: const Icon(LucideIcons.externalLink, size: 16),
                label: const Text('Open System Settings'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ref
                      .read(accessibilityPermissionProvider.notifier)
                      .refresh();
                },
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Check Again'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
