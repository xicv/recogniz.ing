import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_key_usage_stats.dart';
import '../services/storage_service.dart';
import 'api_keys_provider.dart';

/// Provider for managing API key usage statistics
class ApiKeyUsageNotifier extends Notifier<Map<String, ApiKeyUsageStats>> {
  @override
  Map<String, ApiKeyUsageStats> build() {
    // Load stats asynchronously
    _loadStats();
    return {};
  }

  /// Load stats from storage
  Future<void> _loadStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      // Stats would be stored in a separate box
      // For now, we'll rebuild from transcriptions
      final transcriptions = StorageService.transcriptions;
      final apiKeys = ref.read(apiKeysProvider);

      final statsMap = <String, ApiKeyUsageStats>{};

      // Initialize empty stats for each API key
      for (final key in apiKeys) {
        statsMap[key.id] = ApiKeyUsageStats.empty(key.id);
      }

      // Aggregate from transcriptions
      // Note: This requires Transcription to have apiKeyId field
      // For now, use the selected key
      final settings = StorageService.settings;
      final selectedKey = settings.selectedApiKeyId;

      if (selectedKey != null) {
        int totalTranscriptions = 0;
        int totalTokens = 0;
        double totalDuration = 0;
        int totalWords = 0;
        double totalCost = 0;
        final dailyUsageMap = <DateTime, DailyUsage>{};

        final transcriptionsList = transcriptions.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        for (final t in transcriptionsList) {
          totalTranscriptions++;
          totalTokens += t.tokenUsage;
          totalDuration += t.audioDurationSeconds / 60;
          totalWords += _countWords(t.processedText);

          // Estimate cost (50% input, 50% output)
          final inputTokens = t.tokenUsage * 0.5;
          final outputTokens = t.tokenUsage * 0.5;
          totalCost += (inputTokens / 1000000) * 0.075 +
                      (outputTokens / 1000000) * 0.40;

          // Add to daily usage
          final dateKey = DateTime(
            t.createdAt.year,
            t.createdAt.month,
            t.createdAt.day,
          );
          final existing = dailyUsageMap[dateKey];
          dailyUsageMap[dateKey] = DailyUsage(
            transcriptionCount: (existing?.transcriptionCount ?? 0) + 1,
            tokens: (existing?.tokens ?? 0) + t.tokenUsage,
            durationMinutes: (existing?.durationMinutes ?? 0) +
                (t.audioDurationSeconds / 60),
            words: (existing?.words ?? 0) + _countWords(t.processedText),
            date: dateKey,
          );
        }

        statsMap[selectedKey] = ApiKeyUsageStats(
          apiKeyId: selectedKey,
          totalTranscriptions: totalTranscriptions,
          totalTokens: totalTokens,
          totalDurationMinutes: totalDuration,
          totalWords: totalWords,
          firstUsedAt: transcriptionsList.isNotEmpty
              ? transcriptionsList.last.createdAt
              : null,
          lastUsedAt: transcriptionsList.isNotEmpty
              ? transcriptionsList.first.createdAt
              : null,
          dailyUsage: dailyUsageMap.values.toList(),
          totalEstimatedCost: totalCost,
        );
      }

      state = statsMap;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ApiKeyUsageNotifier] Failed to load stats: $e');
      }
    }
  }

  int _countWords(String text) {
    return text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  /// Record usage from a new transcription
  Future<void> recordUsage({
    required String apiKeyId,
    required int tokens,
    required double durationMinutes,
    required int words,
    required double estimatedCost,
  }) async {
    final currentStats = state[apiKeyId];

    if (currentStats != null) {
      final updated = currentStats.addUsage(
        tokens: tokens,
        durationMinutes: durationMinutes,
        words: words,
        estimatedCost: estimatedCost,
      );

      final updatedMap = Map<String, ApiKeyUsageStats>.from(state);
      updatedMap[apiKeyId] = updated;
      state = updatedMap;

      // Save to storage
      await _saveStats(apiKeyId, updated);
    } else {
      // Create new stats entry
      final newStats = ApiKeyUsageStats.empty(apiKeyId).addUsage(
        tokens: tokens,
        durationMinutes: durationMinutes,
        words: words,
        estimatedCost: estimatedCost,
      );

      final updatedMap = Map<String, ApiKeyUsageStats>.from(state);
      updatedMap[apiKeyId] = newStats;
      state = updatedMap;

      await _saveStats(apiKeyId, newStats);
    }
  }

  Future<void> _saveStats(String apiKeyId, ApiKeyUsageStats stats) async {
    // In a full implementation, this would save to a dedicated box
    // For now, we'll trigger a reload when needed
    debugPrint('[ApiKeyUsageNotifier] Stats saved for key: $apiKeyId');
  }

  /// Reload stats from transcriptions
  Future<void> reload() async {
    await _loadStats();
  }

  /// Get stats for a specific API key
  ApiKeyUsageStats? getStats(String apiKeyId) {
    return state[apiKeyId];
  }
}

/// API key usage stats provider
final apiKeyUsageProvider =
    NotifierProvider<ApiKeyUsageNotifier, Map<String, ApiKeyUsageStats>>(
  ApiKeyUsageNotifier.new,
);

/// Provider for the selected API key's stats
final selectedKeyStatsProvider = Provider<ApiKeyUsageStats?>((ref) {
  final selectedKey = ref.watch(selectedApiKeyProvider);
  final allStats = ref.watch(apiKeyUsageProvider);

  if (selectedKey == null) return null;
  return allStats[selectedKey.id];
});

/// Provider for quota info of the selected API key
final selectedKeyQuotaProvider = Provider<QuotaInfo?>((ref) {
  final selectedKey = ref.watch(selectedApiKeyProvider);
  final stats = ref.watch(selectedKeyStatsProvider);

  if (selectedKey == null || stats == null) {
    return null;
  }

  return QuotaInfo.fromStats(
    apiKeyId: selectedKey.id,
    apiKeyName: selectedKey.name,
    stats: stats,
  );
});

/// Provider for all quota info (for switching between keys)
final allQuotaInfoProvider = Provider<List<QuotaInfo>>((ref) {
  final keys = ref.watch(apiKeysProvider);
  final allStats = ref.watch(apiKeyUsageProvider);

  final result = <QuotaInfo>[];

  for (final key in keys) {
    final stats = allStats[key.id];
    if (stats != null) {
      result.add(QuotaInfo.fromStats(
        apiKeyId: key.id,
        apiKeyName: key.name,
        stats: stats,
      ));
    } else {
      // No stats yet for this key
      result.add(QuotaInfo.fromStats(
        apiKeyId: key.id,
        apiKeyName: key.name,
        stats: ApiKeyUsageStats.empty(key.id),
      ));
    }
  }

  return result;
});
