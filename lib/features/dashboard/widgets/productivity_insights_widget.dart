import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/analytics_service.dart';

/// Widget showing productivity insights and metrics
class ProductivityInsightsWidget extends StatefulWidget {
  final EnhancedStatistics stats;

  const ProductivityInsightsWidget({
    super.key,
    required this.stats,
  });

  @override
  State<ProductivityInsightsWidget> createState() => _ProductivityInsightsWidgetState();
}

class _ProductivityInsightsWidgetState extends State<ProductivityInsightsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: UIConstants.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with trend indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(UIConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                  ),
                  child: Icon(
                    LucideIcons.trendingUp,
                    color: AppColors.success,
                    size: UIConstants.iconSmall,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingSmall),
                Text(
                  'Productivity Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.stats.streakDays > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingSmall,
                      vertical: UIConstants.spacingXXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.zap,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.stats.streakDays} day streak!',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: UIConstants.spacingMedium),

            // Main metrics
            Row(
              children: [
                // Efficiency Score
                Expanded(
                  child: _buildMetricCard(
                    context,
                    icon: LucideIcons.target,
                    value: '${widget.stats.efficiencyScore.toStringAsFixed(0)}%',
                    label: 'Efficiency Score',
                    color: AppColors.primary,
                    showPulse: widget.stats.efficiencyScore > 80,
                    pulseAnimation: _pulseAnimation,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingSmall),
                // Time Saved
                Expanded(
                  child: _buildMetricCard(
                    context,
                    icon: LucideIcons.clock,
                    value: _formatDuration(widget.stats.timeSavedMinutes),
                    label: 'Time Saved',
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingSmall),
                // Words per Minute
                Expanded(
                  child: _buildMetricCard(
                    context,
                    icon: LucideIcons.messageSquare,
                    value: '${widget.stats.avgWordsPerMinute.toStringAsFixed(0)}',
                    label: 'Words/min',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: UIConstants.spacingMedium),

            // Progress indicators
            _buildProgressBar(
              context,
              icon: LucideIcons.trendingUp,
              label: 'Voice Efficiency vs Typing',
              value: widget.stats.efficiencyScore / 100,
              color: AppColors.success,
              subtitle: '${widget.stats.efficiencyScore.toStringAsFixed(0)}% more efficient',
            ),

            const SizedBox(height: UIConstants.spacingSmall),

            _buildProgressBar(
              context,
              icon: LucideIcons.mic,
              label: 'Audio Quality Score',
              value: widget.stats.audioQualityScore,
              color: widget.stats.audioQualityScore > 0.7 ? AppColors.success : AppColors.warning,
              subtitle: '${(widget.stats.audioQualityScore * 100).toStringAsFixed(0)}% quality',
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool showPulse = false,
    Animation<double>? pulseAnimation,
  }) {
    Widget child = Container(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: UIConstants.iconMedium,
          ),
          const SizedBox(height: UIConstants.spacingXSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (showPulse && pulseAnimation != null) {
      child = AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: pulseAnimation.value,
          child: child,
        ),
        child: child,
      );
    }

    return child;
  }

  Widget _buildProgressBar(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: UIConstants.spacingXSmall),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (subtitle != null)
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingXSmall),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()}m';
    } else {
      final hours = minutes ~/ 60;
      final mins = (minutes % 60).round();
      return '${hours}h ${mins}m';
    }
  }
}