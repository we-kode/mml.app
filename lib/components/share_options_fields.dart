import 'package:flutter/material.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/share_options.dart';

/// Fields to choose validity and usage of a share link. The fields change the
/// passed [options].
class ShareOptionsFields extends StatefulWidget {
  /// The options changed by the fields.
  final ShareOptions options;

  /// Initializes the fields.
  const ShareOptionsFields({super.key, required this.options});

  @override
  State<ShareOptionsFields> createState() => _ShareOptionsFieldsState();
}

class _ShareOptionsFieldsState extends State<ShareOptionsFields> {
  String _label(AppLocalizations locales, int hours) {
    return switch (hours) {
      1 => locales.shareValid1Hour,
      24 => locales.shareValid1Day,
      168 => locales.shareValid7Days,
      720 => locales.shareValid30Days,
      _ => locales.shareValid90Days,
    };
  }

  @override
  Widget build(BuildContext context) {
    final locales = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<int>(
          initialValue: widget.options.validForHours,
          decoration: InputDecoration(labelText: locales.shareValidFor),
          items: [
            for (final hours in ShareOptions.validForHoursChoices)
              DropdownMenuItem(
                value: hours,
                child: Text(_label(locales, hours)),
              ),
          ],
          onChanged: (hours) => widget.options.validForHours =
              hours ?? widget.options.validForHours,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(locales.shareSingleUse),
          subtitle: Text(locales.shareSingleUseHint),
          value: widget.options.singleUse,
          onChanged: (singleUse) =>
              setState(() => widget.options.singleUse = singleUse),
        ),
      ],
    );
  }
}
