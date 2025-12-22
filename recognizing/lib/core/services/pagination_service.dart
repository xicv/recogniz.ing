import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/transcription.dart';

class PaginationService {
  static const String _transcriptionsBox = 'transcriptions';
  static const int _pageSize = 50;
  static const String _sortIndexBox = 'transcriptions_sort_index';

  /// Initialize pagination service
  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_sortIndexBox)) {
      await Hive.openBox<String>(_sortIndexBox);
    }
    await _rebuildSortIndexIfNeeded();
  }

  /// Get paginated transcriptions
  static Future<PaginationResult> getTranscriptions({
    String? cursorKey,
    int limit = _pageSize,
    String? searchText,
  }) async {
    final box = await Hive.openBox<Transcription>(_transcriptionsBox);
    final indexBox = Hive.box<String>(_sortIndexBox);

    // Get all transcriptions (for now, we'll optimize this later)
    final allTranscriptions = box.values.toList();

    // Sort by creation time (newest first)
    allTranscriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply search filter
    List<Transcription> filteredList = allTranscriptions;
    if (searchText != null && searchText.isNotEmpty) {
      final query = searchText.toLowerCase();
      filteredList = allTranscriptions.where((t) =>
          t.rawText.toLowerCase().contains(query) ||
          t.processedText.toLowerCase().contains(query)).toList();
    }

    // Find starting position from cursor
    int startIndex = 0;
    String? nextCursor;

    if (cursorKey != null) {
      for (int i = 0; i < filteredList.length; i++) {
        if (filteredList[i].id == cursorKey) {
          startIndex = i + 1;
          break;
        }
      }
    }

    // Get page
    final endIndex = (startIndex + limit).clamp(0, filteredList.length);
    final page = filteredList.sublist(startIndex, endIndex);

    // Set next cursor if there are more items
    if (endIndex < filteredList.length) {
      nextCursor = filteredList[endIndex].id;
    }

    // Close box to save memory
    await box.close();

    return PaginationResult(
      items: page,
      nextCursor: nextCursor,
      hasMore: endIndex < filteredList.length,
      totalCount: filteredList.length,
    );
  }

  /// Rebuild sort index for faster queries
  static Future<void> _rebuildSortIndexIfNeeded() async {
    final indexBox = Hive.box<String>(_sortIndexBox);

    // Check if index exists and is up to date
    if (indexBox.isNotEmpty) {
      // For now, we'll rebuild every time
      // In production, add timestamp checking
    }

    final box = await Hive.openBox<Transcription>(_transcriptionsBox);
    final transcriptions = box.values.toList();

    // Sort by creation time (newest first)
    transcriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Clear and rebuild index
    await indexBox.clear();
    final sortedIds = transcriptions.map((t) => t.id).toList();

    for (int i = 0; i < sortedIds.length; i++) {
      await indexBox.put(i.toString(), sortedIds[i]);
    }

    await box.close();
  }

  /// Get transcription by ID
  static Future<Transcription?> getTranscriptionById(String id) async {
    final box = await Hive.openBox<Transcription>(_transcriptionsBox);
    final transcription = box.get(id);
    await box.close();
    return transcription;
  }

  /// Get count of all transcriptions
  static Future<int> getTotalCount({String? searchText}) async {
    final box = await Hive.openBox<Transcription>(_transcriptionsBox);
    List<Transcription> transcriptions = box.values.toList();

    if (searchText != null && searchText.isNotEmpty) {
      final query = searchText.toLowerCase();
      transcriptions = transcriptions.where((t) =>
          t.rawText.toLowerCase().contains(query) ||
          t.processedText.toLowerCase().contains(query)).toList();
    }

    await box.close();
    return transcriptions.length;
  }
}

/// Pagination result wrapper
class PaginationResult {
  final List<Transcription> items;
  final String? nextCursor;
  final bool hasMore;
  final int totalCount;

  PaginationResult({
    required this.items,
    this.nextCursor,
    required this.hasMore,
    required this.totalCount,
  });
}