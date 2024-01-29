import 'package:flutter/material.dart';

/// Action which is whoen in the app bar when items are selected in a selection list.
class SelectedItemsAction extends ChangeNotifier {
  /// Id of the action.
  static const String actionId = 'AppBarAction_SelectedItems';

  /// The actual count of selected items.
  int _count = 0;

  /// True, if the action is enabled and can be called.
  bool _selectionEnabled = false;

  /// True, if action was called.
  bool _actionPerformed = false;

  /// Returns the actual count of selected items.
  int get count => _count;

  /// Icon of the action, shown in the action bar.
  final Icon icon;

  /// True, if the parent list of this action should be reloaded after action performed.
  final bool reload;

  /// Creates instants of the action.
  SelectedItemsAction(this.icon, {this.reload = false});

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

  /// Called,when action call finished.
  void actionPerformedFinished() {
    _actionPerformed = false;
  }
}
