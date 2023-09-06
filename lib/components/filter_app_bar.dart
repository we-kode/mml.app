import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/models/filter.dart';
import 'package:mml_app/models/navigation_state.dart';
import 'package:mml_app/models/selected_items_action.dart';
import 'package:mml_app/services/router.dart';

/// An appbar containing one expandable filter input.
class FilterAppBar extends StatefulWidget {
  /// Title shown in the app bar.
  final String title;

  /// Flag, thats enables the filter button of this app bar.
  ///
  /// If false or not provided the filter button will not be shown.
  final bool? enableFilter;

  /// Flag, that enables the back button on the app bar.
  final bool enableBack;

  /// [Filter], which holds the entered text in the app bar.
  final Filter filter = Filter();

  /// [SelectedItemsAction] which controls the app bar if a list with muiltselection
  /// is available in the widget, the app bar belongs to.
  final SelectedItemsAction? listAction;

  /// [NavigationState] to show the path of navigation in the appbar.
  final NavigationState navigationState = NavigationState();

  /// Initiales the app bar.
  FilterAppBar({
    Key? key,
    required this.title,
    this.listAction,
    this.enableFilter,
    this.enableBack = false,
  }) : super(key: key);

  @override
  FilterAppBarState createState() => FilterAppBarState();
}

///  State of the [FilterAppBar].
class FilterAppBarState extends State<FilterAppBar> {
  /// Shows whether the filter input is expanded.
  ///
  /// Default the input text field is collapsed.
  bool _filterOpened = false;

  /// The actual entered filter text.
  String? _filter;

  @override
  void initState() {
    widget.listAction?.addListener(_updateState);
    widget.navigationState.addListener(_updateState);
    super.initState();
  }

  @override
  void didUpdateWidget(FilterAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.listAction != widget.listAction) {
      widget.listAction?.removeListener(_updateState);
      widget.listAction?.addListener(_updateState);
    }

    if (oldWidget.navigationState != widget.navigationState) {
      widget.navigationState.removeListener(_updateState);
      widget.navigationState.addListener(_updateState);
    }
  }

  @override
  void dispose() async {
    super.dispose();
    widget.listAction?.removeListener(_updateState);
    widget.navigationState.removeListener(_updateState);
  }

  /// Updates the state if the [SelectedItemsAction] state changed.
  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: widget.listAction != null && widget.listAction!.enabled
          ? Row(
              children: [
                IconButton(
                  onPressed: () {
                    widget.listAction?.clear();
                  },
                  icon: const Icon(Icons.close),
                  tooltip: AppLocalizations.of(context)!.cancel,
                ),
                Text("${widget.listAction!.count}")
              ],
            )
          : widget.enableBack || widget.navigationState.path != null
              ? IconButton(
                  onPressed: () async {
                    if (widget.navigationState.path != null) {
                      widget.navigationState.returnPressed();
                    } else {
                      await RouterService.getInstance().popNestedRoute();
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  tooltip: AppLocalizations.of(context)!.back,
                )
              : null,
      title: Visibility(
        visible: widget.listAction == null || !widget.listAction!.enabled,
        child: !_filterOpened || !(widget.enableFilter ?? false)
            ? Text(
                widget.navigationState.path ?? _getLocalizedString(context),
              )
            : Container(
                margin: const EdgeInsets.only(bottom: 4.0),
                child: _createInput(),
              ),
      ),
      actions: _createActions(),
    );
  }

  /// Returns the translated title of the entered [widget.title].
  String _getLocalizedString(BuildContext context) {
    final locales = AppLocalizations.of(context)!;
    switch (widget.title) {
      case "records":
        return locales.records;
      case "playlist":
        return locales.playlist;
      case "settings":
        return locales.settings;
      case "livestreams":
        return locales.livestreams;
      default:
        return widget.title;
    }
  }

  /// Creates the input filter field.
  Widget _createInput() {
    return TextFormField(
      initialValue: _filter,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        labelStyle: const TextStyle(color: Colors.white),
        labelText: AppLocalizations.of(context)!.filter,
        icon: const Icon(
          Icons.filter_list_alt,
          color: Colors.white,
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.clear,
            color: Colors.white,
          ),
          onPressed: () {
            setState(
              () {
                _filter = '';
                _filterOpened = false;
              },
            );

            widget.filter.textFilter = '';
          },
        ),
      ),
      onChanged: (String filterText) {
        setState(
          () {
            _filter = filterText;
          },
        );

        widget.filter.textFilter = filterText;
      },
    );
  }

  /// Creates the actions of the app bar.
  List<Widget> _createActions() {
    var enableFilter = widget.enableFilter ?? false;
    return !enableFilter && widget.listAction == null
        ? []
        : [
            if (enableFilter &&
                !_filterOpened &&
                (widget.listAction != null && !widget.listAction!.enabled))
              IconButton(
                onPressed: () => setState(
                  () {
                    _filterOpened = !_filterOpened;
                  },
                ),
                icon: const Icon(Icons.search),
              ),
            if (widget.listAction != null && widget.listAction!.enabled)
              IconButton(
                onPressed: () => setState(
                  () {
                    widget.listAction!.actionPerformed = true;
                  },
                ),
                icon: widget.listAction!.icon,
              ),
          ];
  }
}
