import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/components/horizontal_spacer.dart';
import 'package:mml_app/components/list_subfilter_view.dart';
import 'package:mml_app/components/vertical_spacer.dart';
import 'package:mml_app/models/filter.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/subfilter.dart';
import 'package:shimmer/shimmer.dart';

/// Function to load data with the passed [filter], starting from [offset] and
/// loading an amount of [take] data. Also a [subfilter] can be added to filter
/// the list more specific.
typedef LoadDataFunction = Future<ModelList> Function({
  String? filter,
  int? offset,
  int? take,
  Subfilter? subfilter,
});

typedef OpenItemFunction = Function(ModelBase item);

/// List that supports async loading of data, when necessary in chunks.
class AsyncListView extends StatefulWidget {
  /// Function to load data with the passed [filter], starting from [offset] and
  /// loading an amount of [take] data.
  final LoadDataFunction loadData;

  /// A subfilter widget which can be used to add subfilters like chips for more
  /// filter posibilities.
  final ListSubfilterView? subfilter;

  /// The title shown above the list.
  final String title;

  /// [Filter] to filter the items by display description.
  final Filter? filter;

  final OpenItemFunction? openItemFunction;

  /// Initializes the list view.
  const AsyncListView({
    Key? key,
    required this.title,
    required this.loadData,
    this.subfilter,
    this.filter,
    this.openItemFunction,
  }) : super(key: key);

  @override
  State<AsyncListView> createState() => _AsyncListViewState();
}

/// State of the list view.
class _AsyncListViewState extends State<AsyncListView> {
  /// Initial offset to start loading data from.
  final int _initialOffset = 0;

  /// Intial amount of data that should be loaded.
  final int _initialTake = 100;

  /// Delta the [_offset] should be increased or decreased while scrolling and
  /// lazy loading next/previuous data.
  final int _offsetDelta = 50;

  /// List of lazy loaded items.
  ModelList? _items;

  /// Offset to start loading data from.
  int _offset = 0;

  /// Amount of data that should be loaded starting from [_offset].
  int _take = 100;

  /// Indicates, whether data is loading and an loading indicator should be
  /// shown.
  bool _isLoadingData = true;

  /// The actual item group if list items should be grouped.
  String? _actualGroup;

  @override
  void initState() {
    _reloadData();

    widget.subfilter?.filter.addListener(_reloadData);
    widget.filter?.addListener(_reloadData);

    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    widget.subfilter?.filter.removeListener(_reloadData);
    widget.filter?.removeListener(_reloadData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }

  /// Reloads the data starting from inital offset with inital count.
  void _reloadData() {
    if (!mounted) {
      return;
    }

    _offset = _initialOffset;
    _take = _initialTake;

    _loadData(subfilter: widget.subfilter?.filter);
  }

  /// Loads the data for the [_offset] and [_take].
  ///
  /// Shows a loading indicator instead of the list during load, if
  /// [showLoadingOverlay] is true.
  /// Otherwhise the data will be loaded lazy in the background.
  void _loadData({
    bool showLoadingOverlay = true,
    Subfilter? subfilter,
  }) {
    if (showLoadingOverlay) {
      setState(() {
        _isLoadingData = true;
      });
    }

    var dataFuture = widget.loadData(
      filter: widget.filter?.textFilter,
      offset: _offset,
      take: _take,
      subfilter: subfilter,
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

  /// Creates the list header widget with filter and remove action buttons.
  Widget _createListHeaderWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              children: [
                // add subfilter if one is provided.
                if (widget.subfilter != null) verticalSpacer,
                if (widget.subfilter != null) widget.subfilter!,
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Creates the list view widget.
  Widget _createListViewWidget() {
    return RefreshIndicator(
      onRefresh: () async {
        _reloadData();
      },
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: ScrollConfiguration(
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

            var itemLoaded =
                index < (_offset + _take) && (index - _offset) >= 0;

            return itemLoaded ? _createListTile(index) : _createLoadingTile();
          },
          itemCount: _items?.totalCount ?? 0,
        ),
      ),
    );
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
            onPressed: () => _loadData(subfilter: widget.subfilter?.filter),
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.reload),
          ),
        ],
      ),
    );
  }

  /// Creates a tile widget for one list item at the given [index] or a group
  /// widget.
  Widget _createListTile(int index) {
    var item = _items![index];

    if (item == null) {
      return _createLoadingTile();
    }

    var itemGroup = item.getGroup(context) ?? '';
    if (itemGroup.isEmpty) {
      return _listTile(item, index);
    }

    // Grouping if first element or
    // group is a new one and the predecessor has another group
    if (index == 0 ||
        (itemGroup != _actualGroup &&
            _items![index - 1]?.getGroup(context) != itemGroup)) {
      _actualGroup = itemGroup;
      return Column(
        children: [
          Chip(
            label: Text(
              item.getGroup(context)!,
            ),
          ),
          _listTile(item, index),
        ],
      );
    }

    return _listTile(item, index);
  }

  /// Creates a tile widget for one list [item] at the given [index].
  ListTile _listTile(ModelBase item, int index) {
    return ListTile(
      minVerticalPadding: 0,
      visualDensity: const VisualDensity(vertical: 0),
      title: Row(
        children: [
          Text(item.getDisplayDescription()),
          _createTitleSuffix(item),
        ],
      ),
      subtitle: item.getSubtitle(context) != null
          ? Text(item.getSubtitle(context)!)
          : null,
      trailing: Column(
        children: [
          verticalSpacer,
          item.getMetadata(context) != null
              ? Text(
                  item.getMetadata(context)!,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : const SizedBox.shrink(),
        ],
      ),
      onTap: widget.openItemFunction != null ? () {
        widget.openItemFunction!(item);
      } : null,
    );
  }

  /// Cretaes a suffix widget of the title if suffix exists.
  Widget _createTitleSuffix(ModelBase? item) {
    if (item!.getDisplayDescriptionSuffix(context) != null) {
      return Text(
        " (${item.getDisplayDescriptionSuffix(context)})",
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return const Text('');
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
}
