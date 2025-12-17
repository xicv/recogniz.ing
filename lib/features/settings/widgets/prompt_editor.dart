import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/custom_prompt.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class PromptEditor extends ConsumerStatefulWidget {
  final CustomPrompt? prompt;

  const PromptEditor({super.key, this.prompt});

  @override
  ConsumerState<PromptEditor> createState() => _PromptEditorState();
}

class _PromptEditorState extends ConsumerState<PromptEditor> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _templateController;

  bool get isEditing => widget.prompt != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prompt?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.prompt?.description ?? '');
    _templateController =
        TextEditingController(text: widget.prompt?.promptTemplate ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _templateController.dispose();
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
                    isEditing ? 'Edit Prompt' : 'New Prompt',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const Spacer(),
                  if (isEditing && !widget.prompt!.isDefault)
                    IconButton(
                      onPressed: _deletePrompt,
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
                      hintText: 'Enter prompt name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Brief description of this prompt',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _templateController,
                    decoration: const InputDecoration(
                      labelText: 'Prompt Template',
                      hintText: 'Enter your prompt template...',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 10,
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
                            'Use {{text}} as placeholder for the transcription',
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
                    onPressed: _savePrompt,
                    child: Text(isEditing ? 'Update Prompt' : 'Create Prompt'),
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

  void _savePrompt() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final template = _templateController.text.trim();

    if (name.isEmpty || template.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and template are required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final prompt = CustomPrompt(
      id: widget.prompt?.id ?? const Uuid().v4(),
      name: name,
      description: description,
      promptTemplate: template,
      isDefault: false,
      createdAt: widget.prompt?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      ref.read(promptsProvider.notifier).updatePrompt(prompt);
    } else {
      ref.read(promptsProvider.notifier).addPrompt(prompt);
    }

    Navigator.pop(context);
  }

  void _deletePrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: const Text('Are you sure you want to delete this prompt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(promptsProvider.notifier)
                  .deletePrompt(widget.prompt!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close editor
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
