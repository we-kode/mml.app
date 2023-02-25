import 'package:flutter/material.dart';
import 'package:mml_app/view_models/logs_overview.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

/// Overview screen of logs.
class LogsOverviewScreen extends StatelessWidget {
  /// Initializes the instance.
  const LogsOverviewScreen({Key? key}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LogsOverviewViewModel>(
      create: (context) => LogsOverviewViewModel(),
      builder: (context, _) {
        var vm = Provider.of<LogsOverviewViewModel>(context, listen: false);

        return FutureBuilder(
          future: vm.init(context),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: vm.logFiles.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(basename(vm.logFiles[index].path)),
                  onTap: () {
                    vm.showLog(vm.logFiles[index].path);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
