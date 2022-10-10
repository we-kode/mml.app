import 'package:flutter/material.dart';
import 'package:mml_app/view_models/settings.dart';
import 'package:provider/provider.dart';

/// Settings screen.
class SettingsScreen extends StatelessWidget {
  /// Initializes the instance.
  const SettingsScreen({Key? key}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsViewModel>(
      create: (context) => SettingsViewModel(),
      builder: (context, _) {
        var vm = Provider.of<SettingsViewModel>(context, listen: false);

        return FutureBuilder(
          future: vm.init(context),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: [
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -4),
                  title: Text(
                    vm.locales.settings,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                ListTile(
                  title: Text(vm.locales.changeServerConnection),
                  onTap: vm.changeServerConnection,
                ),
                ListTile(
                  title: Text(
                    vm.locales.removeRegistration,
                    style: TextStyle(
                      color: Theme.of(context).errorColor,
                    ),
                  ),
                  onTap: vm.removeRegistration,
                ),
                const Divider(),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -4),
                  title: Text(
                    vm.locales.info,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                if (vm.privacyLink.isNotEmpty)
                  ListTile(
                    title: Text(vm.locales.privacyPolicy),
                    onTap: vm.showPrivacyPolicy,
                  ),
                if (vm.legalInfoLink.isNotEmpty)
                  ListTile(
                    title: Text(vm.locales.legalInformation),
                    onTap: vm.showLegalInformation,
                  ),
                ListTile(
                  title: Text(vm.locales.licenses),
                  onTap: vm.showLicensesOverview,
                ),
                ListTile(
                  title: Text(vm.version),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
