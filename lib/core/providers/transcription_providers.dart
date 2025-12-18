import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transcription.dart';
import '../services/storage_service.dart';

/// Transcription management providers
final transcriptionsProvider = StateNotifierProvider<TranscriptionsNotifier, List<Transcription>>((ref) {
  return TranscriptionsNotifier();
});

/// Search query for filtering transcriptions
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered transcriptions based on search query
final filteredTranscriptionsProvider = Provider<List<Transcription>>((ref) {
  final transcriptions = ref.watch(transcriptionsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) return transcriptions;

  return transcriptions
      .where((t) =>
          t.rawText.toLowerCase().contains(query) ||
          t.processedText.toLowerCase().contains(query))
      .toList();
});

/// Statistics provider for dashboard
final statisticsProvider = Provider<Statistics>((ref) {
  final transcriptions = ref.watch(transcriptionsProvider);

  final totalUsage = transcriptions.length;
  final totalTokens = transcriptions.fold<int>(0, (sum, t) => sum + t.tokenUsage);
  final totalDuration = transcriptions.fold<double>(0, (sum, t) => sum + t.audioDurationSeconds);

  // Usage by day for last 7 days
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  final recentTranscriptions = transcriptions.where((t) => t.createdAt.isAfter(weekAgo)).toList();

  return Statistics(
    totalUsage: totalUsage,
    totalTokens: totalTokens,
    totalDurationMinutes: totalDuration / 60,
    thisWeekUsage: recentTranscriptions.length,
  );
});

/// Notifier for managing transcription state
class TranscriptionsNotifier extends StateNotifier<List<Transcription>> {
  TranscriptionsNotifier() : super(_loadTranscriptions());

  static List<Transcription> _loadTranscriptions() {
    try {
      return StorageService.transcriptions.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

  Future<void> deleteTranscription(String id) async {
    await StorageService.transcriptions.delete(id);
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