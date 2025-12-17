import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/gemini_service.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/prompt_editor.dart';
import 'widgets/settings_section.dart';
import 'widgets/vocabulary_editor.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final prompts = ref.watch(promptsProvider);
    final vocabulary = ref.watch(vocabularyProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 4),
          Text(
            'Configure your voice typing experience',
            style: Theme.of(context).textTheme.bodyMedium,
          ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

          const SizedBox(height: 24),

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
                subtitle: Text(settings.globalHotkey),
                trailing: const Icon(LucideIcons.chevronRight, size: 18),
                onTap: () => _showHotkeyDialog(context, ref),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

          const SizedBox(height: 20),

          // Custom Prompts
          SettingsSection(
            title: 'Custom Prompts',
            icon: LucideIcons.messageSquare,
            action: IconButton(
              onPressed: () => _showPromptEditor(context, ref),
              icon: const Icon(LucideIcons.plus, size: 20),
              tooltip: 'Add Prompt',
            ),
            children: [
              ...prompts.map((prompt) => ListTile(
                    title: Text(prompt.name),
                    subtitle: Text(
                      prompt.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Radio<String>(
                      value: prompt.id,
                      groupValue: settings.selectedPromptId,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateSelectedPrompt(value);
                        }
                      },
                    ),
                    trailing: prompt.isDefault
                        ? null
                        : IconButton(
                            onPressed: () =>
                                _showPromptEditor(context, ref, prompt: prompt),
                            icon: const Icon(LucideIcons.edit, size: 16),
                          ),
                    onTap: () {
                      ref
                          .read(settingsProvider.notifier)
                          .updateSelectedPrompt(prompt.id);
                    },
                  )),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

          const SizedBox(height: 20),

          // Custom Vocabulary
          SettingsSection(
            title: 'Custom Vocabulary',
            icon: LucideIcons.bookOpen,
            action: IconButton(
              onPressed: () => _showVocabularyEditor(context, ref),
              icon: const Icon(LucideIcons.plus, size: 20),
              tooltip: 'Add Vocabulary',
            ),
            children: [
              ...vocabulary.map((vocab) => ListTile(
                    title: Text(vocab.name),
                    subtitle: Text(
                      '${vocab.words.length} words',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Radio<String>(
                      value: vocab.id,
                      groupValue: settings.selectedVocabularyId,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateSelectedVocabulary(value);
                        }
                      },
                    ),
                    trailing: vocab.isDefault
                        ? null
                        : IconButton(
                            onPressed: () => _showVocabularyEditor(context, ref,
                                vocabulary: vocab),
                            icon: const Icon(LucideIcons.edit, size: 16),
                          ),
                    onTap: () {
                      ref
                          .read(settingsProvider.notifier)
                          .updateSelectedVocabulary(vocab.id);
                    },
                  )),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

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
              const ListTile(
                title: Text('Version'),
                trailing: Text('1.0.0'),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

          const SizedBox(height: 100),
        ],
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
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<bool>(
            valueListenable: isObscured,
            builder: (context, obscured, _) => ValueListenableBuilder<bool>(
              valueListenable: isValidating,
              builder: (context, validating, _) => TextField(
                controller: controller,
                obscureText: obscured,
                enabled: !validating,
                decoration: InputDecoration(
                  hintText: 'Enter your Gemini API key',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => isObscured.value = !obscured,
                        icon: Icon(
                            obscured ? LucideIcons.eye : LucideIcons.eyeOff,
                            size: 18),
                      ),
                      if (validating)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        IconButton(
                          onPressed: () => _saveApiKey(
                              context, ref, controller.text, isValidating),
                          icon: const Icon(LucideIcons.check, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Get your key from Google AI Studio',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _saveApiKey(
    BuildContext context,
    WidgetRef ref,
    String key,
    ValueNotifier<bool> isValidating,
  ) async {
    final trimmedKey = key.trim();
    if (trimmedKey.isEmpty) {
      _showMessage(context, 'Please enter an API key', isError: true);
      return;
    }

    isValidating.value = true;

    try {
      final geminiService = GeminiService();
      final (isValid, error) = await geminiService.validateApiKey(trimmedKey);

      if (isValid) {
        await ref.read(settingsProvider.notifier).updateApiKey(trimmedKey);
        if (context.mounted) {
          _showMessage(context, 'API key saved successfully');
        }
      } else {
        if (context.mounted) {
          _showMessage(context, error ?? 'Invalid API key', isError: true);
        }
      }
    } catch (e) {
      if (trimmedKey.startsWith('AIza') && trimmedKey.length > 30) {
        await ref.read(settingsProvider.notifier).updateApiKey(trimmedKey);
        if (context.mounted) {
          _showMessage(context, 'API key saved');
        }
      } else {
        if (context.mounted) {
          _showMessage(context, 'Error: ${e.toString()}', isError: true);
        }
      }
    } finally {
      isValidating.value = false;
    }
  }

  void _showMessage(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  void _showHotkeyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Global Hotkey'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Current hotkey:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ref.read(settingsProvider).globalHotkey,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Global hotkeys work on desktop only',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPromptEditor(BuildContext context, WidgetRef ref,
      {dynamic prompt}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PromptEditor(prompt: prompt),
    );
  }

  void _showVocabularyEditor(BuildContext context, WidgetRef ref,
      {dynamic vocabulary}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VocabularyEditor(vocabulary: vocabulary),
    );
  }
}
