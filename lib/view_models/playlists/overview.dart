import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/components/progress_indicator.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/file.dart';
import 'package:mml_app/services/router.dart';

/// View model of the playlist view.
class PlaylistViewModel extends ChangeNotifier {
  /// Route of the plalist screen.
  static String route = '/playlist';

  /// [RecordService] used to load data for the records uplaod dialog.
  final DBService _service = DBService.getInstance();

  /// App locales.
  late AppLocalizations locales;

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
    return _service.load(filter, offset, take);
  }

  /// Removes the [offlineRecords] from local databse and deltes cahced file, if record is not available anymore.
  Future deleteRecords(List<ModelBase?> offlineRecords) async {
    showProgressIndicator();
    for (var record in offlineRecords) {
      var offlineRecord = record as Record;
      await _service.removeFromPlaylist(
          offlineRecord.recordId!, offlineRecord.playlist!.id!);

      if (!(await _service.isInPlaylist(offlineRecord.recordId!))) {
        await _service.removeRecord(offlineRecord.recordId!);
        await FileService.getInstance().remove(offlineRecord.file!);
      }
    }
    RouterService.getInstance().navigatorKey.currentState!.pop();
  }
}
