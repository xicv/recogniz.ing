import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/hotkey_service.dart';

class HotkeyTestPage extends ConsumerStatefulWidget {
  const HotkeyTestPage({super.key});

  @override
  ConsumerState<HotkeyTestPage> createState() => _HotkeyTestPageState();
}

class _HotkeyTestPageState extends ConsumerState<HotkeyTestPage> {
  final HotkeyService _hotkeyService = HotkeyService();
  int _pressCount = 0;
  String _lastPressedKey = '';

  @override
  void initState() {
    super.initState();
    _setupHotkeyTest();
  }

  void _setupHotkeyTest() {
    // Test different hotkey formats
    _hotkeyService.onHotkeyPressed = () {
      setState(() {
        _pressCount++;
        _lastPressedKey = 'Global Hotkey Pressed!';
      });
    };
  }

  Future<void> _testRegisterHotkey(String hotkeyString) async {
    await _hotkeyService.registerHotkey(hotkeyString);
    setState(() {
      _lastPressedKey = 'Registered: $hotkeyString';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hotkey Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Press Count: $_pressCount',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Last Action: $_lastPressedKey',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            const Text('Test Hotkeys:'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _testRegisterHotkey('F9'),
              child: const Text('Register F9'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _testRegisterHotkey('Ctrl+Shift+R'),
              child: const Text('Register Ctrl+Shift+R'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _testRegisterHotkey('Cmd+Space'),
              child: const Text('Register Cmd+Space'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _testRegisterHotkey('Alt+T'),
              child: const Text('Register Alt+T'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Instructions:\n'
              '1. Click a button to register a hotkey\n'
              '2. Press the hotkey globally (even when app is in background)\n'
              '3. Watch the press count increase',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hotkeyService.dispose();
    super.dispose();
  }
}