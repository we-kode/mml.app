import 'package:flutter/material.dart';
import 'package:mml_app/oss_licenses.dart';

/// License detail screen.
class LicenseScreen extends StatelessWidget {
  /// Package model to show the license for.
  final Package package;

  /// Initializes the instance.
  const LicenseScreen({super.key, required this.package});

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(package.license ?? ""),
      ),
    );
  }
}
