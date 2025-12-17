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

  // Default prompts
  static List<CustomPrompt> get defaults => [
        CustomPrompt(
          id: 'default-clean',
          name: 'Clean Transcription',
          description: 'Clean up speech, fix grammar, remove filler words',
          promptTemplate:
              '''You are a transcription assistant. Clean up the following speech transcription:
- Fix grammar and punctuation
- Remove filler words (um, uh, like, you know)
- Keep the original meaning intact
- Output only the cleaned text, nothing else

Transcription: {{text}}''',
          isDefault: true,
          createdAt: DateTime.now(),
        ),
        CustomPrompt(
          id: 'default-formal',
          name: 'Formal Writing',
          description: 'Convert speech to formal written text',
          promptTemplate:
              '''Convert the following speech transcription into formal written text:
- Use professional language
- Structure into proper paragraphs if needed
- Fix all grammar and punctuation
- Output only the formal text, nothing else

Transcription: {{text}}''',
          isDefault: true,
          createdAt: DateTime.now(),
        ),
        CustomPrompt(
          id: 'default-bullet',
          name: 'Bullet Points',
          description: 'Convert speech to organized bullet points',
          promptTemplate:
              '''Convert the following speech transcription into organized bullet points:
- Extract key points
- Use clear, concise language
- Group related points together
- Output only the bullet points, nothing else

Transcription: {{text}}''',
          isDefault: true,
          createdAt: DateTime.now(),
        ),
        CustomPrompt(
          id: 'default-email',
          name: 'Email Draft',
          description: 'Convert speech to email format',
          promptTemplate:
              '''Convert the following speech transcription into a professional email:
- Add appropriate greeting and closing
- Structure the content clearly
- Use professional tone
- Output only the email, nothing else

Transcription: {{text}}''',
          isDefault: true,
          createdAt: DateTime.now(),
        ),
      ];
}
