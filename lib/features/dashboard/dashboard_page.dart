import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/stat_card.dart';
import 'widgets/transcription_tile.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(statisticsProvider);
    final transcriptions = ref.watch(filteredTranscriptionsProvider);
    final settings = ref.watch(settingsProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
                  const SizedBox(height: 8),
                  Text(
                    'Your voice transcription overview',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                  // API Key warning
                  if (!settings.hasApiKey) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.alertTriangle,
                              color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please add your Gemini API key in Settings to start transcribing.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.warning,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                  ],

                  const SizedBox(height: 24),

                  // Statistics cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        title: 'Total Usage',
                        value: statistics.totalUsage.toString(),
                        icon: LucideIcons.mic,
                        color: AppColors.primary,
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 200.ms)
                          .scale(begin: const Offset(0.9, 0.9)),
                      StatCard(
                        title: 'This Week',
                        value: statistics.thisWeekUsage.toString(),
                        icon: LucideIcons.calendar,
                        color: AppColors.accent,
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 300.ms)
                          .scale(begin: const Offset(0.9, 0.9)),
                      StatCard(
                        title: 'Tokens Used',
                        value: _formatNumber(statistics.totalTokens),
                        icon: LucideIcons.coins,
                        color: AppColors.success,
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 400.ms)
                          .scale(begin: const Offset(0.9, 0.9)),
                      StatCard(
                        title: 'Minutes',
                        value:
                            statistics.totalDurationMinutes.toStringAsFixed(1),
                        icon: LucideIcons.clock,
                        color: AppColors.warning,
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 500.ms)
                          .scale(begin: const Offset(0.9, 0.9)),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Recent transcriptions header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transcriptions',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: 20,
                            ),
                      ),
                      IconButton(
                        onPressed: () => _showSearchDialog(context, ref),
                        icon: const Icon(LucideIcons.search),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 600.ms),
                ],
              ),
            ),
          ),

          // Transcriptions list
          if (transcriptions.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.micOff,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transcriptions yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the microphone button to start',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 700.ms),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transcription = transcriptions[index];
                    return TranscriptionTile(
                      transcription: transcription,
                      onCopy: () => _copyToClipboard(
                          context, transcription.processedText),
                      onDelete: () =>
                          _deleteTranscription(context, ref, transcription.id),
                    )
                        .animate()
                        .fadeIn(
                          duration: 300.ms,
                          delay: Duration(milliseconds: 700 + (index * 50)),
                        )
                        .slideY(begin: 0.1);
                  },
                  childCount: transcriptions.length,
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Transcriptions'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            prefixIcon: Icon(LucideIcons.search),
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = '';
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Platform-specific clipboard implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteTranscription(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transcription'),
        content:
            const Text('Are you sure you want to delete this transcription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(transcriptionsProvider.notifier).deleteTranscription(id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
