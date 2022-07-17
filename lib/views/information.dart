import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Shows informations from the passed url in a webview.
class InformationScreen extends StatelessWidget {
  /// Url that should be opened in the webview.
  final String url;

  /// Initializes the instance.
  InformationScreen({Key? key, required this.url}) : super(key: key) {
    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
  }

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: url,
    );
  }
}
