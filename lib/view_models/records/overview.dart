import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/models/record_view_settings.dart';
import 'package:mml_app/models/share_action.dart';
import 'package:mml_app/models/share_link.dart';
import 'package:mml_app/models/filter.dart';
import 'package:mml_app/services/share.dart';
import 'package:mml_app/services/share_link.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/record.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:mml_app/view_models/records/share_selection.dart';

/// View model of the records screen.
class RecordsViewModel extends ChangeNotifier {
  /// Route of the records screen.
  static String route = '/records';

  /// App locales.
  late AppLocalizations locales;

  /// [RecordService] used to load data for the records upload dialog.
  final RecordService _service = RecordService.getInstance();

  /// DB service to update settings in db.
  final DBService _dbService = DBService.getInstance();

  /// Indicates if the folder view is active or not.
  bool isFolderView = false;

  late ID3TagFilter tagFilter;

  /// settings for the records view.
  late RecordViewSettings recordViewSettings;

  /// Text filter of the screen.
  Filter? _textFilter;

  /// Checks and shares the selected records.
  final RecordShareSelection _shareSelection = RecordShareSelection();

  /// Initializes the view model. A search link the app was opened with is
  /// applied to the [textFilter] and the tag filter.
  Future<bool> init(BuildContext context, {Filter? textFilter}) {
    return Future.microtask(() async {
      if (!context.mounted) {
        return false;
      }
      _textFilter = textFilter;
      ShareService.getInstance().supported.addListener(_updateSearchShareable);
      ShareLinkService.getInstance().currentSearch = () =>
          ShareLink(filter: _textFilter?.textFilter, tagFilter: tagFilter);
      locales = AppLocalizations.of(context)!;
      isFolderView =
          (await SecureStorageService.getInstance().get(
            SecureStorageService.folderViewStorageKey,
          ))?.toLowerCase() ==
          'true';
      tagFilter = await _dbService.loadID3Filter();
      if (isFolderView) {
        var startDate = tagFilter.startDate;
        var endDate = tagFilter.endDate;
        tagFilter[ID3TagFilters.folderView] = isFolderView;
        if (startDate != null && endDate != null) {
          tagFilter[ID3TagFilters.date] = DateTimeRange(
            start: startDate,
            end: endDate,
          );
        }
      }

      recordViewSettings = await _dbService.loadRecordViewSettings();
      _applySearchLink(ShareLinkService.getInstance().takePendingSearch());
      tagFilter.addListener(_updateSearchShareable);
      _textFilter?.addListener(_updateSearchShareable);
      _updateSearchShareable();
      return true;
    });
  }

  void _updateSearchShareable() {
    ShareLinkService.getInstance().searchShareable.value =
        ShareService.getInstance().supported.value &&
        ShareLink(
          filter: _textFilter?.textFilter,
          tagFilter: tagFilter,
        ).hasSearch;
  }

  @override
  void dispose() {
    _shareSelection.dispose();
    _textFilter?.removeListener(_updateSearchShareable);
    ShareService.getInstance().supported.removeListener(_updateSearchShareable);
    ShareLinkService.getInstance().searchShareable.value = false;
    ShareLinkService.getInstance().currentSearch = null;
    super.dispose();
  }

  void _applySearchLink(ShareLink? link) {
    if (link == null) {
      return;
    }

    tagFilter.replaceWith(link.tagFilter);
    _textFilter?.textFilter = link.filter;
  }

  /// Stores the replaced tag filter, if filters are persisted.
  Future<void> saveTagFilter() async {
    await _dbService.clearID3Filter();
    if (await isFilterPersistActive()) {
      await saveFolderPath(tagFilter);
      await _dbService.saveID3Filter(
        ID3TagFilters.albums,
        jsonEncode(tagFilter.albums),
      );
    }
  }

  /// Checks which of the [selected] items the user may share and shows the
  /// share action of the [action] accordingly.
  void selectionChanged(List<ModelBase> selected, ShareAction? action) {
    _shareSelection.selectionChanged(selected, action);
  }

  /// Shares a download link of the [selected] items. Returns whether the
  /// selection should be reset.
  Future<bool> share(List<ModelBase?> selected, BuildContext context) {
    return _shareSelection.share(selected, context);
  }

  /// Loads the records with the passing [filter] starting at [offset] and loading
  /// [take] data.
  Future<ModelList> load({
    String? filter,
    int? offset,
    int? take,
    dynamic subfilter,
  }) async {
    if (subfilter is ID3TagFilter &&
        subfilter.isGrouped &&
        (subfilter.startDate == null ||
            subfilter.startDate != subfilter.endDate)) {
      return _service.getRecordsFolder(filter, offset, take, subfilter);
    }

    return _service.getRecords(
      filter,
      offset,
      take,
      subfilter,
      recordViewSettings,
    );
  }

  /// Plays one record.
  Future<void> playRecord(
    ModelBase record,
    String? filter,
    ID3TagFilter? subfilter,
  ) async {
    await PlayerService.getInstance().play(record as Record, filter, subfilter);
  }

  /// Loads the next folder which is before actual date range filtered by [subFilter].
  void moveFolderUp(ID3TagFilter subFilter) {
    if (subFilter.startDate == null) {
      return;
    }
    if (subFilter.startDate == subFilter.endDate) {
      subFilter[ID3TagFilters.date] = DateTimeRange(
        start: DateTime(
          subFilter.startDate!.year,
          subFilter.startDate!.month,
          1,
        ),
        end: DateTime(
          subFilter.endDate!.year,
          subFilter.endDate!.month,
          DateUtils.getDaysInMonth(
            subFilter.endDate!.year,
            subFilter.endDate!.month,
          ),
        ),
      );
      saveFolderPath(subFilter);
    } else if (subFilter.startDate!.month == subFilter.endDate!.month) {
      subFilter[ID3TagFilters.date] = DateTimeRange(
        start: DateTime(subFilter.startDate!.year, 1, 1),
        end: DateTime(subFilter.endDate!.year, 12, 31),
      );
      saveFolderPath(subFilter);
    } else {
      subFilter.clear(ID3TagFilters.date);
      _dbService.clearID3Filter(ID3TagFilters.date);
    }
  }

  /// Performs item open action.
  Future saveFolderPath(ID3TagFilter subfilter) async {
    if ((await isFilterPersistActive())) {
      _dbService.saveID3Filter(
        ID3TagFilters.date,
        jsonEncode(
          List<String>.from([
            subfilter.startDate.toString(),
            subfilter.endDate.toString(),
          ]),
        ),
      );
    }
  }

  Future<bool> isFilterPersistActive() async {
    return (await SecureStorageService.getInstance().get(
          SecureStorageService.saveFiltersStorageKey,
        ))?.toLowerCase() ==
        'true';
  }
}
