import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/gemini_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/vocabulary.dart';
import '../../core/models/app_settings.dart';
import '../../core/constants/app_constants.dart';
import 'widgets/critical_instructions_editor.dart';
import 'widgets/hotkey_editor.dart';
import 'widgets/prompt_editor.dart';
import 'widgets/settings_section.dart';
import 'widgets/vocabulary_editor.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final Set<String> _expandedVocabIds = <String>{};

  Widget _buildVocabularyTile(
    BuildContext context,
    WidgetRef ref,
    VocabularySet vocab,
    AppSettings settings,
  ) {
    final isExpanded = _expandedVocabIds.contains(vocab.id);

    return Column(
      children: [
        ListTile(
          title: Text(vocab.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${vocab.words.length} words',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (!isExpanded && vocab.words.isNotEmpty)
                Text(
                  vocab.words.take(3).join(', '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedVocabIds.remove(vocab.id);
                    } else {
                      _expandedVocabIds.add(vocab.id);
                    }
                  });
                },
                icon: Icon(
                  isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 16,
                ),
                tooltip: isExpanded ? 'Show less' : 'Show words',
              ),
              if (!vocab.isDefault)
                IconButton(
                  onPressed: () =>
                      _showVocabularyEditor(context, ref, vocabulary: vocab),
                  icon: const Icon(LucideIcons.edit, size: 16),
                ),
            ],
          ),
          onTap: () {
            ref
                .read(settingsProvider.notifier)
                .updateSelectedVocabulary(vocab.id);
          },
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vocab.description.isNotEmpty) ...[
                  Text(
                    vocab.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: vocab.words
                      .map((word) => Chip(
                            label: Text(
                              word,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
      ],
    );
  }

  String _formatHotkeyForDisplay(String hotkey) {
    if (!Platform.isMacOS) return hotkey;

    return hotkey
        .replaceAll('Ctrl+', '⌃')
        .replaceAll('Cmd+', '⌘')
        .replaceAll('Shift+', '⇧')
        .replaceAll('Alt+', '⌥')
        .replaceAll('+', '');
  }

  @override
  Widget build(BuildContext context) {
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

          // Critical Instructions
          const CriticalInstructionsEditor()
              .animate()
              .fadeIn(duration: 300.ms, delay: 200.ms),

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
              ...vocabulary.map((vocab) =>
                  _buildVocabularyTile(context, ref, vocab, settings)),
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
              if (settings.autoStopAfterSilence)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Silence Duration',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            '${settings.silenceDuration}s',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      Slider(
                        value: settings.silenceDuration.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '${settings.silenceDuration}s',
                        onChanged: (value) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            ref.read(settingsProvider.notifier).updateSilenceDuration(value.toInt());
                          });
                        },
                      ),
                      Text(
                        'Recording will stop after this many seconds of silence',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              SwitchListTile(
                title: const Text('Auto-stop After Silence'),
                subtitle: Text(settings.autoStopAfterSilence
                    ? 'Stop automatically when silent'
                    : 'Manual stop only'),
                value: settings.autoStopAfterSilence,
                onChanged: (value) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    ref.read(settingsProvider.notifier).toggleAutoStopAfterSilence();
                  });
                },
              ),
              // Start at login (desktop only)
              if (Platform.isMacOS || Platform.isWindows || Platform.isLinux)
                SwitchListTile(
                  title: const Text('Start at Login'),
                  subtitle: Text(settings.startAtLogin
                      ? 'App will launch automatically on login'
                      : 'Launch app manually'),
                  value: settings.startAtLogin,
                  onChanged: (value) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      ref.read(settingsProvider.notifier).toggleStartAtLogin();
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

  void _showHotkeyEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HotkeyEditorDialog(),
    );
  }

  void _showPromptEditor(BuildContext context, WidgetRef ref,
      {dynamic prompt}) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PromptEditor(prompt: prompt),
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

  void _showVocabularyEditor(BuildContext context, WidgetRef ref,
      {dynamic vocabulary}) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VocabularyEditor(vocabulary: vocabulary),
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
