/// Supported transcription languages
class TranscriptionLanguage {
  final String code;
  final String name;
  final String nativeName;

  const TranscriptionLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  /// Whether this is the auto-detect option
  bool get isAuto => code == 'auto';
}

/// Available transcription languages
class TranscriptionLanguages {
  static const List<TranscriptionLanguage> all = [
    TranscriptionLanguage(
      code: 'auto',
      name: 'Auto Detect',
      nativeName: 'Auto Detect',
    ),
    TranscriptionLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
    ),
    TranscriptionLanguage(
      code: 'zh',
      name: 'Chinese',
      nativeName: '中文',
    ),
    TranscriptionLanguage(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
    ),
    TranscriptionLanguage(
      code: 'ko',
      name: 'Korean',
      nativeName: '한국어',
    ),
    TranscriptionLanguage(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
    ),
    TranscriptionLanguage(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
    ),
    TranscriptionLanguage(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
    ),
    TranscriptionLanguage(
      code: 'it',
      name: 'Italian',
      nativeName: 'Italiano',
    ),
    TranscriptionLanguage(
      code: 'pt',
      name: 'Portuguese',
      nativeName: 'Português',
    ),
    TranscriptionLanguage(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Русский',
    ),
    TranscriptionLanguage(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
    ),
    TranscriptionLanguage(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
    ),
    TranscriptionLanguage(
      code: 'th',
      name: 'Thai',
      nativeName: 'ไทย',
    ),
    TranscriptionLanguage(
      code: 'vi',
      name: 'Vietnamese',
      nativeName: 'Tiếng Việt',
    ),
    TranscriptionLanguage(
      code: 'id',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
    ),
    TranscriptionLanguage(
      code: 'ms',
      name: 'Malay',
      nativeName: 'Bahasa Melayu',
    ),
    TranscriptionLanguage(
      code: 'tl',
      name: 'Tagalog',
      nativeName: 'Tagalog',
    ),
    TranscriptionLanguage(
      code: 'nl',
      name: 'Dutch',
      nativeName: 'Nederlands',
    ),
    TranscriptionLanguage(
      code: 'pl',
      name: 'Polish',
      nativeName: 'Polski',
    ),
    TranscriptionLanguage(
      code: 'tr',
      name: 'Turkish',
      nativeName: 'Türkçe',
    ),
    TranscriptionLanguage(
      code: 'uk',
      name: 'Ukrainian',
      nativeName: 'Українська',
    ),
  ];

  /// Find language by code
  static TranscriptionLanguage? findByCode(String code) {
    for (final language in all) {
      if (language.code == code) return language;
    }
    return null;
  }

  /// Default language (auto detect)
  static const TranscriptionLanguage defaultLanguage = TranscriptionLanguage(
    code: 'auto',
    name: 'Auto Detect',
    nativeName: 'Auto Detect',
  );

  /// Get display name for a language code
  static String getDisplayName(String? code) {
    if (code == null || code.isEmpty) return 'Unknown';
    final language = findByCode(code);
    return language?.name ?? code;
  }

  /// Map of common language code variations to standard codes
  static const Map<String, String> _codeAliases = {
    'zh-CN': 'zh',
    'zh-TW': 'zh',
    'zh-Hans': 'zh',
    'zh-Hant': 'zh',
    'en-US': 'en',
    'en-GB': 'en',
    'ja-JP': 'ja',
    'ko-KR': 'ko',
    'es-ES': 'es',
    'es-MX': 'es',
    'fr-FR': 'fr',
    'de-DE': 'de',
    'it-IT': 'it',
    'pt-BR': 'pt',
    'pt-PT': 'pt',
    'ru-RU': 'ru',
    'ar-SA': 'ar',
    'hi-IN': 'hi',
    'th-TH': 'th',
    'vi-VN': 'vi',
    'id-ID': 'id',
    'ms-MY': 'ms',
    'nl-NL': 'nl',
    'pl-PL': 'pl',
    'tr-TR': 'tr',
    'uk-UA': 'uk',
  };

  /// Normalize language code (handle aliases)
  static String normalizeCode(String code) {
    return _codeAliases[code] ?? code;
  }
}
