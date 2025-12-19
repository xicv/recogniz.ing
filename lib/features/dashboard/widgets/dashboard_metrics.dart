import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/analytics_service.dart';

class DashboardMetrics extends StatelessWidget {
  final EnhancedStatistics stats;

  const DashboardMetrics({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.trendingUp,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: UIConstants.spacingXSmall),
                Text(
                  'Usage Analytics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: UIConstants.spacingMedium),

            // Primary metrics grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: UIConstants.spacingSmall,
              crossAxisSpacing: UIConstants.spacingSmall,
              children: [
                _buildMetricTile(
                  context,
                  'Avg Duration',
                  stats.totalTranscriptions > 0
                      ? _formatDurationMinutes(stats.totalDurationMinutes /
                          stats.totalTranscriptions)
                      : '0:00',
                  LucideIcons.clock,
                  theme.colorScheme.primaryContainer,
                ),
                _buildMetricTile(
                  context,
                  'Avg Words/Min',
                  '${stats.avgWordsPerMinute.toStringAsFixed(0)}',
                  LucideIcons.trendingUp,
                  theme.colorScheme.secondaryContainer,
                ),
                _buildMetricTile(
                  context,
                  'Total Words',
                  '${stats.totalWords}',
                  LucideIcons.type,
                  theme.colorScheme.tertiaryContainer,
                ),
                _buildMetricTile(
                  context,
                  'Total Cost',
                  '\$${stats.totalCost.toStringAsFixed(2)}',
                  LucideIcons.dollarSign,
                  theme.colorScheme.surfaceVariant,
                ),
              ],
            ),

            // Simple trend indicator
            const SizedBox(height: UIConstants.spacingSmall),
            Row(
              children: [
                Icon(
                  stats.monthlyUsage.isNotEmpty &&
                          stats.monthlyUsage.length > 1 &&
                          stats.monthlyUsage.last >
                              stats.monthlyUsage[stats.monthlyUsage.length - 2]
                      ? LucideIcons.trendingUp
                      : LucideIcons.trendingDown,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${stats.totalTranscriptions} transcriptions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.05);
  }

  Widget _buildMetricTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color backgroundColor,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingSmall),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: UIConstants.spacingXSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDurationMinutes(double minutes) {
    final mins = minutes.floor();
    final secs = ((minutes - mins) * 60).floor();
    return '${mins}:${secs.toString().padLeft(2, '0')}';
  }
}
