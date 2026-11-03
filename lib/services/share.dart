import 'package:dio/dio.dart';
import 'package:mml_app/models/record_folder.dart';
import 'package:mml_app/models/share_check.dart';
import 'package:mml_app/models/share_link_info.dart';
import 'package:mml_app/models/share_options.dart';
import 'package:mml_app/models/share_settings.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/secure_storage.dart';

/// Service that handles the sharing of download links for records.
class ShareService {
  /// Instance of the share service.
  static final ShareService _instance = ShareService._();

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  /// Instance of the [SecureStorageService] the cached values are stored in.
  final SecureStorageService _store = SecureStorageService.getInstance();

  /// Request extras, that suppress the messages of the default error handling.
  static const Map<String, dynamic> _silent = {
    ApiService.silentErrorsKey: true,
  };

  /// Names of the values of the stored rights and defaults.
  static const String _canShareKey = 'canShare';
  static const String _userChoosesOptionsKey = 'userChoosesOptions';
  static const String _hasLinksKey = 'hasLinks';
  static const String _validForHoursKey = 'validForHours';
  static const String _singleUseKey = 'singleUse';
  static const String _useDefaultsKey = 'useDefaults';

  /// The running refresh, so parallel calls wait for the same request.
  Future<void>? _refreshing;

  /// Private constructor of the service.
  ShareService._();

  /// Returns the singleton instance of the [ShareService].
  static ShareService getInstance() {
    return _instance;
  }

  /// Loads whether the user may share records and the settings of the server
  /// and caches them, so they are available without connection. The cached
  /// values stay untouched, if the server cannot be reached. Parallel calls wait
  /// for the same request.
  Future<void> refresh() {
    return _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  }

  Future<void> _refresh() async {
    try {
      final capability = await _apiService.request(
        '/media/share/capability',
        options: Options(method: 'GET', extra: _silent),
      );
      final settings = await _apiService.request(
        '/media/share/settings',
        options: Options(method: 'GET', extra: _silent),
      );

      await _store.setJson(SecureStorageService.shareStateStorageKey, {
        _canShareKey: capability.data == true,
        _userChoosesOptionsKey: ShareSettings.fromJson(
          settings.data,
        ).userSettingsAllowed,
        _hasLinksKey: (await getLinks(silent: true)).isNotEmpty,
      });
    } catch (_) {
      // Keep the cached values, errors are handled by the api service.
    }
  }

  /// Whether the user may share records, as last known. Never needs a
  /// connection.
  Future<bool> canShare() async {
    return await _state(_canShareKey);
  }

  /// Whether the user may choose the options of share links, as last known.
  /// Never needs a connection.
  Future<bool> userChoosesOptions() async {
    return await canShare() && await _state(_userChoosesOptionsKey);
  }

  /// Whether the user has active share links, as last known. Never needs a
  /// connection.
  Future<bool> hasLinks() async {
    return await _state(_hasLinksKey);
  }

  /// Remembers whether the user has active share links.
  Future<void> rememberLinks(bool hasLinks) async {
    final state = await _store.getJson(
      SecureStorageService.shareStateStorageKey,
    );
    await _store.setJson(SecureStorageService.shareStateStorageKey, {
      ...state,
      _hasLinksKey: hasLinks,
    });
  }

  Future<bool> _state(String key) async {
    final state = await _store.getJson(
      SecureStorageService.shareStateStorageKey,
    );
    return state[key] == true;
  }

  /// Loads the active share links of the user.
  Future<List<ShareLinkInfo>> getLinks({bool silent = false}) async {
    final response = await _apiService.request(
      '/media/share/links',
      options: Options(method: 'GET', extra: silent ? _silent : null),
    );

    return List<ShareLinkInfo>.from(
      (response.data as List).map((e) => ShareLinkInfo.fromJson(e)),
    );
  }

  /// Deletes the share link with the [id], so it can not be used anymore.
  Future<void> deleteLink(String id) async {
    await _apiService.request(
      '/media/share/$id',
      options: Options(method: 'DELETE'),
    );
  }

  /// Loads the options used as defaults for new share links.
  Future<ShareOptions> loadDefaults() async {
    final defaults = await _store.getJson(
      SecureStorageService.shareDefaultsStorageKey,
    );
    final hours = defaults[_validForHoursKey];

    return ShareOptions(
      validForHours: ShareOptions.validForHoursChoices.contains(hours)
          ? hours as int
          : ShareOptions.validForHoursChoices.last,
      singleUse: defaults[_singleUseKey] != false,
    );
  }

  /// Whether share links are created with the defaults without asking.
  Future<bool> useDefaults() async {
    final defaults = await _store.getJson(
      SecureStorageService.shareDefaultsStorageKey,
    );
    return defaults[_useDefaultsKey] == true;
  }

  /// Saves the [options] as defaults and whether they are used without asking.
  Future<void> saveDefaults(ShareOptions options, bool useDefaults) async {
    await _store.setJson(SecureStorageService.shareDefaultsStorageKey, {
      _validForHoursKey: options.validForHours,
      _singleUseKey: options.singleUse,
      _useDefaultsKey: useDefaults,
    });
  }

  /// Checks how many of the records with the [recordIds] and within the
  /// [folders] the user may share.
  Future<ShareCheck> check(
    List<String> recordIds,
    List<RecordFolder> folders,
  ) async {
    final response = await _apiService.request(
      '/media/share/check',
      data: _body(recordIds, folders),
      options: Options(
        method: 'POST',
        contentType: Headers.jsonContentType,
        extra: _silent,
      ),
    );

    return ShareCheck.fromJson(response.data);
  }

  /// Creates a download link for the records with the [recordIds] and within
  /// the [folders] and returns its url. The server decides about the
  /// [options], if the user may not choose them.
  Future<Uri> create(
    List<String> recordIds,
    List<RecordFolder> folders,
    ShareOptions? options,
  ) async {
    final response = await _apiService.request(
      '/media/share',
      data: {
        ..._body(recordIds, folders),
        if (options != null) 'validForHours': options.validForHours,
        if (options != null) 'singleUse': options.singleUse,
      },
      options: Options(method: 'POST', contentType: Headers.jsonContentType),
    );
    await rememberLinks(true);
    final serverName = await _store.get(
      SecureStorageService.serverNameStorageKey,
    );

    return Uri.parse(
      'https://$serverName/s/download/${response.data['token']}',
    );
  }

  Map<String, dynamic> _body(
    List<String> recordIds,
    List<RecordFolder> folders,
  ) {
    return {
      'records': recordIds,
      'folders': folders
          .map((e) => {'year': e.year, 'month': e.month, 'day': e.day})
          .toList(),
    };
  }
}
