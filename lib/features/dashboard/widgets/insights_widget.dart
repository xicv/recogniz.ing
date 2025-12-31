import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/analytics_service.dart';

/// Widget showing personalized insights and recommendations
class InsightsWidget extends StatefulWidget {
  final EnhancedStatistics stats;

  const InsightsWidget({
    super.key,
    required this.stats,
  });

  @override
  State<InsightsWidget> createState() => _InsightsWidgetState();
}

class _InsightsWidgetState extends State<InsightsWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: UIConstants.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(UIConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(UIConstants.borderRadiusSmall),
                  ),
                  child: Icon(
                    LucideIcons.lightbulb,
                    color: AppColors.warning,
                    size: UIConstants.iconSmall,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingSmall),
                Text(
                  'Insights & Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),

            const SizedBox(height: UIConstants.spacingMedium),

            // Forecast
            if (widget.stats.totalTranscriptions > 0) ...[
              _buildForecastSection(context),
              const SizedBox(height: UIConstants.spacingMedium),
            ],

            // Recommendations
            if (widget.stats.recommendations.isNotEmpty) ...[
              Text(
                'Personalized Recommendations',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: UIConstants.spacingSmall),
              ...widget.stats.recommendations.map((recommendation) =>
                  _buildRecommendation(context, recommendation)),
            ] else ...[
              _buildEmptyState(context),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.05);
  }

  Widget _buildForecastSection(BuildContext context) {
    // Calculate trend from forecast
    final forecast = widget.stats.usageForecast;
    if (forecast.isEmpty) return const SizedBox.shrink();

    final avgFutureUsage = forecast.reduce((a, b) => a + b) / forecast.length;
    final currentAvg = widget.stats.totalTranscriptions / 30; // Last 30 days
    final trend = avgFutureUsage - currentAvg;
    final trendPercentage = currentAvg > 0 ? (trend / currentAvg * 100) : 0;

    Color trendColor;
    IconData trendIcon;
    String trendText;

    if (trendPercentage.abs() < 5) {
      trendColor = AppColors.warning;
      trendIcon = LucideIcons.minus;
      trendText = 'Stable';
    } else if (trendPercentage > 0) {
      trendColor = AppColors.success;
      trendIcon = LucideIcons.trendingUp;
      trendText = 'Increasing';
    } else {
      trendColor = AppColors.error;
      trendIcon = LucideIcons.trendingDown;
      trendText = 'Decreasing';
    }

    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.activity,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: UIConstants.spacingXSmall),
              Text(
                'Usage Forecast',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    trendIcon,
                    size: 16,
                    color: trendColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trendText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            'Based on your usage pattern, you\'ll likely transcribe ${avgFutureUsage.round()} times per day next week.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withValues(alpha: 0.8),
                ),
          ),
          if (trendPercentage.abs() > 5) ...[
            const SizedBox(height: UIConstants.spacingXSmall),
            Text(
              '${trendPercentage > 0 ? '📈' : '📉'} That\'s ${trendPercentage.abs().toStringAsFixed(0)}% ${trendPercentage > 0 ? 'more' : 'less'} than your current average.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withValues(alpha: 0.8),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context, String recommendation) {
    IconData icon;
    Color color;

    if (recommendation.toLowerCase().contains('microphone') ||
        recommendation.toLowerCase().contains('audio')) {
      icon = LucideIcons.mic;
      color = AppColors.warning;
    } else if (recommendation.toLowerCase().contains('budget') ||
        recommendation.toLowerCase().contains('cost')) {
      icon = LucideIcons.dollarSign;
      color = AppColors.accent;
    } else if (recommendation.toLowerCase().contains('speed') ||
        recommendation.toLowerCase().contains('speaking')) {
      icon = LucideIcons.zap;
      color = AppColors.primary;
    } else {
      icon = LucideIcons.info;
      color = AppColors.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: UIConstants.spacingSmall),
          Expanded(
            child: Text(
              recommendation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.heart,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            'Keep using the app to get personalized insights!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingXSmall),
          Text(
            'The more you transcribe, the better we can help optimize your experience.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
