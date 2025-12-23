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
        content:
            const Text('Are you sure you want to delete this transcription?'),
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

  void _openFullScreenEdit() {
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _TranscriptionEditModal(
            transcription: widget.transcription,
            onSave: (newText) {
              if (widget.onUpdate != null) {
                widget.onUpdate!(newText);
              }
              // Update the controller text
              _controller.text = newText;
              _hasChanges = false;
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
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
          const SingleActivator(LogicalKeyboardKey.keyS, control: true):
              _saveChanges,
        if (_isEditing && _hasChanges)
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
              _saveChanges,
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
                                dateFormat
                                    .format(widget.transcription.createdAt),
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
                                    _formatDuration(widget
                                        .transcription.audioDurationSeconds),
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
                                    _controller.text =
                                        widget.transcription.processedText;
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
                              _TranscriptionMenuButton(
                                iconColor: colorScheme.onSurfaceVariant,
                                errorColor: colorScheme.error,
                                onEdit: _openFullScreenEdit,
                                onCopy: widget.onCopy,
                                onDelete: () => _confirmDelete(context),
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
                          fillColor:
                              colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _hasChanges =
                                value != widget.transcription.processedText;
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

// Custom menu button without keyboard shortcut hints
class _TranscriptionMenuButton extends StatefulWidget {
  final Color iconColor;
  final Color errorColor;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _TranscriptionMenuButton({
    required this.iconColor,
    required this.errorColor,
    required this.onEdit,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  State<_TranscriptionMenuButton> createState() =>
      _TranscriptionMenuButtonState();
}

class _TranscriptionMenuButtonState extends State<_TranscriptionMenuButton> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _showMenu() {
    _overlayEntry = OverlayEntry(
      builder: (context) => _MenuOverlay(
        targetLink: _layerLink,
        onEdit: widget.onEdit,
        onCopy: widget.onCopy,
        onDelete: widget.onDelete,
        onClose: _hideMenu,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton.outlined(
        onPressed: () {
          if (_overlayEntry == null) {
            _showMenu();
          } else {
            _hideMenu();
          }
        },
        icon: const Icon(LucideIcons.moreVertical, size: 18),
        tooltip: 'More options',
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
        ),
      ),
    );
  }
}

class _MenuOverlay extends StatelessWidget {
  final LayerLink targetLink;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const _MenuOverlay({
    required this.targetLink,
    required this.onEdit,
    required this.onCopy,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TapRegion(
      onTapOutside: (_) => onClose(),
      child: CompositedTransformFollower(
        link: targetLink,
        offset: const Offset(-120, 40),
        targetAnchor: Alignment.topRight,
        followerAnchor: Alignment.topLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scaleX: value,
                scaleY: value,
                alignment: Alignment.topRight,
                child: child,
              ),
            );
          },
          child: _MenuContent(
            onEdit: onEdit,
            onCopy: onCopy,
            onDelete: onDelete,
            onClose: onClose,
          ),
        ),
      ),
    );
  }
}

class _MenuContent extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const _MenuContent({
    required this.onEdit,
    required this.onCopy,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.surface,
      child: Container(
        constraints: const BoxConstraints(minWidth: 160),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuItem(
              icon: LucideIcons.edit,
              label: 'Edit',
              onTap: () {
                onClose();
                onEdit();
              },
            ),
            _MenuItem(
              icon: LucideIcons.copy,
              label: 'Copy',
              onTap: () {
                onClose();
                onCopy();
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
            _MenuItem(
              icon: LucideIcons.trash2,
              label: 'Delete',
              textColor: colorScheme.error,
              onTap: () {
                onClose();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? textColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: textColor ?? colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor ?? colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Full-screen edit modal
class _TranscriptionEditModal extends StatefulWidget {
  final Transcription transcription;
  final Function(String) onSave;

  const _TranscriptionEditModal({
    required this.transcription,
    required this.onSave,
  });

  @override
  State<_TranscriptionEditModal> createState() =>
      _TranscriptionEditModalState();
}

class _TranscriptionEditModalState extends State<_TranscriptionEditModal> {
  late TextEditingController _controller;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.transcription.processedText);
    _controller.addListener(() {
      setState(() {
        _hasChanges = _controller.text != widget.transcription.processedText;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_hasChanges) {
      widget.onSave(_controller.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            _saveChanges,
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
            _saveChanges,
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.pop(context),
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: colorScheme.surfaceTint,
          leading: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close',
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Transcription'),
              Text(
                dateFormat.format(widget.transcription.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            if (_hasChanges)
              FilledButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(LucideIcons.check, size: 18),
                label: const Text('Save'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Word count and duration info
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 16,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatDuration(widget.transcription.audioDurationSeconds)} • ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      Icon(
                        LucideIcons.fileText,
                        size: 16,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_controller.text.split(' ').length} words',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      if (widget.transcription.tokenUsage != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          LucideIcons.zap,
                          size: 16,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.transcription.tokenUsage!.toString()} tokens',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Text editor
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type your transcription...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Save hint
                if (_hasChanges)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.keyboard,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Press Ctrl+S (Cmd+S) to save • Esc to cancel',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins}:${secs.toString().padLeft(2, '0')}';
  }
}
