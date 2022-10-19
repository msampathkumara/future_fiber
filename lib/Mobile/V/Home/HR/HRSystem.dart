import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HRSystem extends StatelessWidget {
  WebViewController? _webViewController;

  HRSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("HR System"),
          actions: [
            if (_webViewController != null)
              IconButton(
                  icon: const Icon(Icons.autorenew_outlined),
                  onPressed: () {
                    _webViewController!.reload();
                  })
          ],
        ),
        body: WebView(
          initialUrl: 'https://northsails.cemex.cloud/Security/Login',
          // initialUrl: "http://10.200.4.31/webclient/",
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
            // _controller.complete(webViewController);
          },
          onProgress: (int progress) {
            print("WebView is loading (progress : $progress%)");
          },
          javascriptChannels: const <JavascriptChannel>{},
          navigationDelegate: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            // _controller!.evaluateJavascript(jsString);
          },
          gestureNavigationEnabled: true,
        ));
  }
}
