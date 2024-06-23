import 'package:audio_service/audio_service.dart';
import 'package:mml_app/constants/mml_media_constants.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/record_view_settings.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/livestreams.dart';
import 'package:mml_app/services/record.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MMLMediaItemService {
  /// Instance of the [MMLMediaItemService].
  static final MMLMediaItemService _instance = MMLMediaItemService._();

  PackageInfo? packageInfo;

  late AppLocalizations locales;

  /// Private constructor of the service.
  MMLMediaItemService._();

  /// Returns the singleton instance of the [MMLMediaItemService].
  static MMLMediaItemService getInstance(AppLocalizations locales) {
    _instance.locales = locales;

    return _instance;
  }

  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    switch (parentMediaId) {
      case AudioService.browsableRootId:
        return _getRootTabs();
      case MMLMediaConstants.homeTabId:
        return _getHomeMediaItems();
      case MMLMediaConstants.favoritesTabId:
        return _getFavoritesMediaItems();
      case MMLMediaConstants.livestreamsTabId:
        return _getLivestreamsMediaItems();
      case MMLMediaConstants.browseTabId:
        return _getBrowsableCategoryMediaItems();
      default:
        return [];
    }
  }

  Future<List<MediaItem>> _getRootTabs() async {
    var tabs = [
      MediaItem(
        id: MMLMediaConstants.homeTabId,
        title: locales.overview,
        artUri: await getIconUri('subscriptions'),
        playable: false,
      ),
      MediaItem(
        id: MMLMediaConstants.favoritesTabId,
        title: locales.favorites,
        artUri: await getIconUri('playlist'),
        playable: false,
        extras: {
          MMLMediaConstants.mediaPlayableContentKey:
              MMLMediaConstants.mediaPlayableContentValue,
        },
      ),
      MediaItem(
        id: MMLMediaConstants.livestreamsTabId,
        title: locales.livestreamShort,
        playable: false,
        artUri: await getIconUri('sensors'),
        extras: {
          MMLMediaConstants.mediaPlayableContentKey:
              MMLMediaConstants.mediaPlayableContentValue,
        },
      ),
      MediaItem(
        id: MMLMediaConstants.browseTabId,
        title: locales.discover,
        artUri: await getIconUri('search'),
        playable: false,
      ),
    ];

    if ((await LivestreamService.getInstance().get(null, null, null))
        .isEmpty) {
          tabs.removeWhere((x) => x.id == MMLMediaConstants.livestreamsTabId);
        }

    return tabs;
  }

  Future<List<MediaItem>> _getBrowsableCategoryMediaItems() async {
    var res = [
      MediaItem(
        id: MMLMediaConstants.artistsDiscoverId,
        title: locales.artists,
        playable: false,
        artUri: await getIconUri('artist'),
      ),
      MediaItem(
        id: MMLMediaConstants.genresDiscoverId,
        title: locales.genres,
        playable: false,
        artUri: await getIconUri('genres'),
      ),
      MediaItem(
        id: MMLMediaConstants.albumsDiscoverId,
        title: locales.albums,
        playable: false,
        artUri: await getIconUri('library_music'),
      ),
      MediaItem(
        id: MMLMediaConstants.languagesDiscoverId,
        title: locales.languages,
        playable: false,
        artUri: await getIconUri('translate'),
      ),
    ];

    res.sort((x, y) => x.title.compareTo(y.title));

    return res;
  }

  Future<List<MediaItem>> _getHomeMediaItems() async {
    var items = _getMediaItems(
      await RecordService.getInstance().getRecords(
        null,
        0,
        10,
        null,
        RecordViewSettings(
          genre: false,
          album: false,
          cover: true,
          language: false,
          tracknumber: false,
        ),
      ),
      true,
      extras: {
        MMLMediaConstants.groupTitle: locales.newest,
      },
    ).toList();

    // TODO: Sorting or special service method
    items.addAll(_getMediaItems(
      await RecordService.getInstance().getArtists(null, 0, 10),
      true,
      extras: {
        MMLMediaConstants.groupTitle: locales.newestArtists,
      },
    ));

    // TODO: Sorting or special service method
    items.addAll(_getMediaItems(
      await RecordService.getInstance().getArtists(null, 0, 10),
      true,
      extras: {
        MMLMediaConstants.groupTitle: locales.commonArtists,
      },
    ));

    // TODO: Sorting or special service method
    items.addAll(_getMediaItems(
      await RecordService.getInstance().getGenres(null, 0, 10),
      true,
      extras: {
        MMLMediaConstants.groupTitle: locales.commonGenres,
      },
    ));

    return items;
  }

  List<MediaItem> _getMediaItems(
    ModelList models,
    bool playable, {
    Map<String, dynamic>? extras,
  }) {
    if (models.isEmpty) {
      return [MediaItem(id: '', title: locales.noData)];
    }

    // TODO: Art & additional infos
    return models
        .whereType<ModelBase>()
        .map(
          (model) => MediaItem(
            id: model.getIdentifier(),
            title: model.getDisplayDescription(),
            artUri: model.getAvatarUri(),
            playable: playable,
            extras: extras,
          ),
        )
        .toList();
    /*
            album: ,
            artist: ,
            genre: ,
            duration: Duration(
              milliseconds: (currentRecord?.duration ?? 0).toInt(),
            ),*/
  }

  Future<Uri> getIconUri(String name) async {
    packageInfo ??= await PackageInfo.fromPlatform();

    return Uri.parse(
      'android.resource://${packageInfo?.packageName}/drawable/$name',
    );
  }

  Future<List<MediaItem>> _getFavoritesMediaItems() async {
    return _getMediaItems(
      await DBService.getInstance().getPlaylists(null, 0, 50),
      true,
    );
  }

  Future<List<MediaItem>> _getLivestreamsMediaItems() async {
    return _getMediaItems(
      await LivestreamService.getInstance().get(null, 0, 50),
      true,
    );
  }
}
