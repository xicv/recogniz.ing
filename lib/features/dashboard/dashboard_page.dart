import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/simplified_stats_card.dart';
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
                      // Search button
                      IconButton(
                        onPressed: () => _showSearchDialog(context, ref),
                        icon: const Icon(LucideIcons.search),
                        tooltip: 'Search',
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

                  // Simplified stats card
                  SimplifiedStatsCard(
                    totalUsage: statistics.totalUsage,
                    thisWeekUsage: statistics.thisWeekUsage,
                    totalTokens: statistics.totalTokens,
                    totalDurationMinutes: statistics.totalDurationMinutes,
                  ),

                  const SizedBox(height: 24),

                  // Recent transcriptions header
                  Text(
                    'Recent Transcriptions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                  const SizedBox(height: 12),
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
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No transcriptions yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap the mic button to start',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
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
                      onUpdate: (newText) {
                        ref
                            .read(transcriptionsProvider.notifier)
                            .updateTranscription(
                              transcription.id,
                              newText,
                            );
                      },
                    ).animate().fadeIn(
                          duration: 200.ms,
                          delay: Duration(milliseconds: 250 + (index * 30)),
                        );
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

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search transcriptions...',
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
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteTranscription(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('This transcription will be permanently deleted.'),
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
