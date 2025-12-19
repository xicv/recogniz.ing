import 'dart:convert';
import 'package:flutter/services.dart';

class PromptItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String template;
  final bool isDefault;

  const PromptItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.template,
    required this.isDefault,
  });
}

class PromptConfig {
  final String version;
  final List<PromptItem> prompts;

  const PromptConfig({
    required this.version,
    required this.prompts,
  });

  static Future<PromptConfig> fromAsset() async {
    final String jsonString =
        await rootBundle.loadString('config/prompts/default_prompts.json');
    final Map<String, dynamic> json = jsonDecode(jsonString);

    return PromptConfig(
      version: json['version'],
      prompts: (json['prompts'] as List)
          .map((prompt) => PromptItem(
                id: prompt['id'],
                name: prompt['name'],
                description: prompt['description'],
                category: prompt['category'],
                template: prompt['template'],
                isDefault: prompt['isDefault'],
              ))
          .toList(),
    );
  }
}
