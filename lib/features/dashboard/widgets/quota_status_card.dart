import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/models/api_key_usage_stats.dart';
import '../../../core/providers/api_key_usage_provider.dart';
import '../../../core/providers/api_keys_provider.dart';
import '../../../core/theme/app_theme.dart';

// ============================================================
// DESIGN SYSTEM - Dashboard Card Constants
// ============================================================
//
// 8-point grid system for consistent spacing:
// - Card padding: 16px (2 grid units)
// - Card margin: 24px vertical (3 grid units), 20px horizontal
// - Grid spacing: 16px (2 grid units)
// - Border radius: 16px for all cards
// - Border: 1px with 0.08 opacity
// - Icon container: 40px × 40px, 8px border radius
//
// ============================================================

/// Dashboard spacing constants
class DashboardSpacing {
  static const double cardPadding = 16.0;
  static const double cardMarginH = 20.0;
  static const double cardMarginV = 24.0;
  static const double gridGap = 16.0;
  static const double cardRadius = 16.0;
  static const double iconSize = 40.0;
  static const double iconRadius = 8.0;
}

/// Circular progress widget for showing quota usage
class QuotaProgressRing extends StatelessWidget {
  final double percentage;
  final String status;
  final String statusColor;
  final int remaining;
  final int total;

  const QuotaProgressRing({
    super.key,
    required this.percentage,
    required this.status,
    required this.statusColor,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    const size = 120.0;
    const strokeWidth = 10.0;
    final progressColor = _getStatusColor(statusColor);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: const Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              color: progressColor.withValues(alpha: 0.12),
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress ring
          CustomPaint(
            size: const Size(size, size),
            painter: _RingPainter(
              progress: percentage.clamp(0.0, 1.0),
              color: progressColor,
              strokeWidth: strokeWidth,
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(percentage * 100).toInt()}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: progressColor,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String colorCode) {
    return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
  }
}

/// Painter for the circular progress ring
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      startAngle + sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _RingPainter ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}

/// Main quota status card - Primary dashboard widget
/// Shows free tier usage with circular progress indicator
class QuotaStatusCard extends ConsumerWidget {
  const QuotaStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotaInfo = ref.watch(selectedKeyQuotaProvider);
    final selectedKey = ref.watch(selectedApiKeyProvider);

    if (quotaInfo == null || selectedKey == null) {
      return const SizedBox.shrink();
    }

    final statusColor = _getStatusColor(quotaInfo.statusColor);
    final isNearLimit = quotaInfo.isNearLimit || quotaInfo.isExhausted;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DashboardSpacing.cardMarginH,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(DashboardSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isNearLimit
            ? statusColor.withValues(alpha: 0.06)
            : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(DashboardSpacing.cardRadius),
        border: Border.all(
          color: isNearLimit
              ? statusColor.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              // Status badge
              _StatusBadge(
                icon: _getStatusIcon(quotaInfo.statusColor),
                label: quotaInfo.quotaStatus,
                color: statusColor,
              ),
              const Spacer(),
              // API key name
              Text(
                selectedKey.name,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main content row with progress ring and stats
          Row(
            children: [
              // Circular progress
              QuotaProgressRing(
                percentage: quotaInfo.quotaPercentage,
                status: quotaInfo.quotaStatus,
                statusColor: quotaInfo.statusColor,
                remaining: quotaInfo.remainingRequests,
                total: quotaInfo.dailyRequestLimit,
              ),

              const SizedBox(width: 24),

              // Stats column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QuotaStat(
                      label: 'Remaining',
                      value: '${quotaInfo.remainingRequests}',
                      unit: 'requests',
                      color: statusColor,
                    ),
                    const SizedBox(height: 12),
                    _QuotaStat(
                      label: 'Daily Average',
                      value: quotaInfo.dailyAverageRequests.toStringAsFixed(1),
                      unit: 'requests/day',
                    ),
                    const SizedBox(height: 12),
                    _QuotaStat(
                      label: 'Days Until Exhaustion',
                      value: quotaInfo.daysUntilExhaustion != null
                          ? '${quotaInfo.daysUntilExhaustion}'
                          : '∞',
                      unit: 'days',
                      valueColor: quotaInfo.daysUntilExhaustion != null &&
                              quotaInfo.daysUntilExhaustion! < 7
                          ? AppColors.warning
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Color _getStatusColor(String colorCode) {
    return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
  }

  IconData _getStatusIcon(String colorCode) {
    if (colorCode == '#EF4444') return LucideIcons.alertOctagon;
    if (colorCode == '#F59E0B') return LucideIcons.alertTriangle;
    return LucideIcons.checkCircle;
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quota stat widget
class _QuotaStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? color;
  final Color? valueColor;

  const _QuotaStat({
    required this.label,
    required this.value,
    required this.unit,
    this.color,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Enhanced stats grid - Secondary metrics
class EnhancedStatsGrid extends ConsumerWidget {
  const EnhancedStatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(selectedKeyStatsProvider);

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardSpacing.cardMarginH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Text(
            'Usage Statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          const SizedBox(height: 12),

          // Stats grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: DashboardSpacing.gridGap,
            crossAxisSpacing: DashboardSpacing.gridGap,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: LucideIcons.fileText,
                iconColor: AppColors.primary,
                title: 'Transcriptions',
                value: stats.totalTranscriptions.toString(),
                subtitle: 'all time',
              ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
              _StatCard(
                icon: LucideIcons.type,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Words',
                value: _formatNumber(stats.totalWords),
                subtitle: 'total processed',
              ).animate().fadeIn(duration: 300.ms, delay: 175.ms),
              _StatCard(
                icon: LucideIcons.clock,
                iconColor: const Color(0xFFF59E0B),
                title: 'Duration',
                value: '${stats.totalDurationMinutes.toStringAsFixed(0)}m',
                subtitle: '${(stats.totalDurationMinutes / 60).toStringAsFixed(1)}h total',
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              _StatCard(
                icon: LucideIcons.trendingUp,
                iconColor: const Color(0xFF10B981),
                title: 'Daily Average',
                value: stats.dailyAverageTranscriptions.toStringAsFixed(1),
                subtitle: 'transcriptions/day',
              ).animate().fadeIn(duration: 300.ms, delay: 225.ms),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

/// Individual stat card for the grid
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DashboardSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(DashboardSpacing.cardRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: DashboardSpacing.iconSize,
            height: DashboardSpacing.iconSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DashboardSpacing.iconRadius),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),

          const SizedBox(height: 12),

          // Value
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
          ),

          const SizedBox(height: 2),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),

          const SizedBox(height: 2),

          // Subtitle
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: iconColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

/// Usage insights banner - Contextual messages
class UsageInsightsCard extends ConsumerWidget {
  const UsageInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotaInfo = ref.watch(selectedKeyQuotaProvider);
    final stats = ref.watch(selectedKeyStatsProvider);

    if (quotaInfo == null || stats == null) {
      return const SizedBox.shrink();
    }

    final insights = _generateInsights(quotaInfo, stats);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DashboardSpacing.cardMarginH,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(DashboardSpacing.cardPadding),
      decoration: BoxDecoration(
        color: insights.isWarning
            ? const Color(0xFFFFF7ED).withValues(alpha: 0.6)
            : const Color(0xFFECFDF5).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(DashboardSpacing.cardRadius),
        border: Border.all(
          color: insights.isWarning
              ? const Color(0xFFF97316).withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: insights.iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              insights.icon,
              size: 18,
              color: insights.iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insights.title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: insights.iconColor,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  insights.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 250.ms);
  }

  _InsightData _generateInsights(QuotaInfo quota, ApiKeyUsageStats stats) {
    if (quota.isExhausted) {
      return _InsightData(
        icon: LucideIcons.alertOctagon,
        iconColor: const Color(0xFFEF4444),
        title: 'Free Tier Exhausted',
        message: 'Add another API key in Settings to continue transcribing.',
        isWarning: true,
      );
    }

    if (quota.isNearLimit) {
      return _InsightData(
        icon: LucideIcons.alertTriangle,
        iconColor: const Color(0xFFF59E0B),
        title: 'Approaching Limit',
        message: '${quota.remainingRequests} requests left today. Consider adding a backup key.',
        isWarning: true,
      );
    }

    if (quota.daysUntilExhaustion != null && quota.daysUntilExhaustion! < 7) {
      return _InsightData(
        icon: LucideIcons.trendingDown,
        iconColor: const Color(0xFFF59E0B),
        title: 'High Usage Detected',
        message: 'At current rate, free tier will expire in ${quota.daysUntilExhaustion} days.',
        isWarning: true,
      );
    }

    if (stats.totalTranscriptions == 0) {
      return _InsightData(
        icon: LucideIcons.info,
        iconColor: AppColors.primary,
        title: 'Get Started',
        message: 'Make your first transcription to see usage insights.',
        isWarning: false,
      );
    }

    return _InsightData(
      icon: LucideIcons.checkCircle,
      iconColor: const Color(0xFF10B981),
      title: 'Good Standing',
      message: '${quota.remainingRequests} free requests remaining today.',
      isWarning: false,
    );
  }
}

class _InsightData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final bool isWarning;

  const _InsightData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.isWarning,
  });
}
