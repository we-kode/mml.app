import 'package:flutter/material.dart';
import 'package:mml_app/components/async_list_view.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/subfilter.dart';
import 'package:mml_app/view_models/records/overview.dart';
import 'package:mml_app/views/records/record_tag_filter.dart';
import 'package:provider/provider.dart';

/// Overview screen of the uploaded records to the music lib.
class RecordsScreen extends StatelessWidget {
  /// Initializes the instance.
  const RecordsScreen({Key? key}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecordsViewModel>(
      create: (context) => RecordsViewModel(),
      builder: (context, _) {
        var vm = Provider.of<RecordsViewModel>(context, listen: false);

        return FutureBuilder(
          future: vm.init(context),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return AsyncListView(
              title: vm.locales.records,
              subfilter: RecordTagFilter(),
              loadData: vm.load,
              filter: RecordsViewModel.appBar.filter,
              openItemFunction: (
                ModelBase item,
                String? filter,
                Subfilter? subfilter,
              ) {
                vm.playRecord(
                  context,
                  item,
                  filter,
                  subfilter as ID3TagFilter,
                );
              },
            );
          },
        );
      },
    );
  }
}
