import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mml_app/services/news.dart';

/// View model of the news view
class NewsViewModel extends ChangeNotifier {
  /// Route of the information screen.
  static String route = '/news';

  String? url = 'https://';

  final InAppWebViewSettings settings = InAppWebViewSettings(
    geolocationEnabled: false,
  );

  /// Initialize the view model.
  Future<bool> init(BuildContext context) async {
    return Future<bool>.microtask(() async {
      url = await NewsService.getInstance().getNewsUrl();
      return true;
    });
  }
}
