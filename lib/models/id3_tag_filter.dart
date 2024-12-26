import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/subfilter.dart';

part 'id3_tag_filter.g.dart';

/// ID§ tag filters for records.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class ID3TagFilter extends Subfilter {
  /// Ids of artist tags.
  List<String> artists = [];

  /// Names of artist tags.
  List<String> artistNames = [];

  /// Ids of genre tags.
  List<String> genres = [];

  /// Names of genre tags.
  List<String> genreNames = [];

  /// Ids of album tags.
  List<String> albums = [];

  /// Names of album tags.
  List<String> albumNames = [];

  /// Ids of language tags.
  List<String> languages = [];

  /// Start date of a date interval or null if not set.
  DateTime? startDate;

  /// End date of a date interval or null if not set.
  DateTime? endDate;

  /// Initializes the model.
  ID3TagFilter({
    List<String>? artists,
    List<String>? artistNames,
    List<String>? genres,
    List<String>? genreNames,
    List<String>? albums,
    List<String>? albumNames,
    List<String>? languages,
    this.startDate,
    this.endDate,
    isFolderView = false,
  }) {
    this.artists = artists ?? [];
    this.artistNames = artistNames ?? [];
    this.genres = genres ?? [];
    this.genreNames = genreNames ?? [];
    this.albums = albums ?? [];
    this.albumNames = albumNames ?? [];
    this.languages = languages ?? [];
    isGrouped = isFolderView;
  }

  /// Converts a json object/map to the model.
  factory ID3TagFilter.fromJson(Map<String, dynamic> json) =>
      _$ID3TagFilterFromJson(json);

  /// Converts the current model to a json object/map.
  Map<String, dynamic> toJson() => _$ID3TagFilterToJson(this);

  /// Assigns the new filter [value] to the [ID3TagFilters] identifier.
  void operator []=(String identifier, dynamic value) {
    switch (identifier) {
      case ID3TagFilters.artists:
        artists = value as List<String>;
        break;
      case ID3TagFilters.artistNames:
        artistNames = value as List<String>;
        break;
      case ID3TagFilters.genres:
        genres = value as List<String>;
        break;
      case ID3TagFilters.genreNames:
        genreNames = value as List<String>;
        break;
      case ID3TagFilters.albums:
        albums = value as List<String>;
        break;
      case ID3TagFilters.albumNames:
        albumNames = value as List<String>;
        break;
      case ID3TagFilters.languages:
        languages = value as List<String>;
        break;
      case ID3TagFilters.date:
        var range = value as DateTimeRange;
        startDate = range.start;
        endDate = range.end;
        break;
      case ID3TagFilters.folderView:
        startDate = null;
        endDate = null;
        isGrouped = value as bool;
        break;
    }
    notifyListeners();
  }

  /// Returns the saved values of the [ID3TagFilters] identifier.
  dynamic operator [](String identifier) {
    switch (identifier) {
      case ID3TagFilters.artists:
        return artists;
      case ID3TagFilters.artistNames:
        return artistNames;
      case ID3TagFilters.genres:
        return genres;
      case ID3TagFilters.genreNames:
        return genreNames;
      case ID3TagFilters.albums:
        return albums;
      case ID3TagFilters.albumNames:
        return albumNames;
      case ID3TagFilters.languages:
        return languages;
      case ID3TagFilters.date:
        return startDate != null && endDate != null
            ? DateTimeRange(start: startDate!, end: endDate!)
            : null;
      case ID3TagFilters.folderView:
        return isGrouped;
    }
  }

  /// Clears the filter value of the [identifier].
  void clear(String identifier) {
    _remove(identifier);
    notifyListeners();
  }

  // Clears all filters.
  void clearAll() {
    _remove(ID3TagFilters.artists);
    _remove(ID3TagFilters.artistNames);
    _remove(ID3TagFilters.albums);
    _remove(ID3TagFilters.albumNames);
    _remove(ID3TagFilters.genres);
    _remove(ID3TagFilters.genreNames);
    _remove(ID3TagFilters.languages);
    _remove(ID3TagFilters.date);
    _remove(ID3TagFilters.folderView);
    notifyListeners();
  }

  void _remove(String identifier) {
    switch (identifier) {
      case ID3TagFilters.artists:
        artists.clear();
        break;
      case ID3TagFilters.artistNames:
        artistNames.clear();
        break;
      case ID3TagFilters.genres:
        genres.clear();
        break;
      case ID3TagFilters.genreNames:
        genreNames.clear();
        break;
      case ID3TagFilters.albums:
        albums.clear();
        break;
      case ID3TagFilters.albumNames:
        albumNames.clear();
        break;
      case ID3TagFilters.languages:
        languages.clear();
        break;
      case ID3TagFilters.date:
        startDate = null;
        endDate = null;
        break;
      case ID3TagFilters.folderView:
        startDate = null;
        endDate = null;
        isGrouped = false;
        break;
    }
  }

  /// Checks if the value of the [identifier] is not empty.
  bool isNotEmpty(String identifier) {
    switch (identifier) {
      case ID3TagFilters.artists:
        return artists.isNotEmpty;
      case ID3TagFilters.genres:
        return genres.isNotEmpty;
      case ID3TagFilters.albums:
        return albums.isNotEmpty;
      case ID3TagFilters.languages:
        return languages.isNotEmpty;
      case ID3TagFilters.date:
        return startDate != null;
      case ID3TagFilters.folderView:
        return isGrouped;
      default:
        return true;
    }
  }

  /// Determines whether at least one filter is set.
  bool isAny() =>
      artists.isNotEmpty ||
      genres.isNotEmpty ||
      albums.isNotEmpty ||
      languages.isNotEmpty ||
      startDate != null ||
      endDate != null;
}

/// Holds the tags identifiers on which records can be filtered.
abstract class ID3TagFilters {
  /// Artists tag identifier.
  static const String artists = "artists";

  /// Artist names tag identifier.
  static const String artistNames = "artistNames";

  /// Albums tag identifier.
  static const String albums = "albums";

  /// Album names tag identifier.
  static const String albumNames = "albumNames";

  /// Date tag identifier.
  static const String date = "date";

  /// Genres tag identifier.
  static const String genres = "genres";

  /// Genre names tag identifier.
  static const String genreNames = "genreNames";

  /// Folder view identifier.
  static const String folderView = "folderView";

  /// Languages tag identifier.
  static const String languages = "languages";
}
