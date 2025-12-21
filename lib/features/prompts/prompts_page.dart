import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/prompt_providers.dart';
import '../../core/models/custom_prompt.dart';
import '../../core/models/app_settings.dart';
import '../../widgets/shared/app_bars.dart';
import '../settings/widgets/prompt_editor.dart';

class PromptsPage extends ConsumerStatefulWidget {
  const PromptsPage({super.key});

  @override
  ConsumerState<PromptsPage> createState() => _PromptsPageState();
}

class _PromptsPageState extends ConsumerState<PromptsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  CustomPrompt? _expandedPrompt;

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
    final prompts = ref.watch(promptsProvider);

    // Filter prompts based on search
    final filteredPrompts = _searchQuery.isEmpty
        ? prompts
        : prompts.where((prompt) =>
            prompt.name.toLowerCase().contains(_searchQuery) ||
            prompt.description.toLowerCase().contains(_searchQuery) ||
            prompt.promptTemplate.toLowerCase().contains(_searchQuery)).toList();

    return Scaffold(
      appBar: AppBars.primary(
        title: 'Prompts',
        actions: [
          IconButton(
            onPressed: () => _showPromptEditor(context, ref),
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Add Prompt',
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
                hintText: 'Search prompts...',
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

          // Prompt list
          Expanded(
            child: filteredPrompts.isEmpty
                ? _buildEmptyState(context, _searchQuery.isNotEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPrompts.length,
                    itemBuilder: (context, index) {
                      final prompt = filteredPrompts[index];
                      return _buildPromptCard(context, ref, prompt, settings);
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
            isSearching ? LucideIcons.search : LucideIcons.messageSquare,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No prompts found' : 'No prompts yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try adjusting your search terms'
                : 'Create your first custom prompt',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (!isSearching) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showPromptEditor(context, ref),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Create Prompt'),
            ),
          ],
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildPromptCard(
    BuildContext context,
    WidgetRef ref,
    CustomPrompt prompt,
    AppSettings settings,
  ) {
    final isSelected = settings.selectedPromptId == prompt.id;
    final isExpanded = _expandedPrompt?.id == prompt.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          InkWell(
            onTap: () {
              if (!isSelected) {
                ref.read(settingsProvider.notifier).updateSelectedPrompt(prompt.id);
              }
              setState(() {
                _expandedPrompt = isExpanded ? null : prompt;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.messageSquare,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title and description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    prompt.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                    ),
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
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prompt.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!prompt.isDefault)
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
                                PopupMenuItem(
                                  value: 'duplicate',
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.copy, size: 16),
                                      const SizedBox(width: 8),
                                      Text('Duplicate'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showPromptEditor(context, ref, prompt: prompt);
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, ref, prompt);
                                } else if (value == 'duplicate') {
                                  _duplicatePrompt(context, ref, prompt);
                                }
                              },
                            ),
                          Icon(
                            isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded content (template preview)
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Template Preview',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prompt.promptTemplate,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  void _showPromptEditor(
    BuildContext context,
    WidgetRef ref, {
    CustomPrompt? prompt,
  }) {
    showDialog(
      context: context,
      builder: (context) => PromptEditor(
        prompt: prompt,
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    CustomPrompt prompt,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: Text('Are you sure you want to delete "${prompt.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement prompt deletion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Prompt "${prompt.name}" deleted')),
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

  void _duplicatePrompt(
    BuildContext context,
    WidgetRef ref,
    CustomPrompt prompt,
  ) {
    final duplicatedPrompt = CustomPrompt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${prompt.name} (Copy)',
      description: prompt.description,
      promptTemplate: prompt.promptTemplate,
      isDefault: false,
      createdAt: DateTime.now(),
    );

    // TODO: Add duplicated prompt to storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Prompt "${prompt.name}" duplicated')),
    );
  }
}