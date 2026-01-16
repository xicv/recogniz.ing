import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

/// Provider for the application configuration loaded from config/app_config.json
///
/// This provides centralized access to all configuration values including
/// API settings like the Gemini model name.
final appConfigProvider = FutureProvider<AppConfig>((ref) async {
  return await AppConfig.fromAsset();
});

/// Helper to get the gemini model name from config
final geminiModelProvider = Provider<String>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.when(
    data: (config) => config.api.model,
    loading: () => 'gemini-3-flash-preview', // Fallback while loading
    error: (_, __) => 'gemini-3-flash-preview', // Fallback on error
  );
});
