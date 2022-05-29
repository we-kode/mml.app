import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mml_app/services/local_storage.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/view_models/register.dart';

/// View model for the intro screen.
class IntroViewModel extends ChangeNotifier {
  /// Route for the intro screen.
  static String route = '/intro';

  /// Pages for the intro screen.
  final List<PageViewModel> pages = [
    PageViewModel(
      title: "Title of first page",
      body:
          "Here you can write the description of the page, to explain someting...",
    ),
    PageViewModel(
      title: "Title of second page",
      body:
          "Here you can write the description of the page, to explain someting...",
    ),
    PageViewModel(
      title: "Title of third page",
      body:
          "Here you can write the description of the page, to explain someting...",
    )
  ];

  /// Current build context.
  late BuildContext _context;

  /// Locales of the application.
  late AppLocalizations locales;

  /// [LocalStorageService] used to load data from the local storage.
  late LocalStorageService _storage;

  /// Initialize the view model.
  Future<bool> init(BuildContext context) async {
    return Future<bool>.microtask(() async {
      _context = context;
      locales = AppLocalizations.of(_context)!;
      _storage = await LocalStorageService.getInstance();
      var skipTutorial = _storage.get<bool?>(LocalStorageService.skipIntro);
      if (skipTutorial == true) {
        _nextScreen();
      }
      return true;
    });
  }

  /// Manages the user skip or done click event.
  void finish() async {
    await _storage.setBool(LocalStorageService.skipIntro, true);
    await _nextScreen();
  }

  /// Calls the [RegisterScreen].
  Future _nextScreen() async {
    await RouterService.getInstance()
        .navigatorKey
        .currentState!
        .pushReplacementNamed(RegisterViewModel.route);
  }
}
