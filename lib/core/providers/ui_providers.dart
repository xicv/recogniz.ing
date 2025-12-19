import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI state providers for application-level UI state

/// Recording state enum
enum RecordingState {
  idle,
  recording,
  processing,
}

/// Current recording state
final recordingStateProvider = StateProvider<RecordingState>((ref) {
  return RecordingState.idle;
});

/// Current page index for navigation
final currentPageProvider = StateProvider<int>((ref) => 0);

/// Global error message provider
final lastErrorProvider = StateProvider<String?>((ref) => null);

/// Tray recording trigger - increment to trigger recording toggle from tray
final trayRecordingTriggerProvider = StateProvider<int>((ref) => 0);
