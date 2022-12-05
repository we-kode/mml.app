import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:intl/intl_standalone.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mml_app/components/intro_playlist_animation.dart';
import 'package:mml_app/components/intro_records_animation.dart';
import 'package:mml_app/components/intro_register_animation.dart';
import 'package:mml_app/services/file.dart';
import 'package:mml_app/services/player/mml_audio_handler.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:mml_app/view_models/register.dart';

/// View model for the intro screen.
class IntroViewModel extends ChangeNotifier {
  /// Route for the intro screen.
  static const String route = '/intro';

  /// Locales of the application.
  late AppLocalizations locales;

  /// [SecureStorageService] used to load data from secure store.
  final SecureStorageService _storage = SecureStorageService.getInstance();

  /// Initialize the view model.
  Future<bool> init(BuildContext context) async {
    return Future<bool>.microtask(() async {
      locales = AppLocalizations.of(context)!;

      _initApp(context);

      var skipTutorial = await _storage.get(
        SecureStorageService.skipIntroStorageKey,
      );

      if (skipTutorial == true.toString()) {
        _nextScreen();
        return false;
      }

      return true;
    });
  }

  /// Manages the user skip or done click event.
  void finish() async {
    await _storage.set(
      SecureStorageService.skipIntroStorageKey,
      true.toString(),
    );

    await _nextScreen();
  }

  /// Calls the [RegisterScreen].
  Future _nextScreen() async {
    await RouterService.getInstance()
        .pushReplacementNamed(RegisterViewModel.route);
  }

  /// Returns intro pages.
  List<PageViewModel> get pages {
    return [
      PageViewModel(
        title: locales.introTitleRegister,
        body: locales.introTextRegister,
        image: const SizedBox(
          height: 256,
          width: 256,
          child: IntroRegisterAnimation(),
        ),
      ),
      PageViewModel(
        title: locales.introTitleRecords,
        body: locales.introTextRecords,
        image: const SizedBox(
          height: 256,
          width: 256,
          child: IntroRecordsAnimation(),
        ),
      ),
      PageViewModel(
        title: locales.introTitlePlaylist,
        body: locales.introTextPlaylist,
        image: const SizedBox(
          height: 256,
          width: 256,
          child: IntroPlaylistAnimation(),
        ),
      )
    ];
  }

  /// Inits the app. All initalizing processes run here.
  Future _initApp(BuildContext context) async {
    var notificationColor = Theme.of(context).colorScheme.inverseSurface;

    await findSystemLocale();
    await FileService.getInstance().createFolder();

    PlayerService.getInstance().audioHandler = await AudioService.init(
      builder: () => MMLAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'de.wekode.mml.audio',
        androidNotificationChannelName: locales.appTitle,
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        notificationColor: notificationColor,
        androidNotificationIcon: 'mipmap/ic_notification',
        fastForwardInterval: const Duration(seconds: 10),
        rewindInterval: const Duration(seconds: 10),
      ),
    );
  }
}
