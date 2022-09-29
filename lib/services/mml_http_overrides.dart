import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mml_app/services/messenger.dart';

/// HTTP-Overrides that allows bad certificates in debug mode and shows a
/// message in release mode.
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
