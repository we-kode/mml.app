import 'package:flutter/material.dart';
import 'package:mml_app/view_models/intro.dart';
import 'package:mml_app/view_models/main.dart';
import 'package:mml_app/view_models/playlist.dart';
import 'package:mml_app/view_models/records.dart';
import 'package:mml_app/view_models/register.dart';
import 'package:mml_app/view_models/settings.dart';
import 'package:mml_app/views/intro.dart';
import 'package:mml_app/views/main.dart';
import 'package:mml_app/views/playlist.dart';
import 'package:mml_app/views/records.dart';
import 'package:mml_app/views/register.dart';
import 'package:mml_app/views/settings.dart';

/// Service that holds all routing information of the navigators of the app.
class RouterService {
  /// Instance of the router service.
  static final RouterService _instance = RouterService._();

  /// GlobalKey of the state of the main navigator.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  /// Private constructor of the service.
  RouterService._();

  /// Returns the singleton instance of the [RouterService].
  static RouterService getInstance() {
    return _instance;
  }

  /// Routes of the main navigator.
  Map<String, Widget Function(BuildContext)> get routes {
    return {
      IntroViewModel.route: (context) => const IntroScreen(),
      RegisterViewModel.route: (context) => const RegisterScreen(),
      MainViewModel.route: (context) => const MainScreen(),
    };
  }

  /// Name of the initial route for the main navigation.
  String get initialRoute {
    return IntroViewModel.route;
  }

  /// Routes of the nested navigator.
  Map<String, Route<dynamic>?> get nestedRoutes {
   return {
      RecordsViewModel.route: PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const RecordsScreen(),
        transitionDuration: const Duration(seconds: 0),
      ),
      PlaylistViewModel.route: PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const PlaylistScreen(),
        transitionDuration: const Duration(seconds: 0),
      ),
      SettingsViewModel.route: PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            const SettingsScreen(),
        transitionDuration: const Duration(seconds: 0),
      ),
    };
  }

  /// Replaces the complete route history stack with the route with the passed
  /// [name].
  Future pushReplacementNamed(String name) async {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
    await navigatorKey.currentState!.pushReplacementNamed(name);
  }
}
