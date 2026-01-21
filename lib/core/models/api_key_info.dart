import 'package:hive/hive.dart';

part 'api_key_info.g.dart';

/// Model representing a stored API key with metadata
///
/// Features:
/// - Unique ID for tracking
/// - User-friendly name/label
/// - Rate limit tracking with timestamp
/// - Selection state for active key
@HiveType(typeId: 13)
class ApiKeyInfo extends HiveObject {
  /// Unique identifier for this API key entry
  @HiveField(0)
  final String id;

  /// User-friendly name for this API key
  @HiveField(1)
  final String name;

  /// The actual API key (stored encrypted at rest in production)
  @HiveField(2)
  final String apiKey;

  /// When this key was added
  @HiveField(3)
  final DateTime createdAt;

  /// When this key was marked as rate limited
  @HiveField(4)
  final DateTime? rateLimitedAt;

  /// Whether this key is currently selected for use
  /// Note: Only one key should be selected at a time
  @HiveField(5)
  final bool isSelected;

  ApiKeyInfo({
    required this.id,
    required this.name,
    required this.apiKey,
    required this.createdAt,
    this.rateLimitedAt,
    this.isSelected = false,
  });

  /// Whether this key is currently rate limited
  ///
  /// Rate limits typically reset after a cooldown period.
  /// Gemini free tier limits usually reset daily.
  bool get isRateLimited => rateLimitedAt != null;

  /// Check if the rate limit should have expired
  ///
  /// Gemini rate limits typically reset after 24 hours or sometimes sooner.
  /// This provides a grace period for users to retry.
  bool get isRateLimitExpired {
    if (rateLimitedAt == null) return true;
    // 24 hour cooldown for rate limits
    final cooldownPeriod = const Duration(hours: 24);
    return DateTime.now().isAfter(rateLimitedAt!.add(cooldownPeriod));
  }

  /// Get a masked version of the API key for display
  String get maskedKey {
    if (apiKey.length <= 8) return '***';
    return '${apiKey.substring(0, 8)}...${apiKey.substring(apiKey.length - 4)}';
  }

  /// Create a copy with modified fields
  ApiKeyInfo copyWith({
    String? id,
    String? name,
    String? apiKey,
    DateTime? createdAt,
    DateTime? rateLimitedAt,
    bool? isSelected,
    bool clearRateLimit = false,
  }) {
    return ApiKeyInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      apiKey: apiKey ?? this.apiKey,
      createdAt: createdAt ?? this.createdAt,
      rateLimitedAt: clearRateLimit ? null : (rateLimitedAt ?? this.rateLimitedAt),
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Create an ApiKeyInfo with a generated ID
  factory ApiKeyInfo.create({
    required String name,
    required String apiKey,
    bool isSelected = false,
  }) {
    return ApiKeyInfo(
      id: _generateId(),
      name: name,
      apiKey: apiKey,
      createdAt: DateTime.now(),
      isSelected: isSelected,
    );
  }

  /// Generate a unique ID for the API key
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'key_${timestamp}_$random';
  }
}
