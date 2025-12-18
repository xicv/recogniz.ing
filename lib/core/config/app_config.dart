import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfigModel {
  final String version;
  final String buildNumber;
  final String name;

  const AppConfigModel({
    required this.version,
    required this.buildNumber,
    required this.name,
  });
}

class ApiConfig {
  final String model;
  final int maxTokens;
  final double temperature;
  final double topP;
  final int topK;

  const ApiConfig({
    required this.model,
    required this.maxTokens,
    required this.temperature,
    required this.topP,
    required this.topK,
  });
}

class AudioConfig {
  final int sampleRate;
  final int bitDepth;
  final int channels;
  final int maxRecordingDuration;
  final double silenceThreshold;
  final int minRecordingLength;
  final double vadThreshold;
  final double amplitudeThreshold;
  final double speechRatioThreshold;
  final int minFileSize;
  final double minDuration;

  const AudioConfig({
    required this.sampleRate,
    required this.bitDepth,
    required this.channels,
    required this.maxRecordingDuration,
    required this.silenceThreshold,
    required this.minRecordingLength,
    required this.vadThreshold,
    required this.amplitudeThreshold,
    required this.speechRatioThreshold,
    required this.minFileSize,
    required this.minDuration,
  });
}

class UiConfig {
  final FabConfig fab;
  final AnimationConfig animation;
  final DebounceConfig debounce;

  const UiConfig({
    required this.fab,
    required this.animation,
    required this.debounce,
  });
}

class FabConfig {
  final int size;
  final int iconSize;

  const FabConfig({
    required this.size,
    required this.iconSize,
  });
}

class AnimationConfig {
  final DurationConfig duration;

  const AnimationConfig({
    required this.duration,
  });
}

class DurationConfig {
  final int fast;
  final int normal;
  final int slow;

  const DurationConfig({
    required this.fast,
    required this.normal,
    required this.slow,
  });
}

class DebounceConfig {
  final int search;
  final int input;

  const DebounceConfig({
    required this.search,
    required this.input,
  });
}

class StorageConfig {
  final int maxTranscriptionsPerPage;
  final int maxHistoryEntries;
  final String cacheSize;

  const StorageConfig({
    required this.maxTranscriptionsPerPage,
    required this.maxHistoryEntries,
    required this.cacheSize,
  });
}

class FeaturesConfig {
  final GlobalHotkeysConfig globalHotkeys;
  final SystemTrayConfig systemTray;
  final AutoSaveConfig autoSave;

  const FeaturesConfig({
    required this.globalHotkeys,
    required this.systemTray,
    required this.autoSave,
  });
}

class GlobalHotkeysConfig {
  final bool enabled;
  final String defaultShortcut;

  const GlobalHotkeysConfig({
    required this.enabled,
    required this.defaultShortcut,
  });
}

class SystemTrayConfig {
  final bool enabled;
  final bool showOnStartup;

  const SystemTrayConfig({
    required this.enabled,
    required this.showOnStartup,
  });
}

class AutoSaveConfig {
  final bool enabled;
  final int interval;

  const AutoSaveConfig({
    required this.enabled,
    required this.interval,
  });
}

class AppConfig {
  final AppConfigModel app;
  final ApiConfig api;
  final AudioConfig audio;
  final UiConfig ui;
  final StorageConfig storage;
  final FeaturesConfig features;

  const AppConfig({
    required this.app,
    required this.api,
    required this.audio,
    required this.ui,
    required this.storage,
    required this.features,
  });

  static Future<AppConfig> fromAsset() async {
    final String jsonString = await rootBundle.loadString('config/app_config.json');
    final Map<String, dynamic> json = jsonDecode(jsonString);

    return AppConfig(
      app: AppConfigModel(
        version: json['app']['version'],
        buildNumber: json['app']['buildNumber'],
        name: json['app']['name'],
      ),
      api: ApiConfig(
        model: json['api']['gemini']['model'],
        maxTokens: json['api']['gemini']['maxTokens'],
        temperature: json['api']['gemini']['temperature'].toDouble(),
        topP: json['api']['gemini']['topP'].toDouble(),
        topK: json['api']['gemini']['topK'],
      ),
      audio: AudioConfig(
        sampleRate: json['audio']['sampleRate'],
        bitDepth: json['audio']['bitDepth'],
        channels: json['audio']['channels'],
        maxRecordingDuration: json['audio']['maxRecordingDuration'],
        silenceThreshold: json['audio']['silenceThreshold'].toDouble(),
        minRecordingLength: json['audio']['minRecordingLength'],
        vadThreshold: json['audio']['vadThreshold'].toDouble(),
        amplitudeThreshold: json['audio']['amplitudeThreshold'].toDouble(),
        speechRatioThreshold: json['audio']['speechRatioThreshold'].toDouble(),
        minFileSize: json['audio']['minFileSize'],
        minDuration: json['audio']['minDuration'].toDouble(),
      ),
      ui: UiConfig(
        fab: FabConfig(
          size: json['ui']['fab']['size'],
          iconSize: json['ui']['fab']['iconSize'],
        ),
        animation: AnimationConfig(
          duration: DurationConfig(
            fast: json['ui']['animation']['duration']['fast'],
            normal: json['ui']['animation']['duration']['normal'],
            slow: json['ui']['animation']['duration']['slow'],
          ),
        ),
        debounce: DebounceConfig(
          search: json['ui']['debounce']['search'],
          input: json['ui']['debounce']['input'],
        ),
      ),
      storage: StorageConfig(
        maxTranscriptionsPerPage: json['storage']['maxTranscriptionsPerPage'],
        maxHistoryEntries: json['storage']['maxHistoryEntries'],
        cacheSize: json['storage']['cacheSize'],
      ),
      features: FeaturesConfig(
        globalHotkeys: GlobalHotkeysConfig(
          enabled: json['features']['globalHotkeys']['enabled'],
          defaultShortcut: json['features']['globalHotkeys']['defaultShortcut'],
        ),
        systemTray: SystemTrayConfig(
          enabled: json['features']['systemTray']['enabled'],
          showOnStartup: json['features']['systemTray']['showOnStartup'],
        ),
        autoSave: AutoSaveConfig(
          enabled: json['features']['autoSave']['enabled'],
          interval: json['features']['autoSave']['interval'],
        ),
      ),
    );
  }
}