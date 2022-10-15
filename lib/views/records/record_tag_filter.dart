import 'package:flutter/material.dart';
import 'package:mml_app/components/async_select_list_dialog.dart';
import 'package:mml_app/components/horizontal_spacer.dart';
import 'package:mml_app/components/list_subfilter_view.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/view_models/records/record_tag_filter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';

typedef FilterChangedFunction = Future<bool> Function(ID3TagFilter filter);

// Tag filters for the records view.
class RecordTagFilter extends ListSubfilterView {
  /// Initializes the [RecordTagFilter].
  RecordTagFilter({
    Key? key,
    DateTime? startDate,
    DateTime? endDate,
    bool isFolderView = false,
  }) : super(
          key: key,
          filter: ID3TagFilter(
            startDate: startDate,
            endDate: endDate,
            isFolderView: isFolderView,
          ),
        );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecordTagFilterViewModel>(
      create: (context) => RecordTagFilterViewModel(filter as ID3TagFilter),
      builder: (context, _) {
        var locales = AppLocalizations.of(context)!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _createTagFilter(
                ID3TagFilters.folderView,
                locales.folder,
                const Icon(Icons.folder),
                Colors.indigoAccent,
              ),
              Consumer<RecordTagFilterViewModel>(
                builder: (context, vm, child) {
                  var isFolderView = (filter as ID3TagFilter).isGrouped;
                  return !isFolderView ? horizontalSpacer : Container();
                },
              ),
              _createTagFilter(
                ID3TagFilters.date,
                locales.date,
                const Icon(Icons.calendar_month),
                Colors.blueGrey,
              ),
              horizontalSpacer,
              _createTagFilter(
                ID3TagFilters.artists,
                locales.artist,
                const Icon(Icons.person),
                Colors.teal,
              ),
              horizontalSpacer,
              _createTagFilter(
                ID3TagFilters.genres,
                locales.genre,
                const Icon(Icons.discount),
                Colors.red,
              ),
              horizontalSpacer,
              _createTagFilter(
                ID3TagFilters.albums,
                locales.album,
                const Icon(Icons.library_music),
                Colors.amber,
              ),
              horizontalSpacer,
            ],
          ),
        );
      },
    );
  }

  /// Creates a single tag filter for given [identifier].
  ///
  /// [icon] and the [activeBGColor] can be set.
  Widget _createTagFilter(
    String identifier,
    String label,
    Icon icon,
    Color activeBGColor,
  ) {
    return Consumer<RecordTagFilterViewModel>(
      builder: (context, vm, child) {
        var isFolderView = identifier == ID3TagFilters.date &&
            (filter as ID3TagFilter).isGrouped;
        return isFolderView
            ? Container()
            : InputChip(
                label: Text(label),
                avatar: icon,
                backgroundColor:
                    vm.tagFilter.isNotEmpty(identifier) ? activeBGColor : null,
                onPressed: () => identifier == ID3TagFilters.date
                    ? _handleDateFilter(context, vm)
                    : identifier == ID3TagFilters.folderView
                        ? _handleFolderFilter(context, vm)
                        : _handleFilter(identifier, context, vm),
                onDeleted: vm.tagFilter.isNotEmpty(identifier)
                    ? () => {
                          vm.clear(identifier),
                        }
                    : null,
              );
      },
    );
  }

  /// Updates the folder view tag.
  Future _handleFolderFilter(
    BuildContext context,
    RecordTagFilterViewModel vm,
  ) async {
    var isFolderView = !(filter as ID3TagFilter).isGrouped;
    await vm.updateFilter(ID3TagFilters.folderView, isFolderView);
  }

  /// Creates a [showDateRangePicker] to handle the date filter.
  Future _handleDateFilter(
    BuildContext context,
    RecordTagFilterViewModel vm,
  ) async {
    var dateUpdated = await showDateRangePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if (dateUpdated == null) {
      return;
    }

    vm.updateFilter(ID3TagFilters.date, dateUpdated);
  }

  /// Creates an [AsyncSelectListDialog] to handle list filters.
  Future _handleFilter(
    String identifier,
    BuildContext context,
    RecordTagFilterViewModel vm,
  ) async {
    var selectedValues = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AsyncSelectListDialog(
          loadData: ({filter, offset, take}) => vm.load(
            identifier,
            filter: filter,
            offset: offset,
            take: take,
          ),
          initialSelected: vm.tagFilter[identifier],
        );
      },
    );
    if (selectedValues == null) {
      return;
    }

    vm.updateFilter(identifier, selectedValues);
  }
}
