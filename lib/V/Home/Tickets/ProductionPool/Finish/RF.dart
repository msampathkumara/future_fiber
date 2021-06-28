import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui
    show ImageFilter, Gradient, Image, Color, ImageByteFormat;
import 'package:native_screenshot/native_screenshot.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/C/ServerResponce/UserRFCredentials.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RF extends StatefulWidget {
  Ticket ticket;
  UserRFCredentials userRFCredentials;

  RF(this.ticket, this.userRFCredentials);

  @override
  _RFState createState() {
    return _RFState();
  }
}

class _RFState extends State<RF> {
  Map? checkListMap;
  File? ticketFile;

  @override
  void initState() {
    super.initState();

    getExternalStorageDirectory().then((value) {
      ticketFile = new File(value!.path + "/1111.pdf");
      setState(() {
        print(
            "dfddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
        print(ticketFile!.path);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  WebViewController? _controller;
  final Completer<PDFViewController> _pdfcontroller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  static GlobalKey previewContainer = new GlobalKey();


  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: previewContainer,
      child: Scaffold(


          body: Builder(builder: (BuildContext context) {
        return Column(
          children: [
            if (ticketFile != null)
              Expanded(
                child: new PDFView(
                  filePath: ticketFile!.path,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: true,
                  pageSnap: true,
                  defaultPage: 1,
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
                    _pdfcontroller.complete(pdfViewController);
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {takescrshot();},
                  child: Text("scan"),
                )
              ],
            ),
            Expanded(
              child: WebView(
                initialUrl:
                    'https://www.w3schools.com/howto/howto_css_register_form.asp',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  // _controller.complete(webViewController);
                },
                onProgress: (int progress) {
                  print("WebView is loading (progress : $progress%)");
                },
                javascriptChannels: <JavascriptChannel>{
                  _toasterJavascriptChannel(context),
                },
                navigationDelegate: (NavigationRequest request) {
                  if (request.url.startsWith('https://www.youtube.com/')) {
                    print('blocking navigation to $request}');
                    return NavigationDecision.prevent;
                  }
                  print('allowing navigation to $request');
                  return NavigationDecision.navigate;
                },
                onPageStarted: (String url) {
                  print('Page started loading: $url');
                },
                onPageFinished: (String url) {
                  print('Page finished loading: $url');
                  _controller!.evaluateJavascript('''
                      var email = document.getElementsByClassName('w3-input'); 
                            email[0].value = "wwww"; ''');
                },
                gestureNavigationEnabled: true,
              ),
            ),
          ],
        );
      })),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  takescrshot() async {

    String? path = await NativeScreenshot.takeScreenshot();
    print(path);

  }
}
