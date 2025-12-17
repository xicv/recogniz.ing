import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/vocabulary.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class VocabularyEditor extends ConsumerStatefulWidget {
  final VocabularySet? vocabulary;

  const VocabularyEditor({super.key, this.vocabulary});

  @override
  ConsumerState<VocabularyEditor> createState() => _VocabularyEditorState();
}

class _VocabularyEditorState extends ConsumerState<VocabularyEditor> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _wordsController;

  bool get isEditing => widget.vocabulary != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.vocabulary?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.vocabulary?.description ?? '');
    _wordsController = TextEditingController(
      text: widget.vocabulary?.words.join('\n') ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _wordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    isEditing ? 'Edit Vocabulary' : 'New Vocabulary',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const Spacer(),
                  if (isEditing && !widget.vocabulary!.isDefault)
                    IconButton(
                      onPressed: _deleteVocabulary,
                      icon: Icon(LucideIcons.trash2, color: AppColors.error),
                    ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter vocabulary set name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Brief description of this vocabulary',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _wordsController,
                    decoration: const InputDecoration(
                      labelText: 'Words',
                      hintText: 'Enter one word or phrase per line...',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 15,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.info,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Add proper nouns, technical terms, or domain-specific vocabulary (one per line)',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveVocabulary,
                    child: Text(
                        isEditing ? 'Update Vocabulary' : 'Create Vocabulary'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveVocabulary() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final wordsText = _wordsController.text.trim();

    if (name.isEmpty || wordsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and words are required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final words = wordsText
        .split('\n')
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();

    final vocabulary = VocabularySet(
      id: widget.vocabulary?.id ?? const Uuid().v4(),
      name: name,
      description: description,
      words: words,
      isDefault: false,
      createdAt: widget.vocabulary?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      ref.read(vocabularyProvider.notifier).updateVocabulary(vocabulary);
    } else {
      ref.read(vocabularyProvider.notifier).addVocabulary(vocabulary);
    }

    Navigator.pop(context);
  }

  void _deleteVocabulary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vocabulary'),
        content:
            const Text('Are you sure you want to delete this vocabulary set?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(vocabularyProvider.notifier)
                  .deleteVocabulary(widget.vocabulary!.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
