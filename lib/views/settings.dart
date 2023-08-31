import 'package:flutter/material.dart';
import 'package:mml_app/components/vertical_spacer.dart';
import 'package:mml_app/constants/development.dart';
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
                    vm.locales.display,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(vm.locales.displayDescription),
                ),
                ListTile(
                  leading: const Icon(Icons.numbers),
                  title: Text(vm.locales.showTrackNumber),
                  trailing: Consumer<SettingsViewModel>(
                    builder: (context, vm, _) {
                      return Switch(
                        onChanged: (value) => {
                          vm.recordViewSettings.tracknumber = value,
                          vm.updateRecordViewSettings()
                        },
                        value: vm.recordViewSettings.tracknumber,
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.discount),
                  title: Text(vm.locales.showGenre),
                  trailing: Consumer<SettingsViewModel>(
                    builder: (context, vm, _) {
                      return Switch(
                        onChanged: (value) => {
                          vm.recordViewSettings.genre = value,
                          vm.updateRecordViewSettings()
                        },
                        value: vm.recordViewSettings.genre,
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text(vm.locales.showLanguage),
                  trailing: Consumer<SettingsViewModel>(
                    builder: (context, vm, _) {
                      return Switch(
                        onChanged: (value) => {
                          vm.recordViewSettings.language = value,
                          vm.updateRecordViewSettings()
                        },
                        value: vm.recordViewSettings.language,
                      );
                    },
                  ),
                ),
                const Divider(),
                verticalSpacer,
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -4),
                  title: Text(
                    vm.locales.settings,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_2),
                  title: Text(vm.locales.changeServerConnection),
                  onTap: vm.changeServerConnection,
                ),
                ListTile(
                  leading: Icon(
                    Icons.app_blocking,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    vm.locales.removeRegistration,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: vm.removeRegistration,
                ),
                if (isDebugBuild) const Divider(),
                if (isDebugBuild) verticalSpacer,
                if (isDebugBuild)
                  ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -4),
                    title: Text(
                      vm.locales.development,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                if (isDebugBuild)
                  ListTile(
                    leading: const Icon(Icons.manage_search),
                    title: Text(vm.locales.showLogs),
                    onTap: vm.showLogs,
                  ),
                if (isDebugBuild)
                  ListTile(
                    leading: const Icon(Icons.delete_sweep),
                    title: Text(vm.locales.clearLogs),
                    onTap: vm.clearLogs,
                  ),
                const Divider(),
                verticalSpacer,
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -4),
                  title: Text(
                    vm.locales.info,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: Text(vm.locales.faq),
                  onTap: vm.showFAQ,
                ),
                if (vm.supportEMail.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: Text(vm.locales.sendFeedback),
                    onTap: vm.sendFeedback,
                  ),
                if (vm.privacyLink.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.verified_user),
                    title: Text(vm.locales.privacyPolicy),
                    onTap: vm.showPrivacyPolicy,
                  ),
                if (vm.legalInfoLink.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: Text(vm.locales.legalInformation),
                    onTap: vm.showLegalInformation,
                  ),
                ListTile(
                  leading: const Icon(Icons.key),
                  title: Text(vm.locales.licenses),
                  onTap: vm.showLicensesOverview,
                ),
                ListTile(
                  leading: const Icon(Icons.new_releases),
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
