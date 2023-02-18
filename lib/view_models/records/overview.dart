import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/models/record_view_settings.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/record.dart';
import 'package:mml_app/services/secure_storage.dart';

/// View model of the records screen.
class RecordsViewModel extends ChangeNotifier {
  /// Route of the records screen.
  static String route = '/records';

  /// App locales.
  late AppLocalizations locales;

  /// [RecordService] used to load data for the records uplaod dialog.
  final RecordService _service = RecordService.getInstance();

  /// DB service to update settings in db.
  final DBService _dbService = DBService.getInstance();

  /// Indicates if the folder view is active or not.
  bool isFolderView = false;

  /// settings for the records view.
  late RecordViewSettings recordViewSettings;

  /// Initializes the view model.
  Future<bool> init(BuildContext context) {
    return Future.microtask(() async {
      locales = AppLocalizations.of(context)!;

      isFolderView = (await SecureStorageService.getInstance().get(
            SecureStorageService.folderViewStorageKey,
          ))
              ?.toLowerCase() ==
          'true';
      recordViewSettings = await _dbService.loadRecordViewSettings();
      return true;
    });
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

    return _service.getRecords(filter, offset, take, subfilter, recordViewSettings);
  }

  /// Plays one record.
  Future<void> playRecord(
    BuildContext context,
    ModelBase record,
    String? filter,
    ID3TagFilter? subfilter,
  ) async{
    await PlayerService.getInstance().play(
      context,
      record as Record,
      filter,
      subfilter,
    );
  }

  /// Loads the next folder which is before actual date range filtered by [subFilter].
  moveFolderUp(ID3TagFilter subFilter) {
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
              subFilter.endDate!.year, subFilter.endDate!.month),
        ),
      );
    } else if (subFilter.startDate!.month == subFilter.endDate!.month) {
      subFilter[ID3TagFilters.date] = DateTimeRange(
        start: DateTime(
          subFilter.startDate!.year,
          1,
          1,
        ),
        end: DateTime(
          subFilter.endDate!.year,
          12,
          31,
        ),
      );
    } else {
      subFilter.clear(ID3TagFilters.date);
    }
  }
}
