import 'package:flutter/material.dart';
import 'package:mml_app/view_models/intro.dart';
import 'package:mml_app/views/intro.dart';

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
    return {IntroViewModel.route: (context) => const IntroScreen()};
  }

  /// Name of the initial route for the main navigation.
  String get initialRoute {
    return IntroViewModel.route;
  }

  /// Routes of the nested navigator.
  Map<String, Route<dynamic>?> get nestedRoutes {
    // TODO do we need it?
    return {};
  }
}
