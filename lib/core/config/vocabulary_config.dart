import 'dart:convert';
import 'package:flutter/services.dart';

class VocabularyItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> words;
  final bool isDefault;

  const VocabularyItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.words,
    required this.isDefault,
  });
}

class VocabularyConfig {
  final String version;
  final List<VocabularyItem> vocabularies;

  const VocabularyConfig({
    required this.version,
    required this.vocabularies,
  });

  static Future<VocabularyConfig> fromAsset() async {
    final String jsonString = await rootBundle.loadString('config/vocabulary/default_vocabulary.json');
    final Map<String, dynamic> json = jsonDecode(jsonString);

    return VocabularyConfig(
      version: json['version'],
      vocabularies: (json['vocabularies'] as List)
          .map((vocab) => VocabularyItem(
                id: vocab['id'],
                name: vocab['name'],
                description: vocab['description'],
                category: vocab['category'],
                words: List<String>.from(vocab['words']),
                isDefault: vocab['isDefault'],
              ))
          .toList(),
    );
  }
}