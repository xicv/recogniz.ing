import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/vocabulary_providers.dart';
import '../../core/models/vocabulary.dart';
import '../../core/models/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/shared/app_bars.dart';
import '../settings/widgets/vocabulary_editor.dart';

class DictionariesPage extends ConsumerStatefulWidget {
  const DictionariesPage({super.key});

  @override
  ConsumerState<DictionariesPage> createState() => _DictionariesPageState();
}

class _DictionariesPageState extends ConsumerState<DictionariesPage> {
  final Set<String> _expandedVocabIds = <String>{};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final vocabulary = ref.watch(vocabularyProvider);

    // Filter vocabulary based on search
    final filteredVocabulary = _searchQuery.isEmpty
        ? vocabulary
        : vocabulary
            .where((vocab) =>
                vocab.name.toLowerCase().contains(_searchQuery) ||
                vocab.words
                    .any((word) => word.toLowerCase().contains(_searchQuery)))
            .toList();

    return Scaffold(
      appBar: AppBars.primary(
        title: 'Dictionaries',
        actions: [
          IconButton(
            onPressed: () => _showVocabularyEditor(context, ref),
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Add Dictionary',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search dictionaries...',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: const Icon(LucideIcons.x),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),

          // Dictionary list
          Expanded(
            child: filteredVocabulary.isEmpty
                ? _buildEmptyState(context, _searchQuery.isNotEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredVocabulary.length,
                    itemBuilder: (context, index) {
                      final vocab = filteredVocabulary[index];
                      return _buildVocabularyTile(
                          context, ref, vocab, settings);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? LucideIcons.search : LucideIcons.bookOpen,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No dictionaries found' : 'No dictionaries yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try adjusting your search terms'
                : 'Create your first custom dictionary',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (!isSearching) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showVocabularyEditor(context, ref),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Create Dictionary'),
            ),
          ],
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildVocabularyTile(
    BuildContext context,
    WidgetRef ref,
    VocabularySet vocab,
    AppSettings settings,
  ) {
    final isExpanded = _expandedVocabIds.contains(vocab.id);
    final isSelected = settings.selectedVocabularyId == vocab.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.bookOpen,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              vocab.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${vocab.words.length} words',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                if (!isExpanded && vocab.words.isNotEmpty)
                  Text(
                    vocab.words.take(3).join(', '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Active',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (!vocab.isDefault)
                  PopupMenuButton(
                    icon: const Icon(LucideIcons.moreVertical, size: 20),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(LucideIcons.edit, size: 16),
                            const SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(LucideIcons.trash2, size: 16),
                            const SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showVocabularyEditor(context, ref, vocabulary: vocab);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, ref, vocab);
                      }
                    },
                  ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedVocabIds.remove(vocab.id);
                      } else {
                        _expandedVocabIds.add(vocab.id);
                      }
                    });
                  },
                  icon: Icon(
                    isExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            onTap: () {
              ref
                  .read(settingsProvider.notifier)
                  .updateSelectedVocabulary(vocab.id);
            },
          ),
          if (isExpanded && vocab.words.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vocab.words.map((word) {
                  return Chip(
                    label: Text(word),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                    deleteIcon: const Icon(LucideIcons.x, size: 16),
                    onDeleted: !vocab.isDefault
                        ? () {
                            // TODO: Implement word removal
                          }
                        : null,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  void _showVocabularyEditor(
    BuildContext context,
    WidgetRef ref, {
    VocabularySet? vocabulary,
  }) {
    showDialog(
      context: context,
      builder: (context) => VocabularyEditor(
        vocabulary: vocabulary,
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    VocabularySet vocab,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dictionary'),
        content: Text('Are you sure you want to delete "${vocab.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement vocabulary deletion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dictionary "${vocab.name}" deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
