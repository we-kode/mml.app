import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mml_app/mml_app.dart';
import 'package:mml_app/services/messenger.dart';

class MMLHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
      ) {
        // Ignore bad certificates in debug mode!
        if (kReleaseMode) {
          final messenger = MessengerService.getInstance();
          messenger.showMessage(messenger.badCertificate);
        }
        return !kReleaseMode;
      };
  }
}

/// Runs the application.
void main() {
  HttpOverrides.global = MMLHttpOverrides();
  runApp(const MMLApp());
}
