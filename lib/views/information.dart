import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Shows informations from the passed url in a webview.
class InformationScreen extends StatelessWidget {
  /// Url that should be opened in the webview.
  final String url;

  /// Initializes the instance.
  const InformationScreen({Key? key, required this.url}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    final controller = WebViewController();
    controller.loadRequest(Uri.parse(url));

    return WebViewWidget(
      controller: controller,
    );
  }
}
