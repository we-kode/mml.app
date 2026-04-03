import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mml_app/components/vertical_spacer.dart';
import 'package:mml_app/view_models/settings.dart';
import 'package:provider/provider.dart';

/// Settings screen.
class SettingsScreen extends StatelessWidget {
  /// Initializes the instance.
  const SettingsScreen({super.key});

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
                  leading: const Icon(Symbols.numbers),
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
                  leading: const Icon(Symbols.genres),
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
                  leading: const Icon(Symbols.translate),
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
                ListTile(
                  leading: const Icon(Symbols.image),
                  title: Text(vm.locales.cover),
                  trailing: Consumer<SettingsViewModel>(
                    builder: (context, vm, _) {
                      return Switch(
                        onChanged: (value) => {
                          vm.recordViewSettings.cover = value,
                          vm.updateRecordViewSettings()
                        },
                        value: vm.recordViewSettings.cover,
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
                  leading: const Icon(Symbols.filter_alt),
                  title: Text(vm.locales.saveFilters),
                  trailing: Consumer<SettingsViewModel>(
                    builder: (context, vm, _) {
                      return Switch(
                        onChanged: (value) => {
                          vm.saveFilters = value,
                          vm.updateFilterSaveSettings()
                        },
                        value: vm.saveFilters,
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Symbols.qr_code_2),
                  title: Text(vm.locales.changeServerConnection),
                  onTap: vm.changeServerConnection,
                ),
                ListTile(
                  leading: Icon(
                    Symbols.app_blocking,
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
                const Divider(),
                verticalSpacer,
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -4),
                  title: Text(
                    vm.locales.cacheSettings,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  leading: const Icon(Symbols.avg_pace),
                  trailing: DropdownMenu(
                    inputDecorationTheme: InputDecorationTheme(isDense: true),
                    selectOnly: true,
                    dropdownMenuEntries: [
                      DropdownMenuEntry(
                        value: 7,
                        label: vm.locales.cacheRangeWeek,
                      ),
                      DropdownMenuEntry(
                        value: 30,
                        label: vm.locales.cacheRangeMonth,
                      ),
                      DropdownMenuEntry(
                        value: 365,
                        label: vm.locales.cacheRangeYear,
                      ),
                      DropdownMenuEntry(
                        value: 3650,
                        label: vm.locales.cacheRangeNever,
                      ),
                    ],
                    initialSelection: vm.cacheManager.durationLimit,
                    onSelected: (value) {
                      vm.updateCacheLimits(duration: value);
                    },
                  ),
                  title: Text(vm.locales.cacheRemoveTime),
                ),
                verticalSpacer,
                TextButton(
                  onPressed: () {
                    vm.clearCache();
                  },
                  child: ValueListenableBuilder<double>(
                    valueListenable: vm.cacheManager.cacheSizeMB,
                    builder: (context, size, _) {
                      return Text(
                        '${vm.locales.cacheRemove} (${size.toStringAsFixed(2)} MB)',
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
                    vm.locales.info,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  leading: const Icon(Symbols.help),
                  title: Text(vm.locales.faq),
                  onTap: vm.showFAQ,
                ),
                if (vm.supportEMail.isNotEmpty)
                  ListTile(
                    leading: const Icon(Symbols.feedback),
                    title: Text(vm.locales.sendFeedback),
                    onTap: vm.sendFeedback,
                  ),
                if (vm.privacyLink.isNotEmpty)
                  ListTile(
                    leading: const Icon(Symbols.verified_user),
                    title: Text(vm.locales.privacyPolicy),
                    onTap: vm.showPrivacyPolicy,
                  ),
                if (vm.legalInfoLink.isNotEmpty)
                  ListTile(
                    leading: const Icon(Symbols.privacy_tip),
                    title: Text(vm.locales.legalInformation),
                    onTap: vm.showLegalInformation,
                  ),
                ListTile(
                  leading: const Icon(Symbols.key),
                  title: Text(vm.locales.licenses),
                  onTap: vm.showLicensesOverview,
                ),
                ListTile(
                  leading: const Icon(Symbols.new_releases),
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
