import 'package:flutter/material.dart';
import 'package:mml_app/oss_licenses.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/view_models/license.dart';

/// Overview screen of all licenses of the used packaged.
class LicensesOverviewViewModel extends ChangeNotifier {
  /// Route of the licenses overview screen.
  static String route = '/licenses_overview';

  /// Opens a license details screen for the passed [package].
  void showLicense(Package package) {
    RouterService.getInstance().pushNestedRoute(
      LicenseViewModel.route,
      arguments: package,
    );
  }
}
