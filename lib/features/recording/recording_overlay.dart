import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/shared/widgets.dart';

class RecordingOverlay extends ConsumerWidget {
  const RecordingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingStateProvider);

    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state == RecordingState.recording) ...[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.mic,
                      size: 40,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.1, 1.1),
                        duration: 800.ms,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.1, 1.1),
                        end: const Offset(1, 1),
                        duration: 800.ms,
                      ),
                  const SizedBox(height: 24),
                  Text(
                    'Recording...',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the mic button to stop',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 24),
                  const _RecordingTimer(),
                ] else if (state == RecordingState.processing) ...[
                  LoadingIndicators.medium(
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Processing...',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sending to Gemini AI for transcription',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  // Only show debug text in debug mode
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Check terminal for debug logs',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.54),
                          ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }
}

class _RecordingTimer extends StatefulWidget {
  const _RecordingTimer();

  @override
  State<_RecordingTimer> createState() => _RecordingTimerState();
}

class _RecordingTimerState extends State<_RecordingTimer> {
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$minutes:$seconds',
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontFeatures: [const FontFeature.tabularFigures()],
        color: AppColors.primaryLight,
      ),
    );
  }
}
