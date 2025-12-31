import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Processing progress indicator with stage indication and ETA
///
/// Design principles:
/// - Müller-Brockmann: Mathematical precision, aligned elements
/// - Dieter Rams: Honest communication, functional clarity
///
/// Features:
/// - Linear progress bar (0-100%)
/// - Stage indication with icons
/// - Estimated time remaining
/// - Cancellation option

class ProcessingIndicator extends StatefulWidget {
  /// Current progress (0.0 to 1.0)
  final double progress;

  /// Current processing stage
  final String stage;

  /// Estimated time remaining in seconds
  final int? estimatedSeconds;

  /// Total audio duration for context
  final int? audioDurationSeconds;

  /// Callback for cancellation
  final VoidCallback? onCancel;

  /// Whether cancellation is allowed (disabled after 90%)
  final bool canCancel;

  const ProcessingIndicator({
    super.key,
    required this.progress,
    required this.stage,
    this.estimatedSeconds,
    this.audioDurationSeconds,
    this.onCancel,
    this.canCancel = true,
  });

  @override
  State<ProcessingIndicator> createState() => _ProcessingIndicatorState();
}

class _ProcessingIndicatorState extends State<ProcessingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressAnimation;
  late Animation<double> _progressTween;

  @override
  void initState() {
    super.initState();
    _progressAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressTween = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _progressAnimation, curve: Curves.easeOut),
    );
    _progressAnimation.forward();
  }

  @override
  void didUpdateWidget(ProcessingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressTween = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressAnimation,
        curve: Curves.easeOut,
      ));
      _progressAnimation.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progressAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressPercent = (widget.progress * 100).toInt();
    final allowCancel = widget.canCancel && widget.progress < 0.9;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stage icon and title
          _buildStageHeader(context, colorScheme),

          const SizedBox(height: 24),

          // Progress bar
          _buildProgressBar(context, colorScheme),

          const SizedBox(height: 16),

          // Progress details
          _buildProgressDetails(context, colorScheme, progressPercent),

          const SizedBox(height: 16),

          // Cancel button
          if (allowCancel && widget.onCancel != null)
            _buildCancelButton(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildStageHeader(BuildContext context, ColorScheme colorScheme) {
    final stageInfo = _getStageInfo(widget.stage, widget.progress);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            stageInfo.icon,
            color: colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stageInfo.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                stageInfo.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _progressTween,
      builder: (context, child) {
        return Column(
          children: [
            // Progress bar track
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                widthFactor: _progressTween.value,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Progress percentage text
            Text(
              '${(_progressTween.value * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressDetails(
    BuildContext context,
    ColorScheme colorScheme,
    int progressPercent,
  ) {
    List<String> details = [];

    // Add estimated time if available
    if (widget.estimatedSeconds != null && widget.estimatedSeconds! > 0) {
      details.add('About ${widget.estimatedSeconds}s remaining');
    }

    // Add audio duration for context
    if (widget.audioDurationSeconds != null) {
      final duration = widget.audioDurationSeconds!;
      final durationText = duration >= 60
          ? '${duration ~/ 60}m ${duration % 60}s'
          : '${duration}s';
      details.add('Audio: $durationText');
    }

    if (details.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.clock,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            details.join(' • '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, ColorScheme colorScheme) {
    return TextButton.icon(
      onPressed: widget.onCancel,
      icon: const Icon(LucideIcons.x, size: 16),
      label: const Text('Cancel'),
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
      ),
    );
  }

  _StageInfo _getStageInfo(String stage, double progress) {
    // Determine stage based on progress if not explicitly provided
    String actualStage = stage.toLowerCase();
    IconData stageIcon;
    String stageTitle;
    String stageDescription;

    if (actualStage.contains('upload') || progress < 0.2) {
      stageIcon = LucideIcons.upload;
      stageTitle = 'Uploading Audio';
      stageDescription = 'Preparing your recording for transcription...';
    } else if (actualStage.contains('transcrib') || progress < 0.6) {
      stageIcon = LucideIcons.mic;
      stageTitle = 'Transcribing';
      stageDescription = 'Converting speech to text...';
    } else if (actualStage.contains('vocab') ||
        actualStage.contains('apply') ||
        progress < 0.85) {
      stageIcon = LucideIcons.bookOpen;
      stageTitle = 'Applying Vocabulary';
      stageDescription = 'Refining with custom words...';
    } else {
      stageIcon = LucideIcons.checkCircle;
      stageTitle = 'Finalizing';
      stageDescription = 'Almost done...';
    }

    return _StageInfo(
      icon: stageIcon,
      title: stageTitle,
      description: stageDescription,
    );
  }
}

class _StageInfo {
  final IconData icon;
  final String title;
  final String description;

  _StageInfo({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ============================================================
// COMPACT PROCESSING INDICATOR
// ============================================================

/// Compact version for use in cards and smaller spaces
class CompactProcessingIndicator extends StatelessWidget {
  final double progress;
  final String? label;
  final int? estimatedSeconds;
  final Color? color;

  const CompactProcessingIndicator({
    super.key,
    required this.progress,
    this.label,
    this.estimatedSeconds,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
        ],

        // Progress bar
        Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // ETA text
        if (estimatedSeconds != null && estimatedSeconds! > 0)
          Text(
            '${(progress * 100).toInt()}% • ~${estimatedSeconds}s left',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
          ),
      ],
    );
  }
}

// ============================================================
// STAGE-BASED PROCESSING WIDGET
// ============================================================

/// Full-featured processing widget for use in dialogs/overlays
class ProcessingDialog extends StatelessWidget {
  final double progress;
  final String stage;
  final int? estimatedSeconds;
  final VoidCallback? onCancel;
  final bool canCancel;

  const ProcessingDialog({
    super.key,
    required this.progress,
    required this.stage,
    this.estimatedSeconds,
    this.onCancel,
    this.canCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(24),
      title: null,
      content: ProcessingIndicator(
        progress: progress,
        stage: stage,
        estimatedSeconds: estimatedSeconds,
        onCancel: onCancel,
        canCancel: canCancel,
      ),
    );
  }

  /// Show the processing dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required double progress,
    required String stage,
    int? estimatedSeconds,
    VoidCallback? onCancel,
    bool canCancel = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProcessingDialog(
        progress: progress,
        stage: stage,
        estimatedSeconds: estimatedSeconds,
        onCancel: onCancel,
        canCancel: canCancel,
      ),
    );
  }
}

// ============================================================
// PROCESSING STAGE ENUM
// ============================================================

/// Predefined processing stages for consistent messaging
class ProcessingStages {
  static const String uploading = 'Uploading';
  static const String transcribing = 'Transcribing';
  static const String applyingVocabulary = 'Applying Vocabulary';
  static const String finalizing = 'Finalizing';

  /// Get stage based on progress (0-1)
  static String getStageForProgress(double progress) {
    if (progress < 0.2) return uploading;
    if (progress < 0.6) return transcribing;
    if (progress < 0.85) return applyingVocabulary;
    return finalizing;
  }

  /// Calculate estimated time based on audio duration and current progress
  static int? calculateETA({
    required int audioDurationSeconds,
    required double progress,
    int overheadSeconds = 5,
  }) {
    if (progress <= 0 || audioDurationSeconds <= 0) return null;

    // Estimate: 15% of audio duration + overhead
    final totalEstimated =
        (audioDurationSeconds * 0.15 + overheadSeconds).ceil();
    final remaining = totalEstimated - (totalEstimated * progress).round();

    return remaining > 0 ? remaining : 1;
  }
}
