import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_theme.dart';

/// Simplified statistics card with expandable details
class SimplifiedStatsCard extends StatefulWidget {
  final int totalUsage;
  final int thisWeekUsage;
  final int totalTokens;
  final double totalDurationMinutes;

  const SimplifiedStatsCard({
    super.key,
    required this.totalUsage,
    required this.thisWeekUsage,
    required this.totalTokens,
    required this.totalDurationMinutes,
  });

  @override
  State<SimplifiedStatsCard> createState() => _SimplifiedStatsCardState();
}

class _SimplifiedStatsCardState extends State<SimplifiedStatsCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
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
      child: InkWell(
        onTap: _toggleExpanded,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        child: Padding(
          padding: UIConstants.cardPadding,
          child: Column(
            children: [
              // Main stats row - showing only the most important metrics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMainStat(
                    icon: LucideIcons.activity,
                    value: _formatNumber(widget.totalUsage),
                    label: 'Transcriptions',
                    color: AppColors.primary,
                  ),
                  _buildMainStat(
                    icon: LucideIcons.trendingUp,
                    value: widget.thisWeekUsage.toString(),
                    label: 'This Week',
                    color: AppColors.accent,
                  ),
                  _buildMainStat(
                    icon: LucideIcons.clock,
                    value: '${widget.totalDurationMinutes.toStringAsFixed(0)}m',
                    label: 'Total Time',
                    color: AppColors.warning,
                  ),
                ],
              ),

              // Expandable details
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: UIConstants.spacingMedium),
                  child: Column(
                    children: [
                      Divider(height: 1, color: Theme.of(context).dividerColor),
                      const SizedBox(height: UIConstants.spacingSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailStat(
                            icon: LucideIcons.coins,
                            label: 'Total Tokens',
                            value: _formatNumber(widget.totalTokens),
                          ),
                          _buildDetailStat(
                            icon: LucideIcons.fileText,
                            label: 'Avg Duration',
                            value: widget.totalUsage > 0
                                ? '${(widget.totalDurationMinutes / widget.totalUsage).toStringAsFixed(1)}s'
                                : '0s',
                          ),
                          _buildDetailStat(
                            icon: LucideIcons.barChart,
                            label: 'Daily Avg',
                            value: widget.totalUsage > 0
                                ? (widget.totalUsage / 7.0).toStringAsFixed(1)
                                : '0',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Expand button
              const SizedBox(height: UIConstants.spacingSmall),
              Icon(
                _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: UIConstants.iconSmall,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: 0.05);
  }

  Widget _buildMainStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(UIConstants.spacingSmall),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
          ),
          child: Icon(
            icon,
            color: color,
            size: UIConstants.iconSmall,
          ),
        ),
        const SizedBox(height: UIConstants.spacingXSmall),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildDetailStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: UIConstants.iconSmall,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: UIConstants.spacingXSmall),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= AppConstants.million) {
      return '${(number / AppConstants.million).toStringAsFixed(1)}M';
    } else if (number >= AppConstants.thousand) {
      return '${(number / AppConstants.thousand).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
