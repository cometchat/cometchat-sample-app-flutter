/// Cache Entity - Domain Model
/// Represents cached data in the domain layer
class CacheEntity<T> {
  /// Unique cache key
  final String key;

  /// Cached value
  final T value;

  /// Cache expiration time
  final DateTime? expiresAt;

  /// When cache was created
  final DateTime createdAt;

  /// Whether cache is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Constructor
  const CacheEntity({
    required this.key,
    required this.value,
    required this.createdAt,
    this.expiresAt,
  });

  /// Copy with method
  CacheEntity<T> copyWith({
    String? key,
    T? value,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return CacheEntity(
      key: key ?? this.key,
      value: value ?? this.value,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CacheEntity{key: $key, isExpired: $isExpired, createdAt: $createdAt, expiresAt: $expiresAt}';
  }
}

/// Enum for cache strategies
enum CacheStrategy {
  /// Always fetch fresh data
  alwaysFresh,

  /// Use cache if available
  preferCache,

  /// Use cache only
  cacheOnly,

  /// Network only
  networkOnly,
}
