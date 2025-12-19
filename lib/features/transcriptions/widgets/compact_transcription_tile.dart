import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/models/transcription.dart';

class CompactTranscriptionTile extends StatefulWidget {
  final Transcription transcription;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final Function(String)? onUpdate;

  const CompactTranscriptionTile({
    super.key,
    required this.transcription,
    required this.onCopy,
    required this.onDelete,
    this.onUpdate,
  });

  @override
  State<CompactTranscriptionTile> createState() =>
      _CompactTranscriptionTileState();
}

class _CompactTranscriptionTileState extends State<CompactTranscriptionTile>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.transcription.processedText);
  }

  @override
  void didUpdateWidget(CompactTranscriptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transcription.processedText !=
        widget.transcription.processedText) {
      _controller.text = widget.transcription.processedText;
      _hasChanges = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins}:${secs.toString().padLeft(2, '0')}';
  }

  String _getPreviewText(String text) {
    final lines = text.split('\n');
    final preview = lines.first;
    return preview.length > 100 ? '${preview.substring(0, 100)}...' : preview;
  }

  void _saveChanges() {
    if (_hasChanges && widget.onUpdate != null) {
      widget.onUpdate!(_controller.text);
    }
    setState(() {
      _isEditing = false;
      _hasChanges = false;
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transcription'),
        content:
            const Text('Are you sure you want to delete this transcription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d');

    return CallbackShortcuts(
      bindings: {
        if (_isEditing && _hasChanges)
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): _saveChanges,
        if (_isEditing && _hasChanges)
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true): _saveChanges,
      },
      child: Focus(
        autofocus: _isEditing,
        child: Card(
          margin: const EdgeInsets.only(bottom: UIConstants.spacingXSmall),
          child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingMedium,
          vertical: UIConstants.spacingSmall,
        ),
        title: _isEditing
            ? TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 3,
                minLines: 1,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(UIConstants.borderRadiusSmall),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(UIConstants.borderRadiusSmall),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingSmall,
                    vertical: UIConstants.spacingXSmall,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _hasChanges = value != widget.transcription.processedText;
                  });
                },
                onSubmitted: (_) => _saveChanges(),
              )
            : Text(
                _getPreviewText(_controller.text),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: UIConstants.spacingXXSmall),
          child: Row(
            children: [
              Text(
                dateFormat.format(widget.transcription.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: UIConstants.spacingSmall),
              Text(
                '• ${_formatDuration(widget.transcription.audioDurationSeconds)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        trailing: _isEditing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _controller.text = widget.transcription.processedText;
                        _hasChanges = false;
                        _isEditing = false;
                      });
                    },
                    icon: const Icon(LucideIcons.x, size: 18),
                    tooltip: 'Cancel',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: _saveChanges,
                    icon: const Icon(LucideIcons.check, size: 18),
                    tooltip: 'Save',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: widget.onCopy,
                    icon: const Icon(LucideIcons.copy, size: 18),
                    tooltip: 'Copy',
                    visualDensity: VisualDensity.compact,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(LucideIcons.moreVertical, size: 18),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          setState(() => _isEditing = true);
                          break;
                        case 'delete':
                          _confirmDelete(context);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(LucideIcons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(LucideIcons.trash2, size: 16),
                            const SizedBox(width: 8),
                            const Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        onTap: () {
          if (!_isEditing) {
            setState(() => _isEditing = true);
          }
        },
          ),
        ),
      ),
    );
  }
}
