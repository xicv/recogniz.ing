import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/transcription_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/shared/content_skeletons.dart';
import '../../widgets/shared/empty_states.dart';
import 'widgets/compact_stats_card.dart';
import 'widgets/dashboard_metrics.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(statisticsProvider);
    final enhancedStats = ref.watch(enhancedStatisticsProvider);
    final transcriptions = ref.watch(filteredTranscriptionsProvider);
    final settings = ref.watch(settingsProvider);

    // Show empty state if no transcriptions and no API key
    if (transcriptions.isEmpty && !settings.hasApiKey) {
      return Scaffold(
        body: DashboardEmptyState(
          hasApiKey: false,
          onOpenSettings: () => ref.read(currentPageProvider.notifier).state = 4,
        ),
      );
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ).animate().fadeIn(duration: 300.ms),
                            const SizedBox(height: 4),
                            Text(
                              'Voice transcription overview',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ).animate().fadeIn(duration: 300.ms, delay: 50.ms),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // API Key warning
                  if (!settings.hasApiKey) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.alertTriangle,
                              color: AppColors.warning, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Add your Gemini API key in Settings to start',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.warning,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  ],

                  const SizedBox(height: 16),

                  // Compact stats card
                  CompactStatsCard(
                    totalUsage: statistics.totalUsage,
                    thisWeekUsage: statistics.thisWeekUsage,
                    totalTokens: statistics.totalTokens,
                    totalDurationMinutes: statistics.totalDurationMinutes,
                  ),

                  const SizedBox(height: 16),

                  // Consolidated Dashboard Metrics
                  DashboardMetrics(stats: enhancedStats),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}
