import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Common loading indicators for consistent loading states
class LoadingIndicators {
  /// Small circular progress indicator for inline loading
  static Widget small({
    Color? color,
    double? size,
  }) {
    return SizedBox(
      width: size ?? 16,
      height: size ?? 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }

  /// Medium circular progress indicator
  static Widget medium({
    Color? color,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.blue,
        ),
      ),
    );
  }

  /// Large circular progress indicator with text
  static Widget large({
    required String message,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            color: color ?? Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  /// Skeleton loader for content placeholders
  static Widget skeleton({
    double height = 20,
    double width = double.infinity,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: const Duration(seconds: 2),
          color: Colors.white.withOpacity(0.3),
        );
  }

  /// Full-screen loading overlay
  static Widget fullScreen({
    required String message,
    Color? barrierColor,
    Widget? child,
  }) {
    return Material(
      color: barrierColor ?? Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                large(message: message),
                if (child != null) ...[
                  const SizedBox(height: 24),
                  child!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Inline loading state replacement
  static Widget inlinePlaceholder({
    required Widget child,
    required bool isLoading,
  }) {
    return isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : child;
  }

  /// Button with loading state
  static Widget loadingButton({
    required Widget child,
    required bool isLoading,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor?.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : child,
    );
  }
}

/// Loading overlay for sections of the screen
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LoadingIndicators.medium(),
                        const SizedBox(height: 16),
                        if (loadingText != null)
                          Text(
                            loadingText!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Loading shimmer effect wrapper
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? child.animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: const Duration(seconds: 2),
              color: (highlightColor ?? Colors.white).withOpacity(0.3),
            )
        : child;
  }
}
