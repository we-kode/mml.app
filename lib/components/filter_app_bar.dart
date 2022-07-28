import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/models/filter.dart';

/// An appbar containing one expandable filter input.
class FilterAppBar extends StatefulWidget {
  /// Title shown in the app bar.
  final String title;

  /// Falg, thats enables the filter button of this app bar.
  ///
  /// If false or not provided the filter button will not be shown.
  final bool? enableFilter;

  /// [Filter], which holds the entered text in the app bar.
  final Filter filter = Filter();

  /// Initiales the app bar.
  FilterAppBar({
    Key? key,
    required this.title,
    this.enableFilter,
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
  Widget build(BuildContext context) {
    return AppBar(
      title: !_filterOpened || !(widget.enableFilter ?? false)
          ? Text(_getLocalizedString(context))
          : Container(
              margin: const EdgeInsets.only(bottom: 4.0),
              child: TextFormField(
                initialValue: _filter,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.filter,
                  icon: const Icon(Icons.filter_list_alt),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(
                        () {
                          _filterOpened = false;
                        },
                      );
                    },
                  ),
                ),
                onChanged: (String filterText) {
                  setState(() {
                    _filter = filterText;
                  });

                  widget.filter.textFilter = filterText;
                },
              ),
            ),
      actions: !(widget.enableFilter ?? false)
          ? []
          : [
              if (!_filterOpened)
                IconButton(
                  onPressed: () => setState(
                    () {
                      _filterOpened = !_filterOpened;
                    },
                  ),
                  icon: const Icon(Icons.search),
                ),
            ],
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
      default:
        return "";
    }
  }
}
