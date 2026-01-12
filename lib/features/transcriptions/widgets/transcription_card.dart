import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/languages.dart';
import '../../../core/models/transcription.dart';
import '../../../core/models/transcription_status.dart';
import '../../../core/theme/app_theme.dart';

/// Enhanced transcription card with improved visual hierarchy
///
/// Design principles:
/// - Müller-Brockmann: Grid-aligned, information hierarchy through scale
/// - Dieter Rams: Content over chrome, honest metadata presentation
///
/// Key improvements:
/// - Three-tier visual hierarchy (100%, 80%, 60% opacity)
/// - Progressive action reveal (hover/focus)
/// - Card border accent for visual scanning
/// - Compact view mode option

class TranscriptionCard extends StatefulWidget {
  final Transcription transcription;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final Function(String)? onUpdate;
  final VoidCallback? onToggleFavorite;
  final Function(Transcription)? onRetry;
  final bool isSelected;
  final bool isCompact;

  const TranscriptionCard({
    super.key,
    required this.transcription,
    required this.onCopy,
    required this.onDelete,
    this.onUpdate,
    this.onToggleFavorite,
    this.onRetry,
    this.isSelected = false,
    this.isCompact = false,
  });

  @override
  State<TranscriptionCard> createState() => _TranscriptionCardState();
}

class _TranscriptionCardState extends State<TranscriptionCard>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  bool _isEditing = false;
  bool _hasChanges = false;
  bool _isHovered = false;
  bool _isStarred = false;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.transcription.processedText);
    _isStarred = widget.transcription.isFavorite ?? false;
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
    super.dispose();
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleStar() {
    setState(() {
      _isStarred = !_isStarred;
    });
    // Notify parent to persist the change
    widget.onToggleFavorite?.call();
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

  Color _getAccentColor(ColorScheme colorScheme) {
    // Status-based colors take priority
    final status = widget.transcription.status;
    if (status == TranscriptionStatus.failed) {
      return colorScheme.error;
    } else if (status == TranscriptionStatus.pending ||
        status == TranscriptionStatus.processing) {
      return colorScheme.tertiary;
    }

    // Time-based accent for completed transcriptions
    final now = DateTime.now();
    final difference = now.difference(widget.transcription.createdAt);

    if (difference.inHours < 1) {
      return colorScheme.primary; // Recent - primary
    } else if (difference.inDays < 1) {
      return colorScheme.secondary; // Today - secondary
    } else {
      return Colors.transparent; // Older - no accent
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y • h:mm a');
    final colorScheme = theme.colorScheme;
    final accentColor = _getAccentColor(colorScheme);

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
        onExit: (_) {
          // Don't clear hover state if menu is open
          if (!_isMenuOpen) {
            setState(() => _isHovered = false);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            color: _isHovered ? colorScheme.surfaceContainerHigh : null,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Card(
            margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
            elevation: 0,
            surfaceTintColor: colorScheme.surfaceTint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              side: accentColor != Colors.transparent
                  ? BorderSide(color: accentColor, width: 2)
                  : BorderSide(
                      color: colorScheme.outlineVariant.withValues(
                        alpha: _isHovered ? 0.5 : 0.3,
                      ),
                      width: 1,
                    ),
            ),
            child: InkWell(
              onTap: () {
                // Only allow editing completed transcriptions with content
                final canEdit = widget.transcription.status ==
                        TranscriptionStatus.completed &&
                    widget.transcription.processedText.isNotEmpty;
                if (!_isEditing && !widget.isCompact && canEdit) {
                  setState(() => _isEditing = true);
                }
              },
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              hoverColor: colorScheme.onSurface.withValues(alpha: 0.04),
              splashColor: colorScheme.onSurface.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.spacingMedium),
                child: widget.isCompact
                    ? _buildCompactContent(context, colorScheme, dateFormat)
                    : _buildFullContent(context, colorScheme, dateFormat),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullContent(
    BuildContext context,
    ColorScheme colorScheme,
    DateFormat dateFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge (for non-completed transcriptions)
        _buildStatusBadge(context, colorScheme),

        // Header with date, duration and actions
        _buildHeader(context, colorScheme, dateFormat),

        const SizedBox(height: UIConstants.spacingSmall),

        // Content or editing state
        if (_isEditing)
          _buildEditingContent(context, colorScheme)
        else
          _buildPreviewContent(context, colorScheme),

        // Footer metadata (non-editing mode only)
        if (!_isEditing) ...[
          const SizedBox(height: UIConstants.spacingSmall),
          _buildMetadataRow(context, colorScheme),
        ],
      ],
    );
  }

  Widget _buildCompactContent(
    BuildContext context,
    ColorScheme colorScheme,
    DateFormat dateFormat,
  ) {
    final preview = _getPreviewText(_controller.text);
    final lines = _controller.text.split('\n');
    final hasMoreContent = lines.length > 1 || preview.length > 80;

    return Row(
      children: [
        // Star indicator
        GestureDetector(
          onTap: _toggleStar,
          child: Icon(
            _isStarred ? LucideIcons.star : LucideIcons.star,
            size: 16,
            color: _isStarred
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),

        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preview,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                dateFormat.format(widget.transcription.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),

        // More content indicator
        if (hasMoreContent)
          Icon(
            LucideIcons.chevronRight,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),

        const SizedBox(width: 4),

        // Quick actions
        _buildQuickActions(context, colorScheme, compact: true),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    DateFormat dateFormat,
  ) {
    return Row(
      children: [
        // Date and duration
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(widget.transcription.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 13,
                    color: colorScheme.outline.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(widget.transcription.audioDurationSeconds),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Actions - Progressive reveal on hover
        if (_isEditing)
          _buildEditActions(context, colorScheme)
        else
          _buildViewActions(context, colorScheme),
      ],
    );
  }

  Widget _buildViewActions(BuildContext context, ColorScheme colorScheme) {
    // Show fewer actions by default, reveal all on hover or when menu is open
    final showAll = _isHovered || _isMenuOpen;
    final status = widget.transcription.status;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Retry button for failed transcriptions (always visible)
        if (status == TranscriptionStatus.failed && widget.onRetry != null)
          FilledButton.icon(
            onPressed: () => widget.onRetry!(widget.transcription),
            icon: const Icon(LucideIcons.refreshCw, size: 14),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
            ),
          ),

        // Processing indicator (instead of actions)
        if (status == TranscriptionStatus.processing)
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(colorScheme.tertiary),
              ),
            ),
          ),

        // Normal actions for completed/pending transcriptions
        if (status != TranscriptionStatus.processing) ...[
          // Star toggle (always visible, hide for failed)
          if (status != TranscriptionStatus.failed)
            IconButton.outlined(
              onPressed: _toggleStar,
              icon: Icon(
                _isStarred ? LucideIcons.star : LucideIcons.star,
                size: 16,
              ),
              color: _isStarred
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              tooltip: _isStarred ? 'Unfavorite' : 'Favorite',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(UIConstants.touchTargetMinimum,
                    UIConstants.touchTargetMinimum),
                side: BorderSide.none,
              ),
            ),

          // Copy (always visible, hide for failed)
          if (status != TranscriptionStatus.failed)
            IconButton.outlined(
              onPressed: widget.onCopy,
              icon: const Icon(LucideIcons.copy, size: 16),
              tooltip: 'Copy to clipboard',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(UIConstants.touchTargetMinimum,
                    UIConstants.touchTargetMinimum),
                side: BorderSide.none,
              ),
            ),

          // Edit and more (show on hover or when menu is open, hide for failed/pending)
          if (showAll && status == TranscriptionStatus.completed) ...[
            IconButton.outlined(
              onPressed: _openFullScreenEdit,
              icon: const Icon(LucideIcons.edit, size: 16),
              tooltip: 'Edit',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(UIConstants.touchTargetMinimum,
                    UIConstants.touchTargetMinimum),
                side: BorderSide.none,
              ),
            ),
            _TranscriptionMenuButton(
              iconColor: colorScheme.onSurfaceVariant,
              errorColor: colorScheme.error,
              onEdit: _openFullScreenEdit,
              onCopy: widget.onCopy,
              onDelete: () => _confirmDelete(context),
              onMenuOpen: () => setState(() => _isMenuOpen = true),
              onMenuClose: () => setState(() => _isMenuOpen = false),
            ),
          ],

          // Delete only for failed/pending
          if (showAll &&
              status != TranscriptionStatus.completed &&
              status != TranscriptionStatus.processing)
            IconButton.outlined(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(LucideIcons.trash2, size: 16),
              tooltip: 'Delete',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(UIConstants.touchTargetMinimum,
                    UIConstants.touchTargetMinimum),
                side: BorderSide.none,
                foregroundColor: colorScheme.error,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildEditActions(BuildContext context, ColorScheme colorScheme) {
    return Row(
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
          icon: const Icon(LucideIcons.x, size: 16),
          tooltip: 'Cancel (Esc)',
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(
                UIConstants.touchTargetMinimum, UIConstants.touchTargetMinimum),
          ),
        ),
        const SizedBox(width: 4),
        FilledButton.icon(
          onPressed: _saveChanges,
          icon: const Icon(LucideIcons.check, size: 16),
          label: const Text('Save'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    ColorScheme colorScheme, {
    bool compact = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (compact)
          IconButton.outlined(
            onPressed: widget.onCopy,
            icon: const Icon(LucideIcons.copy, size: 14),
            tooltip: 'Copy',
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(UIConstants.touchTargetCompact,
                  UIConstants.touchTargetCompact),
            ),
          )
        else
          IconButton.outlined(
            onPressed: widget.onCopy,
            icon: const Icon(LucideIcons.copy, size: 16),
            tooltip: 'Copy to clipboard',
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(UIConstants.touchTargetMinimum,
                  UIConstants.touchTargetMinimum),
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
    );
  }

  Widget _buildPreviewContent(BuildContext context, ColorScheme colorScheme) {
    final status = widget.transcription.status;
    final text = _controller.text;

    // Show placeholder for pending/failed transcriptions
    if (text.isEmpty &&
        (status == TranscriptionStatus.pending ||
            status == TranscriptionStatus.failed)) {
      return Text(
        status == TranscriptionStatus.pending
            ? 'Waiting to process...'
            : 'Transcription failed. Tap Retry to try again.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final preview = _getPreviewText(text);

    return Text(
      preview,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEditingContent(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
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
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                size: 13,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Press Ctrl+S (Cmd+S) to save',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataRow(BuildContext context, ColorScheme colorScheme) {
    final wordCount = widget.transcription.processedText
        .split(' ')
        .where((w) => w.isNotEmpty)
        .length;

    return Wrap(
      spacing: 12,
      children: [
        // Word count
        _MetadataItem(
          icon: LucideIcons.fileText,
          label: '$wordCount words',
          color: colorScheme.outline,
        ),

        // Token usage
        _MetadataItem(
          icon: LucideIcons.zap,
          label: '${widget.transcription.tokenUsage} tokens',
          color: colorScheme.outline,
        ),

        // Duration
        _MetadataItem(
          icon: LucideIcons.clock,
          label: _formatDuration(widget.transcription.audioDurationSeconds),
          color: colorScheme.outline,
        ),

        // Detected language (if available)
        if (widget.transcription.detectedLanguage != null)
          _MetadataItem(
            icon: LucideIcons.languages,
            label: TranscriptionLanguages.getDisplayName(
              widget.transcription.detectedLanguage,
            ),
            color: colorScheme.outline,
          ),
      ],
    );
  }

  String _formatDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusBadge(BuildContext context, ColorScheme colorScheme) {
    final status = widget.transcription.status;
    if (status == TranscriptionStatus.completed) {
      return const SizedBox.shrink();
    }

    IconData icon;
    String label;
    Color backgroundColor;
    Color iconColor;
    Color textColor;

    switch (status) {
      case TranscriptionStatus.pending:
        icon = LucideIcons.clock;
        label = 'Pending';
        backgroundColor = colorScheme.tertiaryContainer;
        iconColor = colorScheme.onTertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        break;
      case TranscriptionStatus.processing:
        icon = LucideIcons.loader;
        label = 'Processing';
        backgroundColor = colorScheme.tertiaryContainer;
        iconColor = colorScheme.onTertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        break;
      case TranscriptionStatus.failed:
        icon = LucideIcons.alertCircle;
        label = widget.transcription.errorMessage ?? 'Failed';
        backgroundColor = colorScheme.errorContainer;
        iconColor = colorScheme.onErrorContainer;
        textColor = colorScheme.onErrorContainer;
        break;
      case TranscriptionStatus.completed:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == TranscriptionStatus.processing)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(iconColor),
              ),
            )
          else
            Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getPreviewText(String text) {
    final lines = text.split('\n');
    final preview =
        lines.firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    return preview.length > 120 ? '${preview.substring(0, 120)}...' : preview;
  }

  ThemeData get theme => Theme.of(context);
}

// ============================================================
// METADATA ITEM WIDGET
// ============================================================

class _MetadataItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetadataItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: color.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MENU BUTTON ()
// ============================================================

class _TranscriptionMenuButton extends StatefulWidget {
  final Color iconColor;
  final Color errorColor;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback? onMenuOpen;
  final VoidCallback? onMenuClose;

  const _TranscriptionMenuButton({
    required this.iconColor,
    required this.errorColor,
    required this.onEdit,
    required this.onCopy,
    required this.onDelete,
    this.onMenuOpen,
    this.onMenuClose,
  });

  @override
  State<_TranscriptionMenuButton> createState() =>
      _TranscriptionMenuButtonState();
}

class _TranscriptionMenuButtonState extends State<_TranscriptionMenuButton> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _showMenu() {
    widget.onMenuOpen?.call();
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
    widget.onMenuClose?.call();
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
        icon: const Icon(LucideIcons.moreVertical, size: 16),
        tooltip: 'More options',
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(
              UIConstants.touchTargetMinimum, UIConstants.touchTargetMinimum),
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
    return TapRegion(
      onTapOutside: (_) => onClose(),
      child: CompositedTransformFollower(
        link: targetLink,
        offset: const Offset(-140, 40),
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
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuItem(
              icon: LucideIcons.edit,
              label: 'Edit full',
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
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
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

// ============================================================
// FULL-SCREEN EDIT MODAL ()
// ============================================================

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
                // Info bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                        '${_controller.text.split(' ').where((w) => w.isNotEmpty).length} words',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        LucideIcons.zap,
                        size: 16,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.transcription.tokenUsage} tokens',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
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
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                      color: colorScheme.primaryContainer.withValues(alpha: 0.5),
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
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
