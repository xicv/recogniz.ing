import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/models/transcription.dart';
import '../widgets/shared/app_bars.dart';

class FullscreenTranscriptionEdit extends ConsumerStatefulWidget {
  final Transcription transcription;
  final Function(String) onSave;

  const FullscreenTranscriptionEdit({
    super.key,
    required this.transcription,
    required this.onSave,
  });

  @override
  ConsumerState<FullscreenTranscriptionEdit> createState() => _FullscreenTranscriptionEditState();
}

class _FullscreenTranscriptionEditState extends ConsumerState<FullscreenTranscriptionEdit> {
  late TextEditingController _rawTextController;
  late TextEditingController _processedTextController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _rawTextController = TextEditingController(text: widget.transcription.rawText);
    _processedTextController = TextEditingController(text: widget.transcription.processedText);
  }

  @override
  void dispose() {
    _rawTextController.dispose();
    _processedTextController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasChanges = _rawTextController.text != widget.transcription.rawText ||
                      _processedTextController.text != widget.transcription.processedText;
    
    if (_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Edit Transcription'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => _handleClose(context),
        ),
        actions: [
          if (_hasChanges)
            TextButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(LucideIcons.save, size: 18),
              label: const Text('Save'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          tabs: const [
            Tab(text: 'Raw Text'),
            Tab(text: 'Processed Text'),
          ],
          labelColor: theme.colorScheme.primary,
          indicatorColor: theme.colorScheme.primary,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              children: [
                _buildTextEditor(
                  controller: _rawTextController,
                  hintText: 'Raw transcription text...',
                  onChanged: _onTextChanged,
                ),
                _buildTextEditor(
                  controller: _processedTextController,
                  hintText: 'Processed transcription text...',
                  onChanged: _onTextChanged,
                ),
              ],
            ),
          ),
          _buildBottomBar(theme),
        ],
      ),
    );
  }

  Widget _buildTextEditor({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.transcription.duration.inSeconds}s • ${widget.transcription.tokenUsed} tokens',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          if (_hasChanges) ...[
            TextButton(
              onPressed: () => _resetChanges(),
              child: const Text('Reset'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(LucideIcons.save, size: 18),
              label: const Text('Save Changes'),
            ),
          ],
        ],
      ),
    );
  }

  void _handleClose(BuildContext context) {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Discard'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveChanges();
              },
              child: const Text('Save & Exit'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _resetChanges() {
    setState(() {
      _rawTextController.text = widget.transcription.rawText;
      _processedTextController.text = widget.transcription.processedText;
      _hasChanges = false;
    });
  }

  void _saveChanges() {
    // Save both raw and processed text
    final updatedProcessedText = _processedTextController.text.isEmpty 
        ? _rawTextController.text 
        : _processedTextController.text;
    
    widget.onSave(updatedProcessedText);
    Navigator.of(context).pop();
  }
}
