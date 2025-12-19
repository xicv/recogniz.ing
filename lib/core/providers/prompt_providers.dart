import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/custom_prompt.dart';
import '../services/storage_service.dart';

/// Custom prompt management providers
final promptsProvider =
    StateNotifierProvider<PromptsNotifier, List<CustomPrompt>>((ref) {
  return PromptsNotifier();
});

/// Notifier for managing custom prompts
class PromptsNotifier extends StateNotifier<List<CustomPrompt>> {
  PromptsNotifier() : super(_loadPrompts());

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
