import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/models/transcription.dart';

class ModernTranscriptionTile extends StatefulWidget {
  final Transcription transcription;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final Function(String)? onUpdate;

  const ModernTranscriptionTile({
    super.key,
    required this.transcription,
    required this.onCopy,
    required this.onDelete,
    this.onUpdate,
  });

  @override
  State<ModernTranscriptionTile> createState() =>
      _ModernTranscriptionTileState();
}

class _ModernTranscriptionTileState extends State<ModernTranscriptionTile>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  bool _isEditing = false;
  bool _hasChanges = false;
  late AnimationController _animationController;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.transcription.processedText);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ModernTranscriptionTile oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final now = DateTime.now();
          if (_lastTapTime != null &&
              now.difference(_lastTapTime!).inMilliseconds < 500) {
            // Double tap detected
            _startEditing();
            _lastTapTime = null; // Reset to prevent triple-tap
          } else {
            _lastTapTime = now;
            // Single tap - show details after a delay if no second tap
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_lastTapTime == now) {
                _showDetails(context);
              }
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and actions
              Row(
                children: [
                  // Date chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingSmall,
                      vertical: UIConstants.spacingXXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(UIConstants.borderRadiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 14,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(widget.transcription.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Duration indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingSmall,
                      vertical: UIConstants.spacingXXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius:
                          BorderRadius.circular(UIConstants.borderRadiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(
                              widget.transcription.audioDurationSeconds),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingSmall),
                  // Copy button
                  IconButton(
                    onPressed: widget.onCopy,
                    icon: Icon(
                      LucideIcons.copy,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Copy',
                    visualDensity: VisualDensity.compact,
                  ),
                  // More options
                  PopupMenuButton<String>(
                    icon: Icon(
                      LucideIcons.moreVertical,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _startEditing();
                          break;
                        case 'copy':
                          widget.onCopy();
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
                            const SizedBox(width: 8),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            Icon(LucideIcons.copy, size: 16),
                            const SizedBox(width: 8),
                            const Text('Copy'),
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
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: UIConstants.spacingMedium),

              // Text content with preview
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: _isEditing
                    ? TextField(
                        controller: _controller,
                        maxLines: null,
                        minLines: 3,
                        autofocus: true,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Edit transcription...',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.outline.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor:
                              theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                UIConstants.borderRadiusMedium),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                UIConstants.borderRadiusMedium),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.all(UIConstants.spacingMedium),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _hasChanges =
                                value != widget.transcription.processedText;
                          });
                        },
                        onTapOutside: (_) {
                          if (_hasChanges) {
                            _saveChanges();
                          } else {
                            setState(() {
                              _isEditing = false;
                            });
                          }
                        },
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPreviewText(_controller.text),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_controller.text.length > 200) ...[
                            const SizedBox(height: UIConstants.spacingXSmall),
                            Text(
                              'Tap to view full transcription',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),

              // Action buttons when editing
              if (_isEditing && _hasChanges) ...[
                const SizedBox(height: UIConstants.spacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _controller.text = widget.transcription.processedText;
                          _hasChanges = false;
                          _isEditing = false;
                        });
                      },
                      icon: const Icon(LucideIcons.x, size: 16),
                      label: const Text('Cancel'),
                    ),
                    const SizedBox(width: UIConstants.spacingSmall),
                    FilledButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(LucideIcons.save, size: 16),
                      label: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    if (seconds < 60) {
      return '${seconds.round()}s';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes}m ${remainingSeconds.round()}s';
    }
  }

  String _getPreviewText(String text) {
    final lines = text.split('\n');
    if (lines.isEmpty) return '';

    // Return first line or first two sentences if very long
    if (lines.first.length <= 200) {
      return lines.first;
    }

    // Try to break at sentence boundary
    final sentences = lines.first.split(RegExp(r'[.!?]+\s+'));
    String preview = '';
    for (final sentence in sentences) {
      if (preview.length + sentence.length <= 200) {
        preview += (preview.isEmpty ? '' : '. ') + sentence;
      } else {
        break;
      }
    }

    return preview.isEmpty ? lines.first.substring(0, 200) : preview;
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
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
      SnackBar(
        content: const Text('Transcription saved'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          LucideIcons.alertTriangle,
          color: Theme.of(context).colorScheme.error,
          size: 24,
        ),
        title: const Text('Delete Transcription?'),
        content: const Text('This transcription will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transcription deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _TranscriptionDetailsPage(
          transcription: widget.transcription,
          onEdit:
              widget.onUpdate != null ? (text) => widget.onUpdate!(text) : null,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        barrierDismissible: true,
        barrierColor: Colors.black54,
        fullscreenDialog: true,
      ),
    );
  }
}

class _TranscriptionDetailsPage extends StatelessWidget {
  final Transcription transcription;
  final Function(String)? onEdit;

  const _TranscriptionDetailsPage({
    required this.transcription,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        title: const Text('Transcription Details'),
        actions: [
          if (onEdit != null)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Trigger edit mode
                // This would need to be implemented
              },
              icon: const Icon(LucideIcons.edit),
              tooltip: 'Edit',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      LucideIcons.calendar,
                      'Date',
                      DateFormat('EEEE, MMMM d, yyyy')
                          .format(transcription.createdAt),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      LucideIcons.clock,
                      'Time',
                      DateFormat('h:mm a').format(transcription.createdAt),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      LucideIcons.timer,
                      'Duration',
                      _formatDuration(transcription.audioDurationSeconds),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      LucideIcons.zap,
                      'Tokens Used',
                      '${transcription.tokenUsage}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Processed text
            _buildTextSection(
              context,
              'Processed Text',
              transcription.processedText,
              canEdit: onEdit != null,
            ),

            const SizedBox(height: 16),

            // Raw text
            _buildTextSection(
              context,
              'Raw Transcription',
              transcription.rawText,
              canEdit: false,
            ),

            const SizedBox(height: 100), // Extra padding at bottom
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection(
    BuildContext context,
    String title,
    String content, {
    bool canEdit = false,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.copy, size: 16),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes}m ${remainingSeconds}s';
  }
}
