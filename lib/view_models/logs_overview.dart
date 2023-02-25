import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/view_models/log.dart';
import 'package:path_provider/path_provider.dart';

/// Overview screen of all licenses of the used packaged.
class LogsOverviewViewModel extends ChangeNotifier {
  /// Route of the licenses overview screen.
  static String route = '/logs_overview';

  /// List of available log files.
  List<FileSystemEntity> logFiles = List.empty(growable: true);

  /// Initialize the view model.
  Future<bool> init(BuildContext context) async {
    return Future<bool>.microtask(() async {
      final directory = (await getApplicationSupportDirectory()).path;
      logFiles = Directory("$directory/Logs/").listSync();
      return true;
    });
  }

  /// Opens a log details screen for the passed [filename].
  void showLog(String filename) {
    RouterService.getInstance().pushNestedRoute(
      LogViewModel.route,
      arguments: filename,
    );
  }
}
