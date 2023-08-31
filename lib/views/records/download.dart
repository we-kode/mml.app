import 'package:flutter/material.dart';
import 'package:mml_app/components/vertical_spacer.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/view_models/records/download.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';

/// View of the download dialog for records.
class RecordDownloadDialog extends StatelessWidget {
  /// Records to be downloaded.
  final List<ModelBase?> records;

  /// Playlists where the records should be added into.
  final List<dynamic> playlists;

  /// Initializes the view for the records download dialog.
  const RecordDownloadDialog({
    Key? key,
    required this.records,
    required this.playlists,
  }) : super(key: key);

  /// Builds the records download dialog.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecordsDownloadDialogViewModel>(
      create: (context) => RecordsDownloadDialogViewModel(),
      builder: (context, _) {
        var vm = Provider.of<RecordsDownloadDialogViewModel>(
          context,
          listen: false,
        );
        var locales = AppLocalizations.of(context)!;

        return AlertDialog(
          title: Text(
            locales.download,
          ),
          content: FutureBuilder(
            future: vm.init(context, records, playlists),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children:  [
                    CircularProgressIndicator(),
                  ],
                );
              }

              return snapshot.data!
                  ? _createDownloadContent(context, vm)
                  : Container();
            },
          ),
          actions: _createActions(context),
        );
      },
    );
  }

  /// Creates the download content that should be shown in the dialog.
  Widget _createDownloadContent(
    BuildContext context,
    RecordsDownloadDialogViewModel vm,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer<RecordsDownloadDialogViewModel>(
          builder: (context, value, child) {
            return Column(
              children: [
                CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 5.0,
                  percent: value.downloadProgress / 100,
                  center: Text('${value.downloadProgress} %'),
                  progressColor: Theme.of(context).colorScheme.primary,
                ),
                verticalSpacer,
                verticalSpacer,
                Text(
                  value.downloadFileName,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Creates a list of action widgets that should be shown at the bottom of the dialog.
  List<Widget> _createActions(
    BuildContext context,
  ) {
    var locales = AppLocalizations.of(context)!;

    return [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(locales.cancel),
      ),
    ];
  }
}
