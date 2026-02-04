import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/accessibility_permission_providers.dart';

/// A widget that informs users about Accessibility permissions on macOS
///
/// Global hotkeys require Accessibility permissions on macOS. This widget
/// provides clear instructions on how to grant these permissions manually.
class AccessibilityPermissionPrompt extends ConsumerWidget {
  const AccessibilityPermissionPrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(accessibilityPermissionProvider);

    // If permission is granted or not macOS, don't show anything
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
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Global hotkeys require Accessibility permissions. To enable the global recording hotkey:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _buildStep(context, '1', 'Open System Settings'),
          const SizedBox(height: 4),
          _buildStep(context, '2', 'Go to Privacy & Security > Accessibility'),
          const SizedBox(height: 4),
          _buildStep(context, '3', 'Find "Recogniz.ing" and enable the toggle'),
          const SizedBox(height: 4),
          _buildStep(context, '4', 'Restart this app'),
          const SizedBox(height: 12),
          Text(
            'After granting permission and restarting, the global hotkey will be enabled.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
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
