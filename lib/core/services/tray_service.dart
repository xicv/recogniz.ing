import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tray_manager/tray_manager.dart';

enum TrayAction {
  toggleRecording,
  showApp,
  openSettings,
  copyLastTranscription,
  quit,
}

class TrayService with TrayListener {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  Function(TrayAction)? onAction;
  String? _lastTranscription;
  bool _isRecording = false;
  String? _normalIconPath;
  String? _recordingIconPath;

  // Method channel for native window control
  static const _channel = MethodChannel('com.recognizing.app/window');

  bool get isSupported =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  Future<void> initialize() async {
    if (!isSupported) return;

    debugPrint('[TrayService] Initializing tray service...');
    trayManager.addListener(this);

    await _createIcons();
    await _setIcon(false);
    await _updateMenu();
    await trayManager.setToolTip('Recogniz.ing');
    debugPrint('[TrayService] Tray service initialized successfully');
  }

  Future<void> _createIcons() async {
    final tempDir = await getTemporaryDirectory();
    _normalIconPath = '${tempDir.path}/recognizing_tray.png';
    _recordingIconPath = '${tempDir.path}/recognizing_tray_rec.png';

    // Create normal icon (black microphone)
    await _createMicrophoneIcon(_normalIconPath!, 0xFF1E293B, false);

    // Create recording icon (red microphone with dot)
    await _createMicrophoneIcon(_recordingIconPath!, 0xFFEF4444, true);
  }

  Future<void> _createMicrophoneIcon(
      String path, int color, bool showDot) async {
    // Create a 44x44 image (for retina displays)
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const size = 44.0;

    final paint = ui.Paint()
      ..color = ui.Color(color)
      ..style = ui.PaintingStyle.fill;

    final strokePaint = ui.Paint()
      ..color = ui.Color(color)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = ui.StrokeCap.round;

    // Scale factor for 44x44
    const scale = size / 22;

    // Microphone body (rounded rect)
    final bodyRect = ui.RRect.fromRectAndRadius(
      const ui.Rect.fromLTWH(7 * scale, 2 * scale, 8 * scale, 12 * scale),
      const ui.Radius.circular(4 * scale),
    );
    canvas.drawRRect(bodyRect, paint);

    // Microphone arc
    final arcPath = ui.Path();
    arcPath.addArc(
      ui.Rect.fromCircle(
          center: const ui.Offset(11 * scale, 10 * scale), radius: 6 * scale),
      0.0,
      3.14159,
    );
    canvas.drawPath(arcPath, strokePaint);

    // Stand
    canvas.drawLine(
      const ui.Offset(11 * scale, 16 * scale),
      const ui.Offset(11 * scale, 19 * scale),
      strokePaint,
    );

    // Base
    canvas.drawLine(
      const ui.Offset(8 * scale, 19 * scale),
      const ui.Offset(14 * scale, 19 * scale),
      strokePaint,
    );

    // Recording dot
    if (showDot) {
      final dotPaint = ui.Paint()
        ..color = const ui.Color(0xFFEF4444)
        ..style = ui.PaintingStyle.fill;
      canvas.drawCircle(const ui.Offset(36, 8), 6, dotPaint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(44, 44);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      final file = File(path);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      debugPrint('Created tray icon: $path');
    }
  }

  Future<void> _setIcon(bool recording) async {
    final iconPath = recording ? _recordingIconPath : _normalIconPath;
    if (iconPath == null || !File(iconPath).existsSync()) {
      debugPrint('Icon not found: $iconPath');
      return;
    }

    try {
      await trayManager.setIcon(iconPath);
    } catch (e) {
      debugPrint('Failed to set tray icon: $e');
    }
  }

  Future<void> _updateMenu() async {
    final menuItems = <MenuItem>[
      MenuItem(
        key: 'toggle_recording',
        label: _isRecording ? 'Stop Recording' : 'Start Recording',
      ),
      MenuItem.separator(),
      if (_lastTranscription != null && _lastTranscription!.isNotEmpty) ...[
        MenuItem(
          key: 'last_transcription_label',
          label: 'Last Transcription:',
          disabled: true,
        ),
        MenuItem(
          key: 'last_transcription',
          label: _truncate(_lastTranscription!, 45),
          disabled: true,
        ),
        MenuItem(
          key: 'copy_last',
          label: 'Copy to Clipboard',
        ),
        MenuItem.separator(),
      ],
      MenuItem(
        key: 'show_app',
        label: 'Show Window',
      ),
      MenuItem(
        key: 'settings',
        label: 'Settings...',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'quit',
        label: 'Quit Recogniz.ing',
      ),
    ];

    await trayManager.setContextMenu(Menu(items: menuItems));
  }

  String _truncate(String text, int maxLength) {
    final cleaned =
        text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length <= maxLength) return cleaned;
    return '${cleaned.substring(0, maxLength)}...';
  }

  Future<void> updateRecordingState(bool isRecording) async {
    if (!isSupported) return;

    _isRecording = isRecording;
    await _setIcon(isRecording);
    await _updateMenu();

    await trayManager.setToolTip(
      isRecording ? 'Recogniz.ing - Recording...' : 'Recogniz.ing',
    );
  }

  Future<void> updateLastTranscription(String? transcription) async {
    if (!isSupported) return;

    _lastTranscription = transcription;
    await _updateMenu();
  }

  /// Show the main application window
  Future<void> showWindow() async {
    if (Platform.isMacOS) {
      try {
        await _channel.invokeMethod('showWindow');
      } catch (e) {
        debugPrint('Failed to show window via channel: $e');
      }
    }
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'toggle_recording':
        onAction?.call(TrayAction.toggleRecording);
        break;
      case 'show_app':
        onAction?.call(TrayAction.showApp);
        break;
      case 'settings':
        onAction?.call(TrayAction.openSettings);
        break;
      case 'copy_last':
        onAction?.call(TrayAction.copyLastTranscription);
        break;
      case 'quit':
        onAction?.call(TrayAction.quit);
        break;
    }
  }

  Future<void> dispose() async {
    if (!isSupported) return;
    trayManager.removeListener(this);
    await trayManager.destroy();
  }
}
