import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/custom_prompt.dart';
import '../services/storage_service.dart';

/// Notifier for managing custom prompts
class PromptsNotifier extends Notifier<List<CustomPrompt>> {
  @override
  List<CustomPrompt> build() => _loadPrompts();

  static List<CustomPrompt> _loadPrompts() {
    try {
      return StorageService.prompts.values.toList();
    } catch (e) {
      debugPrint('[PromptsNotifier] Failed to load prompts: $e');
      return [];
    }
  }

  Future<void> addPrompt(CustomPrompt prompt) async {
    await StorageService.prompts.put(prompt.id, prompt);
    state = _loadPrompts();
  }

  Future<void> updatePrompt(CustomPrompt prompt) async {
    await StorageService.prompts.put(prompt.id, prompt);
    state = _loadPrompts();
  }

  Future<void> deletePrompt(String id) async {
    final prompt = StorageService.prompts.get(id);
    if (prompt != null && !prompt.isDefault) {
      await StorageService.prompts.delete(id);
      state = _loadPrompts();
    }
  }
}

/// Custom prompt management providers
final promptsProvider =
    NotifierProvider<PromptsNotifier, List<CustomPrompt>>(PromptsNotifier.new);
