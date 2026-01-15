import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/models/transcription.dart';
import '../../../core/theme/app_theme.dart';

class TranscriptionTile extends StatefulWidget {
  final Transcription transcription;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final Function(String)? onUpdate;

  const TranscriptionTile({
    super.key,
    required this.transcription,
    required this.onCopy,
    required this.onDelete,
    this.onUpdate,
  });

  @override
  State<TranscriptionTile> createState() => _TranscriptionTileState();
}

class _TranscriptionTileState extends State<TranscriptionTile> {
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
  void didUpdateWidget(TranscriptionTile oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dateFormat.format(widget.transcription.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.transcription.tokenUsage} tokens',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Editable text field
            GestureDetector(
              onTap: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      maxLines: null,
                      minLines: 2,
                      autofocus: true,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 2),
                        ),
                        hintText: 'Enter transcription text...',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _hasChanges =
                              value != widget.transcription.processedText;
                        });
                      },
                      onTapOutside: (_) {
                        setState(() {
                          _isEditing = false;
                        });
                      },
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        _controller.text,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  size: 14,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.transcription.audioDurationSeconds.toStringAsFixed(1)}s',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),

                // Save button (only show when there are changes)
                if (_hasChanges) ...[
                  TextButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(LucideIcons.save, size: 16),
                    label: const Text('Save'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _controller.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.copy, size: 18),
                  tooltip: 'Copy',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: () => _showDetails(context),
                  icon: const Icon(LucideIcons.expand, size: 18),
                  tooltip: 'View details',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: Icon(LucideIcons.trash2,
                      size: 18, color: AppColors.error),
                  tooltip: 'Delete',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    if (widget.onUpdate != null) {
      widget.onUpdate!(_controller.text);
    }
    setState(() {
      _hasChanges = false;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transcription saved'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
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
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Transcription Details',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 18,
                              ),
                    ),
                    const Spacer(),
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
                    _buildSection(
                      context,
                      title: 'Processed Text',
                      content: _controller.text,
                      onCopy: () {
                        Clipboard.setData(
                            ClipboardData(text: _controller.text));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'Raw Transcription',
                      content: widget.transcription.rawText,
                      onCopy: () {
                        Clipboard.setData(
                            ClipboardData(text: widget.transcription.rawText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Raw text copied'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(context, 'Duration',
                        '${widget.transcription.audioDurationSeconds.toStringAsFixed(1)} seconds'),
                    _buildInfoRow(context, 'Tokens Used',
                        '${widget.transcription.tokenUsage}'),
                    _buildInfoRow(
                        context,
                        'Created',
                        DateFormat('MMM d, yyyy h:mm a')
                            .format(widget.transcription.createdAt)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    VoidCallback? onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            if (onCopy != null)
              TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(LucideIcons.copy, size: 16),
                label: const Text('Copy'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
