import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/models/transcription.dart';
import '../core/providers/app_providers.dart';
import 'dashboard/dashboard_page.dart';
import 'recording/recording_overlay.dart';
import 'settings/settings_page.dart';

final lastErrorProvider = StateProvider<String?>((ref) => null);

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);
    final recordingState = ref.watch(recordingStateProvider);
    final lastError = ref.watch(lastErrorProvider);

    // Listen to tray recording trigger
    ref.listen(trayRecordingTriggerProvider, (prev, next) {
      if (prev != next) {
        _toggleRecording(context, ref, recordingState);
      }
    });

    // Show error snackbar if there's an error
    if (lastError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lastError),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ref.read(lastErrorProvider.notifier).state = null;
              },
            ),
          ),
        );
        ref.read(lastErrorProvider.notifier).state = null;
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentPage,
            children: const [
              DashboardPage(),
              SettingsPage(),
            ],
          ),
          if (recordingState != RecordingState.idle) const RecordingOverlay(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPage,
        onDestinationSelected: (index) {
          ref.read(currentPageProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.layoutDashboard),
            selectedIcon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.settings),
            selectedIcon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _buildRecordFab(context, ref, recordingState),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget? _buildRecordFab(
      BuildContext context, WidgetRef ref, RecordingState state) {
    final settings = ref.watch(settingsProvider);

    if (!settings.hasApiKey) return null;

    return FloatingActionButton.large(
      onPressed: state == RecordingState.processing
          ? null
          : () => _toggleRecording(context, ref, state),
      backgroundColor: state == RecordingState.recording
          ? Colors.red
          : Theme.of(context).colorScheme.primary,
      child: state == RecordingState.processing
          ? const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : Icon(
              state == RecordingState.recording
                  ? LucideIcons.micOff
                  : LucideIcons.mic,
              size: 32,
            ),
    );
  }

  Future<void> _toggleRecording(
      BuildContext context, WidgetRef ref, RecordingState state) async {
    final audioService = ref.read(audioServiceProvider);
    final settings = ref.read(settingsProvider);

    print('=== Toggle Recording ===');
    print('Current state: $state');
    print('Has API key: ${settings.hasApiKey}');

    if (state == RecordingState.idle) {
      // Start recording
      try {
        print('Checking microphone permission...');
        final hasPermission = await audioService.hasPermission();
        print('Has permission: $hasPermission');

        if (!hasPermission) {
          ref.read(lastErrorProvider.notifier).state =
              'Microphone permission denied. Please grant access in System Settings.';
          return;
        }

        print('Starting recording...');
        await audioService.startRecording();
        ref.read(recordingStateProvider.notifier).state =
            RecordingState.recording;
        print('Recording started successfully');
      } catch (e) {
        print('Error starting recording: $e');
        ref.read(lastErrorProvider.notifier).state =
            'Failed to start recording: $e';
      }
    } else if (state == RecordingState.recording) {
      // Stop recording and process
      print('Stopping recording...');
      ref.read(recordingStateProvider.notifier).state =
          RecordingState.processing;

      try {
        final result = await audioService.stopRecording();
        print(
            'Recording stopped. Result: ${result != null ? "Got audio data" : "No data"}');

        if (result == null) {
          print('No recording result');
          ref.read(lastErrorProvider.notifier).state = 'No audio recorded';
          ref.read(recordingStateProvider.notifier).state = RecordingState.idle;
          return;
        }

        print('Audio bytes: ${result.bytes.length}');
        print('Duration: ${result.durationSeconds}s');

        // Get services and data
        final geminiService = ref.read(geminiServiceProvider);
        final prompts = ref.read(promptsProvider);
        final vocabulary = ref.read(vocabularyProvider);

        print('Gemini initialized: ${geminiService.isInitialized}');

        if (!geminiService.isInitialized) {
          print('Initializing Gemini with API key...');
          geminiService.initialize(settings.geminiApiKey!);
        }

        // Get selected prompt and vocabulary
        final selectedPrompt = prompts.firstWhere(
          (p) => p.id == settings.selectedPromptId,
          orElse: () => prompts.first,
        );

        final selectedVocab = vocabulary.firstWhere(
          (v) => v.id == settings.selectedVocabularyId,
          orElse: () => vocabulary.first,
        );

        print('Selected prompt: ${selectedPrompt.name}');
        print(
            'Selected vocabulary: ${selectedVocab.name} (${selectedVocab.words.length} words)');

        // Transcribe
        print('Calling Gemini API for transcription...');
        final transcriptionResult = await geminiService.transcribeAudio(
          audioBytes: Uint8List.fromList(result.bytes),
          vocabulary: selectedVocab.wordsAsString,
          promptTemplate: selectedPrompt.promptTemplate,
        );

        print('=== Transcription Result ===');
        print('Raw text: ${transcriptionResult.rawText}');
        print('Processed text: ${transcriptionResult.processedText}');
        print('Tokens: ${transcriptionResult.tokenUsage}');

        // Save transcription
        final transcription = Transcription(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          rawText: transcriptionResult.rawText,
          processedText: transcriptionResult.processedText,
          createdAt: DateTime.now(),
          tokenUsage: transcriptionResult.tokenUsage,
          promptId: selectedPrompt.id,
          audioDurationSeconds: result.durationSeconds,
        );

        await ref
            .read(transcriptionsProvider.notifier)
            .addTranscription(transcription);
        print('Transcription saved');

        // Auto-copy if enabled
        if (settings.autoCopyToClipboard) {
          await Clipboard.setData(
              ClipboardData(text: transcriptionResult.processedText));
          print('Copied to clipboard');
        }

        // Show success notification
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                settings.autoCopyToClipboard
                    ? 'Transcription complete! Copied to clipboard.'
                    : 'Transcription complete!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e, stackTrace) {
        print('=== Error during transcription ===');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        ref.read(lastErrorProvider.notifier).state = 'Transcription failed: $e';
      }

      ref.read(recordingStateProvider.notifier).state = RecordingState.idle;
      print('=== Recording flow complete ===');
    }
  }
}
