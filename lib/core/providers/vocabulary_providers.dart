import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vocabulary.dart';
import '../services/storage_service.dart';

/// Vocabulary set management providers
final vocabularyProvider = StateNotifierProvider<VocabularyNotifier, List<VocabularySet>>((ref) {
  return VocabularyNotifier();
});

/// Notifier for managing vocabulary sets
class VocabularyNotifier extends StateNotifier<List<VocabularySet>> {
  VocabularyNotifier() : super(_loadVocabulary());

  static List<VocabularySet> _loadVocabulary() {
    try {
      return StorageService.vocabulary.values.toList();
    } catch (e) {
      debugPrint('[VocabularyNotifier] Failed to load vocabulary: $e');
      return [];
    }
  }

  Future<void> addVocabulary(VocabularySet vocab) async {
    await StorageService.vocabulary.put(vocab.id, vocab);
    state = _loadVocabulary();
  }

  Future<void> updateVocabulary(VocabularySet vocab) async {
    await StorageService.vocabulary.put(vocab.id, vocab);
    state = _loadVocabulary();
  }

  Future<void> deleteVocabulary(String id) async {
    final vocab = StorageService.vocabulary.get(id);
    if (vocab != null && !vocab.isDefault) {
      await StorageService.vocabulary.delete(id);
      state = _loadVocabulary();
    }
  }
}