import 'package:flutter/material.dart';
import 'package:mml_app/view_models/licenses_overview.dart';
import 'package:provider/provider.dart';

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

        return FutureBuilder<Map<String, String>>(
          future: vm.licenses,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final licenses = snapshot.data!.entries.toList();
            return ListView.builder(
              itemCount: licenses.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(licenses[index].key),
                  onTap: () {
                    vm.showLicense(licenses[index].value);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
