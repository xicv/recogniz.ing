import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/gemini_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/app_settings.dart';
import '../../core/constants/app_constants.dart';
import 'widgets/critical_instructions_editor.dart';
import 'widgets/hotkey_editor.dart';
import 'widgets/settings_section.dart';

class SettingsPageRefactored extends ConsumerStatefulWidget {
  const SettingsPageRefactored({super.key});

  @override
  ConsumerState<SettingsPageRefactored> createState() => _SettingsPageRefactoredState();
}

class _SettingsPageRefactoredState extends ConsumerState<SettingsPageRefactored> {
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

            // Hotkey Settings
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
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatHotkeyForDisplay(settings.globalHotkey),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      color: AppColors.primary.withOpacity(0.1),
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
                    ref.read(currentPageProvider.notifier).state = 2; // Dictionaries
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
                      color: AppColors.primary.withOpacity(0.1),
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
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

            const SizedBox(height: 20),

            // About
            SettingsSection(
              title: 'About',
              icon: LucideIcons.info,
              children: [
                FutureBuilder<String>(
                  future: AppConstants.getVersionDisplayName(),
                  builder: (context, snapshot) {
                    final version = snapshot.data ?? 'Loading...';
                    return ListTile(
                      title: Text('Version'),
                      trailing: Text(version),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Documentation'),
                  subtitle: const Text('View user guide and tutorials'),
                  trailing: const Icon(LucideIcons.externalLink),
                  onTap: () {
                    // TODO: Open documentation
                  },
                ),
                ListTile(
                  title: const Text('Feedback'),
                  subtitle: const Text('Report issues or request features'),
                  trailing: const Icon(LucideIcons.externalLink),
                  onTap: () {
                    // TODO: Open feedback form
                  },
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

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
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(LucideIcons.check),
                            onPressed: validating
                                ? null
                                : () async {
                                  isValidating.value = true;
                                  final trimmedKey = controller.text.trim();

                                  try {
                                    // Use GeminiService to validate the API key
                                    final geminiService = GeminiService();
                                    final (isValid, error) = await geminiService.validateApiKey(trimmedKey);

                                    if (isValid) {
                                      await ref.read(settingsProvider.notifier).updateApiKey(trimmedKey);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('API key saved successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(error ?? 'Invalid API key'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (trimmedKey.startsWith('AIza') && trimmedKey.length > 30) {
                                      await ref.read(settingsProvider.notifier).updateApiKey(trimmedKey);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('API key saved'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: ${e.toString()}'),
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
}