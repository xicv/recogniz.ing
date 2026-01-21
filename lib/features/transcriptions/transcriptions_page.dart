import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/transcription.dart';
import '../../widgets/shared/empty_states.dart';
import 'widgets/transcription_card.dart';

class TranscriptionsPage extends ConsumerStatefulWidget {
  const TranscriptionsPage({super.key});

  @override
  ConsumerState<TranscriptionsPage> createState() => _TranscriptionsPageState();
}

class _TranscriptionsPageState extends ConsumerState<TranscriptionsPage>
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  bool _isSearching = false;
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });
    ref.read(searchQueryProvider.notifier).state = _searchQuery;
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final transcriptions = ref.watch(filteredTranscriptionsProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with Search
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            titleSpacing: 16,
            title: Row(
              children: [
                Text(
                  'Transcriptions',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (transcriptions.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () =>
                        _showClearAllDialog(context, transcriptions.length),
                    icon: const Icon(LucideIcons.trash2),
                    tooltip: 'Clear All',
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showFilterDialog(context),
                    icon: const Icon(LucideIcons.filter),
                    tooltip: 'Filter',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: 'Search transcriptions...',
                  leading: const Icon(LucideIcons.search),
                  trailing: _isSearching
                      ? [
                          IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(LucideIcons.x),
                            tooltip: 'Clear',
                          ),
                        ]
                      : null,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    _onSearchChanged();
                  },
                ),
              ),
            ),
          ),

          // API Key Warning
          if (!settings.hasApiKey) ...[
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertTriangle,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add your Gemini API key in Settings to start recording',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.warning,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(currentPageProvider.notifier).state =
                            4; // Settings tab
                      },
                      child: const Text('Settings'),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Transcription Count & Sort (always show if filter is active or has items)
          if (transcriptions.isNotEmpty ||
              ref.watch(filterOptionProvider) != FilterOption.all) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      transcriptions.isNotEmpty
                          ? '${transcriptions.length} transcription${transcriptions.length != 1 ? 's' : ''}'
                          : 'No transcriptions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(width: 8),
                    // Favorites filter chip
                    _FavoritesFilterChip(
                      currentFilter: ref.watch(filterOptionProvider),
                      onFilterChanged: (filter) {
                        ref.read(filterOptionProvider.notifier).state = filter;
                      },
                    ),
                    const Spacer(),
                    PopupMenuButton<SortOption>(
                      icon: const Icon(LucideIcons.arrowDownUp),
                      tooltip: 'Sort',
                      onSelected: (value) {
                        ref.read(sortOptionProvider.notifier).state = value;
                      },
                      itemBuilder: (context) {
                        final currentSort = ref.watch(sortOptionProvider);
                        return [
                          PopupMenuItem(
                            value: SortOption.newest,
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.clock,
                                  size: 16,
                                  color: currentSort == SortOption.newest
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text('Newest first'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.oldest,
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.history,
                                  size: 16,
                                  color: currentSort == SortOption.oldest
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text('Oldest first'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.duration,
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.timer,
                                  size: 16,
                                  color: currentSort == SortOption.duration
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text('Duration'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.favorites,
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.star,
                                  size: 16,
                                  color: currentSort == SortOption.favorites
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text('Favorites'),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Transcriptions List
          if (transcriptions.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(context, settings),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transcription = transcriptions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TranscriptionCard(
                        transcription: transcription,
                        onCopy: () => _copyToClipboard(
                            context, transcription.processedText),
                        onDelete: () => _deleteTranscription(
                            context, ref, transcription.id),
                        onUpdate: (newText) {
                          ref
                              .read(transcriptionsProvider.notifier)
                              .updateTranscription(
                                transcription.id,
                                newText,
                              );
                        },
                        onToggleFavorite: () {
                          ref
                              .read(transcriptionsProvider.notifier)
                              .toggleFavorite(transcription.id);
                        },
                        onRetry: transcription.canRetry
                            ? (t) => _retryTranscription(context, ref, t)
                            : null,
                      ),
                    )
                        .animate()
                        .fadeIn(
                          duration: 200.ms,
                          delay: Duration(milliseconds: index * 50),
                        )
                        .slideY(begin: 0.05);
                  },
                  childCount: transcriptions.length,
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppSettings settings) {
    // Show favorites filter empty state if filter is active
    final currentFilter = ref.watch(filterOptionProvider);
    if (currentFilter == FilterOption.favorites) {
      return _FavoritesEmptyState(
        onClearFilter: () {
          ref.read(filterOptionProvider.notifier).state = FilterOption.all;
        },
      );
    }

    // Show search empty state if user is searching
    if (_isSearching) {
      return SearchEmptyState(
        searchQuery: _searchQuery,
        onClearSearch: _clearSearch,
      );
    }

    // Show appropriate empty state based on API key status
    return TranscriptionEmptyState(
      hasApiKey: settings.hasApiKey,
      onStartRecording: () async {
        // Start recording when user taps the button
        final voiceRecordingUseCase = ref.read(voiceRecordingUseCaseProvider);
        await HapticService.startRecording();
        await voiceRecordingUseCase.startRecording();
      },
      onOpenSettings: () {
        ref.read(currentPageProvider.notifier).state = 4; // Settings tab
      },
    );
  }

  void _showClearAllDialog(BuildContext context, int count) {
    final isFiltered = _searchQuery.isNotEmpty;
    final message = isFiltered
        ? 'Delete $count transcription${count != 1 ? 's' : ''} matching "$_searchQuery"?'
        : 'Delete all $count transcription${count != 1 ? 's' : ''}?';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFiltered
            ? 'Clear Filtered Transcriptions?'
            : 'Clear All Transcriptions?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              await _clearAllTranscriptions(ref);
              if (!context.mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(isFiltered
                      ? '$count transcription${count != 1 ? 's' : ''} deleted'
                      : 'All transcriptions deleted'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: Colors.white,
                    onPressed: () {
                      if (context.mounted) {
                        messenger.hideCurrentSnackBar();
                      }
                    },
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fixed header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.filter,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Filter Transcriptions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Range Section
                      _buildFilterSection(
                        context,
                        title: 'Date Range',
                        icon: LucideIcons.calendar,
                        children: [
                          'Today',
                          'Yesterday',
                          'This Week',
                          'This Month',
                          'Custom Range',
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Duration Section
                      _buildFilterSection(
                        context,
                        title: 'Duration',
                        icon: LucideIcons.timer,
                        children: [
                          'Under 30 seconds',
                          '30s - 1 minute',
                          '1 - 5 minutes',
                          'Over 5 minutes',
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Status Section
                      _buildFilterSection(
                        context,
                        title: 'Status',
                        icon: LucideIcons.circle,
                        children: [
                          'All',
                          'Has Text',
                          'Empty',
                          'Edited',
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Fixed bottom padding for buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x, size: 16),
                        label: const Text('Clear All'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.check, size: 16),
                        label: const Text('Apply Filters'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Filter options in a grid
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: children.map((option) {
              return FilterChip(
                label: Text(
                  option,
                  style: const TextStyle(fontSize: 12),
                ),
                onSelected: (value) {},
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _deleteTranscription(BuildContext context, WidgetRef ref, String id) {
    // Confirmation dialog is shown in TranscriptionCard._confirmDelete()
    // This method directly performs the deletion
    ref.read(transcriptionsProvider.notifier).deleteTranscription(id);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Transcription deleted'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _retryTranscription(
      BuildContext context, WidgetRef ref, Transcription transcription) async {
    HapticService.lightImpact();
    final useCase = ref.read(voiceRecordingUseCaseProvider);

    try {
      await useCase.retryTranscription(transcription);
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Retrying transcription...'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: _doNothing,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Retry failed: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              messenger.hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> _clearAllTranscriptions(WidgetRef ref) async {
    final transcriptions = ref.watch(filteredTranscriptionsProvider);

    // Extract IDs and delete all at once for better performance
    final ids = transcriptions.map((t) => t.id).toList();
    if (ids.isNotEmpty) {
      await ref
          .read(transcriptionsProvider.notifier)
          .deleteMultipleTranscriptions(ids);
    }

    // Clear search if it was active
    if (_searchQuery.isNotEmpty) {
      _clearSearch();
    }
  }

  /// No-op callback for SnackBarAction that only needs to auto-dismiss
  static void _doNothing() {}
}

/// Favorites filter chip widget
class _FavoritesFilterChip extends StatelessWidget {
  final FilterOption currentFilter;
  final Function(FilterOption) onFilterChanged;

  const _FavoritesFilterChip({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentFilter == FilterOption.favorites;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.star,
            size: 14,
            color: isActive
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          const Text('Favorites'),
        ],
      ),
      selected: isActive,
      onSelected: (selected) {
        onFilterChanged(selected ? FilterOption.favorites : FilterOption.all);
      },
      backgroundColor: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.5),
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Empty state shown when favorites filter is active but no favorites exist
class _FavoritesEmptyState extends StatelessWidget {
  final VoidCallback onClearFilter;

  const _FavoritesEmptyState({required this.onClearFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.star,
                size: 40,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Star your important transcriptions to find them here quickly',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onClearFilter,
              icon: const Icon(LucideIcons.x, size: 16),
              label: const Text('Show All Transcriptions'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
