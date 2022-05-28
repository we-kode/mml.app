import 'package:shared_preferences/shared_preferences.dart';

/// Service that handles data of the local storage for the app.
///
/// Do not store critical information in this service. For crtitical information use [SecureStorageService]
class LocalStorageService {
  /// Instance of the local storage service.
  static final LocalStorageService _instance = LocalStorageService._();

  /// Key under which the skipintro falg is saved
  static const String skipIntro = 'skipIntro';

  /// Instance of the lcoal storage plugin to access the data from the
  /// local storage.
  late SharedPreferences _storage;

  /// Private constructor of the service.
  LocalStorageService._();

  Future _initLocalStorage() async {
    _storage = await SharedPreferences.getInstance();
  }

  /// Returns the singleton instance of the [LocalStorageService].
  static Future<LocalStorageService> getInstance() async {
    await _instance._initLocalStorage();
    return _instance;
  }

  /// Returns the value persisted under the given [key].
  T? get<T>(String key) {
    return _storage.get(key) as T?;
  }

  /// Returns a boolean, that indicates whether a value is persisted under
  /// the given [key] or not.
  bool has(String key) {
    return _storage.containsKey(key);
  }

  /// Stores the [value] under the given [key].
  Future<void> set(String key, String value) async {
    await _storage.setString(key, value);
  }

  /// Deletes the value under the given [key] from the secure storage.
  Future<void> delete(String key) async {
    await _storage.remove(key);
  }

  /// Stores the [value] under the given [key].
  Future<void> setBool(String key, bool value) async {
    await _storage.setBool(key, value);
  }
}
