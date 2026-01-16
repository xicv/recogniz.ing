import 'dart:math';
import 'package:flutter/material.dart';

/// Audio waveform visualization widget that displays real-time audio amplitude.
///
/// This widget creates a bar-based waveform visualization where each bar
/// represents the amplitude of audio at a point in time. The waveform
/// updates dynamically as new audio data is received.
///
/// Material Design 3 Principles Applied:
/// - Uses colorScheme colors for proper theming
/// - Smooth animations with proper duration
/// - Accessible sizing with proper touch targets
class AudioWaveformDisplay extends StatefulWidget {
  /// List of amplitude values (0.0 to 1.0) representing audio intensity.
  final List<double> amplitudes;

  /// Maximum number of amplitude bars to display.
  final int maxBars;

  /// Primary color for the waveform bars.
  final Color? color;

  /// Whether speech is currently detected (affects bar styling).
  final bool isSpeechDetected;

  const AudioWaveformDisplay({
    required this.amplitudes,
    this.maxBars = 40,
    this.color,
    this.isSpeechDetected = false,
    super.key,
  });

  @override
  State<AudioWaveformDisplay> createState() => _AudioWaveformDisplayState();
}

class _AudioWaveformDisplayState extends State<AudioWaveformDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = widget.color ??
        (widget.isSpeechDetected ? colorScheme.secondary : colorScheme.primary);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(280, 80),
          painter: _AudioWaveformPainter(
            amplitudes: widget.amplitudes,
            maxBars: widget.maxBars,
            color: primaryColor,
            isSpeechDetected: widget.isSpeechDetected,
          ),
        );
      },
    );
  }
}

/// Custom painter for audio waveform visualization.
///
/// Draws a series of vertical bars representing audio amplitude.
/// Each bar's height corresponds to the amplitude value, creating
/// a waveform pattern that responds to audio input.
class _AudioWaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final int maxBars;
  final Color color;
  final bool isSpeechDetected;

  _AudioWaveformPainter({
    required this.amplitudes,
    required this.maxBars,
    required this.color,
    required this.isSpeechDetected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final barWidth = 4.0;
    final barSpacing = 3.0;
    final totalBarWidth = barWidth + barSpacing;
    final center = size.height / 2;

    // Calculate visible bars (most recent)
    final visibleCount = min(amplitudes.length, maxBars);
    final startIndex = amplitudes.length - visibleCount;

    // Calculate total width and center it
    final totalWidth = visibleCount * totalBarWidth;
    final startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < visibleCount; i++) {
      final amplitude = amplitudes[startIndex + i].clamp(0.0, 1.0);
      final barHeight = amplitude * (size.height * 0.8);
      final x = startX + i * totalBarWidth;

      // Create gradient for the bar
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.9),
          color.withValues(alpha: 0.5),
          color.withValues(alpha: 0.3),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCenter(
            center: Offset(x, center),
            width: barWidth,
            height: barHeight,
          ),
        )
        ..style = PaintingStyle.fill;

      // Draw rounded bar extending from center
      final rRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, center),
          width: barWidth,
          height: barHeight,
        ),
        Radius.circular(barWidth / 2),
      );

      canvas.drawRRect(rRect, paint);

      // Add glow effect for speech detected
      if (isSpeechDetected && amplitude > 0.3) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawRRect(rRect, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Circular waveform visualization for recording overlay.
///
/// Creates a circular waveform that radiates from the center,
/// simulating a pulsing effect based on audio amplitude.
class CircularAudioWaveform extends StatelessWidget {
  /// Current amplitude value (0.0 to 1.0).
  final double amplitude;

  /// Primary color for the waveform.
  final Color? color;

  /// Number of wave circles to display.
  final int waveCount;

  const CircularAudioWaveform({
    required this.amplitude,
    this.color,
    this.waveCount = 3,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = color ?? colorScheme.primary;

    return SizedBox(
      width: 140,
      height: 140,
      child: CustomPaint(
        painter: _CircularWavePainter(
          amplitude: amplitude,
          color: primaryColor,
          waveCount: waveCount,
        ),
      ),
    );
  }
}

class _CircularWavePainter extends CustomPainter {
  final double amplitude;
  final Color color;
  final int waveCount;

  _CircularWavePainter({
    required this.amplitude,
    required this.color,
    required this.waveCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = 40.0;

    for (int i = 0; i < waveCount; i++) {
      final waveOffset = i * 0.3;
      final waveAmplitude = (amplitude - waveOffset).clamp(0.0, 1.0);
      final radius = baseRadius + (waveAmplitude * 25);

      if (waveAmplitude > 0.01) {
        final paint = Paint()
          ..color = color.withValues(alpha: 0.3 * waveAmplitude)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
