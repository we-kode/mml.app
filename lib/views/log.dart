import 'package:flutter/material.dart';
import 'package:mml_app/view_models/log.dart';
import 'package:provider/provider.dart';

/// License detail screen.
class LogScreen extends StatelessWidget {
  /// The flename to show the content.
  final String filename;

  /// Initializes the instance.
  const LogScreen({Key? key, required this.filename}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LogViewModel>(
      create: (context) => LogViewModel(),
      builder: (context, _) {
        var vm = Provider.of<LogViewModel>(context, listen: false);

        return FutureBuilder(
          future: vm.init(context, filename),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: SelectableText(vm.content ?? ''),
              ),
            );
          },
        );
      },
    );
  }
}
