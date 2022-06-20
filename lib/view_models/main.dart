import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/services/router.dart';

/// View model for the main screen.
class MainViewModel extends ChangeNotifier {
  /// Route of the main screen.
  static String route = '/';

  /// Current build context.
  late BuildContext _context;

  /// Locales of the app.
  late AppLocalizations locales;

  /// Index of the currently selected route.
  int _selectedIndex = 0;

  /// Items of the navigation bar.
  late final List<BottomNavigationBarItem> navItems = [
    BottomNavigationBarItem(
      icon: const Icon(
        Icons.music_note_outlined,
      ),
      label: locales.records,
    ),
    BottomNavigationBarItem(
      icon: const Icon(
        Icons.playlist_play,
      ),
      label: locales.playlist,
    ),
    BottomNavigationBarItem(
      icon: const Icon(
        Icons.settings,
      ),
      label: locales.settings,
    ),
  ];

  /// Initializes the view model.
  Future<bool> init(BuildContext context) async {
    _context = context;
    locales = AppLocalizations.of(_context)!;
    return true;
  }

  /// Sets the actual screens [index] as selected.
  set selectedIndex(int index) {
    _selectedIndex = index;
    loadPage();
    notifyListeners();
  }

  /// Returns index of the actual selected page.
  int get selectedIndex {
    return _selectedIndex;
  }

  /// Loads the selected page of the navigation.
  void loadPage() {
    _context.visitChildElements((element) {
      _loadScreen(element);
    });
  }

  /// Loads the route of the selected item in the bottom navigation bar.
  ///
  /// Searches the [element] for an existing [Navigator]. If element is of type [Navigator]
  /// the new route will be loaded in the nested [Navigator].
  void _loadScreen(Element element) {
    if (element.widget is Navigator) {
      var state = (element as StatefulElement).state as NavigatorState;
      var routeService = RouterService.getInstance();
      var route = routeService.nestedRoutes.keys.elementAt(_selectedIndex);
      state.pushNamed(route);
      return;
    }

    element.visitChildElements((e) {
      _loadScreen(e);
    });
  }
}
