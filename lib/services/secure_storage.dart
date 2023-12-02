import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service that handles data of the secure storage for the app.
class SecureStorageService {
  /// Instance of the secure storage service.
  static final SecureStorageService _instance = SecureStorageService._();

  /// Instance of the secure storage plugin to access the data from the
  /// secure storage.
  final _storage = const FlutterSecureStorage();

  /// Option to allow secure storage access the keychain of ios when phone is locked and app runs in background.
  final iOSOptions = const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  /// Key under which the app key is persisted.
  static const String appKeyStorageKey = 'appKey';

  /// Key under which the client id is persisted.
  static const String clientIdStorageKey = 'clientId';

  /// Key under which the client secret is persisted.
  static const String clientSecretStorageKey = 'clientSecret';

  /// Key under which the private rsa key is stored.
  static const String rsaPrivateStorageKey = 'rsaPrivate';

  /// Key under which the public rsa key is stored.
  static const String rsaPublicStorageKey = 'rsaPublic';

  /// Key under which the key for encryption is stored.
  static const String cryptoKey = 'crypto';

  /// Key under which the servername is persisted.
  static const String serverNameStorageKey = 'serverName';

  /// Key under which the skip intro flag is stored.
  static const String skipIntroStorageKey = 'skipIntro';

  /// Key under which the access token is persisted.
  static const String accessTokenStorageKey = 'a';

  /// Key under which the hierarchical folder view flag is stored.
  static const String folderViewStorageKey = 'isFolderView';

  /// Key under which the store filters flag is stored
  static const String saveFiltersStorageKey = 'saveFilters';

  /// Private constructor of the service.
  SecureStorageService._();

  /// Returns the singleton instance of the [SecureStorageService].
  static SecureStorageService getInstance() {
    return _instance;
  }

  // Caching values in map for ios phones only, cause when app is inactive for
  // long time in background ios will lock the keychain, so we can not read or
  // write anything until the user restarts the app again.
  final Map<String, String?> _cache = {};

  /// Returns the value persisted under the given [key].
  Future<String?> get(String key) async {
    if (!Platform.isIOS) {
      return await _storage.read(
        key: key,
        iOptions: iOSOptions,
      );
    }

    var cachedValue = _cache[key];
    if (cachedValue == null) {
      _cache[key] = await _storage.read(
        key: key,
        iOptions: iOSOptions,
      );
    }
    return _cache[key];
  }

  /// Returns a boolean, that indicates whether a value is persisted under
  /// the given [key] or not.
  Future<bool> has(String key) async {
    return (await get(key)) != null;
  }

  /// Stores the [value] under the given [key].
  Future<void> set(String key, String? value) async {
    if (Platform.isIOS && key == accessTokenStorageKey) {
      _cache[key] = value;
    }
    return await _storage.write(
      key: key,
      value: value,
      iOptions: iOSOptions,
    );
  }

  /// Deletes the value under the given [key] from the secure storage.
  Future<void> delete(String key) async {
    if (Platform.isIOS) {
      _cache.remove(key);
    }

    await _storage.delete(
      key: key,
      iOptions: iOSOptions,
    );
  }

  /// Deletes all tokens and secure information except the skip intro flag.
  Future<void> clearTokens() async {
    await delete(accessTokenStorageKey);
    await delete(appKeyStorageKey);
    await delete(clientIdStorageKey);
    await delete(clientSecretStorageKey);
    await delete(rsaPrivateStorageKey);
    await delete(rsaPublicStorageKey);
    await delete(serverNameStorageKey);
    await delete(cryptoKey);
  }
}
