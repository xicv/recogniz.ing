import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class HotkeyEditorDialog extends ConsumerStatefulWidget {
  const HotkeyEditorDialog({super.key});

  @override
  ConsumerState<HotkeyEditorDialog> createState() => _HotkeyEditorDialogState();
}

class _HotkeyEditorDialogState extends ConsumerState<HotkeyEditorDialog> {
  final FocusNode _focusNode = FocusNode();
  final Set<LogicalKeyboardKey> _pressedModifiers = {};
  LogicalKeyboardKey? _mainKey;
  String? _recordedHotkey;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _recordedHotkey = ref.read(settingsProvider).globalHotkey;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _pressedModifiers.clear();
      _mainKey = null;
    });
    _focusNode.requestFocus();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!_isRecording) return;

    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      if (_isModifierKey(key)) {
        setState(() {
          _pressedModifiers.add(key);
        });
      } else {
        // Got a main key (with or without modifiers)
        setState(() {
          _mainKey = key;
          _recordedHotkey = _buildHotkeyString();
          _isRecording = false;
        });
      }
    }
  }

  bool _isModifierKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight;
  }

  String _buildHotkeyString() {
    final parts = <String>[];

    final hasCtrl =
        _pressedModifiers.contains(LogicalKeyboardKey.controlLeft) ||
            _pressedModifiers.contains(LogicalKeyboardKey.controlRight);
    final hasCmd = _pressedModifiers.contains(LogicalKeyboardKey.metaLeft) ||
        _pressedModifiers.contains(LogicalKeyboardKey.metaRight);
    final hasShift = _pressedModifiers.contains(LogicalKeyboardKey.shiftLeft) ||
        _pressedModifiers.contains(LogicalKeyboardKey.shiftRight);
    final hasAlt = _pressedModifiers.contains(LogicalKeyboardKey.altLeft) ||
        _pressedModifiers.contains(LogicalKeyboardKey.altRight);

    if (hasCtrl) parts.add('Ctrl');
    if (hasCmd) parts.add('Cmd');
    if (hasShift) parts.add('Shift');
    if (hasAlt) parts.add('Alt');

    if (_mainKey != null) {
      parts.add(_mainKey!.keyLabel);
    }

    return parts.join('+');
  }

  String _formatForDisplay(String hotkey) {
    if (!Platform.isMacOS) return hotkey;

    return hotkey
        .replaceAll('Ctrl+', '⌃')
        .replaceAll('Cmd+', '⌘')
        .replaceAll('Shift+', '⇧')
        .replaceAll('Alt+', '⌥')
        .replaceAll('+', '');
  }

  void _saveHotkey() async {
    if (_recordedHotkey != null && _recordedHotkey!.isNotEmpty) {
      // Save to settings
      await ref.read(settingsProvider.notifier).updateHotkey(_recordedHotkey!);

      // Note: The hotkey will be automatically re-registered
      // when the settings change are observed in main.dart

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHotkey = ref.watch(settingsProvider).globalHotkey;

    return AlertDialog(
      title: const Text('Set Global Hotkey'),
      content: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Press a key combination to set as the global hotkey for starting/stopping recording.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Current hotkey display
            GestureDetector(
              onTap: _startRecording,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isRecording
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        _isRecording ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    if (_isRecording) ...[
                      Icon(LucideIcons.keyboard,
                          size: 32, color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text(
                        _pressedModifiers.isNotEmpty
                            ? '${_buildHotkeyString()}...'
                            : 'Press key combination...',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                ),
                      ),
                    ] else ...[
                      Text(
                        _formatForDisplay(_recordedHotkey ?? currentHotkey),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: Platform.isMacOS ? 4 : 0,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Click to record button
            if (!_isRecording)
              TextButton.icon(
                onPressed: _startRecording,
                icon: const Icon(LucideIcons.edit3, size: 16),
                label: const Text('Click to record new hotkey'),
              ),

            const SizedBox(height: 8),

            // Preset hotkeys
            Text(
              'Or choose a preset:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip('Ctrl+Shift+R'),
                _buildPresetChip('Cmd+Shift+R'),
                _buildPresetChip('Ctrl+Space'),
                _buildPresetChip('F9'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _recordedHotkey != null ? _saveHotkey : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String hotkey) {
    final isSelected = _recordedHotkey == hotkey;
    return ActionChip(
      label: Text(_formatForDisplay(hotkey)),
      backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.2) : null,
      onPressed: () {
        setState(() {
          _recordedHotkey = hotkey;
          _isRecording = false;
        });
      },
    );
  }
}
