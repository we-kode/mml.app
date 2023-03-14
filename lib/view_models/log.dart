import 'dart:io';

import 'package:flutter/material.dart';

/// View model of a license detail screen.
class LogViewModel extends ChangeNotifier {
  /// Route of the license screen.
  static String route = '/log';

  // Content of the log file.
  String? content;

  /// Initialize the view model.
  Future<bool> init(BuildContext context, String filename) async {
    return Future<bool>.microtask(() async {
      final file = File(filename);
      content = await file.readAsString();
      return true;
    });
  }
}
