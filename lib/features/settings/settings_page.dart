import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/accessibility_permission_providers.dart';
import '../../core/constants/languages.dart';
import '../../core/models/app_settings.dart';
import '../../widgets/shared/accessibility_permission_prompt.dart';
import 'widgets/critical_instructions_editor.dart';
import 'widgets/hotkey_editor.dart';
import 'widgets/settings_section.dart';
import 'widgets/api_keys_manager.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accessibility Permission Prompt (macOS only)
            if (Platform.isMacOS)
              const AccessibilityPermissionPrompt()
                  .animate()
                  .fadeIn(duration: 300.ms),

            if (Platform.isMacOS) const SizedBox(height: 20),

            // API Configuration
            SettingsSection(
              title: 'API Keys',
              icon: LucideIcons.key,
              children: [
                const ApiKeysManager(),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

            const SizedBox(height: 20),

            // Model Selection
            SettingsSection(
              title: 'AI Model',
              icon: LucideIcons.cpu,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gemini Model',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getModelDescription(settings.selectedModel),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _availableModels.containsKey(settings.selectedModel)
                            ? settings.selectedModel
                            : 'gemini-3-flash-preview',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: _availableModels.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(settingsProvider.notifier).updateModel(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 120.ms),

            const SizedBox(height: 20),

            // Hotkey Settings - Desktop only
            if (Platform.isMacOS || Platform.isWindows || Platform.isLinux)
              SettingsSection(
                title: 'Hotkey',
                icon: LucideIcons.keyboard,
                children: [
                  ListTile(
                    title: const Text('Global Hotkey'),
                    subtitle: Text(
                      'Press to start/stop recording',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatHotkeyForDisplay(settings.globalHotkey),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                  letterSpacing: Platform.isMacOS ? 2 : 0,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.chevronRight, size: 18),
                      ],
                    ),
                    onTap: () => _showHotkeyEditor(context),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

            const SizedBox(height: 20),

            // Quick Access to Dictionaries and Prompts
            SettingsSection(
              title: 'Quick Access',
              icon: LucideIcons.layers,
              children: [
                ListTile(
                  title: const Text('Dictionaries'),
                  subtitle: Text(
                    'Manage custom vocabulary sets',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.bookOpen,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () {
                    ref.read(currentPageProvider.notifier).state =
                        2; // Dictionaries
                  },
                ),
                ListTile(
                  title: const Text('Prompts'),
                  subtitle: Text(
                    'Manage custom AI prompts',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.messageSquare,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () {
                    ref.read(currentPageProvider.notifier).state = 3; // Prompts
                  },
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

            const SizedBox(height: 20),

            // Critical Instructions
            const CriticalInstructionsEditor()
                .animate()
                .fadeIn(duration: 300.ms, delay: 250.ms),

            const SizedBox(height: 20),

            // Preferences
            SettingsSection(
              title: 'Preferences',
              icon: LucideIcons.sliders,
              children: [
                SwitchListTile(
                  title: const Text('Auto-copy to Clipboard'),
                  subtitle: const Text('Copy result automatically'),
                  value: settings.autoCopyToClipboard,
                  onChanged: (value) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      ref.read(settingsProvider.notifier).toggleAutoCopy();
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Show Notifications'),
                  subtitle: const Text('Notify when complete'),
                  value: settings.showNotifications,
                  onChanged: (value) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      ref.read(settingsProvider.notifier).toggleNotifications();
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: settings.darkMode,
                  onChanged: (value) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      ref.read(settingsProvider.notifier).toggleDarkMode();
                    });
                  },
                ),
                // Start at Login - Desktop only
                if (Platform.isMacOS || Platform.isWindows || Platform.isLinux)
                  SwitchListTile(
                    title: const Text('Start at Login'),
                    subtitle: Text(settings.startAtLogin
                        ? 'App will launch automatically on login'
                        : 'Launch app manually'),
                    value: settings.startAtLogin,
                    onChanged: (value) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(settingsProvider.notifier)
                            .toggleStartAtLogin();
                      });
                    },
                  ),
                ListTile(
                  title: const Text('Transcription Language'),
                  subtitle: Text(
                    _getLanguageDisplayName(settings.transcriptionLanguage),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.languages,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () => _showLanguageSelector(context),
                ),
                // Audio Compression Preference
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              LucideIcons.fileAudio,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Audio Format',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  _getCompressionDescription(
                                      settings.audioCompressionPreference),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // SegmentedButton for format selection
                      SegmentedButton<AudioCompressionPreference>(
                        segments: const [
                          ButtonSegment(
                            value: AudioCompressionPreference.auto,
                            label: Text('Auto'),
                            icon: Icon(LucideIcons.wand2, size: 16),
                          ),
                          ButtonSegment(
                            value: AudioCompressionPreference.alwaysCompressed,
                            label: Text('Compact'),
                            icon: Icon(LucideIcons.file, size: 16),
                          ),
                          ButtonSegment(
                            value: AudioCompressionPreference.uncompressed,
                            label: Text('Full'),
                            icon: Icon(LucideIcons.hardDrive, size: 16),
                          ),
                        ],
                        selected: {settings.audioCompressionPreference},
                        onSelectionChanged:
                            (Set<AudioCompressionPreference> selection) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(settingsProvider.notifier)
                                .updateCompressionPreference(
                                  selection.first,
                                );
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return colorScheme.primary.withValues(alpha: 0.15);
                            }
                            return null;
                          }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return colorScheme.primary;
                            }
                            return null;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _formatHotkeyForDisplay(String hotkey) {
    if (hotkey.isEmpty) return 'Not set';

    final parts = hotkey.split('+');
    final formatted = parts.map((part) {
      switch (part.toLowerCase()) {
        case 'cmd':
          return Platform.isMacOS ? '⌘' : 'Ctrl';
        case 'ctrl':
          return 'Ctrl';
        case 'shift':
          return 'Shift';
        case 'alt':
          return Platform.isMacOS ? '⌥' : 'Alt';
        case 'space':
          return 'Space';
        default:
          return part.toUpperCase();
      }
    }).join(' + ');

    return formatted;
  }

  void _showHotkeyEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HotkeyEditorDialog(),
    );
  }

  String _getLanguageDisplayName(String code) {
    final language = TranscriptionLanguages.findByCode(code);
    if (language != null) {
      return language.isAuto ? 'Auto Detect' : language.nativeName;
    }
    return 'Auto Detect';
  }

  static const _availableModels = {
    'gemini-3-flash-preview': 'Gemini 3 Flash (Default)',
    'gemini-3.1-flash-lite-preview': 'Gemini 3.1 Flash Lite (Faster)',
    'gemini-2.5-flash-preview-05-20': 'Gemini 2.5 Flash',
  };

  String _getModelDescription(String model) {
    switch (model) {
      case 'gemini-3-flash-preview':
        return 'Balanced speed and quality';
      case 'gemini-3.1-flash-lite-preview':
        return '2.5x faster, 50% cheaper, great for voice';
      case 'gemini-2.5-flash-preview-05-20':
        return 'Previous generation, stable';
      default:
        return model;
    }
  }

  String _getCompressionDescription(AudioCompressionPreference preference) {
    switch (preference) {
      case AudioCompressionPreference.auto:
        return 'Smart format based on recording length';
      case AudioCompressionPreference.alwaysCompressed:
        return 'Smaller files, may lose 0.5-2s at end';
      case AudioCompressionPreference.uncompressed:
        return 'Larger files, no audio loss';
    }
  }

  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }
}

/// Language selector dialog
class LanguageSelectorDialog extends ConsumerWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final selectedCode = settings.transcriptionLanguage;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.languages,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Transcription Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Language list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: TranscriptionLanguages.all.length,
                itemBuilder: (context, index) {
                  final language = TranscriptionLanguages.all[index];
                  final isSelected = language.code == selectedCode;

                  return ListTile(
                    title: Text(
                      language.isAuto ? 'Auto Detect' : language.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: language.isAuto
                        ? Text(
                            'Automatically detect the language spoken',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : Text(
                            language.nativeName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                    leading: Icon(
                      isSelected ? LucideIcons.check : LucideIcons.circle,
                      size: 20,
                      color:
                          isSelected ? colorScheme.primary : colorScheme.outline,
                    ),
                    selected: isSelected,
                    onTap: () {
                      ref
                          .read(settingsProvider.notifier)
                          .updateTranscriptionLanguage(language.code);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
