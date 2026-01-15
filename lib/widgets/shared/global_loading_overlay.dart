import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import 'loading_indicators.dart';

/// Global loading overlay that can be triggered from anywhere in the app
class GlobalLoadingOverlay extends ConsumerWidget {
  const GlobalLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingState = ref.watch(loadingOverlayProvider);

    if (!loadingState.isLoading) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Stack(
        children: [
          // Tap to dismiss if allowed
          if (loadingState.dismissible)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  ref.read(loadingOverlayProvider.notifier).state =
                      const LoadingOverlayState();
                },
              ),
            ),

          // Loading content
          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingIndicators.large(
                      message: loadingState.message ?? 'Loading...',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    if (loadingState.dismissible) ...[
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () {
                          ref.read(loadingOverlayProvider.notifier).state =
                              const LoadingOverlayState();
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Button that shows loading state while performing async operation
class LoadingButton extends ConsumerWidget {
  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading,
    this.enabled = true,
    this.loadingText,
    this.style,
    this.fullWidth = false,
  });

  final Future<void> Function()? onPressed;
  final Widget child;
  final bool? isLoading;
  final bool enabled;
  final String? loadingText;
  final ButtonStyle? style;
  final bool fullWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActuallyLoading = isLoading ?? false;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: enabled && !isActuallyLoading
            ? () => _executeAction(context, ref)
            : null,
        style: style,
        child: isActuallyLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingIndicators.small(),
                  if (loadingText != null) ...[
                    const SizedBox(width: 8),
                    Text(loadingText!),
                  ],
                ],
              )
            : child,
      ),
    );
  }

  Future<void> _executeAction(BuildContext context, WidgetRef ref) async {
    if (onPressed != null) {
      try {
        await onPressed!();
      } catch (e) {
        // Error handling can be added here
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        rethrow;
      }
    }
  }
}

/// Skeleton list item for placeholder content
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({
    super.key,
    this.hasAvatar = false,
    this.lines = 2,
    this.height,
  });

  final bool hasAvatar;
  final int lines;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (hasAvatar) ...[
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LoadingIndicators.skeleton(
                        height: 16,
                        width: double.infinity * 0.6,
                      ),
                      const SizedBox(height: 8),
                      if (lines > 1) ...[
                        LoadingIndicators.skeleton(
                          height: 14,
                          width: double.infinity,
                        ),
                        if (lines > 2) ...[
                          const SizedBox(height: 4),
                          LoadingIndicators.skeleton(
                            height: 14,
                            width: double.infinity * 0.8,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (height != null) ...[
              const SizedBox(height: 16),
              LoadingIndicators.skeleton(
                height: height!,
                width: double.infinity,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
