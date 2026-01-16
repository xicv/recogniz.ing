import 'package:hive/hive.dart';

part 'vocabulary.g.dart';

@HiveType(typeId: 2)
class VocabularySet extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<String> words;

  @HiveField(4)
  final bool isDefault;

  @HiveField(5)
  final DateTime createdAt;

  VocabularySet({
    required this.id,
    required this.name,
    required this.description,
    required this.words,
    this.isDefault = false,
    required this.createdAt,
  });

  VocabularySet copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? words,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return VocabularySet(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      words: words ?? this.words,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get wordsAsString => words.join(', ');

  // Default vocabulary sets
  static List<VocabularySet> get defaults => [
        VocabularySet(
          id: 'default-general',
          name: 'General',
          description: 'Common words and phrases',
          words: [
            'AI',
            'API',
            'UI',
            'UX',
            'iOS',
            'Android',
            'macOS',
            'Windows',
            'GitHub',
            'Google',
            'Flutter',
            'Dart',
            'JavaScript',
            'Python',
            'machine learning',
            'deep learning',
            'neural network',
          ],
          isDefault: true,
          createdAt: DateTime.now(),
        ),
        VocabularySet(
          id: 'default-tech',
          name: 'Technology',
          description: 'Tech industry terminology',
          words: [
            'Kubernetes',
            'Docker',
            'AWS',
            'Azure',
            'GCP',
            'PostgreSQL',
            'MongoDB',
            'React',
            'Vue',
            'Angular',
            'Node.js',
            'TypeScript',
            'GraphQL',
            'REST',
            'microservices',
            'serverless',
            'DevOps',
            'CI/CD',
            'agile',
            'scrum',
          ],
          isDefault: true,
          createdAt: DateTime.now(),
        ),
        VocabularySet(
          id: 'default-business',
          name: 'Business',
          description: 'Business and corporate terminology',
          words: [
            'ROI',
            'KPI',
            'B2B',
            'B2C',
            'SaaS',
            'PaaS',
            'stakeholder',
            'synergy',
            'leverage',
            'scalable',
            'monetize',
            'pivot',
            'runway',
            'valuation',
            'acquisition',
            'merger',
            'IPO',
            'venture capital',
            'seed funding',
          ],
          isDefault: true,
          createdAt: DateTime.now(),
        ),
      ];
}
