import 'package:mml_app/models/subfilter.dart';

class Filter extends Subfilter {
  String? _textFilter;

  String? get textFilter => _textFilter;

  set textFilter(String? textFilter) {
    _textFilter = textFilter;
    notifyListeners();
  }
}
