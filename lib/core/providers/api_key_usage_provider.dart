import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_key_info.dart';
import '../models/api_key_usage_stats.dart';
import '../models/transcription.dart';
import '../models/transcription_status.dart';
import 'api_keys_provider.dart';
import 'transcription_providers.dart';

/// Provider for managing API key usage statistics.
///
/// Reactively recomputes stats whenever API keys or transcriptions change.
/// Stats are derived from the transcription list (source of truth), ensuring
/// the quota display always reflects reality.
class ApiKeyUsageNotifier extends Notifier<Map<String, ApiKeyUsageStats>> {
  @override
  Map<String, ApiKeyUsageStats> build() {
    // Watch both providers: rebuild stats whenever keys or transcriptions change
    final apiKeys = ref.watch(apiKeysProvider);
    final transcriptions = ref.watch(transcriptionsProvider);

    return _computeStats(apiKeys, transcriptions);
  }

  /// Synchronously compute per-key stats from the transcription list.
  Map<String, ApiKeyUsageStats> _computeStats(
    List<ApiKeyInfo> apiKeys,
    List<Transcription> transcriptions,
  ) {
    final statsMap = <String, ApiKeyUsageStats>{};

    if (apiKeys.isEmpty) return statsMap;

    // Filter to completed transcriptions only (pending/failed don't count as usage)
    final completed = transcriptions
        .where((t) => t.status == TranscriptionStatus.completed)
        .toList();

    for (final key in apiKeys) {
      final keyTranscriptions =
          completed.where((t) => t.apiKeyId == key.id).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (keyTranscriptions.isEmpty) {
        statsMap[key.id] = ApiKeyUsageStats.empty(key.id);
        continue;
      }

      int totalTranscriptions = 0;
      int totalTokens = 0;
      double totalDuration = 0;
      int totalWords = 0;
      final dailyUsageMap = <DateTime, DailyUsage>{};

      for (final t in keyTranscriptions) {
        totalTranscriptions++;
        totalTokens += t.tokenUsage;
        totalDuration += t.audioDurationSeconds / 60;
        totalWords += _countWords(t.processedText);

        // Add to daily usage using actual transcription date
        final dateKey = DateTime(
          t.createdAt.year,
          t.createdAt.month,
          t.createdAt.day,
        );
        final existing = dailyUsageMap[dateKey];
        dailyUsageMap[dateKey] = DailyUsage(
          transcriptionCount: (existing?.transcriptionCount ?? 0) + 1,
          tokens: (existing?.tokens ?? 0) + t.tokenUsage,
          durationMinutes:
              (existing?.durationMinutes ?? 0) + (t.audioDurationSeconds / 60),
          words: (existing?.words ?? 0) + _countWords(t.processedText),
          date: dateKey,
        );
      }

      statsMap[key.id] = ApiKeyUsageStats(
        apiKeyId: key.id,
        totalTranscriptions: totalTranscriptions,
        totalTokens: totalTokens,
        totalDurationMinutes: totalDuration,
        totalWords: totalWords,
        firstUsedAt: keyTranscriptions.last.createdAt,
        lastUsedAt: keyTranscriptions.first.createdAt,
        dailyUsage: dailyUsageMap.values.toList(),
        totalEstimatedCost: 0,
      );
    }

    return statsMap;
  }

  int _countWords(String text) {
    return text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  /// Record usage from a new transcription (optimistic update).
  ///
  /// This provides immediate UI feedback before the reactive rebuild
  /// from [transcriptionsProvider] fires. The next [build()] call will
  /// reconcile with the full transcription list.
  void recordUsage({
    required String apiKeyId,
    required int tokens,
    required double durationMinutes,
    required int words,
  }) {
    final currentStats = state[apiKeyId];

    if (currentStats != null) {
      final updated = currentStats.addUsage(
        tokens: tokens,
        durationMinutes: durationMinutes,
        words: words,
      );

      state = {...state, apiKeyId: updated};
    } else {
      final newStats = ApiKeyUsageStats.empty(apiKeyId).addUsage(
        tokens: tokens,
        durationMinutes: durationMinutes,
        words: words,
      );

      state = {...state, apiKeyId: newStats};
    }

    debugPrint('[ApiKeyUsageNotifier] Optimistic update for key: $apiKeyId');
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

/// Provider for selected API key name (for display in usage bar)
final selectedKeyNameProvider = Provider<String?>((ref) {
  final selectedKey = ref.watch(selectedApiKeyProvider);
  return selectedKey?.name;
});
