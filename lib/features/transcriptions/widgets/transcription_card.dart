import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/models/transcription.dart';

class TranscriptionCard extends StatefulWidget {
  final Transcription transcription;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final Function(String)? onUpdate;
  final bool isSelected;

  const TranscriptionCard({
    super.key,
    required this.transcription,
    required this.onCopy,
    required this.onDelete,
    this.onUpdate,
    this.isSelected = false,
  });

  @override
  State<TranscriptionCard> createState() => _TranscriptionCardState();
}

class _TranscriptionCardState extends State<TranscriptionCard>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  bool _isEditing = false;
  bool _hasChanges = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.transcription.processedText);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(TranscriptionCard oldWidget) {
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
    _animationController.dispose();
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
    return preview.length > 120 ? '${preview.substring(0, 120)}...' : preview;
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
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Delete Transcription'),
        content: const Text('Are you sure you want to delete this transcription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y • h:mm a');
    final colorScheme = theme.colorScheme;

    return CallbackShortcuts(
      bindings: {
        if (_isEditing && _hasChanges)
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): _saveChanges,
        if (_isEditing && _hasChanges)
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true): _saveChanges,
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_isEditing) {
            setState(() {
              _controller.text = widget.transcription.processedText;
              _hasChanges = false;
              _isEditing = false;
            });
          }
        },
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.01 : 1.0),
          child: Card(
            margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
            elevation: _isHovered ? 4 : 2,
            surfaceTintColor: colorScheme.surfaceTint,
            shadowColor: colorScheme.shadow.withOpacity(0.1),
            child: InkWell(
              onTap: () {
                if (!_isEditing) {
                  setState(() => _isEditing = true);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with date, duration and actions
                    Row(
                      children: [
                        // Date and duration
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateFormat.format(widget.transcription.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.clock,
                                    size: 14,
                                    color: colorScheme.outline,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDuration(widget.transcription.audioDurationSeconds),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Action buttons
                        if (_isEditing) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.outlined(
                                onPressed: () {
                                  setState(() {
                                    _controller.text = widget.transcription.processedText;
                                    _hasChanges = false;
                                    _isEditing = false;
                                  });
                                },
                                icon: const Icon(LucideIcons.x, size: 18),
                                tooltip: 'Cancel (Esc)',
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(8),
                                  minimumSize: const Size(36, 36),
                                ),
                              ),
                              const SizedBox(width: 4),
                              FilledButton.icon(
                                onPressed: _saveChanges,
                                icon: const Icon(LucideIcons.check, size: 18),
                                label: const Text('Save'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.outlined(
                                onPressed: widget.onCopy,
                                icon: const Icon(LucideIcons.copy, size: 18),
                                tooltip: 'Copy to clipboard',
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(8),
                                  minimumSize: const Size(36, 36),
                                ),
                              ),
                              const SizedBox(width: 4),
                              PopupMenuButton<String>(
                                icon: Icon(
                                  LucideIcons.moreVertical,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant,
                                ),
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
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(LucideIcons.edit, size: 16),
                                        const SizedBox(width: 12),
                                        const Text('Edit'),
                                        const Spacer(),
                                        Text(
                                          'Enter',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          LucideIcons.trash2,
                                          size: 16,
                                          color: colorScheme.error,
                                        ),
                                        const SizedBox(width: 12),
                                        const Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: UIConstants.spacingSmall),

                    // Content
                    if (_isEditing) ...[
                      TextField(
                        controller: _controller,
                        autofocus: true,
                        maxLines: 5,
                        minLines: 2,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your transcription...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.primary),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _hasChanges = value != widget.transcription.processedText;
                          });
                        },
                        onSubmitted: (_) => _saveChanges(),
                      ),
                      if (_hasChanges) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.info,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Press Ctrl+S (Cmd+S) to save',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ] else ...[
                      Text(
                        _getPreviewText(_controller.text),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Footer with word count
                    if (!_isEditing) ...[
                      const SizedBox(height: UIConstants.spacingSmall),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.fileText,
                            size: 14,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.transcription.processedText.split(' ').length} words',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                          if (widget.transcription.tokenUsage != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              LucideIcons.zap,
                              size: 14,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.transcription.tokenUsage!.toString()} tokens',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}