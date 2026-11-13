import 'package:mml_app/models/id3_tag_filter.dart';

/// A link that opens the app with a search or a record at a position.
class ShareLink {
  /// Scheme the landing page of the server opens the app with.
  static const String scheme = 'mml';

  /// Path of the landing page on the server.
  static const String path = '/media/s/open';

  /// Name of the server the link was created on, or null if not known.
  final String? server;

  /// Text filter of the search.
  final String? filter;

  /// Tag filter of the search.
  final ID3TagFilter tagFilter;

  /// Id of the record to play or null for a search link.
  final String? recordId;

  /// Position in milliseconds the record starts at.
  final int? positionMs;

  /// Token of the filters of a search, which are stored on the server, or null.
  final String? token;

  /// Initializes the link.
  ShareLink({
    this.server,
    this.filter,
    ID3TagFilter? tagFilter,
    this.recordId,
    this.positionMs,
    this.token,
  }) : tagFilter = tagFilter ?? ID3TagFilter();

  /// Whether the link plays a record.
  bool get isRecord => recordId != null;

  /// Whether the link is a search, which contains a text or tag filter. A search
  /// without any filter is not worth to be shared.
  bool get hasSearch =>
      !isRecord &&
      ((filter?.isNotEmpty ?? false) ||
          tagFilter.artists.isNotEmpty ||
          tagFilter.genres.isNotEmpty ||
          tagFilter.albums.isNotEmpty ||
          tagFilter.languages.isNotEmpty ||
          tagFilter.startDate != null ||
          tagFilter.endDate != null);

  /// Parses the [uri] the app was opened with. Returns null, if it is not a
  /// share link.
  static ShareLink? parse(Uri uri) {
    final isAppLink = uri.scheme == scheme;
    final isRoute = uri.scheme.isEmpty && uri.path == '/open';
    if (!isAppLink && !isRoute) {
      return null;
    }

    return ShareLink.fromQuery(uri.queryParametersAll);
  }

  /// Creates the link from the parameters of the query. The server name and
  /// the token are optional.
  factory ShareLink.fromQuery(Map<String, List<String>> query) {
    final filter = ID3TagFilter(
      artists: query['artist'],
      artistNames: query['artistName'],
      genres: query['genre'],
      genreNames: query['genreName'],
      albums: query['album'],
      albumNames: query['albumName'],
      languages: query['language'],
      startDate: DateTime.tryParse(query['from']?.first ?? ''),
      endDate: DateTime.tryParse(query['to']?.first ?? ''),
    );
    final recordId = query['record']?.first;
    final position = int.tryParse(query['t']?.first ?? '');

    return ShareLink(
      server: query['server']?.first,
      filter: query['q']?.first,
      tagFilter: filter,
      recordId: recordId != null && recordId.isNotEmpty ? recordId : null,
      positionMs: position != null && position >= 0 ? position : null,
      token: query['c']?.first,
    );
  }

  /// Largest number of filter values of a search, which can be shared.
  static const int maxSearchValues = 1000;

  /// Creates the link from the filters of a search stored on the server. The
  /// [server] is the name of the server the link was received from.
  factory ShareLink.fromSearch(Map<String, dynamic> search, String? server) {
    return ShareLink.fromQuery({
      for (final entry in search.entries)
        if (entry.value is List)
          entry.key: List<String>.from(entry.value)
        else if (entry.value is String)
          entry.key: [entry.value as String],
      if (server != null) 'server': [server],
    });
  }

  /// Number of the filter values of the search.
  int get searchValueCount => _filterParameters().values
      .map((value) => value is List ? value.length : 1)
      .fold(0, (sum, count) => sum + count);

  /// Returns the filters of the search, as they are stored on the server.
  Map<String, dynamic> toSearch() => _filterParameters();

  /// Creates the https link to the landing page of the [serverName], which
  /// opens the search stored under the [token].
  Uri toTokenUri(String serverName, String token) =>
      _landingPage(serverName, {'c': token});

  /// Creates the https link to the landing page of the [serverName].
  Uri toUri(String serverName) {
    final query = <String, dynamic>{
      ..._filterParameters(),
      if (recordId != null) 'record': recordId,
      if (recordId != null && positionMs != null) 't': positionMs.toString(),
    };

    return _landingPage(serverName, query);
  }

  Map<String, dynamic> _filterParameters() => {
    if (filter != null && filter!.isNotEmpty) 'q': filter,
    if (tagFilter.artists.isNotEmpty) 'artist': tagFilter.artists,
    if (tagFilter.artistNames.isNotEmpty) 'artistName': tagFilter.artistNames,
    if (tagFilter.genres.isNotEmpty) 'genre': tagFilter.genres,
    if (tagFilter.genreNames.isNotEmpty) 'genreName': tagFilter.genreNames,
    if (tagFilter.albums.isNotEmpty) 'album': tagFilter.albums,
    if (tagFilter.albumNames.isNotEmpty) 'albumName': tagFilter.albumNames,
    if (tagFilter.languages.isNotEmpty) 'language': tagFilter.languages,
    if (tagFilter.startDate != null)
      'from': tagFilter.startDate!.toIso8601String(),
    if (tagFilter.endDate != null) 'to': tagFilter.endDate!.toIso8601String(),
  };

  Uri _landingPage(String serverName, Map<String, dynamic> query) {
    return Uri(
      scheme: 'https',
      host: serverName.split(':').first,
      port: int.tryParse(
        serverName.contains(':') ? serverName.split(':').last : '',
      ),
      path: path,
      queryParameters: query.isEmpty ? null : query,
    );
  }
}
