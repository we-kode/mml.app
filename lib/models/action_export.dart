import 'package:flutter/material.dart';

/// Action which is whoen in the app bar when items are selected in a selection list.
class ExportAction extends ChangeNotifier {
  /// Id of the action.
  static const String actionId = "AppBarAction_Export";

  /// True, if action was called.
  bool _actionPerformed = false;

  /// Icon of the action, shown in the action bar.
  final Icon icon = const Icon(Icons.download);

  /// Creates instants of the action.
  ExportAction();

  /// Returns, if the action was called.
  bool get actionPerformed => _actionPerformed;

  /// Updates [actionPerformed].
  set actionPerformed(bool actionPerformed) {
    _actionPerformed = actionPerformed;
    notifyListeners();
  }

  /// Resets the action to initial state.
  void clear() {
    _actionPerformed = false;
    notifyListeners();
  }

  /// Called,when action call finished.
  void actionPerformedFinished() {
    _actionPerformed = false;
  }
}
