import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:mml_app/constants/mml_media_constants.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/models/record_view_settings.dart';
import 'package:mml_app/services/album.dart';
import 'package:mml_app/services/artist.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/genre.dart';
import 'package:mml_app/services/language.dart';
import 'package:mml_app/services/livestreams.dart';
import 'package:mml_app/services/record.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/services/secure_storage.dart';
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
    if (!(await SecureStorageService.getInstance().has(
      SecureStorageService.accessTokenStorageKey,
    ))) {
      // TODO: Wait for the result of https://github.com/ryanheise/audio_service/issues/1081
      // playbackState.add(PlaybackState(
      //     processingState: AudioProcessingState.error,
      //     errorCode: 3,
      //     errorMessage: "Login",
      //     ));

      throw PlatformException(code: "3", message: "Login");
      // return [];
    }

    try {
      switch (parentMediaId) {
        case AudioService.browsableRootId:
          return _getRootTabs();
        case MMLMediaConstants.homeTabId:
          return _getHomeMediaItems();
        case MMLMediaConstants.browseTabId:
          return _getBrowsableCategoryMediaItems();
        case MMLMediaConstants.favoritesTabId:
          return _getFavoritesMediaItems(options);
        case MMLMediaConstants.livestreamsTabId:
          return _getLivestreamsMediaItems(options);
        case MMLMediaConstants.albumsDiscoverId:
          return _getAlbumMediaItems(options);
        case MMLMediaConstants.artistsDiscoverId:
          return _getArtistsMediaItems(options);
        case MMLMediaConstants.genresDiscoverId:
          return _getGenresMediaItems(options);
        case MMLMediaConstants.languagesDiscoverId:
          return _getLanguagesMediaItems(options);
        default:
          return [];
      }
    } catch (e) {
      // For connection errors a list with id (same as the parent) of the parent
      // should be added, otherwise a fullscreen error should be shown!
      // TODO: Handle errors and show them correctly
      // playbackState.addError(e);

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

    if ((await LivestreamService.getInstance().get(null, null, null)).isEmpty) {
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
    var items = await _getMediaItems(
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
      defaultArtUri: await getIconUri('music_note'),
    );

    items.addAll(await _getMediaItems(
      await ArtistService.getInstance().getNewestArtists(),
      true,
      extras: {
        MMLMediaConstants.groupTitle: locales.newestArtists,
      },
      defaultArtUri: await getIconUri('artist'),
    ));

    items.addAll(await _getMediaItems(
      await ArtistService.getInstance().getCommonArtists(),
      true,
      extras: {
        MMLMediaConstants.groupTitle: locales.commonArtists,
      },
      defaultArtUri: await getIconUri('artist'),
    ));

    items.addAll(await _getMediaItems(
      await GenreService.getInstance().getCommonGenres(),
      true,
      extras: {
        MMLMediaConstants.groupTitle: locales.commonGenres,
      },
      defaultArtUri: await getIconUri('genres'),
    ));

    return items;
  }

  Future<List<MediaItem>> _getMediaItems(
    ModelList models,
    bool playable, {
    Map<String, dynamic>? extras,
    Uri? defaultArtUri,
  }) async {
    if (models.isEmpty) {
      return [MediaItem(id: '', title: locales.noData)];
    }

    return Future.wait(
      models.whereType<ModelBase>().map(
            (model) async => MediaItem(
              id: model.getIdentifier(),
              title: model.getDisplayDescription(),
              artUri: await model.getAvatarUri() ?? defaultArtUri,
              playable: playable,
              extras: extras,
              album: model is Record ? model.album : null,
              genre: model is Record ? model.genre : null,
              artist: model is Record ? model.artist : null,
              duration: model is Record
                  ? Duration(
                      milliseconds: ((model as Record?)?.duration ?? 0).toInt(),
                    )
                  : null,
            ),
          ),
    );
  }

  Future<Uri> getIconUri(String name) async {
    packageInfo ??= await PackageInfo.fromPlatform();

    return Uri.parse(
      'android.resource://${packageInfo?.packageName}/drawable/$name',
    );
  }

  Future<List<MediaItem>> _getFavoritesMediaItems(
      Map<String, dynamic>? options) async {
    return _getMediaItems(
      await DBService.getInstance().getPlaylists(
        null,
        options != null && options.containsKey(MMLMediaConstants.extraPage)
            ? options[MMLMediaConstants.extraPage]
            : MMLMediaConstants.defaultPage,
        options != null && options.containsKey(MMLMediaConstants.extraPageSize)
            ? options[MMLMediaConstants.extraPageSize]
            : MMLMediaConstants.defaultPageSize,
      ),
      true,
    );
  }

  Future<List<MediaItem>> _getLivestreamsMediaItems(
      Map<String, dynamic>? options) async {
    return _getMediaItems(
      await LivestreamService.getInstance().get(
        null,
        options != null && options.containsKey(MMLMediaConstants.extraPage)
            ? options[MMLMediaConstants.extraPage]
            : MMLMediaConstants.defaultPage,
        options != null && options.containsKey(MMLMediaConstants.extraPageSize)
            ? options[MMLMediaConstants.extraPageSize]
            : MMLMediaConstants.defaultPageSize,
      ),
      true,
    );
  }

  Future<List<MediaItem>> _getAlbumMediaItems(
      Map<String, dynamic>? options) async {
    return _getMediaItems(
      await AlbumService.getInstance().getAlbums(
        null,
        options != null && options.containsKey(MMLMediaConstants.extraPage)
            ? options[MMLMediaConstants.extraPage]
            : MMLMediaConstants.defaultPage,
        options != null && options.containsKey(MMLMediaConstants.extraPageSize)
            ? options[MMLMediaConstants.extraPageSize]
            : MMLMediaConstants.defaultPageSize,
      ),
      true,
      defaultArtUri: await getIconUri('library_music'),
    );
  }

  Future<List<MediaItem>> _getArtistsMediaItems(
      Map<String, dynamic>? options) async {
    return _getMediaItems(
      await ArtistService.getInstance().getArtists(
        null,
        options != null && options.containsKey(MMLMediaConstants.extraPage)
            ? options[MMLMediaConstants.extraPage]
            : MMLMediaConstants.defaultPage,
        options != null && options.containsKey(MMLMediaConstants.extraPageSize)
            ? options[MMLMediaConstants.extraPageSize]
            : MMLMediaConstants.defaultPageSize,
      ),
      true,
      defaultArtUri: await getIconUri('artist'),
    );
  }

  Future<List<MediaItem>> _getGenresMediaItems(
      Map<String, dynamic>? options) async {
    return _getMediaItems(
      await GenreService.getInstance().getGenres(
        null,
        options != null && options.containsKey(MMLMediaConstants.extraPage)
            ? options[MMLMediaConstants.extraPage]
            : MMLMediaConstants.defaultPage,
        options != null && options.containsKey(MMLMediaConstants.extraPageSize)
            ? options[MMLMediaConstants.extraPageSize]
            : MMLMediaConstants.defaultPageSize,
      ),
      true,
      defaultArtUri: await getIconUri('genres'),
    );
  }

  Future<List<MediaItem>> _getLanguagesMediaItems(
      Map<String, dynamic>? options) async {
    return _getMediaItems(
      await LanguageService.getInstance().getLanguages(
        null,
        options != null && options.containsKey(MMLMediaConstants.extraPage)
            ? options[MMLMediaConstants.extraPage]
            : MMLMediaConstants.defaultPage,
        options != null && options.containsKey(MMLMediaConstants.extraPageSize)
            ? options[MMLMediaConstants.extraPageSize]
            : MMLMediaConstants.defaultPageSize,
      ),
      true,
    );
  }
}
