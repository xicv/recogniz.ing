import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Content-specific skeleton loaders for better perceived performance.
///
/// Skeleton screens provide visual placeholder content while data loads,
/// reducing perceived wait time and improving user experience.
///
/// Material Design 3 Principles Applied:
/// - Uses colorScheme surfaceContainerHighest for bone color
/// - Proper border radius matching actual content
/// - Shimmer animation with appropriate duration
/// - Accessibility support with proper labels

/// Skeleton loader for transcription cards.
///
/// Matches the structure of TranscriptionCard to provide
/// accurate preview of content layout.
class TranscriptionCardSkeleton extends StatelessWidget {
  final bool showActions;

  const TranscriptionCardSkeleton({
    this.showActions = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final boneColor = colorScheme.surfaceContainerHighest;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with date and action buttons
            Row(
              children: [
                // Date placeholder
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeleton(boneColor, width: 120, height: 14),
                      const SizedBox(height: 4),
                      _buildSkeleton(boneColor, width: 60, height: 12),
                    ],
                  ),
                ),
                // Action buttons placeholder
                if (showActions) ...[
                  _buildCircleSkeleton(boneColor),
                  const SizedBox(width: 4),
                  _buildCircleSkeleton(boneColor),
                  const SizedBox(width: 4),
                  _buildCircleSkeleton(boneColor),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Content placeholder
            _buildSkeleton(boneColor, width: double.infinity, height: 16),
            const SizedBox(height: 8),
            _buildSkeleton(boneColor, width: double.infinity, height: 16),
            const SizedBox(height: 8),
            _buildSkeleton(boneColor, width: 200, height: 16),

            const SizedBox(height: 12),

            // Footer metadata placeholder
            Row(
              children: [
                _buildCircleSkeleton(boneColor, size: 14),
                const SizedBox(width: 4),
                _buildSkeleton(boneColor, width: 60, height: 12),
                const SizedBox(width: 12),
                _buildCircleSkeleton(boneColor, size: 14),
                const SizedBox(width: 4),
                _buildSkeleton(boneColor, width: 40, height: 12),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.3));
  }

  Widget _buildSkeleton(Color color, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCircleSkeleton(Color color, {double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton loader for dictionary vocabulary items.
///
/// Matches the structure of vocabulary tiles in DictionariesPage.
class VocabularyTileSkeleton extends StatelessWidget {
  const VocabularyTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final boneColor = colorScheme.surfaceContainerHighest;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Icon placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: boneColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeleton(boneColor, width: 120, height: 16),
                const SizedBox(height: 4),
                _buildSkeleton(boneColor, width: 80, height: 12),
                const SizedBox(height: 4),
                _buildSkeleton(boneColor, width: 150, height: 12),
              ],
            ),
          ),
          // Trailing elements
          _buildCircleSkeleton(boneColor, size: 20),
          const SizedBox(width: 8),
          _buildCircleSkeleton(boneColor, size: 20),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.3));
  }

  Widget _buildSkeleton(Color color, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCircleSkeleton(Color color, {double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton loader for prompt cards.
///
/// Matches the structure of prompt cards in PromptsPage.
class PromptCardSkeleton extends StatelessWidget {
  const PromptCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final boneColor = colorScheme.surfaceContainerHighest;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: boneColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeleton(boneColor, width: 100, height: 16),
                    const SizedBox(height: 4),
                    _buildSkeleton(boneColor, width: 180, height: 12),
                  ],
                ),
              ),
              // Trailing icons
              _buildCircleSkeleton(boneColor, size: 20),
              const SizedBox(width: 8),
              _buildCircleSkeleton(boneColor, size: 20),
            ],
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.3));
  }

  Widget _buildSkeleton(Color color, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCircleSkeleton(Color color, {double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton loader for statistics cards on dashboard.
///
/// Matches the structure of stats cards for consistent loading experience.
class StatsCardSkeleton extends StatelessWidget {
  const StatsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final boneColor = colorScheme.surfaceContainerHighest;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            _buildSkeleton(boneColor, width: 80, height: 12),
            const SizedBox(height: 12),
            // Value
            _buildSkeleton(boneColor, width: 60, height: 28),
            const SizedBox(height: 8),
            // Trend indicator
            Row(
              children: [
                _buildCircleSkeleton(boneColor, size: 12),
                const SizedBox(width: 4),
                _buildSkeleton(boneColor, width: 40, height: 10),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.3));
  }

  Widget _buildSkeleton(Color color, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCircleSkeleton(Color color, {double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// List of transcription card skeletons.
///
/// Displays multiple skeleton cards for list loading states.
class TranscriptionListSkeleton extends StatelessWidget {
  final int count;

  const TranscriptionListSkeleton({
    this.count = 3,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: count,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TranscriptionCardSkeleton(),
        );
      },
    );
  }
}

/// List of vocabulary tile skeletons.
class VocabularyListSkeleton extends StatelessWidget {
  final int count;

  const VocabularyListSkeleton({
    this.count = 3,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: count,
      itemBuilder: (context, index) {
        return VocabularyTileSkeleton();
      },
    );
  }
}

/// List of prompt card skeletons.
class PromptListSkeleton extends StatelessWidget {
  final int count;

  const PromptListSkeleton({
    this.count = 3,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: count,
      itemBuilder: (context, index) {
        return PromptCardSkeleton();
      },
    );
  }
}
