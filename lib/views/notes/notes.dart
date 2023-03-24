import 'package:flutter/material.dart';
import 'package:mml_app/components/async_list_view.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/models/info.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/subfilter.dart';
import 'package:mml_app/view_models/notes/notes.dart';
import 'package:provider/provider.dart';

/// Shows the notes of one directory.
class NotesScreen extends StatelessWidget {
  /// App bar of the notes overview screen.
  final FilterAppBar? appBar;

  /// Actual directory.
  final String? path;

  /// Initializes the instance.
  const NotesScreen({
    Key? key,
    this.appBar,
    this.path,
  }) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotesViewModel>(
      create: (context) => NotesViewModel(),
      builder: (context, _) {
        var vm = Provider.of<NotesViewModel>(context, listen: false);

        return FutureBuilder(
          future: vm.init(context, path),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return const Center(child: CircularProgressIndicator());
            }

            return AsyncListView(
              title: vm.locales.information,
              loadData: vm.load,
              openItemFunction: (
                ModelBase item,
                String? filter,
                Subfilter? subfilter,
              ) {
                vm.navigate(item as Info);
              },
            );
          },
        );
      },
    );
  }
}
