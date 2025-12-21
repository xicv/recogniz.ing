import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'settings_section.dart';

class CriticalInstructionsEditor extends ConsumerStatefulWidget {
  const CriticalInstructionsEditor({super.key});

  @override
  ConsumerState<CriticalInstructionsEditor> createState() =>
      _CriticalInstructionsEditorState();
}

class _CriticalInstructionsEditorState
    extends ConsumerState<CriticalInstructionsEditor> {
  late TextEditingController _controller;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _controller = TextEditingController(
        text: settings.criticalInstructions ??
            settings.effectiveCriticalInstructions);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final settings = ref.read(settingsProvider);
    final hasChanges = _controller.text !=
        (settings.criticalInstructions ??
            settings.effectiveCriticalInstructions);
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Critical Instructions',
      icon: LucideIcons.shield,
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These instructions control how Gemini transcribes audio',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Stricter instructions reduce API costs but may miss quiet speech\n'
                '• Lenient instructions capture more but may include false positives\n'
                '• Changes apply to new recordings only',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Editor
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: _controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Enter critical instructions...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ),
        const SizedBox(height: 12),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showPresets,
                icon: const Icon(LucideIcons.list, size: 16),
                label: const Text('Presets'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetToDefault,
                icon: const Icon(LucideIcons.rotateCcw, size: 16),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _hasChanges ? _saveChanges : null,
                icon: const Icon(LucideIcons.save, size: 16),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasChanges ? AppColors.primary : null,
                  foregroundColor: _hasChanges ? Colors.white : null,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPresets() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instruction Presets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPresetOption(
              context,
              title: 'Strict',
              description: 'Only transcribe clear speech',
              instructions: '''CRITICAL INSTRUCTIONS:
- Only transcribe clear, audible speech
- Reject any recording with background noise or unclear audio
- If audio quality is poor, respond with exactly: [NO_SPEECH]
- Do NOT transcribe anything other than clear human speech''',
            ),
            const SizedBox(height: 12),
            _buildPresetOption(
              context,
              title: 'Balanced',
              description: 'Default settings',
              instructions: '''CRITICAL INSTRUCTIONS:
- Only transcribe actual speech that you hear in the audio
- If the audio contains only silence, background noise, or no discernible speech, respond with exactly: [NO_SPEECH]
- Do NOT transcribe the vocabulary list or any text that is not spoken in the audio
- The vocabulary below is for reference ONLY - do not use it to generate fake transcriptions''',
            ),
            const SizedBox(height: 12),
            _buildPresetOption(
              context,
              title: 'Lenient',
              description: 'Transcribe as much as possible',
              instructions: '''CRITICAL INSTRUCTIONS:
- Transcribe any audible speech or words you can identify
- Even if audio is quiet or has background noise, try to transcribe
- Only respond with [NO_SPEECH] if there is absolutely no discernible speech
- Best effort transcription preferred over rejection''',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetOption(
    BuildContext context, {
    required String title,
    required String description,
    required String instructions,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      onTap: () {
        Navigator.pop(context);
        _applyPreset(title, instructions);
      },
      trailing: const Icon(LucideIcons.chevronRight),
    );
  }

  void _applyPreset(String title, String instructions) {
    setState(() {
      _controller.text = instructions;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied "$title" preset'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetToDefault() {
    final defaultInstructions = '''CRITICAL INSTRUCTIONS:
- Only transcribe actual speech that you hear in the audio
- If the audio contains only silence, background noise, or no discernible speech, respond with exactly: [NO_SPEECH]
- Do NOT transcribe the vocabulary list or any text that is not spoken in the audio
- The vocabulary below is for reference ONLY - do not use it to generate fake transcriptions''';

    setState(() {
      _controller.text = defaultInstructions;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to default instructions'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveChanges() {
    _showSaveConfirmation();
  }

  void _showSaveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Critical Instructions?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to save these changes?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Warning: Custom instructions may cause unexpected behavior:\n'
              '• Too strict: Might miss valid speech\n'
              '• Too lenient: Might transcribe noise as speech\n'
              '• Invalid format: May cause API errors',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _doSave();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.warning),
            child: const Text('Save Anyway'),
          ),
        ],
      ),
    );
  }

  void _doSave() async {
    try {
      await ref.read(settingsProvider.notifier).updateCriticalInstructions(
            _controller.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Critical instructions saved'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
