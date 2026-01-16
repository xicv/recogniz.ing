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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        title: Text(isEditing ? 'Edit Prompt' : 'New Prompt'),
        actions: [
          if (isEditing && !widget.prompt!.isDefault)
            IconButton(
              onPressed: _deletePrompt,
              icon: Icon(LucideIcons.trash2, color: AppColors.error),
              tooltip: 'Delete',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Use {{text}} as placeholder for the transcription',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _savePrompt,
              icon: const Icon(LucideIcons.check),
              label: Text(isEditing ? 'Update Prompt' : 'Create Prompt'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 100),
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
          duration: Duration(seconds: 2),
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
