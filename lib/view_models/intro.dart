import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:mml_app/view_models/register.dart';

/// View model for the intro screen.
class IntroViewModel extends ChangeNotifier {
  /// Route for the intro screen.
  static String route = '/intro';

  /// Locales of the application.
  late AppLocalizations locales;

  /// [SecureStorageService] used to load data from secure store.
  final SecureStorageService _storage = SecureStorageService.getInstance();

  /// Initialize the view model.
  Future<bool> init(BuildContext context) async {
    return Future<bool>.microtask(() async {
      locales = AppLocalizations.of(context)!;

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
      ),
      PageViewModel(
        title: locales.introTitleRecords,
        body: locales.introTextRecords,
      ),
      PageViewModel(
        title: locales.introTitlePlaylist,
        body: locales.introTextPlaylist,
      )
    ];
  }
}
