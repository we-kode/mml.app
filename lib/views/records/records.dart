import 'package:flutter/material.dart';
import 'package:mml_app/components/async_list_view.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/view_models/records/records.dart';
import 'package:mml_app/views/records/record_tag_filter.dart';
import 'package:provider/provider.dart';

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
              subfilter: RecordTagFilter(
                onFilterChanged: (ID3TagFilter filter) async {
                  vm.filterChanged(filter);
                  return true;
                },
              ),
              loadData: vm.load,
              onDataChanged: vm.filterChangedStreamController,
            );
          },
        );
      },
    );
  }
}
