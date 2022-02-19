import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/C/ServerResponce/OperationMinMax.dart';
import 'package:smartwind/C/ServerResponce/Progress.dart';
import 'package:smartwind/C/ServerResponce/UserRFCredentials.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'PDFViewWidget.dart';

class RF extends StatefulWidget {
  Ticket ticket;
  UserRFCredentials userRFCredentials;
  OperationMinMax operationMinMax;
  List<Progress> progressList;

  RF(this.ticket, this.userRFCredentials, this.operationMinMax, this.progressList);

  @override
  _RFState createState() {
    return _RFState();
  }
}

class _RFState extends State<RF> with SingleTickerProviderStateMixin {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  final tabs = ["Ticket", "Progress"];
  TabController? _tabBarcontroller;
  Map? checkListMap;

  late Ticket ticket;

  late UserRFCredentials userRFCredentials;
  late OperationMinMax operationMinMax;
  late List<Progress> progressList;
  var showFinishButton = true;

  WebView? _webView;
  WebViewController? _controller;
  bool webPageConnectionError = false;
  bool loading = true;

  @override
  initState() {
    super.initState();

    ticket = widget.ticket;
    userRFCredentials = widget.userRFCredentials;
    operationMinMax = widget.operationMinMax;
    progressList = widget.progressList;

    _tabBarcontroller = TabController(length: tabs.length, vsync: this);

    DefaultAssetBundle.of(context).loadString('assets/js.txt').then((value) {
      jsString = setupData("$value");
      _webView = WebView(
        // initialUrl:
        //     'https://www.w3schools.com/howto/howto_css_register_form.asp',
        initialUrl: "http://10.200.4.31/webclient/",
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          print('WebViewController set');
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
          return NavigationDecision.navigate;
        },
        onPageStarted: (String url) {
          print('Page started loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
          _controller!.evaluateJavascript(jsString);
          loading = false;
          setState(() {});
        },
        onWebResourceError: (c) {
          loading = false;
          webPageConnectionError = true;
          setState(() {});
        },
        gestureNavigationEnabled: true,
      );

      setState(() {});
    });
    print('cxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');

    db.child("settings").once().then((DatabaseEvent databaseEvent) {
      DataSnapshot result = databaseEvent.snapshot;

      erpNotWorking = result.child("erpNotWorking").value == 0;
    });
    db.child("settings").onChildChanged.listen((DatabaseEvent event) {
      db.child("settings").once().then((DatabaseEvent databaseEvent) {
        DataSnapshot result = databaseEvent.snapshot;
        erpNotWorking = result.child("erpNotWorking").value == 0;
        print('------------ ${erpNotWorking}');
        setState(() {});
      });
    });
  }

  setupTimeout() {
    Future.delayed(const Duration(milliseconds: 15000), () {
      if (loading) {
        loading = false;
        webPageConnectionError = true;
        setState(() {});
      }
    });
  }

  var erpNotWorking = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("progressList.length");
    print(progressList.length);
    if (jsString.isNotEmpty) {
      return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(ticket.mo ?? ""),
          ),
          floatingActionButton: Visibility(
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              icon: Icon(Icons.check_circle_outline_outlined),
              label: Text("Finish"),
              onPressed: () async {
                var r = await OnlineDB.apiGet("tickets/finish", {'erpDone': erpNotWorking ? 0 : 1, 'ticket': ticket.id.toString(), 'doAt': operationMinMax.doAt.toString()});
                print(json.decode(r.data));
                // ServerResponceMap res1 = ServerResponceMap.fromJson(json.decode(r.body));
                Navigator.pop(context, true);
              },
            ),
            visible: showFinishButton, // set it to false
          ),
          body: Column(
            children: [
              // Expanded(child: PDFViewWidget(ticket.ticketFile!.path)),
              Expanded(
                child: DefaultTabController(
                    length: tabs.length,
                    child: Scaffold(
                        appBar: AppBar(
                            toolbarHeight: 0,
                            automaticallyImplyLeading: false,
                            elevation: 4.0,
                            bottom: TabBar(
                                controller: _tabBarcontroller,
                                indicatorWeight: 4.0,
                                indicatorColor: Colors.white,
                                isScrollable: true,
                                tabs: [for (final tab in tabs) Tab(text: tab)])),
                        body: TabBarView(controller: _tabBarcontroller, physics: NeverScrollableScrollPhysics(), children: [
                          Scaffold(body: PDFViewWidget(ticket.ticketFile!.path)),
                          Scaffold(
                            body: ListView.builder(
                              itemCount: progressList.length,
                              itemBuilder: (context, i) {
                                print(progressList[i].toJson());
                                Progress progress = progressList[i];
                                print(progress);
                                bool now = false;
                                bool done = false;
                                if (progress.operationNo! >= operationMinMax.min! && progress.operationNo! <= operationMinMax.max!) {
                                  now = true;
                                }
                                if (progress.operationNo! < operationMinMax.min!) {
                                  done = true;
                                }
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                    ),
                                    tileColor: (now)
                                        ? Colors.deepOrange[200]
                                        : (done)
                                            ? Colors.green[200]
                                            : Colors.white,
                                    leading: progress.status == 1
                                        ? Icon(
                                            Icons.check_circle_outline_outlined,
                                            color: Colors.green,
                                          )
                                        : Icon(Icons.pending_outlined),
                                    title: now ? Text(progress.operation!) : Text(progress.operation!),
                                    subtitle: Text(""),
                                    trailing: Wrap(
                                      children: [Text(progress.operationNo.toString())],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ]))),
              ),
              Divider(),
              if (_webView != null && (erpNotWorking))
                Expanded(
                  child: (loading)
                      ? Center(child: Text("Loading", textScaleFactor: 1.5))
                      : webPageConnectionError
                          ? Center(
                              child: Wrap(
                              direction: Axis.vertical,
                              alignment: WrapAlignment.center,
                              children: [
                                Text("No Network Or Not In Factory Network", textScaleFactor: 1.2),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        webPageConnectionError = false;
                                        loading = true;
                                        setupTimeout();
                                        setState(() {});
                                        _controller!.reload();
                                      },
                                      child: Text("Retry")),
                                )
                              ],
                            ))
                          : _webView!,
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
    // String? path = await NativeScreenshot.takeScreenshot();
    // print(path);
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
