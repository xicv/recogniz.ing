import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/models/api_key_usage_stats.dart';

/// Displays today's actual API usage for the selected key.
///
/// Shows real data (requests and tokens used today) rather than
/// fabricated quota limits, since the Gemini API provides no
/// endpoint to check remaining quota programmatically.
class UsageBar extends StatelessWidget {
  final ApiKeyUsageStats stats;
  final String keyName;

  const UsageBar({super.key, required this.stats, required this.keyName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = stats.todayUsage;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: label + key name
          Row(
            children: [
              Icon(LucideIcons.activity, size: 14,
                  color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                "Today's Usage",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                keyName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stats row: requests + tokens
          Row(
            children: [
              Expanded(
                child: _UsageStat(
                  icon: LucideIcons.messageSquare,
                  value: today.transcriptionCount.toString(),
                  label: 'Requests',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UsageStat(
                  icon: LucideIcons.coins,
                  value: _formatTokens(today.tokens),
                  label: 'Tokens',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UsageStat(
                  icon: LucideIcons.type,
                  value: _formatCount(today.words),
                  label: 'Words',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTokens(int tokens) {
    if (tokens >= 1000000) return '${(tokens / 1000000).toStringAsFixed(1)}M';
    if (tokens >= 1000) return '${(tokens / 1000).toStringAsFixed(1)}k';
    return tokens.toString();
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

class _UsageStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _UsageStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 13, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
