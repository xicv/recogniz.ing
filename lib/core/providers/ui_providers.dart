import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI state providers for application-level UI state

/// Recording state enum
enum RecordingState {
  idle,
  recording,
  processing,
}

/// Notifier for recording state
class RecordingStateNotifier extends Notifier<RecordingState> {
  @override
  RecordingState build() => RecordingState.idle;
}

/// Current recording state
final recordingStateProvider =
    NotifierProvider<RecordingStateNotifier, RecordingState>(
        RecordingStateNotifier.new);

/// Notifier for recording duration
class RecordingDurationNotifier extends Notifier<Duration> {
  @override
  Duration build() => Duration.zero;
}

/// Recording duration provider
final recordingDurationProvider =
    NotifierProvider<RecordingDurationNotifier, Duration>(
        RecordingDurationNotifier.new);

/// Notifier for current page index
class CurrentPageNotifier extends Notifier<int> {
  @override
  int build() => 0;
}

/// Current page index for navigation
final currentPageProvider = NotifierProvider<CurrentPageNotifier, int>(
    CurrentPageNotifier.new);

/// Notifier for global error message
class LastErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;
}

/// Global error message provider
final lastErrorProvider = NotifierProvider<LastErrorNotifier, String?>(
    LastErrorNotifier.new);

/// Notifier for tray recording trigger
class TrayRecordingTriggerNotifier extends Notifier<int> {
  @override
  int build() => 0;
}

/// Tray recording trigger - increment to trigger recording toggle from tray
final trayRecordingTriggerProvider =
    NotifierProvider<TrayRecordingTriggerNotifier, int>(
        TrayRecordingTriggerNotifier.new);
