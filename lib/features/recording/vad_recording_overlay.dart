import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/services/vad_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/providers/recording_providers.dart';
import '../../core/providers/ui_providers.dart';
import '../../core/providers/settings_providers.dart';
import '../../widgets/recording/audio_waveform_display.dart';

class VadRecordingOverlay extends ConsumerStatefulWidget {
  const VadRecordingOverlay({super.key});

  @override
  ConsumerState<VadRecordingOverlay> createState() =>
      _VadRecordingOverlayState();
}

class _VadRecordingOverlayState extends ConsumerState<VadRecordingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize VAD
    _initializeVad();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _durationTimer?.cancel();
    _amplitudeUpdateTimer?.cancel();
    VadService.stopListening();
    super.dispose();
  }

  Future<void> _initializeVad() async {
    await VadService.initialize();
    await HapticService.initialize();

    setState(() {
      _isInitialized = true;
    });

    // Start VAD listening
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
      print('Error starting VAD: $e');
    }
  }

  void _updateAmplitudes() {
    if (_audioAmplitudes.length >= _maxAmplitudes) {
      _audioAmplitudes.removeAt(0);
    }
    // Use speech probability as amplitude for visualization
    // Add some variation for more dynamic appearance
    final baseAmplitude = _speechProbability;
    final variation = (Random().nextDouble() - 0.5) * 0.2;
    final amplitude = (baseAmplitude + variation).clamp(0.0, 1.0);
    _audioAmplitudes.add(amplitude);
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingStateProvider);

    // Manage timer based on recording state
    _manageDurationTimer(recordingState);
    _manageAmplitudeUpdates(recordingState);

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main recording circle with real audio waveform visualization
              Stack(
                alignment: Alignment.center,
                children: [
                  // Real audio waveform visualization
                  CircularAudioWaveform(
                    amplitude: _speechProbability,
                    color: _hasDetectedSpeech
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                  ),

                  // Recording button with stop functionality
                  GestureDetector(
                    onTap: recordingState == RecordingState.recording
                        ? _stopRecording
                        : null,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 80.0,
                          height: 80.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _hasDetectedSpeech
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: _hasDetectedSpeech
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.primary,
                                blurRadius: 30 * _pulseAnimation.value,
                                spreadRadius: 5 * _pulseAnimation.value,
                              ),
                            ],
                          ),
                          child: Icon(
                            recordingState == RecordingState.recording
                                ? LucideIcons.square
                                : LucideIcons.mic,
                            color: Colors.white,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),

                  // VAD status indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getVadStatusColor(),
                        boxShadow: [
                          BoxShadow(
                            color: _getVadStatusColor(),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Real-time bar waveform visualization
              AudioWaveformDisplay(
                amplitudes: _audioAmplitudes,
                maxBars: _maxAmplitudes,
                isSpeechDetected: _hasDetectedSpeech,
              ),

              const SizedBox(height: 32),

              // Stop button (shown when recording)
              if (recordingState == RecordingState.recording)
                GestureDetector(
                  onTap: () async {
                    await HapticService.mediumImpact();
                    _stopRecording();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.square, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Stop Recording',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Recording info
              Text(
                _formatDuration(_currentDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Recording status text - reflects actual recording state
              Text(
                _getRecordingStatusText(recordingState),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Status indicators
              if (_isInitialized) ...[
                _buildStatusIndicator(
                  'Speech Detection',
                  _hasDetectedSpeech,
                  LucideIcons.activity,
                ),
                const SizedBox(height: 12),
                _buildStatusIndicator(
                  'Audio Quality',
                  true,
                  LucideIcons.checkCircle,
                ),
              ],

              const SizedBox(height: 40),

              // Instructions
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.info,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Voice activity detection is active',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final settings = ref.watch(settingsProvider);
                        final message = settings.autoStopAfterSilence
                            ? 'Auto-stops after ${settings.silenceDuration}s of silence'
                            : 'Press stop button when finished';
                        return Text(
                          message,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool active, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: active ? Colors.green : Colors.white.withOpacity(0.5),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.green : Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
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

  String _getVadStatusText() {
    if (!_isInitialized) {
      return 'Initializing voice detection...';
    }

    if (_hasDetectedSpeech) {
      return 'Speaking detected';
    }

    if (_speechProbability > 0.1) {
      return 'Voice detected';
    }

    return 'Listening...';
  }

  String _getRecordingStatusText(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return 'Ready to record';
      case RecordingState.recording:
        return _getVadStatusText();
      case RecordingState.processing:
        return 'Processing transcription...';
    }
  }

  Color _getVadStatusColor() {
    if (_hasDetectedSpeech) {
      return Colors.green;
    }

    return Theme.of(context).colorScheme.primary;
  }

  Duration get _currentDuration {
    if (_recordingStartTime == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(_recordingStartTime!);
  }

  void _manageDurationTimer(RecordingState state) {
    if (state == RecordingState.recording) {
      // Start timer if not already running
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
      // Stop timer and reset if not recording
      _durationTimer?.cancel();
      _durationTimer = null;
      if (state == RecordingState.idle) {
        _recordingStartTime = null;
      }
    }
  }

  void _manageAmplitudeUpdates(RecordingState state) {
    if (state == RecordingState.recording) {
      // Start amplitude updates if not already running
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
      // Stop amplitude updates
      _amplitudeUpdateTimer?.cancel();
      _amplitudeUpdateTimer = null;
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
