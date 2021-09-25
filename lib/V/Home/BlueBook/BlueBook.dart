import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:smartwind/C/ServerResponce/OperationMinMax.dart';
import 'package:smartwind/C/ServerResponce/UserRFCredentials.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BlueBook extends StatefulWidget {
  Ticket? ticket;

  BlueBook({this.ticket});

  @override
  _BlueBookState createState() => _BlueBookState();
}

class _BlueBookState extends State<BlueBook> {
  Ticket? ticket;
  late UserRFCredentials userRFCredentials;
  late OperationMinMax operationMinMax;
  var showFinishButton = true;

  WebView? _webView;

  late WebViewController _webViewController;


  @override
  initState() {
    super.initState();
    ticket = widget.ticket;

    _webView = WebView(
      // initialUrl: "http://bluebook.northsails.com:8088/nsbb/app/blueBook.html",
      // initialUrl: "http://10.200.4.31/webclient/",
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _webViewController = webViewController;
        webViewController.loadUrl("http://bluebook.northsails.com:8088/nsbb/app/blueBook.html", headers: {"Authorization": "Basic c3VtaXRyYUBsazpZeFpGZThIeA=="});
        // _controller.complete(webViewController);
      },
      onProgress: (int progress) {
        print("WebView is loading (progress : $progress%)");
      },
      javascriptChannels: <JavascriptChannel>{},
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
    );
  }

  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          if (widget.ticket != null && (isPortrait))
            Expanded(
              child: PDFView(
                filePath: widget.ticket!.ticketFile!.path,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: false,
                pageFling: true,
                pageSnap: true,
                defaultPage: 0,
                fitPolicy: FitPolicy.BOTH,
                preventLinkNavigation: false,
                onRender: (_pages) {
                  setState(() {
                    pages = _pages!;
                    isReady = true;
                    print('READYYYY');
                  });
                },
                onError: (error) {
                  setState(() {
                    errorMessage = error.toString();
                  });
                  print(error.toString());
                },
                onPageError: (page, error) {
                  setState(() {
                    errorMessage = '$page: ${error.toString()}';
                  });
                  print('$page: ${error.toString()}');
                },
                onViewCreated: (PDFViewController pdfViewController) {
                  _controller.complete(pdfViewController);
                },
                onLinkHandler: (String? uri) {
                  print('goto uri: $uri');
                },
                onPageChanged: (int? page, int? total) {
                  print('page change: $page/$total');
                  setState(() {
                    currentPage = page!;
                  });
                },
              ),
            ),
          if (widget.ticket != null && (isPortrait)) Container(height: 20, color: Colors.blue),
          Expanded(child: Container(child: _webView))
        ],
      )),
    );
  }
}
