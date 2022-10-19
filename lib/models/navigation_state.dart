import 'package:flutter/cupertino.dart';

/// Holds the navigation path.
class NavigationState extends ChangeNotifier {
  /// The actual path of navigation.
  String? _path;

  /// Returns the actual path.
  String? get path => _path;

  /// True, if action was called.
  bool _returnClicked = false;

  /// Updates the [path]. Null if is on top level.
  set path(String? path) {
    _path = path;
    notifyListeners();
  }

  /// Returns, if the action was called.
  bool get returnClicked => _returnClicked;

  /// Updates [actionPerformed].
  void returnPressed() {
    _returnClicked = true;
    notifyListeners();
  }

  /// Resets action perfomed.
  void returnReleased() {
    _returnClicked = false;
  }
}
