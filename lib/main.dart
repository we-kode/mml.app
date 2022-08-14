import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mml_app/mml_app.dart';
import 'package:mml_app/services/player/mml_audio_handler.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:mml_app/services/player/player.dart';

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
Future<void> main() async {
  HttpOverrides.global = MMLHttpOverrides();

  PlayerService.getInstance().audioHandler = await AudioService.init(
    builder: () => MMLAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'de.wekode.mml.audio',
      androidNotificationChannelName: 'MML Audio Channel',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
    ),
  );

/*
this.notificationColor,
this.androidNotificationIcon = 'mipmap/ic_launcher',
this.androidShowNotificationBadge = false,
this.artDownscaleWidth,
this.artDownscaleHeight,
this.preloadArtwork = false,
this.androidBrowsableRootExtras,
*/

  runApp(const MMLApp());
}
