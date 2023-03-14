import 'dart:io';

import 'package:flutter_logs/flutter_logs.dart';
import 'package:mml_app/constants/development.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:path_provider/path_provider.dart';

/// Service that handles debug logging.
class Logging {
  /// Writes an info log.
  static void logInfo(
    String tag,
    String subTag,
    String message,
  ) {
    if (isDebugBuild) {
      FlutterLogs.logInfo(
        tag,
        subTag,
        message,
      );
    }
  }

  /// Writes an error log.
  static void logError(
    String tag,
    String subTag,
    String message,
  ) {
    if (isDebugBuild) {
      FlutterLogs.logError(
        tag,
        subTag,
        message,
      );
    }
  }

  /// Clears all saved logs.
  static Future<void> clear() async {
    await FlutterLogs.clearLogs();
    MessengerService.getInstance().showMessage('Logs deleted!');
  }

  /// Inits the logger.
  static Future<void> init() async {
    await FlutterLogs.initLogs(
      logLevelsEnabled: [
        LogLevel.INFO,
        LogLevel.WARNING,
        LogLevel.ERROR,
        LogLevel.SEVERE
      ],
      timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
      directoryStructure: DirectoryStructure.FOR_DATE,
      logTypesEnabled: ["device", "network", "errors"],
      logFileExtension: LogFileExtension.LOG,
      logsWriteDirectoryName: "mmlLogs",
      logsExportDirectoryName: "mmlLogs/Exported",
      debugFileOperations: true,
      isDebuggable: true,
    );
  }

  /// Lists all available logs saved on device.
  static Future<List<FileSystemEntity>> list() async {
    final directory = (await getApplicationSupportDirectory()).path;
    return Directory("$directory/Logs/").listSync();
  }
}
