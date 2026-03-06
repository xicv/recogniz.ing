# Dashboard Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the over-engineered dashboard (6 sections, ~2,700 lines, duplicate metrics, bugs) with a minimal 3-section glanceable view: stats row, quota bar, recent transcriptions.

**Architecture:** Delete 9 widget files. Create 2 new widgets (`QuickStatsRow`, `QuotaBar`). Rewrite `DashboardPage` to use them plus an inline recent-transcriptions list. Dashboard reads only 2 providers (down from 4).

**Tech Stack:** Flutter, Riverpod, LucideIcons, flutter_animate, Material Design 3, SemanticColors extension

---

### Task 1: Delete Dead Code

Remove the 9 unused widget files and verify the app still compiles.

**Files:**
- Delete: `lib/features/dashboard/widgets/cost_analysis_widget.dart`
- Delete: `lib/features/dashboard/widgets/insights_widget.dart`
- Delete: `lib/features/dashboard/widgets/productivity_insights_widget.dart`
- Delete: `lib/features/dashboard/widgets/usage_pattern_widget.dart`
- Delete: `lib/features/dashboard/widgets/stat_card.dart`
- Delete: `lib/features/dashboard/widgets/compact_stats_card.dart`
- Delete: `lib/features/dashboard/widgets/dashboard_metrics.dart`
- Delete: `lib/features/dashboard/widgets/quota_status_card.dart`
- Delete: `lib/features/dashboard/widgets/transcription_tile.dart`
- Modify: `lib/features/dashboard/dashboard_page.dart` — remove imports and usages of deleted widgets, replace body with a placeholder `Center(child: Text('Dashboard'))` so the app compiles

**Step 1: Delete all 9 widget files**

```bash
rm lib/features/dashboard/widgets/cost_analysis_widget.dart
rm lib/features/dashboard/widgets/insights_widget.dart
rm lib/features/dashboard/widgets/productivity_insights_widget.dart
rm lib/features/dashboard/widgets/usage_pattern_widget.dart
rm lib/features/dashboard/widgets/stat_card.dart
rm lib/features/dashboard/widgets/compact_stats_card.dart
rm lib/features/dashboard/widgets/dashboard_metrics.dart
rm lib/features/dashboard/widgets/quota_status_card.dart
rm lib/features/dashboard/widgets/transcription_tile.dart
```

**Step 2: Replace dashboard_page.dart with a temporary placeholder**

Replace the entire content of `lib/features/dashboard/dashboard_page.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SafeArea(
      child: Center(child: Text('Dashboard — rebuilding')),
    );
  }
}
```

**Step 3: Verify the app compiles**

Run: `make analyze`
Expected: No errors related to dashboard widgets. Warnings are OK.

**Step 4: Commit**

```bash
git add -u lib/features/dashboard/
git commit -m "refactor(dashboard): delete 9 unused widget files (~2,700 lines)"
```

---

### Task 2: Create QuickStatsRow Widget

A horizontal row of 4 stat chips showing total transcriptions, total words, time saved, and today's count.

**Files:**
- Create: `lib/features/dashboard/widgets/quick_stats_row.dart`

**Step 1: Create the widget file**

Create `lib/features/dashboard/widgets/quick_stats_row.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/models/transcription.dart';

class QuickStatsRow extends StatelessWidget {
  final List<Transcription> transcriptions;

  const QuickStatsRow({super.key, required this.transcriptions});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = transcriptions.length;
    final totalWords = _totalWords();
    final timeSavedHours = _timeSavedHours(totalWords);
    final todayCount = _todayCount();

    return Row(
      children: [
        _StatChip(
          icon: LucideIcons.barChart3,
          value: _formatCount(total),
          label: 'Total',
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: LucideIcons.type,
          value: _formatCount(totalWords),
          label: 'Words',
          color: colorScheme.tertiary,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: LucideIcons.clock,
          value: _formatDuration(timeSavedHours),
          label: 'Saved',
          color: colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: LucideIcons.zap,
          value: todayCount.toString(),
          label: 'Today',
          color: colorScheme.primary,
        ),
      ].map((child) => child is SizedBox ? child : Expanded(child: child)).toList(),
    );
  }

  int _totalWords() {
    int total = 0;
    for (final t in transcriptions) {
      final text = t.processedText.trim();
      if (text.isNotEmpty) {
        total += text.split(RegExp(r'\s+')).length;
      }
    }
    return total;
  }

  double _timeSavedHours(int totalWords) {
    // Estimate: voice typing is ~3x faster than keyboard typing at 40 WPM
    // Time saved = time it would take to type - time spent speaking
    // Simplified: totalWords / 40 WPM = minutes to type → convert to hours
    return (totalWords / 40) / 60;
  }

  int _todayCount() {
    final now = DateTime.now();
    return transcriptions.where((t) =>
      t.createdAt.year == now.year &&
      t.createdAt.month == now.month &&
      t.createdAt.day == now.day
    ).length;
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  String _formatDuration(double hours) {
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '${minutes}m';
    }
    return '${hours.toStringAsFixed(1)}h';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Verify it compiles**

Run: `make analyze`
Expected: No errors (the widget isn't used yet, so no integration issues)

**Step 3: Commit**

```bash
git add lib/features/dashboard/widgets/quick_stats_row.dart
git commit -m "feat(dashboard): add QuickStatsRow widget with 4 stat chips"
```

---

### Task 3: Create QuotaBar Widget

A horizontal progress bar showing API quota status with color coding.

**Files:**
- Create: `lib/features/dashboard/widgets/quota_bar.dart`

**Step 1: Create the widget file**

Create `lib/features/dashboard/widgets/quota_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/models/api_key_usage_stats.dart';
import '../../../core/theme/app_theme.dart';

class QuotaBar extends StatelessWidget {
  final QuotaInfo quotaInfo;

  const QuotaBar({super.key, required this.quotaInfo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme);
    final percentage = quotaInfo.quotaPercentage.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: label + status
          Row(
            children: [
              Icon(LucideIcons.gauge, size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'API Quota',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  quotaInfo.quotaStatus,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),

          const SizedBox(height: 8),

          // Footer: remaining + key name
          Row(
            children: [
              Text(
                '${quotaInfo.remainingRequests} remaining today',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                quotaInfo.apiKeyName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    if (quotaInfo.isExhausted) return colorScheme.error;
    if (quotaInfo.isNearLimit) return colorScheme.warning;
    return colorScheme.success;
  }
}
```

**Step 2: Verify it compiles**

Run: `make analyze`
Expected: No errors

**Step 3: Commit**

```bash
git add lib/features/dashboard/widgets/quota_bar.dart
git commit -m "feat(dashboard): add QuotaBar widget with progress indicator"
```

---

### Task 4: Rewrite DashboardPage

Wire everything together: stats row, quota bar, and inline recent transcriptions list.

**Files:**
- Modify: `lib/features/dashboard/dashboard_page.dart`

**Step 1: Rewrite dashboard_page.dart**

Replace the entire content with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/api_key_usage_provider.dart';
import '../../core/providers/api_keys_provider.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/transcription_providers.dart';
import '../../core/providers/settings_providers.dart';
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                            color: colorScheme.warning.withValues(alpha: 0.3)),
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
                      .animate().fadeIn(duration: 300.ms, delay: 100.ms),

                  // Section 2: Quota Bar (only if API key configured)
                  if (quotaInfo != null) ...[
                    const SizedBox(height: 12),
                    QuotaBar(quotaInfo: quotaInfo)
                        .animate().fadeIn(duration: 300.ms, delay: 150.ms),
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
              label: Icon(LucideIcons.arrowRight, size: 14,
                  color: colorScheme.primary),
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
            icon: Icon(LucideIcons.copy, size: 14,
                color: colorScheme.onSurfaceVariant),
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
    return text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
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
```

**Step 2: Verify the app compiles**

Run: `make analyze`
Expected: No errors. Check that imports resolve correctly.

**Important notes for the implementer:**
- `transcriptionsProvider` returns unsorted transcriptions — we sort inline
- `selectedKeyQuotaProvider` returns `null` if no API key is configured — the quota bar is hidden in that case
- The `currentPageProvider.notifier).state = 0` navigates to the Transcriptions page (index 0)
- `settingsProvider` comes from `app_providers.dart` (barrel export)
- `SemanticColors` extension (`.warning`, `.success`) is on `ColorScheme`, imported via `app_theme.dart`

**Step 3: Verify it runs**

Run: `make run-macos` (or `make quick-run`)
Expected: Dashboard shows stats row, quota bar (if API key is set), and recent transcriptions

**Step 4: Commit**

```bash
git add lib/features/dashboard/dashboard_page.dart
git commit -m "feat(dashboard): rewrite with minimal 3-section layout"
```

---

### Task 5: Clean Up Unused Providers and Imports

Remove providers that are no longer used by any page after the dashboard rewrite.

**Files:**
- Modify: `lib/core/providers/transcription_providers.dart` — check if `statisticsProvider` and `enhancedStatisticsProvider` are still used elsewhere

**Step 1: Check for remaining references**

Search the codebase for remaining usages of the old providers:

```bash
grep -r "statisticsProvider\|enhancedStatisticsProvider\|Statistics(" lib/ --include="*.dart" -l
```

If the ONLY references are in `transcription_providers.dart` itself, they can be removed. If other files reference them, leave them in place.

**Step 2: If safe to remove, delete from transcription_providers.dart**

Remove lines 102-130 (the `enhancedStatisticsProvider`, `statisticsProvider`, and `Statistics` class). Also remove the `import '../services/analytics_service.dart';` on line 6 if no other provider in the file uses it.

**Step 3: Verify**

Run: `make analyze`
Expected: No errors

**Step 4: Commit**

```bash
git add lib/core/providers/transcription_providers.dart
git commit -m "refactor: remove unused statisticsProvider and enhancedStatisticsProvider"
```

---

### Task 6: Final Verification

**Step 1: Run full analysis**

```bash
make analyze
```

Expected: No errors, only pre-existing warnings

**Step 2: Run tests**

```bash
make test
```

Expected: All existing tests pass

**Step 3: Visual verification**

Run: `make run-macos`

Verify:
- [ ] Dashboard shows 4 stat chips (Total, Words, Saved, Today)
- [ ] Quota bar appears if API key is configured
- [ ] Quota bar is hidden if no API key
- [ ] Recent transcriptions show up to 5 items newest-first
- [ ] Copy button works on each transcription card
- [ ] "View All" navigates to Transcriptions page
- [ ] Empty state shows when no transcriptions and no API key
- [ ] Dark mode works correctly
- [ ] No console errors

**Step 4: Commit if any fixes were needed, then verify line count**

```bash
# Check the total line reduction
find lib/features/dashboard -name "*.dart" | xargs wc -l
```

Expected: ~300 lines total (down from ~2,700)
