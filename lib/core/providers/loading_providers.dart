import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier for global loading overlay state
class LoadingOverlayNotifier extends Notifier<LoadingOverlayState> {
  @override
  LoadingOverlayState build() => const LoadingOverlayState();

  void set(LoadingOverlayState value) => state = value;

  void clear() => state = const LoadingOverlayState();
}

/// Global loading overlay provider for app-wide loading states
final loadingOverlayProvider =
    NotifierProvider<LoadingOverlayNotifier, LoadingOverlayState>(
        LoadingOverlayNotifier.new);

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

/// Notifier for feature-specific loading states
class FeatureLoadingNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {};

  void set(Map<String, bool> value) => state = value;
}

/// Feature-specific loading states provider
final featureLoadingProvider =
    NotifierProvider<FeatureLoadingNotifier, Map<String, bool>>(
        FeatureLoadingNotifier.new);

/// Helper methods for managing loading states
extension LoadingOverlayRef on WidgetRef {
  void showLoading([String? message]) {
    read(loadingOverlayProvider.notifier).set(LoadingOverlayState(
      isLoading: true,
      message: message,
    ));
  }

  void hideLoading() {
    read(loadingOverlayProvider.notifier).clear();
  }

  void setFeatureLoading(String feature, bool isLoading) {
    final current = read(featureLoadingProvider);
    final updated = Map<String, bool>.from(current);
    updated[feature] = isLoading;
    read(featureLoadingProvider.notifier).set(updated);
  }

  bool isFeatureLoading(String feature) {
    return read(featureLoadingProvider)[feature] ?? false;
  }
}
