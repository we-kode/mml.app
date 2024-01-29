import 'package:flutter/material.dart';
import 'package:mml_app/components/horizontal_spacer.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:shimmer/shimmer.dart';

/// Function to load data with the passed [filter], starting from [offset] and
/// loading an amount of [take] data.
typedef LoadDataFunction = Future<ModelList> Function({
  String? filter,
  int? offset,
  int? take,
});

/// A dialog inlcuding a selection list.
///
/// The list supports async loading of data, when necessary in chunks.
class AsyncSelectListDialog extends StatefulWidget {
  /// Function to load data starting from [offset] and
  /// loading an amount of [take] data.
  final LoadDataFunction loadData;

  /// List of inital selected values.
  final List<dynamic> initialSelected;

  /// Initializes the list view.
  const AsyncSelectListDialog({
    super.key,
    required this.loadData,
    required this.initialSelected,
  });

  @override
  State<AsyncSelectListDialog> createState() => _AsyncSelectListDialogState();
}

class _AsyncSelectListDialogState extends State<AsyncSelectListDialog> {
  /// Initial offset to start loading data from.
  final int _initialOffset = 0;

  /// Intial amount of data that should be loaded.
  final int _initialTake = 100;

  /// Delta the [_offset] should be increased or decreased while scrolling and
  /// lazy loading next/previuous data.
  final int _offsetDelta = 50;

  /// List of lazy loaded items.
  ModelList? _items;

  /// Filter to send to the sever.
  String? _filter;

  /// Offset to start loading data from.
  int _offset = 0;

  /// Amount of data that should be loaded starting from [_offset].
  int _take = 100;

  /// Indicates, whether data is loading and an loading indicator should be
  /// shown.
  bool _isLoadingData = true;

  /// Identifiers of the selected items in the list.
  List<dynamic> _selectedValues = [];

  @override
  void initState() {
    _selectedValues = widget.initialSelected.toList();
    _reloadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            // List header with filter and action buttons.
            _createListHeaderWidget(),

            // List, loading indicator or no data widget.
            Expanded(
              child: _isLoadingData
                  ? _createLoadingWidget()
                  : (_items!.totalCount > 0
                      ? _createListViewWidget()
                      : _createNoDataWidget()),
            ),
          ],
        ),
      ),
      actions: _createActions(context),
    );
  }

  /// Stores the identifer of the item at the [index] or removes it, when
  /// the identifier was in the list of selected items.
  void _onItemChecked(int index) {
    if (_selectedValues.contains(_items![index]?.getIdentifier())) {
      _selectedValues.remove(_items![index]?.getIdentifier());
    } else if (_items![index] != null) {
      _selectedValues.add(_items![index]!.getIdentifier());
    }

    setState(() {
      _selectedValues = _selectedValues;
    });
  }

  /// Reloads the data starting from inital offset with inital count.
  void _reloadData() {
    if (!mounted) {
      return;
    }

    _offset = _initialOffset;
    _take = _initialTake;

    _loadData();
  }

  /// Loads the data for the [_offset] and [_take].
  ///
  /// Shows a loading indicator instead of the list during load, if
  /// [showLoadingOverlay] is true.
  /// Otherwhise the data will be loaded lazy in the background.
  void _loadData({bool showLoadingOverlay = true}) {
    if (showLoadingOverlay) {
      setState(() {
        _isLoadingData = true;
      });
    }

    var dataFuture = widget.loadData(
      filter: _filter,
      offset: _offset,
      take: _take,
    );

    dataFuture.then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingData = false;
        _items = value;
      });
    }).onError((e, _) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingData = false;
        _items = ModelList([], _initialOffset, 0);
      });
    });
  }

  /// Creates a loading indicator widget.
  Widget _createLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Creates a widget that will be shown, if no data were loaded or an error
  /// occured during loading of data.
  Widget _createNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.noData,
            softWrap: true,
          ),
          horizontalSpacer,
          TextButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.reload),
          ),
        ],
      ),
    );
  }

  /// Creates the list header widget with filter and remove action buttons.
  Widget _createListHeaderWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Filter input.
        Expanded(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.filter,
                  icon: const Icon(Icons.filter_list_alt),
                ),
                onChanged: (String filterText) {
                  setState(() {
                    _filter = filterText;
                  });

                  _reloadData();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Creates the list view widget.
  Widget _createListViewWidget() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return const Divider(
            height: 1,
          );
        },
        itemBuilder: (context, index) {
          var endNotReached = (_offset + _take) <= _items!.totalCount;
          var loadNextIndexReached =
              index == (_offset + _take - (_offsetDelta / 2).ceil());
          var loadPreviuousIndexReached = index == _offset;
          var beginNotReached = index > 0;

          if (endNotReached && loadNextIndexReached) {
            _offset = _offset + _offsetDelta;
            _take = _initialTake + _offsetDelta;

            Future.microtask(() {
              _loadData(showLoadingOverlay: false);
            });
          } else if (beginNotReached && loadPreviuousIndexReached) {
            _offset = _offset - _offsetDelta;
            _take = _initialTake + _offsetDelta;

            Future.microtask(() {
              _loadData(showLoadingOverlay: false);
            });
          }

          var itemLoaded = index < (_offset + _take) && (index - _offset) >= 0;

          return itemLoaded ? _createListTile(index) : _createLoadingTile();
        },
        itemCount: _items?.totalCount ?? 0,
      ),
    );
  }

  /// Creates a tile widget for one list item at the given [index].
  Widget _createListTile(int index) {
    var item = _items![index];

    if (item == null) {
      return _createLoadingTile();
    }

    var leadingTile = Checkbox(
      onChanged: (_) {
        _onItemChecked(index);
      },
      value: _selectedValues.contains(
        item.getIdentifier(),
      ),
    );

    return ListTile(
      leading: leadingTile,
      minVerticalPadding: 0,
      visualDensity: const VisualDensity(vertical: 0),
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(item.getDisplayDescription()),
          ],
        ),
      ),
      onTap: () {
        _onItemChecked(index);
      },
    );
  }

  /// Creates a list tile widget for a not loded list item.
  Widget _createLoadingTile() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: ListTile(
        title: Stack(
          children: [
            Container(
              width: 200,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a list of action widgets that should be shown at the bottom of the dialog.
  List<Widget> _createActions(
    BuildContext context,
  ) {
    var locales = AppLocalizations.of(context)!;

    return [
      TextButton(
        onPressed: () => Navigator.pop(context, null),
        child: Text(locales.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, _selectedValues),
        child: Text(locales.save),
      )
    ];
  }
}
