import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/app_settings.dart';
import 'widgets/modern_transcription_tile.dart';

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
                  const SizedBox(width: 16),
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
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
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
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertTriangle, color: AppColors.warning, size: 20),
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
                        ref.read(currentPageProvider.notifier).state = 2; // Settings tab
                      },
                      child: const Text('Settings'),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Transcription Count & Sort
          if (transcriptions.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${transcriptions.length} transcription${transcriptions.length != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(LucideIcons.arrowDownUp),
                      tooltip: 'Sort',
                      onSelected: (value) {
                        // TODO: Implement sorting
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'newest',
                          child: Row(
                            children: [
                              Icon(LucideIcons.clock, size: 16),
                              SizedBox(width: 8),
                              Text('Newest first'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'oldest',
                          child: Row(
                            children: [
                              Icon(LucideIcons.history, size: 16),
                              SizedBox(width: 8),
                              Text('Oldest first'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duration',
                          child: Row(
                            children: [
                              Icon(LucideIcons.timer, size: 16),
                              SizedBox(width: 8),
                              Text('Duration'),
                            ],
                          ),
                        ),
                      ],
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
                      child: ModernTranscriptionTile(
                        transcription: transcription,
                        onCopy: () => _copyToClipboard(context, transcription.processedText),
                        onDelete: () => _deleteTranscription(context, ref, transcription.id),
                        onUpdate: (newText) {
                          ref.read(transcriptionsProvider.notifier).updateTranscription(
                            transcription.id,
                            newText,
                          );
                        },
                      ),
                    ).animate().fadeIn(
                      duration: 200.ms,
                      delay: Duration(milliseconds: index * 50),
                    ).slideY(begin: 0.05);
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.mic,
                size: 48,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            Text(
              'No transcriptions yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 8),

            Text(
              'Tap the record button to start transcribing',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 32),

            if (settings.hasApiKey) ...[
              FilledButton.icon(
                onPressed: () {
                  // Trigger recording
                  ref.read(currentPageProvider.notifier).state = 0; // Dashboard tab
                },
                icon: const Icon(LucideIcons.mic),
                label: const Text('Start Recording'),
              ).animate().fadeIn(delay: 400.ms),
            ] else ...[
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(currentPageProvider.notifier).state = 2; // Settings tab
                },
                icon: const Icon(LucideIcons.settings),
                label: const Text('Add API Key'),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ],
        ),
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
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _deleteTranscription(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transcription?'),
        content: const Text('This transcription will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(transcriptionsProvider.notifier).deleteTranscription(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transcription deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}