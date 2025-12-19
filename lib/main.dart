import 'dart:io';

import 'package:flutter/foundation.dart';
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

// Window control channel
const _windowChannel = MethodChannel('com.recognizing.app/window');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    debugPrint('[Main] WidgetsFlutterBinding initialized');
  }

  await Hive.initFlutter();
  if (kDebugMode) {
    debugPrint('[Main] Hive initialized');
  }

  try {
    await StorageService.initialize();
    if (kDebugMode) {
      debugPrint('[Main] StorageService initialized');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Main] StorageService initialization failed: $e');
      // Try to continue with default settings
      debugPrint('[Main] Continuing with default settings...');
    }
  }

  if (kDebugMode) {
    debugPrint('[Main] Starting runApp');
  }
  runApp(
    const ProviderScope(
      child: RecognizingApp(),
    ),
  );
  if (kDebugMode) {
    debugPrint('[Main] runApp completed');
  }
}

class RecognizingApp extends ConsumerStatefulWidget {
  const RecognizingApp({super.key});

  @override
  ConsumerState<RecognizingApp> createState() => _RecognizingAppState();
}

class _RecognizingAppState extends ConsumerState<RecognizingApp>
    with WidgetsBindingObserver {
  late final HotkeyService _hotkeyService;
  late final TrayService _trayService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize tray service
    _trayService = TrayService();
    await _trayService.initialize();
    if (kDebugMode) {
      debugPrint('[MainApp] TrayService initialized');
    }
    _setupTrayActions();

    // Setup hotkey service
    _setupHotkeyService();
  }

  void _setupTrayActions() {
    _trayService.onAction = (action) {
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
      if (kDebugMode) {
        debugPrint('[MainApp] Global hotkey triggered!');
      }
      _toggleRecording();
    };

    // Wait for the first frame and provider to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Listen to settings for the first time
      final settings = ref.read(settingsProvider);
      if (settings.globalHotkey.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
              '[MainApp] Initial hotkey setup: ${settings.globalHotkey}');
        }
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
        if (kDebugMode) {
          debugPrint('Failed to show window: $e');
        }
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
    _trayService.dispose();
    // Use proper app lifecycle instead of force exit
    if (mounted) {
      SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _trayService.dispose();
    _hotkeyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(settingsProvider.select((s) => s.darkMode));

    ref.listen(recordingStateProvider, (prev, next) {
      _trayService.updateRecordingState(next == RecordingState.recording);
    });

    ref.listen(transcriptionsProvider, (prev, next) {
      if (next.isNotEmpty) {
        _trayService.updateLastTranscription(next.first.processedText);
      }
    });

    // Listen for hotkey changes and re-register
    ref.listen(settingsProvider.select((s) => s.globalHotkey), (prev, next) {
      if (prev != next && next.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('[MainApp] Hotkey changed from $prev to $next');
        }
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
