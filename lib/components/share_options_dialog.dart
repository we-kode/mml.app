import 'package:flutter/material.dart';
import 'package:mml_app/components/share_options_fields.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/share_options.dart';

/// Dialog to configure a share link before it is created. Pops the chosen
/// [ShareOptions] and whether they are used as defaults from now on.
class ShareOptionsDialog extends StatefulWidget {
  /// The options the dialog starts with.
  final ShareOptions options;

  /// Initializes the dialog.
  const ShareOptionsDialog({super.key, required this.options});

  @override
  State<ShareOptionsDialog> createState() => _ShareOptionsDialogState();
}

class _ShareOptionsDialogState extends State<ShareOptionsDialog> {
  bool _useAsDefault = false;

  @override
  Widget build(BuildContext context) {
    final locales = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(locales.shareDownloadLink),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShareOptionsFields(options: widget.options),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(locales.shareUseAsDefault),
              value: _useAsDefault,
              onChanged: (value) => setState(() => _useAsDefault = value!),
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
          onPressed: () =>
              Navigator.pop(context, (widget.options, _useAsDefault)),
          child: Text(locales.share),
        ),
      ],
    );
  }
}
