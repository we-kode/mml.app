import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/models/record_export.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:mml_app/services/playlist.dart';
import 'package:mml_app/services/record.dart';

/// Service handles import of .mml files.
class ImportService {
  /// Instance of the service.
  static final ImportService _instance = ImportService._();

  /// Returns the singleton instance of the [ImportService].
  static ImportService getInstance() {
    return _instance;
  }

  // Service to show messages.
  final MessengerService _messengerService = MessengerService.getInstance();

  /// [RecordService] used to load data for the records uplaod dialog.
  final RecordService _recordService = RecordService.getInstance();

  /// DB service to update settings in db.
  final DBService _dbService = DBService.getInstance();

  /// Private constructor of the service.
  ImportService._();

  /// Imports records from file.
  Future<List<String>> import(
    String? url,
    BuildContext context, {
    String? cnt,
  }) async {
    Map<String, dynamic> savedPlaylists;
    List<RecordExport> notAvailable = List.empty(growable: true);
    String content;
    File? file;
    try {
      if (url != null && url.isNotEmpty) {
        file = File(url);
        content = file.readAsStringSync();
      } else if (cnt != null && cnt.isNotEmpty) {
        content = cnt;
      } else {
        throw Exception("No content or file provided.");
      }

      savedPlaylists = jsonDecode(content);
      for (var entryKey in savedPlaylists.keys) {
        var exportedRecords = List.from(savedPlaylists[entryKey]).map(
          (entry) => RecordExport.fromJson(entry),
        );
        var checksums = exportedRecords.map(
          (entry) => entry.checksum,
        );
        var playlist = await _dbService.createOrUpdatePlaylist(entryKey);
        var records =
            await _recordService.getRecordsByChecksum(List.from(checksums));
        notAvailable.addAll(
          exportedRecords.where(
            (element) => !records
                .any((rec) => (rec as Record).checksum == element.checksum),
          ),
        );

        if (!context.mounted) {
          return List.empty();
        }
        await PlaylistService.getInstance().downloadRecords(
          records,
          context,
          playlist: playlist,
        );
      }
      if (file != null) {
        await file.delete();
      }
    } catch (e) {
      _messengerService.showMessage(_messengerService.notCompatibleFile);
      return List.empty();
    }

    return notAvailable.map((e) => e.title!).toSet().toList();
  }
}
