import 'package:hive/hive.dart';

part 'transcription.g.dart';

@HiveType(typeId: 0)
class Transcription extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String rawText;

  @HiveField(2)
  final String processedText;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int tokenUsage;

  @HiveField(5)
  final String promptId;

  @HiveField(6)
  final double audioDurationSeconds;

  Transcription({
    required this.id,
    required this.rawText,
    required this.processedText,
    required this.createdAt,
    required this.tokenUsage,
    required this.promptId,
    required this.audioDurationSeconds,
  });

  Transcription copyWith({
    String? id,
    String? rawText,
    String? processedText,
    DateTime? createdAt,
    int? tokenUsage,
    String? promptId,
    double? audioDurationSeconds,
  }) {
    return Transcription(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      processedText: processedText ?? this.processedText,
      createdAt: createdAt ?? this.createdAt,
      tokenUsage: tokenUsage ?? this.tokenUsage,
      promptId: promptId ?? this.promptId,
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
    );
  }
}
