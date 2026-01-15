import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/languages.dart';
import 'widgets/critical_instructions_editor.dart';
import 'widgets/hotkey_editor.dart';
import 'widgets/settings_section.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

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
            // API Configuration
            SettingsSection(
              title: 'API Configuration',
              icon: LucideIcons.key,
              children: [
                _buildApiKeyField(context, ref, settings.geminiApiKey),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

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
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatHotkeyForDisplay(settings.globalHotkey),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.bookOpen,
                      color: AppColors.primary,
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.messageSquare,
                      color: AppColors.primary,
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.languages,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () => _showLanguageSelector(context),
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
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyField(
      BuildContext context, WidgetRef ref, String? currentKey) {
    final controller = TextEditingController(text: currentKey ?? '');
    final isObscured = ValueNotifier(true);
    final isValidating = ValueNotifier(false);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gemini API Key',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your API key is stored locally and never shared.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: isObscured,
            builder: (context, obscured, child) {
              return ValueListenableBuilder(
                valueListenable: isValidating,
                builder: (context, validating, child) {
                  return TextField(
                    controller: controller,
                    obscureText: obscured,
                    enabled: !validating,
                    decoration: InputDecoration(
                      hintText: 'Enter your API key',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              obscured ? LucideIcons.eye : LucideIcons.eyeOff,
                            ),
                            onPressed: () {
                              isObscured.value = !obscured;
                            },
                          ),
                          IconButton(
                            icon: validating
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Icon(LucideIcons.check),
                            onPressed: validating
                                ? null
                                : () async {
                                    isValidating.value = true;
                                    final trimmedKey = controller.text.trim();

                                    try {
                                      // Use provider to get GeminiService for validation
                                      final geminiService =
                                          ref.read(geminiServiceProvider);
                                      final (isValid, error) =
                                          await geminiService
                                              .validateApiKey(trimmedKey);

                                      if (isValid) {
                                        await ref
                                            .read(settingsProvider.notifier)
                                            .updateApiKey(trimmedKey);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'API key saved successfully'),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  error ?? 'Invalid API key'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (trimmedKey.startsWith('AIza') &&
                                          trimmedKey.length > 30) {
                                        await ref
                                            .read(settingsProvider.notifier)
                                            .updateApiKey(trimmedKey);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('API key saved'),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Error: ${e.toString()}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } finally {
                                      isValidating.value = false;
                                    }
                                  },
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  );
                },
              );
            },
          ),
        ],
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.languages,
                    color: AppColors.primary,
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
                      color: isSelected ? AppColors.primary : colorScheme.outline,
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
