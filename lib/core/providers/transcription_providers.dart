import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transcription.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

/// Sort options for transcriptions
enum SortOption {
  newest,
  oldest,
  duration,
  favorites,
}

/// Filter options for transcriptions
enum FilterOption {
  all,
  favorites,
}

/// Transcription management providers
final transcriptionsProvider =
    StateNotifierProvider<TranscriptionsNotifier, List<Transcription>>((ref) {
  return TranscriptionsNotifier();
});

/// Search query for filtering transcriptions
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Sort option for transcriptions
final sortOptionProvider =
    StateProvider<SortOption>((ref) => SortOption.newest);

/// Filter option for transcriptions
final filterOptionProvider =
    StateProvider<FilterOption>((ref) => FilterOption.all);

/// Filtered transcriptions based on search query, filter option, and sort option
final filteredTranscriptionsProvider = Provider<List<Transcription>>((ref) {
  final transcriptions = ref.watch(transcriptionsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final sortOption = ref.watch(sortOptionProvider);
  final filterOption = ref.watch(filterOptionProvider);

  // Apply filters
  List<Transcription> filtered = transcriptions;

  // Filter by search query
  if (query.isNotEmpty) {
    filtered = filtered
        .where((t) =>
            t.rawText.toLowerCase().contains(query) ||
            t.processedText.toLowerCase().contains(query))
        .toList();
  }

  // Filter by option (favorites only)
  if (filterOption == FilterOption.favorites) {
    filtered = filtered.where((t) => t.isFavorite ?? false).toList();
  }

  // Sort by selected option
  switch (sortOption) {
    case SortOption.newest:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case SortOption.oldest:
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case SortOption.duration:
      filtered.sort(
          (a, b) => b.audioDurationSeconds.compareTo(a.audioDurationSeconds));
      break;
    case SortOption.favorites:
      filtered.sort((a, b) {
        if (a.isFavorite == b.isFavorite) {
          return b.createdAt.compareTo(a.createdAt);
        }
        return (a.isFavorite ?? false) ? 1 : -1;
      });
      break;
  }

  return filtered;
});

/// Enhanced statistics provider for dashboard
final enhancedStatisticsProvider = Provider<EnhancedStatistics>((ref) {
  final transcriptions = ref.watch(transcriptionsProvider);

  return AnalyticsService.calculateEnhancedStats(transcriptions);
});

/// Legacy statistics provider for backward compatibility
final statisticsProvider = Provider<Statistics>((ref) {
  final enhancedStats = ref.watch(enhancedStatisticsProvider);

  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));

  // Calculate this week's usage from enhanced data
  int thisWeekUsage = 0;
  enhancedStats.usageByDay.forEach((date, count) {
    if (date.isAfter(weekAgo)) {
      thisWeekUsage += count;
    }
  });

  return Statistics(
    totalUsage: enhancedStats.totalTranscriptions,
    totalTokens: enhancedStats.totalTokens,
    totalDurationMinutes: enhancedStats.totalDurationMinutes,
    thisWeekUsage: thisWeekUsage,
  );
});

/// Notifier for managing transcription state
class TranscriptionsNotifier extends StateNotifier<List<Transcription>> {
  TranscriptionsNotifier() : super(_loadTranscriptions());

  /// Load transcriptions from storage without sorting
  /// Sorting is handled by filteredTranscriptionsProvider based on user selection
  static List<Transcription> _loadTranscriptions() {
    try {
      return StorageService.transcriptions.values.toList();
    } catch (e) {
      debugPrint('[TranscriptionsNotifier] Failed to load transcriptions: $e');
      return [];
    }
  }

  Future<void> addTranscription(Transcription transcription) async {
    await StorageService.transcriptions.put(transcription.id, transcription);
    state = _loadTranscriptions();
  }

  Future<void> updateTranscription(String id, String newText) async {
    final existing = StorageService.transcriptions.get(id);
    if (existing != null) {
      final updated = existing.copyWith(processedText: newText);
      await StorageService.transcriptions.put(id, updated);
      state = _loadTranscriptions();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final existing = StorageService.transcriptions.get(id);
    if (existing != null) {
      final updated = existing.copyWith(
        isFavorite: !(existing.isFavorite ?? false),
      );
      await StorageService.transcriptions.put(id, updated);
      state = _loadTranscriptions();
    }
  }

  Future<void> deleteTranscription(String id) async {
    await StorageService.transcriptions.delete(id);
    state = _loadTranscriptions();
  }

  Future<void> deleteMultipleTranscriptions(List<String> ids) async {
    await StorageService.deleteMultipleTranscriptions(ids);
    state = _loadTranscriptions();
  }

  void refresh() {
    state = _loadTranscriptions();
  }
}

/// Statistics data model
class Statistics {
  final int totalUsage;
  final int totalTokens;
  final double totalDurationMinutes;
  final int thisWeekUsage;

  Statistics({
    required this.totalUsage,
    required this.totalTokens,
    required this.totalDurationMinutes,
    required this.thisWeekUsage,
  });
}
