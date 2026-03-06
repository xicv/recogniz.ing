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
      ]
          .map((child) =>
              child is SizedBox ? child : Expanded(child: child))
          .toList(),
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
    // Estimate: typing at 40 WPM baseline, voice is ~3x faster
    // Time saved ≈ totalWords / 40 WPM → minutes → hours
    return (totalWords / 40) / 60;
  }

  int _todayCount() {
    final now = DateTime.now();
    return transcriptions
        .where((t) =>
            t.createdAt.year == now.year &&
            t.createdAt.month == now.month &&
            t.createdAt.day == now.day)
        .length;
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
