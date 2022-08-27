import 'package:flutter/cupertino.dart';

class SelectedItemsAction extends ChangeNotifier {
  /// The actual count of selected items.
  int _count = 0;

  /// True, if the action is enabled and can be called.
  bool _selectionEnabled = false;

  /// True, if action was called.
  bool _actionPerformed = false;

  /// Returns the actual count of selected items.
  int get count => _count;

  /// Updates the [count].
  set count(int count) {
    _count = count;
    notifyListeners();
  }

  /// Returns if the action is enabled and can be called or not.
  bool get enabled => _selectionEnabled;

  /// Updates [enabled].
  set enabled(bool enabled) {
    _selectionEnabled = enabled;
    notifyListeners();
  }

  /// Returns, if the action was called.
  bool get actionPerformed => _actionPerformed;

  /// Updates [actionPerformed].
  set actionPerformed(bool actionPerformed) {
    _actionPerformed = actionPerformed;
    notifyListeners();
  }

  /// Resets the action to initial state.
  void clear() {
    _count = 0;
    _selectionEnabled = false;
    _actionPerformed = false;
    notifyListeners();
  }
}
