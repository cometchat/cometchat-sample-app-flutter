/// Domain Layer - Image Cache Entity
class ImageCacheEntity {
  final String key;
  final String url;
  final DateTime? lastModified;
  final DateTime? createdAt;
  final int? sizeInBytes;
  final bool isPersistent;

  ImageCacheEntity({
    required this.key,
    required this.url,
    this.lastModified,
    this.createdAt,
    this.sizeInBytes,
    this.isPersistent = true,
  });

  /// Create a copy with modified fields
  ImageCacheEntity copyWith({
    String? key,
    String? url,
    DateTime? lastModified,
    DateTime? createdAt,
    int? sizeInBytes,
    bool? isPersistent,
  }) {
    return ImageCacheEntity(
      key: key ?? this.key,
      url: url ?? this.url,
      lastModified: lastModified ?? this.lastModified,
      createdAt: createdAt ?? this.createdAt,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      isPersistent: isPersistent ?? this.isPersistent,
    );
  }

  @override
  String toString() {
    return 'ImageCacheEntity(key: $key, url: $url, size: $sizeInBytes bytes)';
  }
}

/// Image cache statistics
class ImageCacheStatsEntity {
  final int totalItems;
  final int totalSizeInBytes;
  final DateTime lastCleaned;
  final int maxCacheObjects;

  ImageCacheStatsEntity({
    required this.totalItems,
    required this.totalSizeInBytes,
    required this.lastCleaned,
    required this.maxCacheObjects,
  });

  @override
  String toString() {
    return 'ImageCacheStatsEntity(items: $totalItems, size: $totalSizeInBytes bytes, maxObjects: $maxCacheObjects)';
  }
}
