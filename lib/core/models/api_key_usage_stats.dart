import 'package:hive/hive.dart';

part 'api_key_usage_stats.g.dart';

/// Daily usage breakdown for a specific API key
@HiveType(typeId: 15)
class DailyUsage {
  @HiveField(0)
  final int transcriptionCount;

  @HiveField(1)
  final int tokens;

  @HiveField(2)
  final double durationMinutes;

  @HiveField(3)
  final int words;

  @HiveField(4)
  final DateTime date;

  const DailyUsage({
    required this.transcriptionCount,
    required this.tokens,
    required this.durationMinutes,
    required this.words,
    required this.date,
  });

  DailyUsage copyWith({
    int? transcriptionCount,
    int? tokens,
    double? durationMinutes,
    int? words,
    DateTime? date,
  }) {
    return DailyUsage(
      transcriptionCount: transcriptionCount ?? this.transcriptionCount,
      tokens: tokens ?? this.tokens,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      words: words ?? this.words,
      date: date ?? this.date,
    );
  }

  /// Create empty usage for a date
  static DailyUsage empty(DateTime date) {
    return DailyUsage(
      transcriptionCount: 0,
      tokens: 0,
      durationMinutes: 0,
      words: 0,
      date: date,
    );
  }

  /// Add usage from a transcription
  DailyUsage add({
    required int additionalTokens,
    required double additionalMinutes,
    required int additionalWords,
  }) {
    return DailyUsage(
      transcriptionCount: transcriptionCount + 1,
      tokens: tokens + additionalTokens,
      durationMinutes: durationMinutes + additionalMinutes,
      words: words + additionalWords,
      date: date,
    );
  }
}

/// Usage statistics for a specific API key
@HiveType(typeId: 16)
class ApiKeyUsageStats {
  /// ID of the API key this stats belong to
  @HiveField(0)
  final String apiKeyId;

  /// Total number of transcriptions made with this key
  @HiveField(1)
  final int totalTranscriptions;

  /// Total tokens consumed (input + output)
  @HiveField(2)
  final int totalTokens;

  /// Total audio duration transcribed in minutes
  @HiveField(3)
  final double totalDurationMinutes;

  /// Total words transcribed
  @HiveField(4)
  final int totalWords;

  /// When this key was first used
  @HiveField(5)
  final DateTime? firstUsedAt;

  /// When this key was last used
  @HiveField(6)
  final DateTime? lastUsedAt;

  /// Daily usage data for the last 90 days
  @HiveField(7)
  final List<DailyUsage> dailyUsage;

  /// Total estimated cost in USD
  @HiveField(8)
  final double totalEstimatedCost;

  const ApiKeyUsageStats({
    required this.apiKeyId,
    required this.totalTranscriptions,
    required this.totalTokens,
    required this.totalDurationMinutes,
    required this.totalWords,
    this.firstUsedAt,
    this.lastUsedAt,
    required this.dailyUsage,
    required this.totalEstimatedCost,
  });

  /// Create empty stats for a new API key
  factory ApiKeyUsageStats.empty(String apiKeyId) {
    return ApiKeyUsageStats(
      apiKeyId: apiKeyId,
      totalTranscriptions: 0,
      totalTokens: 0,
      totalDurationMinutes: 0,
      totalWords: 0,
      firstUsedAt: null,
      lastUsedAt: null,
      dailyUsage: [],
      totalEstimatedCost: 0,
    );
  }

  /// Get usage for today
  DailyUsage get todayUsage {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    for (final usage in dailyUsage) {
      if (usage.date.year == todayKey.year &&
          usage.date.month == todayKey.month &&
          usage.date.day == todayKey.day) {
        return usage;
      }
    }
    return DailyUsage.empty(todayKey);
  }

  /// Get usage for the last 7 days
  List<DailyUsage> get last7DaysUsage {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final result = <DailyUsage>[];
    for (final usage in dailyUsage) {
      if (usage.date.isAfter(sevenDaysAgo)) {
        result.add(usage);
      }
    }

    // Fill in missing days with empty usage
    final filledResult = <DailyUsage>[];
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayKey = DateTime(day.year, day.month, day.day);

      DailyUsage? usageForDay;
      for (final usage in result) {
        final usageDateKey = DateTime(
          usage.date.year,
          usage.date.month,
          usage.date.day,
        );
        if (usageDateKey == dayKey) {
          usageForDay = usage;
          break;
        }
      }

      filledResult.add(usageForDay ?? DailyUsage.empty(dayKey));
    }

    return filledResult;
  }

  /// Calculate daily average transcriptions
  double get dailyAverageTranscriptions {
    if (firstUsedAt == null) return 0;

    final daysUsed = DateTime.now().difference(firstUsedAt!).inDays;
    if (daysUsed <= 0) return totalTranscriptions.toDouble();

    return totalTranscriptions / daysUsed;
  }

  /// Calculate daily average tokens
  double get dailyAverageTokens {
    if (firstUsedAt == null) return 0;

    final daysUsed = DateTime.now().difference(firstUsedAt!).inDays;
    if (daysUsed <= 0) return totalTokens.toDouble();

    return totalTokens / daysUsed;
  }

  /// Calculate total requests (transcriptions) today
  int get todayRequests {
    return todayUsage.transcriptionCount;
  }

  /// Calculate total tokens used today
  int get todayTokens {
    return todayUsage.tokens;
  }

  ApiKeyUsageStats copyWith({
    String? apiKeyId,
    int? totalTranscriptions,
    int? totalTokens,
    double? totalDurationMinutes,
    int? totalWords,
    DateTime? firstUsedAt,
    DateTime? lastUsedAt,
    List<DailyUsage>? dailyUsage,
    double? totalEstimatedCost,
  }) {
    return ApiKeyUsageStats(
      apiKeyId: apiKeyId ?? this.apiKeyId,
      totalTranscriptions: totalTranscriptions ?? this.totalTranscriptions,
      totalTokens: totalTokens ?? this.totalTokens,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      totalWords: totalWords ?? this.totalWords,
      firstUsedAt: firstUsedAt ?? this.firstUsedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      dailyUsage: dailyUsage ?? this.dailyUsage,
      totalEstimatedCost: totalEstimatedCost ?? this.totalEstimatedCost,
    );
  }

  /// Add usage from a new transcription
  ApiKeyUsageStats addUsage({
    required int tokens,
    required double durationMinutes,
    required int words,
    required double estimatedCost,
  }) {
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);

    // Find or create today's usage
    DailyUsage updatedToday = todayUsage;
    if (updatedToday.date != todayKey) {
      updatedToday = DailyUsage.empty(todayKey);
    }
    updatedToday = updatedToday.add(
      additionalTokens: tokens,
      additionalMinutes: durationMinutes,
      additionalWords: words,
    );

    // Update daily usage list
    final updatedDailyUsage = <DailyUsage>[...dailyUsage];

    // Remove old entry for today if exists
    updatedDailyUsage.removeWhere((u) {
      final d = u.date;
      final dateKey = DateTime(d.year, d.month, d.day);
      return dateKey == todayKey;
    });

    // Add updated today
    updatedDailyUsage.add(updatedToday);

    // Keep only last 90 days to save space
    final ninetyDaysAgo = now.subtract(const Duration(days: 90));
    updatedDailyUsage.removeWhere((u) => u.date.isBefore(ninetyDaysAgo));

    return ApiKeyUsageStats(
      apiKeyId: apiKeyId,
      totalTranscriptions: totalTranscriptions + 1,
      totalTokens: totalTokens + tokens,
      totalDurationMinutes: totalDurationMinutes + durationMinutes,
      totalWords: totalWords + words,
      firstUsedAt: firstUsedAt ?? now,
      lastUsedAt: now,
      dailyUsage: updatedDailyUsage,
      totalEstimatedCost: totalEstimatedCost + estimatedCost,
    );
  }
}

/// Quota information for an API key
class QuotaInfo {
  /// Free tier daily request limit (conservative estimate)
  static const int freeTierDailyRequests = 1000;

  /// Free tier daily token limit (generous estimate)
  static const int freeTierDailyTokens = 1000000; // 1M tokens

  /// Cost per million input tokens for Gemini Flash (2026)
  static const double costPerMillionInputTokens = 0.075;

  /// Cost per million output tokens
  static const double costPerMillionOutputTokens = 0.40;

  /// ID of the API key
  final String apiKeyId;

  /// Name of the API key
  final String apiKeyName;

  /// Requests made today
  final int todayRequests;

  /// Tokens used today
  final int todayTokens;

  /// Daily request limit
  final int dailyRequestLimit;

  /// Daily token limit
  final int dailyTokenLimit;

  /// Percentage of daily quota used
  final double quotaPercentage;

  /// Days until free tier exhaustion (based on current trend)
  final int? daysUntilExhaustion;

  /// Projected monthly cost if usage continues
  final double projectedMonthlyCost;

  /// Daily average requests
  final double dailyAverageRequests;

  /// Whether quota is nearly exhausted (>80%)
  final bool isNearLimit;

  /// Whether quota is exhausted
  final bool isExhausted;

  const QuotaInfo({
    required this.apiKeyId,
    required this.apiKeyName,
    required this.todayRequests,
    required this.todayTokens,
    required this.dailyRequestLimit,
    required this.dailyTokenLimit,
    required this.quotaPercentage,
    this.daysUntilExhaustion,
    required this.projectedMonthlyCost,
    required this.dailyAverageRequests,
    required this.isNearLimit,
    required this.isExhausted,
  });

  /// Create quota info from usage stats
  factory QuotaInfo.fromStats({
    required String apiKeyId,
    required String apiKeyName,
    required ApiKeyUsageStats stats,
  }) {
    final todayRequests = stats.todayRequests;
    final todayTokens = stats.todayTokens;

    // Use the more restrictive limit (requests vs tokens)
    final requestPercentage = todayRequests / freeTierDailyRequests;
    final tokenPercentage = todayTokens / freeTierDailyTokens;
    final quotaPercentage = requestPercentage > tokenPercentage
        ? requestPercentage
        : tokenPercentage;

    // Calculate days until exhaustion
    int? daysUntilExhaustion;
    final dailyAvg = stats.dailyAverageTranscriptions;

    if (dailyAvg > 0) {
      // Based on request limit
      final requestDaysLeft = (freeTierDailyRequests - todayRequests) / dailyAvg;
      daysUntilExhaustion = requestDaysLeft.clamp(1, 365).round();
    }

    // Project monthly cost (30 days * current daily cost)
    final dailyCost = (todayTokens / 1000000) * costPerMillionInputTokens +
                      (todayTokens / 1000000 * 0.5) * costPerMillionOutputTokens;
    final projectedMonthlyCost = dailyCost * 30;

    return QuotaInfo(
      apiKeyId: apiKeyId,
      apiKeyName: apiKeyName,
      todayRequests: todayRequests,
      todayTokens: todayTokens,
      dailyRequestLimit: freeTierDailyRequests,
      dailyTokenLimit: freeTierDailyTokens,
      quotaPercentage: quotaPercentage.clamp(0, 1),
      daysUntilExhaustion: daysUntilExhaustion,
      projectedMonthlyCost: projectedMonthlyCost,
      dailyAverageRequests: stats.dailyAverageTranscriptions,
      isNearLimit: quotaPercentage >= 0.8,
      isExhausted: quotaPercentage >= 1.0,
    );
  }

  /// Remaining requests today
  int get remainingRequests =>
      (dailyRequestLimit - todayRequests).clamp(0, dailyRequestLimit);

  /// Remaining tokens today
  int get remainingTokens =>
      (dailyTokenLimit - todayTokens).clamp(0, dailyTokenLimit);

  /// Human-readable quota status
  String get quotaStatus {
    if (isExhausted) return 'Exhausted';
    if (isNearLimit) return 'Near Limit';
    return 'Good';
  }

  /// Color code for status (hex)
  String get statusColor {
    if (isExhausted) return '#EF4444'; // red
    if (isNearLimit) return '#F59E0B'; // orange
    return '#10B981'; // green
  }
}
