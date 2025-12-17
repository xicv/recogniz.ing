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
          ref.read(lastErrorProvider.notifier).state =
              'No audio recorded. Please speak clearly and try again.\n'
              'Tip: Recordings must be at least 0.5 seconds long.';
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

        // Check if the transcription is meaningful
        if (!_isMeaningfulTranscription(transcriptionResult.rawText)) {
          ref.read(lastErrorProvider.notifier).state =
              'No speech detected. Please try again with clearer speech.';
          ref.read(recordingStateProvider.notifier).state = RecordingState.idle;
          return;
        }

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

        // Provide user-friendly error messages
        final errorMessage = _getErrorMessage(e.toString());
        ref.read(lastErrorProvider.notifier).state = errorMessage;
      }

      ref.read(recordingStateProvider.notifier).state = RecordingState.idle;
      print('=== Recording flow complete ===');
    }
  }

  String _getErrorMessage(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('503') || errorLower.contains('unavailable')) {
      return 'Service temporarily unavailable (503)\n'
             'The AI service is experiencing high demand. Please try again in a few moments.\n'
             'The app will automatically retry up to 3 times.';
    }

    if (errorLower.contains('429') || errorLower.contains('resource_exhausted')) {
      return 'Rate limit exceeded (429)\n'
             'Too many requests. Please wait a moment before trying again.';
    }

    if (errorLower.contains('permission_denied') || errorLower.contains('api_key')) {
      return 'API Key Error\n'
             'Please check your API key in Settings.';
    }

    if (errorLower.contains('invalid_argument')) {
      return 'Invalid audio format\n'
             'Please try recording again with clear speech.';
    }

    if (errorLower.contains('empty transcription')) {
      return 'No speech detected\n'
             'Please speak clearly and ensure your microphone is working.';
    }

    if (errorLower.contains('deadline_exceeded')) {
      return 'Request timeout\n'
             'The request took too long. Please try with a shorter recording.';
    }

    // Generic error with suggestions
    return 'Transcription failed\n'
           'Error: ${error.length > 100 ? error.substring(0, 100) : error}\n\n'
           'Suggestions:\n'
           '• Check your internet connection\n'
           '• Ensure you have a valid API key\n'
           '• Try recording shorter audio clips\n'
           '• Speak clearly during recording';
  }

  bool _isMeaningfulTranscription(String text) {
    if (text.isEmpty) return false;

    // Convert to lowercase and trim
    final cleanText = text.toLowerCase().trim();

    // List of common non-meaningful responses from silence
    const nonMeaningfulResponses = [
      'ok',
      'okay',
      'hello',
      'hi',
      'um',
      'uh',
      'ah',
      'mm',
      'hm',
      'yes',
      'no',
      'thanks',
      'thank you',
      'please',
      'sure',
      'alright',
      'cool',
      'good',
      'bad',
      'nice',
      'great',
    ];

    // Check if it's just one word
    final words = cleanText.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length == 1 && nonMeaningfulResponses.contains(words.first)) {
      return false;
    }

    // Check if it's too short (less than 3 words)
    if (words.length < 3) {
      return false;
    }

    // Check for email template patterns (common when no speech)
    if (cleanText.contains('[recipient name]') ||
        cleanText.contains('[your name]') ||
        cleanText.contains('dear [recipient]') ||
        cleanText.contains('subject:')) {
      return false;
    }

    // Check for repetitive or generic responses
    if (cleanText.contains('confirmation') &&
        cleanText.contains('thank you for your message')) {
      return false;
    }

    // If it passed all checks, consider it meaningful
    return true;
  }
}
