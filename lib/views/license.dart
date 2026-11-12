import 'package:flutter/material.dart';

/// License detail screen.
class LicenseScreen extends StatelessWidget {
  /// License text to show.
  final String license;

  /// Initializes the instance.
  const LicenseScreen({super.key, required this.license});

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.all(5), child: Text(license)),
    );
  }
}
