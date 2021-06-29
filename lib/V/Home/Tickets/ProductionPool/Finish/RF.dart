import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/C/ServerResponce/OperationMinMax.dart';
import 'package:smartwind/C/ServerResponce/UserRFCredentials.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'PDFViewWidget.dart';

class RF extends StatefulWidget {
  Ticket ticket;
  UserRFCredentials userRFCredentials;
  OperationMinMax operationMinMax;

  RF(this.ticket, this.userRFCredentials, this.operationMinMax);

  @override
  _RFState createState() {
    return _RFState();
  }
}

class _RFState extends State<RF> {
  Map? checkListMap;

  late Ticket ticket;

  late UserRFCredentials userRFCredentials;
  late OperationMinMax operationMinMax;
  var showFinishButton = true;

  WebView? _webView;
  WebViewController? _controller;

  @override
  initState() {
    super.initState();
    ticket = widget.ticket;
    userRFCredentials = widget.userRFCredentials;
    operationMinMax = widget.operationMinMax;

    DefaultAssetBundle.of(context).loadString('assets/js.txt').then((value) {
      jsString = setupData("$value");
      _webView = WebView(
        // initialUrl: 'https://www.w3schools.com/howto/howto_css_register_form.asp',
        initialUrl: "http://10.200.4.31/webclient/",
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
          // if (request.url.startsWith('https://www.youtube.com/')) {
          //   print('blocking navigation to $request}');
          //   return NavigationDecision.prevent;
          // }
          // print('allowing navigation to $request');
          return NavigationDecision.navigate;
        },
        onPageStarted: (String url) {
          print('Page started loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
          _controller!.evaluateJavascript(jsString);
        },
        gestureNavigationEnabled: true,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (jsString.isNotEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: Text(ticket.mo ?? ""),
          ),
          floatingActionButton: Visibility(
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              icon: Icon(Icons.check_circle_outline_outlined),
              label: Text("Finish"),
              onPressed: () async {
                var r = await OnlineDB.apiGet("tickets/finish", {'ticket': ticket.id.toString()});
                print(json.decode(r.body));
                // ServerResponceMap res1 = ServerResponceMap.fromJson(json.decode(r.body));
                Navigator.pop(context, true);
              },
            ),
            visible: showFinishButton, // set it to false
          ),
          body: Column(
            children: [
              Expanded(
                child: PDFViewWidget(ticket.ticketFile!.path),
              ),
              // Row(
              //   children: [
              //     ElevatedButton(
              //       onPressed: () async {
              //         setState(() {});
              //       },
              //       child: Text("scan"),
              //     )
              //   ],
              // ),
              if (_webView != null)
                Expanded(
                  child: _webView!,
                ),
            ],
          ));
    } else {
      return Scaffold(
        body: Center(
          child: Text("Loading"),
        ),
      );
    }
  }

  takescrshot() async {
    String? path = await NativeScreenshot.takeScreenshot();
    print(path);
  }

  String jsString = "";

  String setupData(loadData) {
    print(userRFCredentials.toJson());
    loadData = loadData.toString().replaceAll("@@user", userRFCredentials.uname ?? "");
    loadData = loadData.toString().replaceAll("@@pass", userRFCredentials.pword ?? "");
    loadData = loadData.toString().replaceAll("@@mo", widget.ticket.mo ?? "");
    loadData = loadData.toString().replaceAll("@@low", operationMinMax.min.toString());
    loadData = loadData.toString().replaceAll("@@max", operationMinMax.max.toString());

    return loadData;
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'App',
        onMessageReceived: (JavascriptMessage message) {
          showFinishButton = true;
          print('Call Finish ');


          setState(() {});
        });
  }


}
