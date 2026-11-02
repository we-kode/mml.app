import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mml_app/models/announcement.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/secure_storage.dart';

/// Loads the announcements of the admins and stores which ones the user
/// dismissed.
class AnnouncementService {
  /// Instance of the announcement service.
  static final AnnouncementService _instance = AnnouncementService._();

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  /// Instance of the [SecureStorageService] to store the settings with.
  final SecureStorageService _store = SecureStorageService.getInstance();

  /// Private constructor of the service.
  AnnouncementService._();

  /// Returns the singleton instance of the [AnnouncementService].
  static AnnouncementService getInstance() {
    return _instance;
  }

  /// Loads the announcements currently valid for this client. Returns an empty
  /// list on errors, e.g. for servers without announcements.
  Future<List<Announcement>> getActive() async {
    try {
      var response = await _apiService.request(
        '/media/notification/active',
        options: Options(
          method: 'GET',
          extra: {ApiService.silentErrorsKey: true},
        ),
      );
      return List<Announcement>.from(
        (response.data as List).map((item) => Announcement.fromJson(item)),
      );
    } catch (e) {
      return [];
    }
  }

  /// Whether the announcements are shown when the app starts.
  Future<bool> showOnStart() async {
    return await _store.get(SecureStorageService.showAnnouncementsStorageKey) !=
        'false';
  }

  /// Sets whether the announcements are shown when the app starts.
  Future<void> setShowOnStart(bool value) async {
    await _store.set(
      SecureStorageService.showAnnouncementsStorageKey,
      value.toString(),
    );
  }

  /// Returns the announcements of [announcements] the user did not dismiss and
  /// forgets dismissed announcements, which are not active anymore.
  Future<List<Announcement>> notDismissed(
    List<Announcement> announcements,
  ) async {
    var versions = announcements.map((a) => a.version).toSet();
    var dismissed = (await _dismissed()).where(versions.contains).toList();
    await _saveDismissed(dismissed);
    return announcements.where((a) => !dismissed.contains(a.version)).toList();
  }

  /// Dismisses the [announcement], so it is not shown on start until the
  /// admin changes it.
  Future<void> dismiss(Announcement announcement) async {
    var dismissed = await _dismissed();
    if (!dismissed.contains(announcement.version)) {
      await _saveDismissed([...dismissed, announcement.version]);
    }
  }

  Future<List<String>> _dismissed() async {
    var value = await _store.get(
      SecureStorageService.dismissedAnnouncementsStorageKey,
    );
    if (value == null) {
      return [];
    }

    try {
      return List<String>.from(jsonDecode(value));
    } on FormatException {
      return [];
    }
  }

  Future<void> _saveDismissed(List<String> dismissed) async {
    await _store.set(
      SecureStorageService.dismissedAnnouncementsStorageKey,
      jsonEncode(dismissed),
    );
  }
}
