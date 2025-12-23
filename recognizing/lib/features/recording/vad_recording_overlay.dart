import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/services/vad_service.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/providers/recording_providers.dart';
import '../../core/providers/settings_providers.dart';

class VadRecordingOverlay extends ConsumerStatefulWidget {
  const VadRecordingOverlay({super.key});

  @override
  ConsumerState<VadRecordingOverlay> createState() => _VadRecordingOverlayState();
}

class _VadRecordingOverlayState extends ConsumerState<VadRecordingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  bool _isInitialized = false;
  double _speechProbability = 0.0;
  bool _hasDetectedSpeech = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _waveController.repeat(reverse: true);

    // Initialize VAD
    _initializeVad();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    VadService.stopListening();
    super.dispose();
  }

  Future<void> _initializeVad() async {
    await VadService.initialize();
    setState(() {
      _isInitialized = true;
    });

    // Start VAD listening
    try {
      await VadService.startListening(
        onSpeechStart: (audioData) {
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

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingStateProvider);
    final duration = ref.watch(recordingDurationProvider);

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main recording circle with VAD visualization
              Stack(
                alignment: Alignment.center,
                children: [
                  // Wave visualization
                  _buildWaveVisualization(),

                  // Recording button
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: UIConstants.fabSize,
                        height: UIConstants.fabSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _hasDetectedSpeech
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary,
                              blurRadius: 30 * _pulseAnimation.value,
                              spreadRadius: 5 * _pulseAnimation.value,
                            ),
                          ],
                        ),
                        child: Icon(
                          recordingState == RecordingState.recording
                              ? LucideIcons.mic
                              : LucideIcons.mic,
                          color: Colors.white,
                          size: 32,
                        ),
                      );
                    },
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

              // Recording info
              Text(
                _formatDuration(duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // VAD status text
              Text(
                _getVadStatusText(),
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  Widget _buildWaveVisualization() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return SizedBox(
          width: UIConstants.fabSize * 2,
          height: UIConstants.fabSize * 2,
          child: CustomPaint(
            painter: WavePainter(
              amplitude: _waveAnimation.value * 20,
              frequency: 4,
              phase: 0,
              color: _hasDetectedSpeech
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
        );
      },
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
      return '🎤 Speaking detected';
    }

    if (_speechProbability > 0.1) {
      return '🔊 Voice detected';
    }

    return '🎤 Listening...';
  }

  Color _getVadStatusColor() {
    if (_hasDetectedSpeech) {
      return Colors.green;
    }

    return Theme.of(context).colorScheme.primary;
  }
}

/// Custom painter for wave visualization
class WavePainter extends CustomPainter {
  final double amplitude;
  final int frequency;
  final double phase;
  final Color color;

  WavePainter({
    required this.amplitude,
    required this.frequency,
    required this.phase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < frequency; i++) {
      final waveRadius = radius - (i * radius / frequency);
      final waveHeight = amplitude * (1 - i / frequency);

      final path = Path();
      for (double angle = 0; angle <= 2 * 3.14159; angle += 0.1) {
        final x = center.dx + waveRadius * cos(angle) * (1 + waveHeight * sin(frequency * angle + phase) / 100);
        final y = center.dy + waveRadius * sin(angle) * (1 + waveHeight * cos(frequency * angle + phase) / 100);

        if (angle == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant, CustomPainter oldDelegate) => true;
}