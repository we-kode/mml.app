import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/view_models/license.dart';

/// Overview screen of all licenses of the used packaged.
class LicensesOverviewViewModel extends ChangeNotifier {
  /// Route of the licenses overview screen.
  static String route = '/licenses_overview';

  /// License texts of all packages bundled with the app, sorted by package
  /// name.
  late final Future<Map<String, String>> licenses = _loadLicenses();

  /// Opens a license details screen with the passed [license] text.
  void showLicense(String license) {
    RouterService.getInstance().pushNestedRoute(
      LicenseViewModel.route,
      arguments: license,
    );
  }

  Future<Map<String, String>> _loadLicenses() async {
    final licenses = SplayTreeMap<String, String>((a, b) {
      final result = a.toLowerCase().compareTo(b.toLowerCase());
      return result != 0 ? result : a.compareTo(b);
    });
    await for (final entry in LicenseRegistry.licenses) {
      final text = entry.paragraphs
          .map(
            (paragraph) => paragraph.indent == LicenseParagraph.centeredIndent
                ? paragraph.text
                : '${'  ' * paragraph.indent}${paragraph.text}',
          )
          .join('\n\n');
      for (final package in entry.packages) {
        licenses.update(
          package,
          (existing) => '$existing\n\n${'-' * 40}\n\n$text',
          ifAbsent: () => text,
        );
      }
    }
    return licenses;
  }
}
