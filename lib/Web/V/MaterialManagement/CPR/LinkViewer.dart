import 'dart:io';

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
  @override
  void initState() {
    // TODO: implement initState
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
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
        body: WebView(
          gestureNavigationEnabled: true,
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            this.webViewController = webViewController;
          },
          zoomEnabled: false,
          gestureRecognizers: Set()
            ..add(
              Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()
                ..onDown = (DragDownDetails dragDownDetails) {
                  webViewController.getScrollY().then((value) {
                    if (value == 0 && dragDownDetails.globalPosition.direction < 1) {
                      webViewController.reload();
                    }
                  });
                }),
            ),
        ));
  }
}
