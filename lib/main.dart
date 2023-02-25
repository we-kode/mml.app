import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:mml_app/mml_app.dart';
import 'package:mml_app/services/mml_http_overrides.dart';

/// Runs the application.
Future<void> main() async {
  HttpOverrides.global = MMLHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize Logging
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
      isDebuggable: true);

  runApp(const MMLApp());
}
