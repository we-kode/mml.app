import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';

/// View of  dialog of not downloaded records.
class NotDownloadedDialog extends StatelessWidget {
  /// List of not downloaed records
  final List<String> records;

  /// Initializes the view.
  const NotDownloadedDialog({
    super.key,
    required this.records,
  });

  /// Builds the dialog.
  @override
  Widget build(BuildContext context) {
    var locales = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        locales.notDownloaded,
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Text(locales.notDownloadedRecords),
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        records[index],
                        softWrap: false,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(locales.cancel),
        ),
      ],
    );
  }
}
