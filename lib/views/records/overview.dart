import 'package:flutter/material.dart';
import 'package:mml_app/components/async_list_view.dart';
import 'package:mml_app/components/async_select_list_dialog.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/models/record_folder.dart';
import 'package:mml_app/models/subfilter.dart';
import 'package:mml_app/view_models/records/overview.dart';
import 'package:mml_app/views/records/download.dart';
import 'package:mml_app/views/records/record_tag_filter.dart';
import 'package:provider/provider.dart';

/// Overview screen of the uploaded records to the music lib.
class RecordsScreen extends StatelessWidget {
  /// The app bar of the records view.
  final FilterAppBar? appBar;

  /// Initializes the instance.
  const RecordsScreen({Key? key, required this.appBar}) : super(key: key);

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
                isFolderView: vm.isFolderView,
              ),
              navState: appBar?.navigationState,
              moveUp: (subFilter) {
                vm.moveFolderUp(subFilter as ID3TagFilter);
                appBar?.navigationState.path = RecordFolder.fromDate(
                  subFilter.startDate,
                  subFilter.endDate,
                )?.getIdentifier();
              },
              loadData: ({
                String? filter,
                int? offset,
                int? take,
                dynamic subfilter,
              }) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) {
                    if (!(subfilter as ID3TagFilter).isGrouped) {
                      appBar?.navigationState.path = null;
                    }
                  },
                );

                return vm.load(
                  filter: filter,
                  offset: offset,
                  take: take,
                  subfilter: subfilter,
                );
              },
              filter: appBar?.filter,
              selectedItemsAction: appBar?.listAction,
              onMultiSelect: (selectedItems) async {
                List<dynamic>? selectedPlaylists = await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AsyncSelectListDialog(
                      loadData: ({filter, offset, take}) => vm.loadPlaylists(
                        filter: filter,
                        offset: offset,
                        take: take,
                      ),
                      initialSelected: const [],
                    );
                  },
                );

                if (selectedPlaylists == null || selectedPlaylists.isEmpty) {
                  return false;
                }

                return await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return RecordDownloadDialog(
                      records: selectedItems as List<ModelBase?>,
                      playlists: selectedPlaylists,
                    );
                  },
                );
              },
              openItemFunction: (
                ModelBase item,
                String? filter,
                Subfilter? subfilter,
              ) {
                if (item is Record) {
                  vm.playRecord(
                    context,
                    item,
                    filter,
                    subfilter as ID3TagFilter,
                  );
                } else if (item is RecordFolder) {
                  appBar?.navigationState.path = item.getIdentifier();
                  (subfilter as ID3TagFilter)[ID3TagFilters.date] =
                      DateTimeRange(
                    start: DateTime(
                      item.year,
                      item.month ?? 1,
                      item.day ?? 1,
                    ),
                    end: DateTime(
                      item.year,
                      item.month ?? 12,
                      item.day ??
                          DateUtils.getDaysInMonth(
                            item.year,
                            item.month ?? 12,
                          ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
