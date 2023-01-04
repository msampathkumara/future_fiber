import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LinkViewer extends StatefulWidget {
  final String url;
  final String title;

  const LinkViewer(this.url, this.title, {Key? key}) : super(key: key);

  @override
  State<LinkViewer> createState() => _State();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _State extends State<LinkViewer> {
  late WebViewController webViewWidgetController;

  @override
  void initState() {
    // TODO: implement initState
    // if (Platform.isAndroid) webViewController.platform = AndroidWebView();
    webViewWidgetController = WebViewController()
      ..enableZoom(true)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getWebUi();
  }

  late WebViewController webViewController;

  getWebUi() {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: WebViewWidget(
          // gestureNavigationEnabled: true,
          // initialUrl: widget.url,
          // javascriptMode: JavascriptMode.unrestricted,
          // onWebViewCreated: (WebViewController webViewController) {
          //   this.webViewController = webViewController;
          // },

          gestureRecognizers: {}..add(
              Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()
                ..onDown = (DragDownDetails dragDownDetails) {
                  webViewController.getScrollPosition().then((value) {
                    if (value.dx == 0 && dragDownDetails.globalPosition.direction < 1) {
                      webViewController.reload();
                    }
                  });
                }),
            ),
          controller: webViewWidgetController,
        ));
  }
}
