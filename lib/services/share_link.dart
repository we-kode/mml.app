import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:mml_app/models/share_link.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/record.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:mml_app/view_models/records/overview.dart';
import 'package:share_plus/share_plus.dart';

/// Service that creates links to searches and records and opens the links the
/// app receives.
class ShareLinkService {
  /// Instance of the share link service.
  static final ShareLinkService _instance = ShareLinkService._();

  /// Instance of the [SecureStorageService] the server name is read from.
  final SecureStorageService _store = SecureStorageService.getInstance();

  /// Instance of the [ApiService] the stored searches are accessed with.
  final ApiService _apiService = ApiService.getInstance();

  /// Link received before the app was ready to open it.
  Uri? _pending;

  /// Search link, that is applied when the records screen is created.
  ShareLink? _pendingSearch;

  /// Whether the main screen of the registered app is shown.
  bool _ready = false;

  /// Returns the current search of the records screen, or null if it is not
  /// shown.
  ShareLink? Function()? currentSearch;

  /// Whether the current search of the records screen contains a filter, so
  /// sharing it makes sense.
  final ValueNotifier<bool> searchShareable = ValueNotifier(false);

  /// Private constructor of the service.
  ShareLinkService._();

  /// Returns the singleton instance of the [ShareLinkService].
  static ShareLinkService getInstance() {
    return _instance;
  }

  /// Returns the search link received before the records were shown and
  /// forgets it.
  ShareLink? takePendingSearch() {
    final link = _pendingSearch;
    _pendingSearch = null;

    return link;
  }

  /// Opens the received [uri] as soon as the app is ready. Other links than
  /// share links are ignored.
  Future<void> open(Uri uri) async {
    if (ShareLink.parse(uri) == null) {
      return;
    }

    if (!_ready) {
      _pending = uri;
      return;
    }

    await _handle(ShareLink.parse(uri)!);
  }

  /// Marks the app as ready to open links and opens the link received before.
  /// Returns whether a link was opened.
  Future<bool> ready() async {
    _ready = true;
    final pending = _pending;
    _pending = null;
    if (pending == null) {
      return false;
    }

    await open(pending);
    return true;
  }

  /// Shares the link to the current search of the records screen.
  Future<void> shareSearch(BuildContext context) async {
    final link = currentSearch?.call();
    if (link == null || !link.hasSearch) {
      return;
    }

    if (link.searchValueCount > ShareLink.maxSearchValues) {
      final messenger = MessengerService.getInstance();
      messenger.showMessage(
        messenger.shareSearchTooLarge(ShareLink.maxSearchValues),
      );
      return;
    }

    try {
      final response = await _apiService.request(
        '/media/shareQuery',
        data: link.toSearch(),
        options: Options(method: 'POST', contentType: Headers.jsonContentType),
      );
      final token = response.data['token'] as String;
      if (context.mounted) {
        await _share(
          context,
          (serverName) => link.toTokenUri(serverName, token),
        );
      }
    } on DioException {
      // Errors are shown by the api service.
    }
  }

  /// Shares the link to the playing record at its current position.
  Future<void> shareRecord(BuildContext context) async {
    final state = PlayerService.getInstance().playerState;
    final id = state?.currentRecord?.recordId;
    if (id != null) {
      final link = ShareLink(
        recordId: id,
        positionMs: state!.currentSeekPosition.round(),
      );
      await _share(context, link.toUri);
    }
  }

  Future<void> _share(
    BuildContext context,
    Uri Function(String serverName) createUri,
  ) async {
    final serverName = await _store.get(
      SecureStorageService.serverNameStorageKey,
    );
    if (serverName == null || !context.mounted) {
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        uri: createUri(serverName),
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Future<void> _handle(ShareLink received) async {
    var link = received;
    final serverName = await _store.get(
      SecureStorageService.serverNameStorageKey,
    );
    final messenger = MessengerService.getInstance();
    if (link.server != null &&
        link.server!.toLowerCase() != serverName?.toLowerCase()) {
      messenger.showMessage(messenger.shareLinkOtherServer);
      return;
    }

    if (link.token != null) {
      try {
        final response = await _apiService.request(
          '/media/shareQuery/${link.token}',
          options: Options(method: 'GET'),
        );
        link = ShareLink.fromSearch(
          response.data as Map<String, dynamic>,
          link.server,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          messenger.showMessage(messenger.notFound);
        }
        return;
      }
    }

    if (!link.isRecord) {
      _pendingSearch = link;
      await RouterService.getInstance().pushNestedRoute(RecordsViewModel.route);
      return;
    }

    try {
      final record = await RecordService.getInstance().getRecord(
        link.recordId!,
      );
      await PlayerService.getInstance().play(
        record,
        null,
        null,
        startAt: Duration(milliseconds: link.positionMs ?? 0),
      );
    } on DioException catch (e) {
      // Forbidden is reported by the api service.
      if (e.response?.statusCode == 404) {
        messenger.showMessage(messenger.notFound);
      }
    }
  }
}
