import 'package:flutter/material.dart';
import 'package:mml_app/services/router.dart';

/// Shows a progress indicator overlay.
///
/// This method can be used to show an overlay for asynchronous actions and
/// prevent user interaction during requests.
showProgressIndicator() {
  showDialog(
    barrierDismissible: false,
    context: RouterService.getInstance().navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}
