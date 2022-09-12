import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/UserRFCredentials.dart';
import 'package:smartwind/res.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../C/Api.dart';
import '../../../../../C/ServerResponse/OperationMinMax.dart';
import '../../../../../C/ServerResponse/Progress.dart';
import 'PDFViewWidget.dart';

class RF extends StatefulWidget {
  Ticket ticket;
  UserRFCredentials userRFCredentials;
  OperationMinMax operationMinMax;
  List<Progress> progressList;

  RF(this.ticket, this.userRFCredentials, this.operationMinMax, this.progressList, {Key? key}) : super(key: key);

  @override
  _RFState createState() {
    return _RFState();
  }
}

class _RFState extends State<RF> with SingleTickerProviderStateMixin {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  final tabs = ["Ticket", "Progress"];
  TabController? _tabBarController;
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

    _tabBarController = TabController(length: tabs.length, vsync: this);

    DefaultAssetBundle.of(context).loadString(Res.js1).then((value) {
      print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
      jsString = setupData(value);
      _webView = WebView(
        // initialUrl: 'https://www.w3schools.com/howto/howto_css_register_form.asp',
        initialUrl: 'http://10.200.4.31/WebClient/default.aspx?ReturnUrl=%2fWebClient%2fRFSMenu.aspx',
        // initialUrl: "http://10.200.4.31/webclient/",
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
          _controller!.runJavascript(jsString);
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

    db.child("settings").once().then((DatabaseEvent databaseEvent) {
      DataSnapshot result = databaseEvent.snapshot;

      erpNotWorking = result.child("erpNotWorking").value == 0;
      setState(() {});
    });
    db.child("settings").onChildChanged.listen((DatabaseEvent event) {
      db.child("settings").once().then((DatabaseEvent databaseEvent) {
        DataSnapshot result = databaseEvent.snapshot;
        erpNotWorking = result.child("erpNotWorking").value == 0;
        print('------------ $erpNotWorking');
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
          appBar: AppBar(elevation: 0, title: Text(ticket.mo ?? "")),
          floatingActionButton: Visibility(
            visible: showFinishButton,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              icon: const Icon(Icons.check_circle_outline_outlined),
              label: const Text("Finish"),
              onPressed: () async {
                var v = await LoadingDialog(Api.post("tickets/finish", {
                  'erpDone': erpNotWorking ? 0 : 1,
                  'ticket': ticket.id.toString(),
                  'userSectionId': AppUser.getSelectedSection()?.id,
                  'doAt': operationMinMax.doAt.toString()
                }).then((res) {
                  Map data = res.data;
                  print(data);

                  if (data["errorResponce"] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${data["errorResponce"]["message"]}"), backgroundColor: Colors.red));
                  }
                  return data["errorResponce"] == null;
                }));

                if (mounted) Navigator.pop(context, v);
              },
            ), // set it to false
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
                                  controller: _tabBarController,
                                  indicatorWeight: 4.0,
                                  indicatorColor: Colors.white,
                                  isScrollable: true,
                                  tabs: [for (final tab in tabs) Tab(text: tab)])),
                          body: TabBarView(controller: _tabBarController, physics: const NeverScrollableScrollPhysics(), children: [
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
                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                              tileColor: (now)
                                                  ? Colors.deepOrange[200]
                                                  : (done)
                                                      ? Colors.green[200]
                                                      : Colors.white,
                                              leading:
                                                  progress.status == 1 ? const Icon(Icons.check_circle_outline_outlined, color: Colors.green) : const Icon(Icons.pending_outlined),
                                              title: now ? Text(progress.operation!) : Text(progress.operation!),
                                              subtitle: const Text(""),
                                              trailing: Wrap(
                                                children: [Text(progress.operationNo.toString())],
                                              )));
                                    }))
                          ])))),
              const Divider(),
              if (_webView != null && (erpNotWorking))
                Expanded(
                    child: Stack(children: [
                  webPageConnectionError
                      ? Center(
                          child: Wrap(
                          direction: Axis.vertical,
                          alignment: WrapAlignment.center,
                          children: [
                            const Text("No Network Or Not In Factory Network", textScaleFactor: 1.2),
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
                                    child: const Text("Retry")))
                          ],
                        ))
                      : _webView!,
                  if (loading) Container(color: Colors.white, height: double.infinity, width: double.infinity, child: const Center(child: Text("Loading", textScaleFactor: 1.5))),
                ])),
            ],
          ));
    } else {
      return const Scaffold(
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

  Future LoadingDialog(Future future) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context1) {
          future.then((value) {
            Navigator.of(context1).pop(value);
          });

          return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(builder: (context) {
                return const SizedBox(height: 150, width: 50, child: Center(child: SizedBox(height: 50, width: 50, child: CircularProgressIndicator())));
              }));
        });
  }
}
