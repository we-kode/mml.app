import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/arguments/subroute_arguments.dart';
import 'package:mml_app/services/client.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/view_models/information.dart';
import 'package:mml_app/view_models/licenses_overview.dart';
import 'package:mml_app/view_models/server_connection.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// View model of the settings screen.
class SettingsViewModel extends ChangeNotifier {
  /// Route of the settings screen.
  static String route = '/settings';

  /// App locales.
  late AppLocalizations locales;

  /// Router service used for navigation.
  final RouterService _routerService = RouterService.getInstance();

  final String privacyLink = "";

  final String legalInfoLink = "";

  /// version of the running app.
  late String version;

  /// Initializes the view model.
  Future<bool> init(BuildContext context) {
    return Future.microtask(() async {
      locales = AppLocalizations.of(context)!;
      var pkgInfo = await PackageInfo.fromPlatform();
      version = "${pkgInfo.version}.${pkgInfo.buildNumber}";
      return true;
    });
  }

  /// Calls the service method to remove the client registration.
  Future removeRegistration() async {
    await ClientService.getInstance().removeRegistration();
  }

  /// Redirects to the connection update screen.
  void changeServerConnection() {
    _routerService.pushNestedRoute(
      ServerConnectionViewModel.route,
      arguments: SubrouteArguments(),
    );
  }

  /// Redirects to the license overview screen.
  void showLicensesOverview() {
    _routerService.pushNestedRoute(
      LicensesOverviewViewModel.route,
      arguments: SubrouteArguments(),
    );
  }

  /// Redirects to the legal information webview screen.
  void showLegalInformation() {
    _routerService.pushNestedRoute(
      InformationViewModel.route,
      arguments: SubrouteArguments(arg: legalInfoLink),
    );
  }

  /// Redirects to the privacy policy webview screen.
  void showPrivacyPolicy() {
    _routerService.pushNestedRoute(
      InformationViewModel.route,
      arguments: SubrouteArguments(arg: privacyLink),
    );
  }
}
