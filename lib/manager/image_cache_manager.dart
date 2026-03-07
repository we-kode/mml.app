import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mml_app/services/cover_file_service.dart';
import 'package:mml_app/services/secure_storage.dart';

/// Custom image cache manager for the app to load images from the api.
class ImageCacheManager extends CacheManager {
  /// Instance of the manager.
  static ImageCacheManager? _instance;

  /// Instance of the [SecureStorageService] to handle data in the secure storage.
  static final SecureStorageService _storage =
      SecureStorageService.getInstance();

  /// Cache Key for the cache manager.
  static const _key = "mml_wekode_image_cache";

  /// The cache remove time in days.
  int durationLimit = 0;

  static final int _maxObjects = 1000;

  final ValueNotifier<double> cacheSizeMB = ValueNotifier(0);

  /// factory constructor to return the singleton instance of the [ImageCacheManager].
  factory ImageCacheManager() {
    if (_instance == null) {
      throw Exception("CacheManager not initialized. Call init() first.");
    }
    return _instance!;
  }

  /// Inits the cache manager with the limits from the secure storage or defaults.
  static Future<void> init() async {
    final staleDays =
        int.tryParse(
          await _storage.get(SecureStorageService.cacheDurationStorageKey) ??
              "",
        ) ??
        3650; // 10 years as default

    _instance = ImageCacheManager._internal(
      maxNrOfCacheObjects: _maxObjects,
      stalePeriod: Duration(days: staleDays),
    );

    await _instance!._updateCacheSize();
  }

  ImageCacheManager._internal({
    required int maxNrOfCacheObjects,
    required Duration stalePeriod,
  }) : super(
         Config(
           _key,
           fileService: CoverFileService.getInstance(),
           stalePeriod: stalePeriod,
           maxNrOfCacheObjects: maxNrOfCacheObjects,
         ),
       ) {
    durationLimit = stalePeriod.inDays;
  }

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    final stream = super.getFileStream(
      url,
      key: key,
      headers: headers,
      withProgress: withProgress,
    );

    return stream.map((response) {
      if (response is FileInfo) {
        cacheSizeMB.value += response.file.lengthSync() / (1024 * 1024);
      }
      return response;
    });
  }

  /// Returns the current cache size in MB.
  Future<double> size() async {
    int size = await store.getCacheSize();
    return size / (1024 * 1024);
  }

  /// Clears the cache by deleting all files and resetting the cache size.
  Future<void> clearCache() async {
    await emptyCache();
    cacheSizeMB.value = 0;
  }

  /// Updates the cache limits with the given [limits].
  Future<void> updateLimits({int? maxCacheTime}) async {
    if (maxCacheTime == null) {
      return;
    }

    await _storage.set(
      SecureStorageService.cacheDurationStorageKey,
      maxCacheTime.toString(),
    );
    final oldInstance = _instance;
    if (oldInstance != null) {
      await oldInstance.dispose();
    }

    _instance = null;
    await init();
  }

  Future<void> _updateCacheSize() async {
    final newSize = await size();
    cacheSizeMB.value = newSize;
  }
}
