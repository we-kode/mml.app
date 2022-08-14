import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/record.dart';

/// View model of the records screen.
class RecordsViewModel extends ChangeNotifier {
  /// Route of the records screen.
  static String route = '/records';

  /// The [FilterApp] of the records overview screen.
  static FilterAppBar appBar = FilterAppBar(
    title: 'records',
    enableFilter: true,
  );

  /// App locales.
  late AppLocalizations locales;

  /// [RecordService] used to load data for the records uplaod dialog.
  final RecordService _service = RecordService.getInstance();

  /// Initializes the view model.
  Future<bool> init(BuildContext context) {
    return Future.microtask(() {
      locales = AppLocalizations.of(context)!;

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
    return _service.getRecords(filter, offset, take, subfilter);
  }

  void playRecord(
    BuildContext context,
    ModelBase record,
    String? filter,
    ID3TagFilter? subfilter,
  ) {
    PlayerService.getInstance().play(
      context,
      record as Record,
      filter,
      subfilter,
    );
  }
}
