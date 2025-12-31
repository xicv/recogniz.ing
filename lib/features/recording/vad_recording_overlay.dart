import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/services/vad_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/providers/recording_providers.dart';
import '../../core/providers/app_providers.dart';
import '../../widgets/recording/audio_waveform_display.dart';
import '../../core/theme/app_theme.dart';

/// Enhanced recording overlay with multi-channel state indication
///
/// Design principles:
/// - Müller-Brockmann: Grid-aligned layout, mathematical spacing
/// - Dieter Rams: Honest state communication, minimal decoration
///
/// Key improvements:
/// - Multi-channel state indication (color + icon + text + animation)
/// - Processing progress with ETA
/// - Zen mode option
/// - Accessibility improvements

class VadRecordingOverlay extends ConsumerStatefulWidget {
  const VadRecordingOverlay({super.key});

  @override
  ConsumerState<VadRecordingOverlay> createState() =>
      _VadRecordingOverlayState();
}

class _VadRecordingOverlayState extends ConsumerState<VadRecordingOverlay>
    with TickerProviderStateMixin {
  // Pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Fade animation for state transitions
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // State tracking
  bool _isInitialized = false;
  double _speechProbability = 0.0;
  bool _hasDetectedSpeech = false;

  // Audio amplitude tracking for waveform visualization
  final List<double> _audioAmplitudes = [];
  static const int _maxAmplitudes = 40;
  Timer? _amplitudeUpdateTimer;

  // Duration tracking
  DateTime? _recordingStartTime;
  Timer? _durationTimer;

  // Processing progress
  double _processingProgress = 0.0;
  String _processingStage = '';
  bool _isZenMode = false;

  // Progress simulation for processing state
  Timer? _progressTimer;
  DateTime? _processingStartTime;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Initialize VAD
    _initializeVad();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _durationTimer?.cancel();
    _amplitudeUpdateTimer?.cancel();
    _progressTimer?.cancel();
    VadService.stopListening();
    super.dispose();
  }

  Future<void> _initializeVad() async {
    await VadService.initialize();
    await HapticService.initialize();

    setState(() {
      _isInitialized = true;
    });

    try {
      await VadService.startListening(
        onSpeechStart: (audioData) {
          HapticService.speechDetected();
          setState(() {
            _hasDetectedSpeech = true;
            _speechProbability = 1.0;
          });
        },
        onSpeechEnd: (audioData) {
          setState(() {
            _hasDetectedSpeech = false;
            _speechProbability = 0.0;
          });
        },
        onProbability: (probability) {
          if (mounted) {
            setState(() {
              _speechProbability = probability;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Error starting VAD: $e');
    }
  }

  void _updateAmplitudes() {
    if (_audioAmplitudes.length >= _maxAmplitudes) {
      _audioAmplitudes.removeAt(0);
    }
    final baseAmplitude = _speechProbability;
    final variation = (Random().nextDouble() - 0.5) * 0.2;
    final amplitude = (baseAmplitude + variation).clamp(0.0, 1.0);
    _audioAmplitudes.add(amplitude);
  }

  void _toggleZenMode() {
    setState(() {
      _isZenMode = !_isZenMode;
    });
  }

  RecordingStateValue _getCurrentState(RecordingState recordingState) {
    if (!_isInitialized) return RecordingStateValue.idle;
    if (recordingState == RecordingState.processing) {
      return RecordingStateValue.processing;
    }
    if (recordingState == RecordingState.recording) {
      return _hasDetectedSpeech
          ? RecordingStateValue.voiceDetected
          : RecordingStateValue.recording;
    }
    return RecordingStateValue.listening;
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingStateProvider);
    final currentState = _getCurrentState(recordingState);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    // Trigger fade animation on state change
    _fadeController.forward(from: 0);

    // Manage timers
    _manageDurationTimer(recordingState);
    _manageAmplitudeUpdates(recordingState);
    _manageProgressTimer(recordingState);

    return Container(
      color: isDark
          ? Colors.black.withOpacity(0.90)
          : colorScheme.surface.withOpacity(0.95),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: _isZenMode
                    ? _buildZenModeContent(context, recordingState, currentState)
                    : _buildNormalModeContent(context, recordingState, currentState),
              ),
            ),

            // Zen mode toggle (top-right)
            Positioned(
              top: 16,
              right: 16,
              child: _buildZenModeToggle(),
            ),

            // Close hint (top-left)
            Positioned(
              top: 16,
              left: 16,
              child: _buildCloseHint(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalModeContent(
    BuildContext context,
    RecordingState recordingState,
    RecordingStateValue currentState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final stateColor = _getStateColor(currentState, colorScheme);
    final stateIcon = getStateIcon(currentState);
    final stateText = getStateText(currentState);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // State indicator (multi-channel) - hidden during processing
        if (recordingState != RecordingState.processing)
          _buildStateIndicator(context, currentState, stateColor, stateIcon, stateText),

        // Static processing indicator (no animation, only during processing)
        if (recordingState == RecordingState.processing)
          _buildStaticProcessingIndicator(context, colorScheme),

        const SizedBox(height: 32),

        // Main recording circle with waveform (hidden during processing)
        if (recordingState != RecordingState.processing)
          _buildRecordingCircle(context, recordingState, currentState, stateColor),

        const SizedBox(height: 32),

        // Audio waveform display
        AudioWaveformDisplay(
          amplitudes: _audioAmplitudes,
          maxBars: _maxAmplitudes,
          isSpeechDetected: _hasDetectedSpeech,
        ),

        const SizedBox(height: 32),

        // Timer display (hidden during processing)
        if (recordingState == RecordingState.recording ||
            recordingState == RecordingState.idle)
          _buildTimerDisplay(context),

        const SizedBox(height: 24),

        // Instructions (hidden during processing)
        if (_isInitialized && recordingState != RecordingState.processing)
          _buildInstructions(context),

        // Stop button (when recording)
        if (recordingState == RecordingState.recording) ...[
          const SizedBox(height: 16),
          _buildStopButton(context),
        ],
      ],
    );
  }

  Widget _buildZenModeContent(
    BuildContext context,
    RecordingState recordingState,
    RecordingStateValue currentState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurfaceColor = colorScheme.onSurface;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Minimal waveform (larger)
        Transform.scale(
          scale: 1.5,
          child: AudioWaveformDisplay(
            amplitudes: _audioAmplitudes,
            maxBars: _maxAmplitudes,
            isSpeechDetected: _hasDetectedSpeech,
          ),
        ),

        const SizedBox(height: 64),

        // Timer only (hidden during processing)
        if (recordingState != RecordingState.processing)
          Text(
            _formatDuration(_currentDuration),
            style: TextStyle(
              color: onSurfaceColor,
              fontSize: 56,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
            ),
          ),

        const SizedBox(height: 16),

        // Minimal state indicator (hidden during processing)
        if (recordingState != RecordingState.processing)
          Text(
            getStateText(currentState),
            style: TextStyle(
              color: onSurfaceColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),

        // Static processing text (only during processing, no animation)
        if (recordingState == RecordingState.processing)
          Text(
            'Processing...',
            style: TextStyle(
              color: onSurfaceColor.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),

        // Stop button (when recording)
        if (recordingState == RecordingState.recording) ...[
          const SizedBox(height: 48),
          _buildMinimalStopButton(context),
        ],
      ],
    );
  }

  Widget _buildStateIndicator(
    BuildContext context,
    RecordingStateValue currentState,
    Color stateColor,
    IconData stateIcon,
    String stateText,
  ) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: stateColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: stateColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  stateIcon,
                  color: stateColor,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  stateText,
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Static processing indicator without any animation.
  /// This provides feedback during processing without the flashing effect.
  Widget _buildStaticProcessingIndicator(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final processingColor = colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: processingColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: processingColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.clock,
            color: processingColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            'Processing',
            style: TextStyle(
              color: processingColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingCircle(
    BuildContext context,
    RecordingState recordingState,
    RecordingStateValue currentState,
    Color stateColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        // Pulse only when listening
        final showPulse = currentState == RecordingStateValue.listening ||
            currentState == RecordingStateValue.idle;
        final scale = showPulse ? _pulseAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: recordingState == RecordingState.recording
                ? _stopRecording
                : null,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stateColor,
                boxShadow: [
                  BoxShadow(
                    color: stateColor.withOpacity(0.4),
                    blurRadius: 30 * scale,
                    spreadRadius: 5 * scale,
                  ),
                ],
              ),
              child: Icon(
                recordingState == RecordingState.recording
                    ? LucideIcons.square
                    : LucideIcons.mic,
                color: colorScheme.onPrimary,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildTimerDisplay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      _formatDuration(_currentDuration),
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: -2,
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.info,
            color: colorScheme.onSurface.withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Press stop button when finished',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        await HapticService.mediumImpact();
        _stopRecording();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.error.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.square, color: colorScheme.onError, size: 16),
            const SizedBox(width: 8),
            Text(
              'Stop Recording',
              style: TextStyle(
                color: colorScheme.onError,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalStopButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        await HapticService.mediumImpact();
        _stopRecording();
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.onSurface.withOpacity(0.15),
          border: Border.all(
            color: colorScheme.onSurface.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          LucideIcons.square,
          color: colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildZenModeToggle() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: _toggleZenMode,
        icon: Icon(
          _isZenMode ? LucideIcons.expand : LucideIcons.minimize,
          color: colorScheme.onSurface.withOpacity(0.7),
          size: 18,
        ),
        tooltip: _isZenMode ? 'Exit Zen mode' : 'Zen mode',
      ),
    );
  }

  Widget _buildCloseHint() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Press Esc to close',
        style: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.6),
          fontSize: 11,
        ),
      ),
    );
  }

  Color _getStateColor(RecordingStateValue state, ColorScheme colorScheme) {
    switch (state) {
      case RecordingStateValue.idle:
        return colorScheme.primary.withOpacity(0.6);
      case RecordingStateValue.listening:
        return colorScheme.primary;
      case RecordingStateValue.voiceDetected:
        return RecordingStateColors.voiceDetected;
      case RecordingStateValue.recording:
        return RecordingStateColors.recording;
      case RecordingStateValue.processing:
        return colorScheme.primary;
    }
  }

  Duration get _currentDuration {
    if (_recordingStartTime == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(_recordingStartTime!);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${seconds.toString().padLeft(2, '0')}';
    }
  }

  int _estimateProcessingTime() {
    final durationSeconds = _currentDuration.inSeconds;
    if (durationSeconds == 0) return 0;
    // Estimate: 15% of audio duration + 5s overhead
    return (durationSeconds * 0.15 + 5).ceil();
  }

  void _manageDurationTimer(RecordingState state) {
    if (state == RecordingState.recording) {
      if (_durationTimer == null || !_durationTimer!.isActive) {
        if (_recordingStartTime == null) {
          _recordingStartTime = DateTime.now();
        }
        _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    } else {
      _durationTimer?.cancel();
      _durationTimer = null;
      if (state == RecordingState.idle) {
        _recordingStartTime = null;
      }
    }
  }

  void _manageAmplitudeUpdates(RecordingState state) {
    if (state == RecordingState.recording) {
      if (_amplitudeUpdateTimer == null || !_amplitudeUpdateTimer!.isActive) {
        _amplitudeUpdateTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
          if (mounted) {
            setState(() {
              _updateAmplitudes();
            });
          }
        });
      }
    } else {
      _amplitudeUpdateTimer?.cancel();
      _amplitudeUpdateTimer = null;
    }
  }

  void _manageProgressTimer(RecordingState state) {
    if (state == RecordingState.processing) {
      if (_progressTimer == null || !_progressTimer!.isActive) {
        // Start processing timer
        if (_processingStartTime == null) {
          _processingStartTime = DateTime.now();
          _processingProgress = 0.0;
        }
        _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
          if (mounted && _processingStartTime != null) {
            final elapsed = DateTime.now().difference(_processingStartTime!).inMilliseconds;
            // Estimate processing time: typical transcription takes 3-8 seconds
            // We'll use 5 seconds as baseline, with 0-90% progress
            final estimatedDuration = 5000;
            final newProgress = (elapsed / estimatedDuration * 0.9).clamp(0.0, 0.9);

            // Update stage based on progress
            String stage = '';
            if (newProgress < 0.3) {
              stage = 'Uploading audio...';
            } else if (newProgress < 0.6) {
              stage = 'Transcribing...';
            } else if (newProgress < 0.9) {
              stage = 'Applying vocabulary...';
            }

            setState(() {
              _processingProgress = newProgress;
              _processingStage = stage;
            });
          }
        });
      }
    } else {
      _progressTimer?.cancel();
      _progressTimer = null;
      if (state == RecordingState.idle) {
        _processingStartTime = null;
        _processingProgress = 0.0;
        _processingStage = '';
      }
    }
  }

  Future<void> _stopRecording() async {
    final currentState = ref.read(recordingStateProvider);

    if (currentState != RecordingState.recording) {
      debugPrint('[VadRecordingOverlay] Not recording, ignoring stop');
      return;
    }

    debugPrint('[VadRecordingOverlay] Stopping recording...');
    final voiceRecordingUseCase = ref.read(voiceRecordingUseCaseProvider);

    try {
      // Simulate processing progress
      setState(() {
        _processingProgress = 0.0;
        _processingStage = 'Uploading';
      });

      await voiceRecordingUseCase.stopRecording();
      await HapticService.stopRecording();
      debugPrint('[VadRecordingOverlay] Recording stopped successfully');
    } catch (e) {
      await HapticService.error();
      debugPrint('[VadRecordingOverlay] Error stopping recording: $e');
      rethrow;
    }
  }
}
