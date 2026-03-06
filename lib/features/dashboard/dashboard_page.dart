import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/api_key_usage_provider.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/shared/empty_states.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/quota_bar.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final transcriptions = ref.watch(transcriptionsProvider);
    final settings = ref.watch(settingsProvider);
    final quotaInfo = ref.watch(selectedKeyQuotaProvider);

    // Empty state: no transcriptions and no API key
    if (transcriptions.isEmpty && !settings.hasApiKey) {
      return Scaffold(
        body: DashboardEmptyState(
          hasApiKey: false,
          onOpenSettings: () =>
              ref.read(currentPageProvider.notifier).state = 4,
        ),
      );
    }

    // Sort transcriptions newest-first for the recent list
    final sorted = List.of(transcriptions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recent = sorted.take(5).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Dashboard',
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 4),
                  Text(
                    'Voice transcription overview',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

                  // API Key warning
                  if (!settings.hasApiKey) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                colorScheme.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.alertTriangle,
                              color: colorScheme.warning, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Add your Gemini API key in Settings to start',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: colorScheme.warning),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  ],

                  const SizedBox(height: 16),

                  // Section 1: Quick Stats Row
                  QuickStatsRow(transcriptions: transcriptions)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms),

                  // Section 2: Quota Bar (only if API key configured)
                  if (quotaInfo != null) ...[
                    const SizedBox(height: 12),
                    QuotaBar(quotaInfo: quotaInfo)
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 150.ms),
                  ],

                  // Section 3: Recent Transcriptions
                  if (recent.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _RecentTranscriptionsSection(
                      transcriptions: recent,
                      onViewAll: () =>
                          ref.read(currentPageProvider.notifier).state = 0,
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Recent transcriptions section with header and compact card list
class _RecentTranscriptionsSection extends StatelessWidget {
  final List transcriptions;
  final VoidCallback onViewAll;

  const _RecentTranscriptionsSection({
    required this.transcriptions,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Text(
              'Recent',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onViewAll,
              icon: const Text('View All'),
              label: Icon(LucideIcons.arrowRight,
                  size: 14, color: colorScheme.primary),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Transcription cards
        ...transcriptions.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _RecentTranscriptionCard(transcription: t),
            )),
      ],
    );
  }
}

/// Compact transcription card for the recent list
class _RecentTranscriptionCard extends StatelessWidget {
  final dynamic transcription;

  const _RecentTranscriptionCard({required this.transcription});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = transcription.processedText as String;
    final createdAt = transcription.createdAt as DateTime;
    final wordCount = _countWords(text);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text preview
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text.isEmpty ? '(empty)' : text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_relativeTime(createdAt)} · $wordCount words',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),

          // Copy button
          IconButton(
            icon: Icon(LucideIcons.copy,
                size: 14, color: colorScheme.onSurfaceVariant),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Copy',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  int _countWords(String text) {
    return text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).length;
  }

  String _relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}';
  }
}
