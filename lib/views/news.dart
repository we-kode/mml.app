import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mml_app/view_models/news.dart';
import 'package:provider/provider.dart';

/// Shows informations from the passed url in a webview.
class NewsScreen extends StatelessWidget {
  /// Initializes the instance.
  const NewsScreen({Key? key}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NewsViewModel>(
      create: (context) => NewsViewModel(),
      builder: (context, _) {
        var vm = Provider.of<NewsViewModel>(context, listen: false);

        return FutureBuilder(
          future: vm.init(context),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return const Center(child: CircularProgressIndicator());
            }

            InAppWebViewController? webViewController;
            final pullToRefreshController = PullToRefreshController(
              settings: PullToRefreshSettings(
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.background,
              ),
              onRefresh: () async {
                if (defaultTargetPlatform == TargetPlatform.android) {
                  webViewController?.reload();
                } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                  webViewController?.loadUrl(
                    urlRequest: URLRequest(
                      url: await webViewController?.getUrl(),
                    ),
                  );
                }
              },
            );

            return InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(vm.url!),
              ),
              initialSettings: vm.settings,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              // initialSettings: vm.settings,
              pullToRefreshController: pullToRefreshController,
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController.endRefreshing();
                }
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                  action: kDebugMode
                      ? ServerTrustAuthResponseAction.PROCEED
                      : ServerTrustAuthResponseAction.CANCEL,
                );
              },
            );
          },
        );
      },
    );
  }
}
