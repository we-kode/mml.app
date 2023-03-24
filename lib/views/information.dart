import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Shows informations from the passed url in a webview.
class InformationScreen extends StatelessWidget {
  /// Url that should be opened in the webview.
  final String url;

  /// Initializes the instance.
  const InformationScreen({Key? key, required this.url}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(url),
      ),
    );
  }
}
