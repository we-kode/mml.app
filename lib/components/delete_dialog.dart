import 'package:flutter/material.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';

/// Shows a confirmation dialog for deletion. A custom [message] replaces the
/// default confirmation text.
Future<bool> showDeleteDialog(BuildContext context, {String? message}) async {
  var localization = AppLocalizations.of(context)!;
  var shouldDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(localization.remove),
      content: Text(message ?? localization.deleteConfirmation),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(localization.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(localization.yes),
        ),
      ],
    ),
  );

  return shouldDelete ?? false;
}
