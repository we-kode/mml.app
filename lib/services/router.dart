import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mml_app/arguments/navigation_arguments.dart';
import 'package:mml_app/arguments/playlists.dart';
import 'package:mml_app/arguments/subroute_arguments.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/models/selected_items_action.dart';
import 'package:mml_app/oss_licenses.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/view_models/faq.dart';
import 'package:mml_app/view_models/information.dart';
import 'package:mml_app/view_models/intro.dart';
import 'package:mml_app/view_models/license.dart';
import 'package:mml_app/view_models/licenses_overview.dart';
import 'package:mml_app/view_models/livestreams/overview.dart';
import 'package:mml_app/view_models/log.dart';
import 'package:mml_app/view_models/logs_overview.dart';
import 'package:mml_app/view_models/main.dart';
import 'package:mml_app/view_models/playlists/overview.dart';
import 'package:mml_app/view_models/records/overview.dart';
import 'package:mml_app/view_models/register.dart';
import 'package:mml_app/view_models/server_connection.dart';
import 'package:mml_app/view_models/settings.dart';
import 'package:mml_app/views/faq.dart';
import 'package:mml_app/views/information.dart';
import 'package:mml_app/views/intro.dart';
import 'package:mml_app/views/license.dart';
import 'package:mml_app/views/licenses_overview.dart';
import 'package:mml_app/views/livestreams/overview.dart';
import 'package:mml_app/views/log.dart';
import 'package:mml_app/views/logs_overview.dart';
import 'package:mml_app/views/main.dart';
import 'package:mml_app/views/playlists/overview.dart';
import 'package:mml_app/views/records/overview.dart';
import 'package:mml_app/views/register.dart';
import 'package:mml_app/views/server_connection.dart';
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

  /// Maps routes and subroutes to their root route.
  final Map<String, int> _rootRoutes = {
    RecordsViewModel.route: 0,
    PlaylistViewModel.route: 1,
    LivestreamsViewModel.route: 2,
    SettingsViewModel.route: 3,
    ServerConnectionViewModel.route: 3,
    LicensesOverviewViewModel.route: 3,
    LicenseViewModel.route: 3,
    FAQViewModel.route: 3,
    LogsOverviewViewModel.route: 3,
    LogViewModel.route: 3,
  };

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
  Map<String, PageRouteBuilder> getNestedRoutes({Object? args}) {
    return {
      RecordsViewModel.route: PageRouteBuilder(
        settings: RouteSettings(
          name: RecordsViewModel.route,
          arguments: NavigationArguments(
            FilterAppBar(
              title: 'records',
              enableFilter: true,
              listAction: SelectedItemsAction(
                const Icon(Icons.star_outline),
              ),
            ),
          ),
        ),
        pageBuilder: (context, animation1, animation2) {
          return RecordsScreen(
            appBar: MainViewModel.appBar,
          );
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      PlaylistViewModel.route: PageRouteBuilder(
        settings: RouteSettings(
          name: PlaylistViewModel.route,
          arguments: PlaylistArguments(
            appBar: FilterAppBar(
              title: (args is PlaylistArguments) && args.playlist != null
                  ? args.playlist!.name!
                  : 'playlist',
              enableBack: (args is PlaylistArguments) && args.playlist != null,
              listAction: SelectedItemsAction(
                const Icon(Icons.delete),
                reload: true,
              ),
            ),
          ),
        ),
        pageBuilder: (context, animation1, animation2) {
          return PlaylistScreen(
            appBar: MainViewModel.appBar,
            playlistId: (args is PlaylistArguments) ? args.playlist?.id : null,
          );
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      LivestreamsViewModel.route: PageRouteBuilder(
        settings: RouteSettings(
          name: LivestreamsViewModel.route,
          arguments: NavigationArguments(
            FilterAppBar(
              title: 'livestreams',
            ),
          ),
        ),
        pageBuilder: (context, animation1, animation2) {
          return LivestreamScreen(
            appBar: MainViewModel.appBar,
          );
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      SettingsViewModel.route: PageRouteBuilder(
        settings: RouteSettings(
          name: SettingsViewModel.route,
          arguments: NavigationArguments(
            FilterAppBar(
              title: 'settings',
            ),
          ),
        ),
        pageBuilder: (context, animation1, animation2) {
          return const SettingsScreen();
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      ServerConnectionViewModel.route: PageRouteBuilder(
        settings: RouteSettings(
          name: ServerConnectionViewModel.route,
          arguments: args,
        ),
        pageBuilder: (context, animation1, animation2) =>
            const ServerConnectionScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      InformationViewModel.route: PageRouteBuilder(
        settings: RouteSettings(
          name: InformationViewModel.route,
          arguments: args,
        ),
        pageBuilder: (context, animation1, animation2) => InformationScreen(
          url: ((args as SubrouteArguments).arg as String),
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      LicensesOverviewViewModel.route: PageRouteBuilder(
        settings: RouteSettings(
          name: LicensesOverviewViewModel.route,
          arguments: args,
        ),
        pageBuilder: (context, animation1, animation2) =>
            const LicensesOverviewScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      LicenseViewModel.route: PageRouteBuilder(
        settings: RouteSettings(
          name: LicenseViewModel.route,
          arguments: args,
        ),
        pageBuilder: (context, animation1, animation2) => LicenseScreen(
          package: (args as Package),
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      FAQViewModel.route: PageRouteBuilder(
        settings: RouteSettings(
          name: FAQViewModel.route,
          arguments: args,
        ),
        pageBuilder: (context, animation1, animation2) => const FAQScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      LogsOverviewViewModel.route: PageRouteBuilder(
        settings: RouteSettings(
          name: LogsOverviewViewModel.route,
          arguments: args,
        ),
        pageBuilder: (context, animation1, animation2) =>
            const LogsOverviewScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      LogViewModel.route: PageRouteBuilder(
        settings: RouteSettings(
          name: LogViewModel.route,
          arguments: args,
        ),
        pageBuilder: (context, animation1, animation2) => LogScreen(
          filename: (args as String),
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    };
  }

  /// Replaces the complete route history stack with the route with the passed
  /// [name].
  Future pushReplacementNamed(String name) async {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
    await navigatorKey.currentState!.pushReplacementNamed(name);
  }

  /// Pops the latest route of the nested navigator.
  Future<bool> popNestedRoute() async {
    return await _getNestedNavigatorState()!.maybePop();
  }

  /// Pushes the route with the passed [name] and [arguments] to the nested
  /// navigator.
  Future pushNestedRoute(String name, {Object? arguments}) async {
    await PlayerService.getInstance().resetOnRecordChange();
    await _getNestedNavigatorState()!.pushNamed(name, arguments: arguments);
  }

  /// Returns the state of the nested navigator, by searching from the outer
  /// navigator.
  NavigatorState? _getNestedNavigatorState({Element? element}) {
    if (element?.widget is Navigator) {
      return (element as StatefulElement).state as NavigatorState;
    } else if (element == null) {
      NavigatorState? state;

      navigatorKey.currentContext!.visitChildElements((e) {
        state ??= _getNestedNavigatorState(element: e);
      });

      return state;
    }

    NavigatorState? state;

    element.visitChildElements((e) {
      state ??= _getNestedNavigatorState(element: e);
    });

    return state;
  }

  /// Returns the root route index.
  int getRootRoute(String route) {
    return _rootRoutes[route] ?? _rootRoutes.values.reduce(max);
  }
}
