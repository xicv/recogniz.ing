import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global loading overlay provider for app-wide loading states
final loadingOverlayProvider = StateProvider<LoadingOverlayState>((ref) {
  return const LoadingOverlayState();
});

/// State for the global loading overlay
class LoadingOverlayState {
  final bool isLoading;
  final String? message;
  final bool dismissible;

  const LoadingOverlayState({
    this.isLoading = false,
    this.message,
    this.dismissible = false,
  });

  LoadingOverlayState copyWith({
    bool? isLoading,
    String? message,
    bool? dismissible,
  }) {
    return LoadingOverlayState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      dismissible: dismissible ?? this.dismissible,
    );
  }
}

/// Feature-specific loading states provider
final featureLoadingProvider = StateProvider<Map<String, bool>>((ref) => {});

/// Helper methods for managing loading states
extension LoadingOverlayRef on WidgetRef {
  void showLoading([String? message]) {
    read(loadingOverlayProvider.notifier).state = LoadingOverlayState(
      isLoading: true,
      message: message,
    );
  }

  void hideLoading() {
    read(loadingOverlayProvider.notifier).state = const LoadingOverlayState();
  }

  void setFeatureLoading(String feature, bool isLoading) {
    final current = read(featureLoadingProvider);
    final updated = Map<String, bool>.from(current);
    updated[feature] = isLoading;
    read(featureLoadingProvider.notifier).state = updated;
  }

  bool isFeatureLoading(String feature) {
    return read(featureLoadingProvider)[feature] ?? false;
  }
}
