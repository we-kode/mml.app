import 'package:flutter/material.dart';
import 'package:mml_app/view_models/licenses_overview.dart';
import 'package:provider/provider.dart';
import 'package:mml_app/oss_licenses.dart';

/// Overview screen of licenses of all used packages.
class LicensesOverviewScreen extends StatelessWidget {
  /// Initializes the instance.
  const LicensesOverviewScreen({super.key});

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LicensesOverviewViewModel>(
      create: (context) => LicensesOverviewViewModel(),
      builder: (context, _) {
        var vm = Provider.of<LicensesOverviewViewModel>(context, listen: false);

        return ListView.builder(
          itemCount: ossLicenses.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(ossLicenses[index].name),
              onTap: () {
                vm.showLicense(ossLicenses[index]);
              },
            );
          },
        );
      },
    );
  }
}
