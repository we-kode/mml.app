import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/arguments/subroute_arguments.dart';
import 'package:mml_app/models/record_view_settings.dart';
import 'package:mml_app/services/client.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/logging.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/view_models/faq.dart';
import 'package:mml_app/view_models/information.dart';
import 'package:mml_app/view_models/licenses_overview.dart';
import 'package:mml_app/view_models/logs_overview.dart';
import 'package:mml_app/view_models/server_connection.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mml_app/components/delete_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// View model of the settings screen.
class SettingsViewModel extends ChangeNotifier {
  /// Route of the settings screen.
  static String route = '/settings';

  /// App locales.
  late AppLocalizations locales;

  /// Build context.
  late BuildContext _context;

  /// Router service used for navigation.
  final RouterService _routerService = RouterService.getInstance();

  /// DB service to update settings in db.
  final DBService _dbService = DBService.getInstance();

  /// Link of the privacy policy.
  final String privacyLink = "https://ecgm.freeddns.org:18188/privacy";

  /// Link of the legal informations.
  final String legalInfoLink = "";

  /// E-Mail adress for support requests.
  final String supportEMail = "";

  /// version of the running app.
  late String version;

  /// settings for the records view.
  late RecordViewSettings recordViewSettings;

  /// Initializes the view model.
  Future<bool> init(BuildContext context) {
    return Future.microtask(() async {
      _context = context;
      locales = AppLocalizations.of(context)!;
      var pkgInfo = await PackageInfo.fromPlatform();
      version = "${pkgInfo.version}.${pkgInfo.buildNumber}";
      recordViewSettings = await _dbService.loadRecordViewSettings();
      return true;
    });
  }

  /// Calls the service method to remove the client registration.
  Future removeRegistration() async {
    var shouldDelete = await showDeleteDialog(_context);

    if (shouldDelete) {
      await ClientService.getInstance().removeRegistration();
    }
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

  /// Redirects to the faq screen.
  void showFAQ() {
    _routerService.pushNestedRoute(
      FAQViewModel.route,
      arguments: SubrouteArguments(),
    );
  }

  /// Opens mail program to send feedback.
  Future<void> sendFeedback() async {
    if (supportEMail.isEmpty) {
      return;
    }
    final Uri uri = Uri(
      scheme: 'mailto',
      path: supportEMail,
      query: _encodeQueryParameters(
        <String, String>{
          'subject': locales.appTitle,
        },
      ),
    );
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future updateRecordViewSettings() async {
    await _dbService.saveRecordViewSettings(recordViewSettings);
    notifyListeners();
  }

  Future clearLogs() async {
    await Logging.clear();
  }

  void showLogs() {
    _routerService.pushNestedRoute(
      LogsOverviewViewModel.route,
      arguments: SubrouteArguments(),
    );
  }
}
