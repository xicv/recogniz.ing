import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotkeyService {
  static final HotkeyService _instance = HotkeyService._internal();
  factory HotkeyService() => _instance;
  HotkeyService._internal();

  HotKey? _currentHotKey;
  VoidCallback? onHotkeyPressed;

  bool get isSupported =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  Future<void> initialize(String hotkeyString) async {
    if (!isSupported) return;
    await registerHotkey(hotkeyString);
  }

  Future<void> registerHotkey(String hotkeyString) async {
    if (!isSupported) return;

    // Unregister existing hotkey
    await unregisterHotkey();

    try {
      final hotKey = parseHotkeyString(hotkeyString);
      if (hotKey == null) {
        debugPrint('[HotkeyService] Failed to parse hotkey: $hotkeyString');
        return;
      }

      _currentHotKey = hotKey;

      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (hotKey) {
          debugPrint('[HotkeyService] Hotkey pressed!');
          onHotkeyPressed?.call();
        },
      );

      debugPrint('[HotkeyService] Registered hotkey: $hotkeyString');
    } catch (e) {
      debugPrint('[HotkeyService] Error registering hotkey: $e');
    }
  }

  Future<void> unregisterHotkey() async {
    if (_currentHotKey != null) {
      try {
        await hotKeyManager.unregister(_currentHotKey!);
        _currentHotKey = null;
      } catch (e) {
        debugPrint('[HotkeyService] Error unregistering hotkey: $e');
      }
    }
  }

  HotKey? parseHotkeyString(String hotkeyString) {
    // Parse strings like "Ctrl+Shift+R", "Cmd+Shift+Space", "F9", etc.
    final parts =
        hotkeyString.split('+').map((s) => s.trim().toLowerCase()).toList();

    if (parts.isEmpty) return null;

    final modifiers = <HotKeyModifier>[];
    LogicalKeyboardKey? key;

    for (final part in parts) {
      switch (part) {
        case 'ctrl':
        case 'control':
          modifiers.add(HotKeyModifier.control);
          break;
        case 'cmd':
        case 'command':
        case 'meta':
          modifiers.add(HotKeyModifier.meta);
          break;
        case 'shift':
          modifiers.add(HotKeyModifier.shift);
          break;
        case 'alt':
        case 'option':
          modifiers.add(HotKeyModifier.alt);
          break;
        case 'space':
          key = LogicalKeyboardKey.space;
          break;
        case 'enter':
        case 'return':
          key = LogicalKeyboardKey.enter;
          break;
        case 'tab':
          key = LogicalKeyboardKey.tab;
          break;
        case 'escape':
        case 'esc':
          key = LogicalKeyboardKey.escape;
          break;
        default:
          // Check for function keys first (before single character check)
          if (part.startsWith('f') && part.length <= 3) {
            final num = int.tryParse(part.substring(1));
            if (num != null && num >= 1 && num <= 24) {
              // Support F1-F24
              key = _getFunctionKey(num);
            }
          }
          // Single letter or number
          else if (part.length == 1) {
            final char = part.toUpperCase().codeUnitAt(0);
            if (char >= 65 && char <= 90) {
              // A-Z - use the key code directly without adding 32
              key = LogicalKeyboardKey.findKeyByKeyId(
                      char | 0x1000000) ?? // Use proper key ID
                  _getKeyFromLabel(
                      part.toUpperCase()); // Fallback if key not found
            } else if (char >= 48 && char <= 57) {
              // 0-9
              key = LogicalKeyboardKey.findKeyByKeyId(char | 0x1000000) ??
                  _getKeyFromLabel(part); // Fallback if key not found
            }
          }
      }
    }

    if (key == null) return null;

    return HotKey(
      key: key,
      modifiers: modifiers,
      scope: HotKeyScope.system,
    );
  }

  LogicalKeyboardKey _getFunctionKey(int num) {
    switch (num) {
      case 1:
        return LogicalKeyboardKey.f1;
      case 2:
        return LogicalKeyboardKey.f2;
      case 3:
        return LogicalKeyboardKey.f3;
      case 4:
        return LogicalKeyboardKey.f4;
      case 5:
        return LogicalKeyboardKey.f5;
      case 6:
        return LogicalKeyboardKey.f6;
      case 7:
        return LogicalKeyboardKey.f7;
      case 8:
        return LogicalKeyboardKey.f8;
      case 9:
        return LogicalKeyboardKey.f9;
      case 10:
        return LogicalKeyboardKey.f10;
      case 11:
        return LogicalKeyboardKey.f11;
      case 12:
        return LogicalKeyboardKey.f12;
      case 13:
        return LogicalKeyboardKey.f13;
      case 14:
        return LogicalKeyboardKey.f14;
      case 15:
        return LogicalKeyboardKey.f15;
      case 16:
        return LogicalKeyboardKey.f16;
      case 17:
        return LogicalKeyboardKey.f17;
      case 18:
        return LogicalKeyboardKey.f18;
      case 19:
        return LogicalKeyboardKey.f19;
      case 20:
        return LogicalKeyboardKey.f20;
      case 21:
        return LogicalKeyboardKey.f21;
      case 22:
        return LogicalKeyboardKey.f22;
      case 23:
        return LogicalKeyboardKey.f23;
      case 24:
        return LogicalKeyboardKey.f24;
      default:
        return LogicalKeyboardKey.f1;
    }
  }

  LogicalKeyboardKey _getKeyFromLabel(String label) {
    // Helper method to find key by its label
    // Common key mappings for faster lookup
    switch (label) {
      case 'A':
        return LogicalKeyboardKey.keyA;
      case 'B':
        return LogicalKeyboardKey.keyB;
      case 'C':
        return LogicalKeyboardKey.keyC;
      case 'D':
        return LogicalKeyboardKey.keyD;
      case 'E':
        return LogicalKeyboardKey.keyE;
      case 'F':
        return LogicalKeyboardKey.keyF;
      case 'G':
        return LogicalKeyboardKey.keyG;
      case 'H':
        return LogicalKeyboardKey.keyH;
      case 'I':
        return LogicalKeyboardKey.keyI;
      case 'J':
        return LogicalKeyboardKey.keyJ;
      case 'K':
        return LogicalKeyboardKey.keyK;
      case 'L':
        return LogicalKeyboardKey.keyL;
      case 'M':
        return LogicalKeyboardKey.keyM;
      case 'N':
        return LogicalKeyboardKey.keyN;
      case 'O':
        return LogicalKeyboardKey.keyO;
      case 'P':
        return LogicalKeyboardKey.keyP;
      case 'Q':
        return LogicalKeyboardKey.keyQ;
      case 'R':
        return LogicalKeyboardKey.keyR;
      case 'S':
        return LogicalKeyboardKey.keyS;
      case 'T':
        return LogicalKeyboardKey.keyT;
      case 'U':
        return LogicalKeyboardKey.keyU;
      case 'V':
        return LogicalKeyboardKey.keyV;
      case 'W':
        return LogicalKeyboardKey.keyW;
      case 'X':
        return LogicalKeyboardKey.keyX;
      case 'Y':
        return LogicalKeyboardKey.keyY;
      case 'Z':
        return LogicalKeyboardKey.keyZ;
      case '0':
        return LogicalKeyboardKey.digit0;
      case '1':
        return LogicalKeyboardKey.digit1;
      case '2':
        return LogicalKeyboardKey.digit2;
      case '3':
        return LogicalKeyboardKey.digit3;
      case '4':
        return LogicalKeyboardKey.digit4;
      case '5':
        return LogicalKeyboardKey.digit5;
      case '6':
        return LogicalKeyboardKey.digit6;
      case '7':
        return LogicalKeyboardKey.digit7;
      case '8':
        return LogicalKeyboardKey.digit8;
      case '9':
        return LogicalKeyboardKey.digit9;
      case ' ':
        return LogicalKeyboardKey.space;
      case 'Enter':
        return LogicalKeyboardKey.enter;
      case 'Escape':
        return LogicalKeyboardKey.escape;
      case 'Tab':
        return LogicalKeyboardKey.tab;
      default:
        return LogicalKeyboardKey.space;
    }
  }

  String formatHotkey(HotKey hotKey) {
    final parts = <String>[];

    for (final modifier in hotKey.modifiers ?? []) {
      switch (modifier) {
        case HotKeyModifier.control:
          parts.add(Platform.isMacOS ? '⌃' : 'Ctrl');
          break;
        case HotKeyModifier.meta:
          parts.add(Platform.isMacOS ? '⌘' : 'Win');
          break;
        case HotKeyModifier.shift:
          parts.add(Platform.isMacOS ? '⇧' : 'Shift');
          break;
        case HotKeyModifier.alt:
          parts.add(Platform.isMacOS ? '⌥' : 'Alt');
          break;
        default:
          break;
      }
    }

    parts.add(hotKey.key.keyLabel);
    return parts.join(Platform.isMacOS ? '' : '+');
  }

  Future<void> dispose() async {
    await unregisterHotkey();
  }
}

// Hotkey recorder for capturing new hotkeys
class HotkeyRecorder {
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  final Set<HotKeyModifier> _pressedModifiers = {};
  LogicalKeyboardKey? _mainKey;

  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      // Check if it's a modifier
      if (_isModifier(key)) {
        _pressedModifiers.add(_getModifier(key));
      } else {
        _mainKey = key;
      }
      _pressedKeys.add(key);
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }
  }

  bool _isModifier(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight;
  }

  HotKeyModifier _getModifier(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight) {
      return HotKeyModifier.control;
    }
    if (key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight) {
      return HotKeyModifier.meta;
    }
    if (key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight) {
      return HotKeyModifier.shift;
    }
    if (key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight) {
      return HotKeyModifier.alt;
    }
    return HotKeyModifier.control;
  }

  String? getHotkeyString() {
    if (_mainKey == null || _pressedModifiers.isEmpty) return null;

    final parts = <String>[];

    if (_pressedModifiers.contains(HotKeyModifier.control)) parts.add('Ctrl');
    if (_pressedModifiers.contains(HotKeyModifier.meta)) parts.add('Cmd');
    if (_pressedModifiers.contains(HotKeyModifier.shift)) parts.add('Shift');
    if (_pressedModifiers.contains(HotKeyModifier.alt)) parts.add('Alt');

    parts.add(_mainKey!.keyLabel);

    return parts.join('+');
  }

  void reset() {
    _pressedKeys.clear();
    _pressedModifiers.clear();
    _mainKey = null;
  }

  bool get hasValidHotkey => _mainKey != null && _pressedModifiers.isNotEmpty;
}
