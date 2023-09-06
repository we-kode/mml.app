import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mml_app/mml_app.dart';
import 'package:mml_app/services/mml_http_overrides.dart';

/// Runs the application.
Future<void> main() async {
  HttpOverrides.global = MMLHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MMLApp());
}
