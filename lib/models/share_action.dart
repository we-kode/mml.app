import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Action of the app bar that shares a download link of the selected records.
class ShareAction extends ChangeNotifier {
  /// Identifier of the action.
  static const String actionId = 'AppBarAction_Share';

  bool _visible = false;

  bool _actionPerformed = false;

  /// The share icon of the platform.
  static IconData get iconData => defaultTargetPlatform == TargetPlatform.iOS
      ? Symbols.ios_share
      : Symbols.share;

  /// Icon of the action.
  final Icon icon = Icon(iconData);

  /// Whether the selected records can be shared and the action is shown.
  bool get visible => _visible;

  set visible(bool visible) {
    if (_visible == visible) {
      return;
    }

    _visible = visible;
    notifyListeners();
  }

  /// Whether the user pressed the action.
  bool get actionPerformed => _actionPerformed;

  set actionPerformed(bool actionPerformed) {
    _actionPerformed = actionPerformed;
    notifyListeners();
  }

  /// Hides the action and resets its state.
  void clear() {
    _visible = false;
    _actionPerformed = false;
    notifyListeners();
  }

  /// Marks the performed action as finished.
  void actionPerformedFinished() {
    _actionPerformed = false;
  }
}
