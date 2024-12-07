/// Constants for the media item service that serves media items for android.
class MMLMediaConstants {
  /// Id of the offline message media item.
  static const String offlineId = 'offline';

  /// Android auto tab id prefix.
  static const String tabId = 'tab';

  /// Id of the home tab in android auto.
  static const String homeTabId = '${tabId}Home';

  /// Id of the favorites tab in android auto.
  static const String favoritesTabId = '${tabId}Favorites';

  /// Id of the livestreams tab in android auto.
  static const String livestreamsTabId = '${tabId}Livestreams';

  /// Id of the browse tab in android auto.
  static const String browseTabId = '${tabId}Browse';

  /// Id prefix of local record media items.
  static const String localRecordId = 'local';

  /// Id prefix of genre media items.
  static const String genreId = 'genres';

  /// Id prefix of artist media items.
  static const String artistId = 'artists';

  /// Id prefix of album media items.
  static const String albumId = 'album';

  /// Id prefix of language media items.
  static const String languageId = 'languages';

  /// Id prefix of livestream media items.
  static const String livestreamId = 'livestreams';

  /// Id of group for newest records media items.
  static const String newestRecordsGroupId = 'groupNewestRecords';

  /// Id of group for common genres media items.
  static const String commonGenresGroupId = 'groupCommonGenres';

  /// Id of group for common artists media items.
  static const String commonArtistsGroupId = 'groupCommonArtists';

  /// Id of group for newest artists media items.
  static const String newestArtistsGroupId = 'groupNewestArtists';

  /// Id for browse artists media item.
  static const String artistsDiscoverId = 'discoverArtists';

  /// Id for browse genres media item.
  static const String genresDiscoverId = 'discoverGenres';

  /// Id for browse albums media item.
  static const String albumsDiscoverId = 'discoverAlbums';

  /// Id for browse language media item.
  static const String languagesDiscoverId = 'discoverLanguages';

  /// Extras string that indicates that search is supported in android auto.
  static const String mediaBrowseSupported =
      'android.media.browse.SEARCH_SUPPORTED';

  /// Extras key for browsable media items style of a tab.
  static const String mediaBrowsableContentKey =
      'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT';

  /// Extras value for browsable media items, to show them as grid items.
  static const int mediaBrowsableContentValue = 4;

  /// Extras key for playable media items style of a tab.
  static const String mediaPlayableContentKey =
      'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT';

  /// Extras key for single media item style.
  static const String mediaSingleItemContentKey =
      'android.media.browse.CONTENT_STYLE_SINGLE_ITEM_HINT';

  /// Extras value for playable media items, to show them as list items.
  static const int mediaPlayableContentValue = 1;

  /// Extras value for playable media items, to show them as grid items.
  static const int mediaPlayableContentGridItemValue = 2;

  /// Extras key for a title of a media items group.
  static const String groupTitle =
      'android.media.browse.CONTENT_STYLE_GROUP_TITLE_HINT';

  /// Extras key for the page of media items to load.
  static const String extraPage = 'android.media.browse.extra.PAGE';

  /// Extras key for the page size of media items to load.
  static const String extraPageSize = 'android.media.browse.extra.PAGE_SIZE';

  /// Extras key for album filter query.
  static const String extraAlbum = 'android.intent.extra.album';

  /// Extras key for artist filter query.
  static const String extraArtist = 'android.intent.extra.artist';

  /// Extras key for genre filter query.
  static const String extraGenre = 'android.intent.extra.genre';

  /// Default page of the media items to load.
  static const int defaultPage = 0;

  /// Default page size of the media items to load.
  static const int defaultPageSize = 100;

  /// Key for custom action shuffle in android auto.
  static const String customActionShuffle = 'shuffle';

  /// Key for custom action repeat in android auto.
  static const String customActionRepeat = 'repeat';

  /// Android media service error code for expired authentication.
  static const String errorCodeAuthenticationExpired = '3';

  /// Android media service error code for unknown errors.
  static const String errorCodeUnknownError = '0';
}
