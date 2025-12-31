import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/analytics_service.dart';

/// Widget showing usage patterns and visualizations
class UsagePatternWidget extends StatefulWidget {
  final EnhancedStatistics stats;

  const UsagePatternWidget({
    super.key,
    required this.stats,
  });

  @override
  State<UsagePatternWidget> createState() => _UsagePatternWidgetState();
}

class _UsagePatternWidgetState extends State<UsagePatternWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingMedium),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(UIConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(UIConstants.borderRadiusSmall),
                  ),
                  child: Icon(
                    LucideIcons.barChart3,
                    color: AppColors.primary,
                    size: UIConstants.iconSmall,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingSmall),
                Text(
                  'Usage Patterns',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Daily', icon: Icon(LucideIcons.calendar, size: 18)),
              Tab(text: 'Weekly', icon: Icon(LucideIcons.calendar, size: 18)),
              Tab(text: 'Hourly', icon: Icon(LucideIcons.clock3, size: 18)),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.outline,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDailyPattern(),
                _buildWeeklyPattern(),
                _buildHourlyPattern(),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05);
  }

  Widget _buildDailyPattern() {
    final dailyData = widget.stats.usageByDay;
    final maxCount = dailyData.values.isNotEmpty
        ? dailyData.values.reduce((a, b) => a > b ? a : b)
        : 1;

    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      child: Column(
        children: [
          Text(
            'Last 30 Days',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Expanded(
            child: dailyData.isEmpty
                ? _buildEmptyState('No recent activity')
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: dailyData.entries
                        .take(30)
                        .map((entry) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.8),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(2),
                                          ),
                                        ),
                                        child: FractionallySizedBox(
                                          heightFactor: (entry.value / maxCount)
                                              .clamp(0.1, 1.0),
                                          alignment: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${entry.key.day}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontSize: 10,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPattern() {
    final weeklyData = widget.stats.weeklyPattern;
    final maxCount =
        weeklyData.isNotEmpty ? weeklyData.reduce((a, b) => a > b ? a : b) : 1;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      child: Column(
        children: [
          Text(
            'Weekly Distribution',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = weeklyData[index];
                final heightFactor =
                    maxCount > 0 ? (value / maxCount).clamp(0.1, 1.0) : 0.1;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 32,
                          height: 80 * heightFactor,
                          decoration: BoxDecoration(
                            color: index >= 5 // Weekend
                                ? AppColors.accent
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyPattern() {
    final hourlyData = widget.stats.usageByHour;
    final maxCount =
        hourlyData.isNotEmpty ? hourlyData.reduce((a, b) => a > b ? a : b) : 1;

    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      child: Column(
        children: [
          Text(
            'Activity by Hour of Day',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Expanded(
            child: hourlyData.every((count) => count == 0)
                ? _buildEmptyState('No hourly data available')
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(24, (index) {
                      final value = hourlyData[index];
                      final isActive = value > 0;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? (index >= 9 &&
                                                index <= 17) // Business hours
                                            ? AppColors.success.withValues(alpha: 0.8)
                                            : AppColors.primary.withValues(alpha: 0.8)
                                        : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(2),
                                    ),
                                  ),
                                  child: FractionallySizedBox(
                                    heightFactor: isActive
                                        ? (value / maxCount).clamp(0.1, 1.0)
                                        : 0.05,
                                    alignment: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                index % 6 == 0 ? '$index' : '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 10,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Business Hours',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Other Hours',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.barChart3,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
