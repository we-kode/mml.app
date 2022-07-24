import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/services/record.dart';

/// View model of the records screen.
class RecordsViewModel extends ChangeNotifier {
  /// Route of the records screen.
  static String route = '/records';

  static Widget routeArgs = const FilterAppBar(
    title: "records",
    enableFilter: true,
  );

  /// App locales.
  late AppLocalizations locales;

  /// [RecordService] used to load data for the records uplaod dialog.
  final RecordService _service = RecordService.getInstance();

  /// [StreamController] to stream events on.
  final StreamController filterChangedStreamController = StreamController();

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

  /// Gets called when [ID3TagFilter] changes.
  void filterChanged(ID3TagFilter? filter) {
    filterChangedStreamController.add(filter);
  }
}
