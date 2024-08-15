import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:mml_app/constants/mml_media_constants.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
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

  String currentItemId = AudioService.browsableRootId;

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
    await _checkRegistration();

    var result = switch (parentMediaId) {
      AudioService.browsableRootId => _getRootTabs(),
      MMLMediaConstants.homeTabId => _getHomeMediaItems(),
      MMLMediaConstants.browseTabId => _getBrowsableCategoryMediaItems(),
      MMLMediaConstants.favoritesTabId => _getFavoritesMediaItems(options),
      MMLMediaConstants.livestreamsTabId =>
        _getLivestreamsMediaItems(options),
      MMLMediaConstants.albumsDiscoverId => _getAlbumMediaItems(options),
      MMLMediaConstants.artistsDiscoverId => _getArtistsMediaItems(options),
      MMLMediaConstants.genresDiscoverId => _getGenresMediaItems(options),
      MMLMediaConstants.languagesDiscoverId =>
        _getLanguagesMediaItems(options),
      _ => Future.value([] as List<MediaItem>)
    };

    return result.catchError((e) {
      if (e is DioException && e.error is SocketException) {
        return [
          MediaItem(
            id: MMLMediaConstants.offlineId,
            title: locales.offlineErrorTitle(locales.appTitle),
            album: locales.offlineError,
            playable: true,
            extras: {
              MMLMediaConstants.mediaSingleItemContentKey:
                  MMLMediaConstants.mediaPlayableContentValue,
            },
          )
        ];
      }

      throw PlatformException(
        code: MMLMediaConstants.errorCodeUnknownError,
        message: locales.unknownError,
      );
    });
  }

  Future<(List<MediaItem>, ID3TagFilter, String)> search(String query,
      [Map<String, dynamic>? extras]) async {
    var searchResult = await searchRecords(query, extras);

    return (
      await _getMediaItems(
        searchResult.$1,
        true,
        defaultArtUri: await getIconUri('music_note'),
      ),
      searchResult.$2,
      searchResult.$3,
    );
  }

  Future<(ModelList, ID3TagFilter, String)> searchRecords(String query,
      [Map<String, dynamic>? extras]) async {
    await _checkRegistration();

    var filter = ID3TagFilter();
    var searchString = "";

    if (extras?.containsKey(MMLMediaConstants.extraAlbum) ?? false) {
      filter.albumNames = [extras![MMLMediaConstants.extraAlbum]];
    } else if (extras?.containsKey(MMLMediaConstants.extraArtist) ?? false) {
      filter.artistNames = [extras![MMLMediaConstants.extraArtist]];
    } else if (extras?.containsKey(MMLMediaConstants.extraGenre) ?? false) {
      filter.genreNames = [extras![MMLMediaConstants.extraGenre]];
    } else {
      searchString = query;
    }

    try {
      return (
        await RecordService.getInstance().getRecords(
          searchString,
          extras != null && extras.containsKey(MMLMediaConstants.extraPage)
              ? extras[MMLMediaConstants.extraPage]
              : MMLMediaConstants.defaultPage,
          extras != null && extras.containsKey(MMLMediaConstants.extraPageSize)
              ? extras[MMLMediaConstants.extraPageSize]
              : MMLMediaConstants.defaultPageSize,
          filter,
          RecordViewSettings(
            genre: true,
            album: true,
            cover: true,
            language: true,
            tracknumber: true,
          ),
        ),
        filter,
        searchString,
      );
    } catch (e) {
      if (e is DioException && e.error is SocketException) {
        return (
          ModelList([
            Record(
              recordId: MMLMediaConstants.offlineId,
              title: locales.offlineErrorTitle(locales.appTitle),
              album: locales.offlineError,
              checksum: '',
            )
          ], 0, 1),
          filter,
          searchString
        );
      }

      throw PlatformException(
        code: MMLMediaConstants.errorCodeUnknownError,
        message: locales.unknownError,
      );
    }
  }

  Future<void> _checkRegistration() async {
    if (!(await SecureStorageService.getInstance().has(
      SecureStorageService.accessTokenStorageKey,
    ))) {
      throw PlatformException(
        code: MMLMediaConstants.errorCodeAuthenticationExpired,
        message: locales.errorAuthenticationExpired(locales.appTitle),
      );
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
          genre: true,
          album: true,
          cover: true,
          language: true,
          tracknumber: true,
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
      idPrefix: MMLMediaConstants.artistId,
      extras: {
        MMLMediaConstants.groupTitle: locales.newestArtists,
      },
      defaultArtUri: await getIconUri('artist'),
    ));

    items.addAll(await _getMediaItems(
      await ArtistService.getInstance().getCommonArtists(),
      true,
      idPrefix: MMLMediaConstants.artistId,
      extras: {
        MMLMediaConstants.groupTitle: locales.commonArtists,
      },
      defaultArtUri: await getIconUri('artist'),
    ));

    items.addAll(await _getMediaItems(
      await GenreService.getInstance().getCommonGenres(),
      true,
      idPrefix: MMLMediaConstants.genreId,
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
    String? idPrefix,
    Map<String, dynamic>? extras,
    Uri? defaultArtUri,
  }) async {
    if (models.isEmpty) {
      return [];
    }

    return Future.wait(
      models.whereType<ModelBase>().map(
            (model) async => MediaItem(
              id: idPrefix != null && idPrefix.isNotEmpty
                  ? '$idPrefix:${model.getIdentifier()}'
                  : model.getIdentifier(),
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
      idPrefix: MMLMediaConstants.localRecordId,
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
      idPrefix: MMLMediaConstants.livestreamId,
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
      idPrefix: MMLMediaConstants.albumId,
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
      idPrefix: MMLMediaConstants.artistId,
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
      idPrefix: MMLMediaConstants.genreId,
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
      idPrefix: MMLMediaConstants.languageId,
    );
  }
}
