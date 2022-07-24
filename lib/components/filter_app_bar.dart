import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/views/records/records.dart';

class FilterAppBar extends StatefulWidget {
  final String title;
  final bool? enableFilter;
  final FilterChangedListener? filterChangedListener;

  const FilterAppBar({
    Key? key,
    required this.title,
    this.enableFilter,
    this.filterChangedListener,
  }) : super(key: key);

  @override
  FilterAppBarState createState() => FilterAppBarState();
}

class FilterAppBarState extends State<FilterAppBar> {
  bool _filterOpened = false;
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

                  if (widget.filterChangedListener != null) {
                    widget.filterChangedListener!.onChanged(_filter);
                  }
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

abstract class FilterChangedListener {
  Future onChanged(String? filter);
}
