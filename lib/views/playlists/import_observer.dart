import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mml_app/services/import.dart';
import 'package:mml_app/views/playlists/not_downloaded.dart';

/// Observer to handle imports from mml files when clicked extern.
class ImportObserver extends StatefulWidget {
  const ImportObserver({
    super.key,
  });

  @override
  ImportObserverState createState() => ImportObserverState();
}

/// State of the [ImportObserver].
class ImportObserverState extends State<ImportObserver>
    with WidgetsBindingObserver {
  static const platform = MethodChannel("de.wekode.mml/import_favs");

  @override
  void initState() {
    super.initState();
    getOpenFileUrl();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getOpenFileUrl();
    }
  }

  /// reads the file content.
  void getOpenFileUrl() async {
    dynamic content = await platform.invokeMethod("getOpenFileUrl");

    if (content != null) {
      if (!context.mounted) {
        return;
      }
      var notDownloaded =
          await ImportService.getInstance().import(null, context, cnt: content);

      if (notDownloaded.isEmpty) {
        return;
      }

      if (!context.mounted) {
        return;
      }
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return NotDownloadedDialog(
            records: notDownloaded,
          );
        },
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
