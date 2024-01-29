import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mml_app/arguments/playlists.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/components/progress_indicator.dart';
import 'package:mml_app/models/action_export.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/local_record.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/playlist.dart';
import 'package:mml_app/models/record_export.dart';
import 'package:mml_app/models/record_view_settings.dart';
import 'package:mml_app/models/selected_items_action.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/file.dart';
import 'package:mml_app/services/import.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// View model of the playlist view.
class PlaylistViewModel extends ChangeNotifier {
  /// Route of the plalist screen.
  static String route = '/playlist';

  late BuildContext _context;

  /// App locales.
  late AppLocalizations locales;

  /// Actual selected playlist.
  late int? playlist;

  /// DB service to update settings in db.
  final DBService _dbService = DBService.getInstance();

  /// settings for the records view.
  late RecordViewSettings recordViewSettings;

  /// Initializes the view model.
  Future<bool> init(BuildContext context, int? playlistId) {
    return Future.microtask(() async {
      _context = context;
      locales = AppLocalizations.of(context)!;
      playlist = playlistId;
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
    return playlist == null
        ? _dbService.getPlaylists(filter, offset, take)
        : _dbService.load(filter, offset, take, playlist, recordViewSettings);
  }

  /// Removes the [offlineRecords] from local database and deletes cached file, if record is not available anymore.
  Future deleteRecords(List<ModelBase?> offlineRecords) async {
    showProgressIndicator();
    for (var record in offlineRecords) {
      if (record is LocalRecord) {
        await _removeRecord(record);
      } else if (record is Playlist) {
        await deletePlaylist(record.id!);
      }
    }
    RouterService.getInstance().navigatorKey.currentState!.pop();
  }

  /// Deletes playlist with [playlistId].
  Future deletePlaylist(int playlistId) async {
    showProgressIndicator();
    var records = await _dbService.getRecords(playlistId);
    for (var record in records) {
      await _removeRecord(record);
    }
    await _dbService.removePlaylist(playlistId);
    RouterService.getInstance().navigatorKey.currentState!.pop();
  }

  /// Removes one record from playlist.
  Future _removeRecord(LocalRecord record) async {
    await _dbService.removeFromPlaylist(
      record.recordId!,
      record.playlist.id!,
    );

    if (!(await _dbService.isInPlaylist(record.recordId!))) {
      await _dbService.removeRecord(record.recordId!);
      await FileService.getInstance().remove(record.checksum!);
    }
  }

  /// Exports the [offlineRecords] from local database.
  Future exportRecords(List<ModelBase?> offlineRecords) async {
    final box = _context.findRenderObject() as RenderBox?;
    var tempDir = await getTemporaryDirectory();
    String fileName =
        "${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.mml";
    String fullPath = "${tempDir.path}/$fileName";
    Map<String, List<RecordExport>> itemsMap = {};
    for (var item in offlineRecords) {
      if (item is Playlist) {
        var plRecs = await _dbService.getRecords(item.id!);
        for (var lr in plRecs) {
          _writeToMap(itemsMap, lr);
        }
      } else {
        _writeToMap(itemsMap, item as LocalRecord);
      }
    }

    var file = File(fullPath);
    file = await file.writeAsString(json.encode(itemsMap));
    var xFile = XFile.fromData(
      file.readAsBytesSync(),
      mimeType: 'application/json',
      name: fileName,
      path: fullPath,
    );
    Share.shareXFiles(
      [xFile],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _writeToMap(
    Map<String, List<RecordExport>> itemsMap,
    LocalRecord localRecord,
  ) {
    var export = RecordExport(
      checksum: localRecord.checksum,
      title: localRecord.title,
    );
    itemsMap.update(
      localRecord.playlist.name!,
      (values) {
        values.add(export);
        return values.toList();
      },
      ifAbsent: () => [export],
    );
  }

  /// Imports records from file.
  Future<List<String>> import(PlatformFile file) async {
    return await ImportService.getInstance().import(file.path!, _context);
  }

  /// Plays one record.
  void playRecord(
    BuildContext context,
    ModelBase record,
    String? filter,
    ID3TagFilter? subfilter,
  ) {
    PlayerService.getInstance().play(
      context,
      record as LocalRecord,
      filter,
      subfilter,
    );
  }

  /// navigates to folder of [playlist].
  void navigate(Playlist playlist) async {
    var routerService = RouterService.getInstance();
    await routerService.pushNestedRoute(
      route,
      arguments: PlaylistArguments(
        appBar: FilterAppBar(
          title: playlist.name!,
          listAction: SelectedItemsAction(
            const Icon(Icons.delete),
            reload: true,
          ),
          exportAction: ExportAction(),
        ),
        playlist: playlist,
      ),
    );
  }

  /// updates listeners for changes
  void update() {
    notifyListeners();
  }
}
