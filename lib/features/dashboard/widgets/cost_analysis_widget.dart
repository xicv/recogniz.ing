import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/analytics_service.dart';

/// Widget showing cost analysis and value metrics
class CostAnalysisWidget extends StatefulWidget {
  final EnhancedStatistics stats;

  const CostAnalysisWidget({
    super.key,
    required this.stats,
  });

  @override
  State<CostAnalysisWidget> createState() => _CostAnalysisWidgetState();
}

class _CostAnalysisWidgetState extends State<CostAnalysisWidget> {
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
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(UIConstants.borderRadiusSmall),
                  ),
                  child: Icon(
                    LucideIcons.dollarSign,
                    color: AppColors.accent,
                    size: UIConstants.iconSmall,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingSmall),
                Text(
                  'Cost Analysis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),

            const SizedBox(height: UIConstants.spacingMedium),

            // Main cost metrics
            Row(
              children: [
                // Total Cost
                Expanded(
                  child: _buildCostMetric(
                    context,
                    icon: LucideIcons.wallet,
                    value: '\$${widget.stats.totalCost.toStringAsFixed(3)}',
                    label: 'Total Spent',
                    color: AppColors.accent,
                    subtitle:
                        '${widget.stats.totalTranscriptions} transcriptions',
                  ),
                ),
                const SizedBox(width: UIConstants.spacingSmall),
                // Cost Per Transcription
                Expanded(
                  child: _buildCostMetric(
                    context,
                    icon: LucideIcons.receipt,
                    value:
                        '\$${widget.stats.costPerTranscription.toStringAsFixed(4)}',
                    label: 'Avg Cost',
                    color: AppColors.primary,
                    subtitle: 'per transcription',
                  ),
                ),
                const SizedBox(width: UIConstants.spacingSmall),
                // Value Saved
                Expanded(
                  child: _buildCostMetric(
                    context,
                    icon: LucideIcons.piggyBank,
                    value:
                        '\$${widget.stats.valueVsTraditionalSavings.toStringAsFixed(2)}',
                    label: 'Money Saved',
                    color: AppColors.success,
                    subtitle: 'vs traditional',
                  ),
                ),
              ],
            ),

            const SizedBox(height: UIConstants.spacingMedium),

            // Token usage breakdown
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingMedium),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(UIConstants.borderRadiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.coins,
                        size: 20,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: UIConstants.spacingXSmall),
                      Text(
                        'Token Usage',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.stats.totalTokens.toStringAsFixed(0)} total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIConstants.spacingSmall),
                  Row(
                    children: [
                      // Input tokens (50% assumption)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Input',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (widget.stats.totalTokens * 0.5).toStringAsFixed(0),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).dividerColor,
                      ),
                      // Output tokens (50% assumption)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Output',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (widget.stats.totalTokens * 0.5).toStringAsFixed(0),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: UIConstants.spacingMedium),

            // Value comparison
            _buildValueComparison(context),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05);
  }

  Widget _buildCostMetric(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 10,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValueComparison(BuildContext context) {
    // Compare to traditional transcription services ($1 per minute)
    final traditionalCost = widget.stats.totalDurationMinutes * 1.0;
    final savings = widget.stats.valueVsTraditionalSavings;
    final savingsPercentage = traditionalCost > 0
        ? (savings / traditionalCost * 100).clamp(0, 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Value Comparison',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: UIConstants.spacingSmall),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Traditional Service',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  Text(
                    '\$${traditionalCost.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.arrowRight,
                color: AppColors.success,
                size: 20,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'With Recogniz.ing',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  Text(
                    '\$${widget.stats.totalCost.toStringAsFixed(3)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (savingsPercentage > 0) ...[
          const SizedBox(height: UIConstants.spacingSmall),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(UIConstants.spacingSmall),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(UIConstants.borderRadiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.trendingDown,
                  color: AppColors.success,
                  size: 16,
                ),
                const SizedBox(width: UIConstants.spacingXSmall),
                Text(
                  'You saved ${savingsPercentage.toStringAsFixed(0)}% on transcription costs!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
