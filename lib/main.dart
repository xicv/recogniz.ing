import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/providers/app_providers.dart';
import 'core/services/hotkey_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/tray_service.dart';
import 'core/theme/app_theme.dart';
import 'features/app_shell.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late ProviderContainer providerContainer;

// Window control channel
const _windowChannel = MethodChannel('com.recognizing.app/window');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await StorageService.initialize();

  providerContainer = ProviderContainer();

  final trayService = TrayService();
  await trayService.initialize();

  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: RecognizingApp(trayService: trayService),
    ),
  );
}

class RecognizingApp extends ConsumerStatefulWidget {
  final TrayService trayService;

  const RecognizingApp({super.key, required this.trayService});

  @override
  ConsumerState<RecognizingApp> createState() => _RecognizingAppState();
}

class _RecognizingAppState extends ConsumerState<RecognizingApp>
    with WidgetsBindingObserver {
  late final HotkeyService _hotkeyService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupTrayActions();
    _setupHotkeyService();
  }

  void _setupTrayActions() {
    widget.trayService.onAction = (action) {
      switch (action) {
        case TrayAction.toggleRecording:
          _toggleRecording();
          break;
        case TrayAction.showApp:
          _showApp();
          break;
        case TrayAction.openSettings:
          _openSettings();
          break;
        case TrayAction.copyLastTranscription:
          _copyLastTranscription();
          break;
        case TrayAction.quit:
          _quitApp();
          break;
      }
    };
  }

  void _setupHotkeyService() {
    _hotkeyService = HotkeyService();

    // Set up the callback BEFORE initializing/registering
    _hotkeyService.onHotkeyPressed = () {
      debugPrint('[MainApp] Global hotkey triggered!');
      _toggleRecording();
    };

    // Wait for the first frame and provider to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Listen to settings for the first time
      final settings = ref.read(settingsProvider);
      if (settings.globalHotkey.isNotEmpty) {
        debugPrint('[MainApp] Initial hotkey setup: ${settings.globalHotkey}');
        _hotkeyService.initialize(settings.globalHotkey);
      }
    });
  }

  void _toggleRecording() {
    final currentState = ref.read(recordingStateProvider);
    if (currentState == RecordingState.processing) return;
    ref.read(trayRecordingTriggerProvider.notifier).state++;
  }

  Future<void> _showApp() async {
    if (Platform.isMacOS) {
      try {
        await _windowChannel.invokeMethod('showWindow');
      } catch (e) {
        debugPrint('Failed to show window: $e');
      }
    }
  }

  void _openSettings() {
    _showApp();
    ref.read(currentPageProvider.notifier).state = 1;
  }

  void _copyLastTranscription() {
    final transcriptions = ref.read(transcriptionsProvider);
    if (transcriptions.isNotEmpty) {
      Clipboard.setData(
          ClipboardData(text: transcriptions.first.processedText));
    }
  }

  void _quitApp() {
    widget.trayService.dispose();
    exit(0);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.trayService.dispose();

    // Dispose hotkey service
    _hotkeyService.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(settingsProvider.select((s) => s.darkMode));

    ref.listen(recordingStateProvider, (prev, next) {
      widget.trayService.updateRecordingState(next == RecordingState.recording);
    });

    ref.listen(transcriptionsProvider, (prev, next) {
      if (next.isNotEmpty) {
        widget.trayService.updateLastTranscription(next.first.processedText);
      }
    });

    // Listen for hotkey changes and re-register
    ref.listen(settingsProvider.select((s) => s.globalHotkey), (prev, next) {
      if (prev != next && next.isNotEmpty) {
        debugPrint('[MainApp] Hotkey changed from $prev to $next');
        _hotkeyService.initialize(next);
      }
    });

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Recogniz.ing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppShell(),
    );
  }
}
