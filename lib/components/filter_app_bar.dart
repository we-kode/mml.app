import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mml_app/models/action_export.dart';
import 'package:mml_app/models/filter.dart';
import 'package:mml_app/models/navigation_state.dart';
import 'package:mml_app/models/selected_items_action.dart';
import 'package:mml_app/models/share_action.dart';
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

  /// [SelectedItemsAction] which controls the app bar if a list with multi
  /// selection is available in the widget, the app bar belongs to.
  final SelectedItemsAction? listAction;

  final ExportAction? exportAction;

  /// [ShareAction] which shares a download link of the selected records.
  final ShareAction? shareAction;

  /// Function called when the user shares a link to the content of the screen
  /// the app bar belongs to. The share button is hidden, if it is not set.
  final void Function(BuildContext context)? onShareLink;

  /// Whether the share button is shown. It is always shown, if not set.
  final ValueListenable<bool>? shareLinkVisible;

  /// [NavigationState] to show the path of navigation in the appbar.
  final NavigationState navigationState = NavigationState();

  /// Initializes the app bar.
  FilterAppBar({
    super.key,
    required this.title,
    this.listAction,
    this.exportAction,
    this.shareAction,
    this.onShareLink,
    this.shareLinkVisible,
    this.enableFilter,
    this.enableBack = false,
  });

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
    widget.shareAction?.addListener(_updateState);
    widget.navigationState.addListener(_updateState);
    widget.filter.addListener(_filterChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(FilterAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.listAction != widget.listAction) {
      oldWidget.listAction?.removeListener(_updateState);
      widget.listAction?.addListener(_updateState);
    }

    if (oldWidget.filter != widget.filter) {
      oldWidget.filter.removeListener(_filterChanged);
      widget.filter.addListener(_filterChanged);
    }

    if (oldWidget.navigationState != widget.navigationState) {
      oldWidget.navigationState.removeListener(_updateState);
      widget.navigationState.addListener(_updateState);
    }

    if (oldWidget.exportAction != widget.exportAction) {
      oldWidget.exportAction?.removeListener(_updateState);
      widget.exportAction?.addListener(_updateState);
    }

    if (oldWidget.shareAction != widget.shareAction) {
      oldWidget.shareAction?.removeListener(_updateState);
      widget.shareAction?.addListener(_updateState);
    }
  }

  @override
  void dispose() async {
    super.dispose();
    widget.listAction?.removeListener(_updateState);
    widget.shareAction?.removeListener(_updateState);
    widget.exportAction?.removeListener(_updateState);
    widget.navigationState.removeListener(_updateState);
    widget.filter.removeListener(_filterChanged);
  }

  void _filterChanged() {
    final text = widget.filter.textFilter ?? '';
    if (text != (_filter ?? '')) {
      setState(() {
        _filter = text;
        _filterOpened = text.isNotEmpty;
      });
    }
  }

  /// Updates the state if the [SelectedItemsAction] state changed.
  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: widget.listAction != null && widget.listAction!.enabled
          ? 104
          : null,
      leading: widget.listAction != null && widget.listAction!.enabled
          ? Row(
              children: [
                IconButton(
                  onPressed: () {
                    widget.listAction?.clear();
                  },
                  icon: const Icon(Symbols.close),
                  tooltip: AppLocalizations.of(context)!.cancel,
                ),
                Flexible(
                  child: Text(
                    "${widget.listAction!.count}",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
              icon: const Icon(Symbols.arrow_back),
              tooltip: AppLocalizations.of(context)!.back,
            )
          : null,
      title: Visibility(
        visible: widget.listAction == null || !widget.listAction!.enabled,
        child: !_filterOpened || !(widget.enableFilter ?? false)
            ? Text(widget.navigationState.path ?? _getLocalizedString(context))
            : Container(child: _createInput(context)),
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
  Widget _createInput(BuildContext context) {
    return TextFormField(
      initialValue: _filter,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.filter,
        icon: const Icon(Symbols.filter_list_alt),
        suffixIcon: IconButton(
          icon: const Icon(Symbols.clear),
          onPressed: () {
            setState(() {
              _filter = '';
              _filterOpened = false;
            });

            widget.filter.textFilter = '';
          },
        ),
      ),
      onChanged: (String filterText) {
        setState(() {
          _filter = filterText;
        });

        widget.filter.textFilter = filterText;
      },
    );
  }

  /// Creates the actions of the app bar.
  List<Widget> _createActions() {
    var enableFilter = widget.enableFilter ?? false;
    var selecting = widget.listAction?.enabled ?? false;
    return !enableFilter &&
            widget.listAction == null &&
            widget.exportAction == null &&
            widget.onShareLink == null
        ? []
        : [
            if (widget.onShareLink != null && !selecting)
              ValueListenableBuilder<bool>(
                valueListenable: widget.shareLinkVisible ?? ValueNotifier(true),
                builder: (context, visible, _) => visible
                    ? IconButton(
                        onPressed: () => widget.onShareLink!(context),
                        icon: const Icon(Symbols.dataset_linked),
                        tooltip: AppLocalizations.of(context)!.shareSearchLink,
                      )
                    : const SizedBox.shrink(),
              ),
            if (selecting && (widget.shareAction?.visible ?? false))
              IconButton(
                onPressed: () => setState(() {
                  widget.shareAction!.actionPerformed = true;
                }),
                icon: widget.shareAction!.icon,
                tooltip: AppLocalizations.of(context)!.shareDownloadLink,
              ),
            if (enableFilter &&
                !_filterOpened &&
                (widget.listAction != null && !widget.listAction!.enabled))
              IconButton(
                onPressed: () => setState(() {
                  _filterOpened = !_filterOpened;
                }),
                icon: const Icon(Symbols.search),
              ),
            if (widget.exportAction != null && widget.listAction!.enabled)
              IconButton(
                onPressed: () => setState(() {
                  widget.exportAction!.actionPerformed = true;
                }),
                icon: widget.exportAction!.icon,
              ),
            if (widget.listAction != null && widget.listAction!.enabled)
              IconButton(
                onPressed: () => setState(() {
                  widget.listAction!.actionPerformed = true;
                }),
                icon: widget.listAction!.icon,
              ),
          ];
  }
}
