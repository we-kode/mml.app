import 'dart:math';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mml_app/components/async_select_list_dialog.dart';
import 'package:mml_app/components/horizontal_spacer.dart';
import 'package:mml_app/components/list_subfilter_view.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/view_models/records/record_tag_filter.dart';
import 'package:provider/provider.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

typedef FilterChangedFunction = Future<bool> Function(ID3TagFilter filter);

// Tag filters for the records view.
class RecordTagFilter extends ListSubfilterView {
  /// Initializes the [RecordTagFilter].
  const RecordTagFilter({super.key, required ID3TagFilter tagFilter})
    : super(filter: tagFilter);

  /// Shows the dialog to select the date range of the filter with the
  /// preselected [value] and returns the selected range.
  @visibleForTesting
  static Future<List<DateTime?>?> showDateRangeDialog(
    BuildContext context,
    List<DateTime?> value,
  ) {
    final locales = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme.primary;
    final screen = MediaQuery.sizeOf(context);
    final isLow = screen.height < _dateDialogHeight + 48;
    return showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        lastDate: DateTime.now(),
        useAbbrLabelForMonthModePicker: true,
        dayMaxWidth: isLow ? 30 : null,
        controlsHeight: isLow ? 40 : null,
        cancelButton: Text(locales.cancel, style: TextStyle(color: color)),
        okButton: Text(locales.save, style: TextStyle(color: color)),
      ),
      dialogSize: Size(
        min(screen.width - 32, 360),
        min(_dateDialogHeight, screen.height - 48),
      ),
      borderRadius: BorderRadius.circular(0),
      value: value,
    );
  }

  static const double _dateDialogHeight = 410;

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
              Consumer<RecordTagFilterViewModel>(
                builder: (context, vm, child) {
                  final brightness = Theme.of(context).brightness;
                  final isDarkMode = brightness == Brightness.dark;
                  var activeColor = isDarkMode ? Colors.black54 : Colors.white;
                  return vm.tagFilter.isAny()
                      ? ActionChip(
                          side: BorderSide.none,
                          label: Icon(
                            Symbols.filter_alt_off,
                            color: activeColor,
                          ),
                          padding: const EdgeInsets.only(top: 6, bottom: 6),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondary,
                          onPressed: () => vm.clearAll(),
                        )
                      : const SizedBox.shrink();
                },
              ),
              Consumer<RecordTagFilterViewModel>(
                builder: (context, vm, child) {
                  return vm.tagFilter.isAny()
                      ? const SizedBox(width: 8)
                      : const SizedBox.shrink();
                },
              ),
              _createTagFilter(
                ID3TagFilters.folderView,
                locales.folder,
                Symbols.folder,
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
                Symbols.calendar_month,
              ),
              horizontalSpacer,
              _createTagFilter(
                ID3TagFilters.artists,
                locales.artist,
                Symbols.artist,
              ),
              horizontalSpacer,
              _createTagFilter(
                ID3TagFilters.genres,
                locales.genre,
                Symbols.genres,
              ),
              horizontalSpacer,
              _createTagFilter(
                ID3TagFilters.albums,
                locales.album,
                Symbols.library_music,
              ),
              horizontalSpacer,
              _createTagFilter(
                ID3TagFilters.languages,
                locales.language,
                Symbols.translate,
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
  Widget _createTagFilter(String identifier, String label, IconData icon) {
    return Consumer<RecordTagFilterViewModel>(
      builder: (context, vm, child) {
        var isFolderView =
            identifier == ID3TagFilters.date &&
            (filter as ID3TagFilter).isGrouped;
        final isActive = vm.tagFilter.isNotEmpty(identifier);
        final brightness = Theme.of(context).brightness;
        final isDarkMode = brightness == Brightness.dark;
        var activeColor = isDarkMode ? Colors.black54 : Colors.white;
        return isFolderView
            ? Container()
            : InputChip(
                side: BorderSide.none,
                label: Text(label),
                labelStyle: isActive ? TextStyle(color: activeColor) : null,
                backgroundColor: isActive
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.outlineVariant,
                avatar: Icon(
                  icon,
                  color: isActive
                      ? activeColor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                deleteIconColor: isActive ? activeColor : null,
                onPressed: () => identifier == ID3TagFilters.date
                    ? _handleDateFilter(context, vm)
                    : identifier == ID3TagFilters.folderView
                    ? _handleFolderFilter(context, vm)
                    : _handleFilter(identifier, context, vm),
                onDeleted: vm.tagFilter.isNotEmpty(identifier)
                    ? () => {vm.clear(identifier)}
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
    var dateUpdated = await showDateRangeDialog(context, [
      vm.tagFilter.startDate,
      vm.tagFilter.endDate,
    ]);

    if (dateUpdated == null || dateUpdated.isEmpty) {
      return;
    }

    vm.updateFilter(
      ID3TagFilters.date,
      DateTimeRange(start: dateUpdated.first!, end: dateUpdated.last!),
    );
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
          loadData: ({filter, offset, take}) =>
              vm.load(identifier, filter: filter, offset: offset, take: take),
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
