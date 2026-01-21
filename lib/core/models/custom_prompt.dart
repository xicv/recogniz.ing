import 'package:hive/hive.dart';

part 'custom_prompt.g.dart';

@HiveType(typeId: 1)
class CustomPrompt extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String promptTemplate;

  @HiveField(4)
  final bool isDefault;

  @HiveField(5)
  final DateTime createdAt;

  CustomPrompt({
    required this.id,
    required this.name,
    required this.description,
    required this.promptTemplate,
    this.isDefault = false,
    required this.createdAt,
  });

  CustomPrompt copyWith({
    String? id,
    String? name,
    String? description,
    String? promptTemplate,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CustomPrompt(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      promptTemplate: promptTemplate ?? this.promptTemplate,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Default prompts (optimized for token efficiency)
  static List<CustomPrompt> get defaults => [
        CustomPrompt(
          id: 'default-clean',
          name: 'Clean Transcription',
          description: 'Clean up speech, fix grammar, remove filler words',
          promptTemplate:
              'Fix grammar, remove fillers (um/uh/like), preserve meaning:\n\n{{text}}',
          isDefault: true,
          createdAt: DateTime.now(),
        ),
        CustomPrompt(
          id: 'default-formal',
          name: 'Formal Writing',
          description: 'Convert speech to formal written text',
          promptTemplate:
              'Convert to formal written text with proper structure and professional language:\n\n{{text}}',
          isDefault: true,
          createdAt: DateTime.now(),
        ),
        CustomPrompt(
          id: 'default-bullet',
          name: 'Bullet Points',
          description: 'Convert speech to organized bullet points',
          promptTemplate:
              'Extract and organize key points as bullet points:\n\n{{text}}',
          isDefault: true,
          createdAt: DateTime.now(),
        ),
        CustomPrompt(
          id: 'default-email',
          name: 'Email Draft',
          description: 'Convert speech to email format',
          promptTemplate:
              'Convert to a professional email with greeting and closing:\n\n{{text}}',
          isDefault: true,
          createdAt: DateTime.now(),
        ),
      ];
}
