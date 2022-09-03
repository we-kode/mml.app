import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/file.dart';

/// ViewModel of the uplaod dialog for records.
class RecordsDownloadDialogViewModel extends ChangeNotifier {
  /// Locales of the application.
  late AppLocalizations locales;

  /// The [BuildContext] of this vie model.
  late BuildContext _context;

  /// The progress of downloading the current record.
  int downloadProgress = 0;

  /// Name of the record which is current downlaoding.
  String downloadFileName = '';

  /// Initializes the ViewModel and starts the downloading process.
  ///
  /// If no [folderPath] is provided, files from the [fileList] will be uploaded, else
  /// all files from the [folderPath] will be uploaded recursive.
  Future<bool> init(
    BuildContext context,
    List<ModelBase?> records,
    List<dynamic> playlists,
  ) async {
    _context = context;
    locales = AppLocalizations.of(context)!;
    return Future<bool>.microtask(
      () {
        _download(records, playlists);
        return true;
      },
    );
  }

  /// Downloads and adds the selected [records] into the selected [playlists].
  Future _download(
    List<ModelBase?> records,
    List<dynamic> playlists,
  ) async {
    final nav = Navigator.of(_context);
    for (var record in records) {
      var r = record as Record;
      downloadFileName = record.title ?? locales.unknown;
      await FileService.getInstance().download(r,
          onProgress: (count, total) async {
        downloadProgress = ((count / total) * 100).toInt();
        if (downloadProgress == 100) {
          await DBService.getInstance().addRecord(r, playlists);
        }
        notifyListeners();
      });
    }
    nav.pop(true);
    return true;
  }
}
