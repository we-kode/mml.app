import 'package:flutter/material.dart';
import 'package:mml_app/components/share_options_fields.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/share_options.dart';
import 'package:mml_app/services/share.dart';

/// Dialog to edit the options of the download links, the user shares. Works
/// without connection to the server.
class ShareSettingsDialog extends StatefulWidget {
  /// Initializes the dialog.
  const ShareSettingsDialog({super.key});

  @override
  State<ShareSettingsDialog> createState() => _ShareSettingsDialogState();
}

class _ShareSettingsDialogState extends State<ShareSettingsDialog> {
  final ShareService _service = ShareService.getInstance();

  late final Future<(ShareOptions, bool)> _loaded = _load();

  bool? _ask;

  Future<(ShareOptions, bool)> _load() async {
    return (await _service.loadDefaults(), await _service.useDefaults());
  }

  @override
  Widget build(BuildContext context) {
    final locales = AppLocalizations.of(context)!;

    return FutureBuilder(
      future: _loaded,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final options = snapshot.data!.$1;
        final ask = _ask ?? !snapshot.data!.$2;

        return AlertDialog(
          title: Text(locales.shareSettings),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  locales.shareSettingsInfo,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ShareOptionsFields(options: options),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(locales.shareAskBeforeSharing),
                  value: ask,
                  onChanged: (value) => setState(() => _ask = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(locales.cancel),
            ),
            TextButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                await _service.saveDefaults(options, !ask);
                nav.pop();
              },
              child: Text(locales.save),
            ),
          ],
        );
      },
    );
  }
}
