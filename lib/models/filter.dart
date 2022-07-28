import 'package:mml_app/models/subfilter.dart';

/// Filter class including one text filter.
class Filter extends Subfilter {
  /// The actual entered text of this filter.
  String? _textFilter;

  /// Returns the actual saved filter text.
  String? get textFilter => _textFilter;

  /// Updates the [textFilter].
  set textFilter(String? textFilter) {
    _textFilter = textFilter;
    notifyListeners();
  }
}
