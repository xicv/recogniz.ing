import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transcription.dart';
import '../services/pagination_service.dart';

/// Paginated transcriptions provider
class PaginatedTranscriptionsNotifier extends StateNotifier<PaginationState> {
  PaginatedTranscriptionsNotifier(this._searchText) : super(const PaginationState());

  final String? _searchText;
  String? _currentCursor;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  Future<void> loadFirstPage() async {
    _currentCursor = null;
    state = const PaginationState();
    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_isLoading || !state.hasMore) return;

    _isLoading = true;
    _hasError = false;

    try {
      final result = await PaginationService.getTranscriptions(
        cursorKey: _currentCursor,
        limit: 50,
        searchText: _searchText,
      );

      state = state.copyWith(
        items: [...state.items, ...result.items],
        nextCursor: result.nextCursor,
        hasMore: result.hasMore,
        totalCount: result.totalCount,
        isLoading: false,
      );

      _currentCursor = result.nextCursor;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    _currentCursor = null;
    state = const PaginationState();
    await _loadNextPage();
  }

  Future<void> retry() async {
    if (_hasError) {
      _hasError = false;
      await _loadNextPage();
    }
  }
}

class PaginationState {
  final List<Transcription> items;
  final bool isLoading;
  final bool hasMore;
  final String? nextCursor;
  final int totalCount;
  final String? error;

  const PaginationState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.nextCursor,
    this.totalCount = 0,
    this.error,
  });

  PaginationState copyWith({
    List<Transcription>? items,
    bool? isLoading,
    bool? hasMore,
    String? nextCursor,
    int? totalCount,
    String? error,
  }) {
    return PaginationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      totalCount: totalCount ?? this.totalCount,
      error: error ?? this.error,
    );
  }
}

/// Provider for paginated transcriptions
final paginatedTranscriptionsProvider = StateNotifierProvider.family<PaginatedTranscriptionsNotifier, PaginationState, String?>(
  (ref, searchText) {
    return PaginatedTranscriptionsNotifier(searchText);
  },
);

/// Total count provider
final totalCountProvider = FutureProvider.family<int, String?>((ref, searchText) async {
  return await PaginationService.getTotalCount(searchText: searchText);
});