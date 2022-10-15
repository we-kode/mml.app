import 'package:flutter/material.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/services/record.dart';
import 'package:mml_app/services/secure_storage.dart';

/// View model for the records tag filter.
class RecordTagFilterViewModel extends ChangeNotifier {
  /// The active [ID3TagFilter].
  final ID3TagFilter tagFilter;

  /// [RecordService] used to load data for the tag filter.
  final RecordService _service = RecordService.getInstance();

  final SecureStorageService _storage = SecureStorageService.getInstance();

  /// Initializes the view model.
  RecordTagFilterViewModel(this.tagFilter);

  /// Initializes the view model.
  Future<bool> init(BuildContext context) {
    return Future.microtask(() async {
      bool isFolderView = (await _storage.get(
            SecureStorageService.folderViewStorageKey,
          ))
              ?.toLowerCase() ==
          'true';
      tagFilter[ID3TagFilters.folderView] = isFolderView;
      return true;
    });
  }

  /// Clears the filter value of the [identifier].
  void clear(String identifier) {
    tagFilter.clear(identifier);
    notifyListeners();
  }

  /// Updates the tag filter [identifier] with the [selectedValues].
  void updateFilter(String identifier, dynamic selectedValues) {
    tagFilter[identifier] = selectedValues;
    if (identifier == ID3TagFilters.folderView) {
      _storage.set(
        SecureStorageService.folderViewStorageKey,
        (selectedValues as bool).toString(),
      );
    }
    notifyListeners();
  }

  /// Loads data by [identifier] function.
  Future<ModelList> load(
    String identifier, {
    String? filter,
    int? offset,
    int? take,
  }) async {
    switch (identifier) {
      case ID3TagFilters.artists:
        return _service.getArtists(filter, offset, take);
      case ID3TagFilters.genres:
        return _service.getGenres(filter, offset, take);
      case ID3TagFilters.albums:
        return _service.getAlbums(filter, offset, take);
    }

    throw UnimplementedError();
  }
}
