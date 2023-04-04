import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/Mobile/V/Home/Tickets/FinishedGoods/AddRFCredentials.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../../C/Api.dart';
import '../../../../../../C/ServerResponse/OperationMinMax.dart';
import '../../../../../../C/ServerResponse/Progress.dart';
import '../../../../../../M/EndPoints.dart';
import '../../../../../../M/UserRFCredentials.dart';
import '../../../../../../globals.dart';
import 'PDFViewWidget.dart';
import 'package:flutter/services.dart' show rootBundle;

// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// #enddocregion platform_imports
class RF extends StatefulWidget {
  final Ticket ticket;

  final OperationMinMax operationMinMax;
  final List<Progress> progressList;

  const RF(this.ticket, this.operationMinMax, this.progressList, {Key? key}) : super(key: key);

  Future show(context) {
    return Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }

  @override
  _RFState createState() {
    return _RFState();
  }
}

class _RFState extends State<RF> with SingleTickerProviderStateMixin {
  final DatabaseReference db = firebaseDatabase;

  final tabs = ["Ticket", "Progress"];
  TabController? _tabBarController;
  Map? checkListMap;

  late Ticket ticket;

  UserRFCredentials? userRFCredentials;
  late OperationMinMax operationMinMax;
  late List<Progress> progressList;
  var showFinishButton = true;

  // WebView? _webView;
  // WebViewController? _controller;
  bool webPageConnectionError = false;
  bool loading = true;

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/rf/rf.js');
  }

  String setupData(loadData) {
    // print(userRFCredentials.toJson());
    loadData = loadData.toString().replaceAll("@@user", userRFCredentials?.uname ?? "MalithG");
    loadData = loadData.toString().replaceAll("@@pass", userRFCredentials?.pword ?? "abc@123");
    loadData = loadData.toString().replaceAll("@@mo", widget.ticket.mo ?? "");
    loadData = loadData.toString().replaceAll("@@min", operationMinMax.min.toString());
    loadData = loadData.toString().replaceAll("@@max", operationMinMax.max.toString());

    return loadData;
  }

  late final WebViewController _controller;
  bool pageIsLoading = true;

  bool loadingUserRFCredentials = true;

  @override
  initState() {
    super.initState();
    print('RFFFFFFFFFFFFFFF==== >>>> ');
    ticket = widget.ticket;
    progressList = widget.progressList;

    Api.get(EndPoints.users_getRfCredentials, {}).then((value) async {
      var uc = value.data["userRFCredentials"];

      print('userRFCredentials==== $uc');

      if (uc == null) {
        userRFCredentials = await const AddRFCredentials().show(context);
      } else {
        userRFCredentials = UserRFCredentials.fromJson(uc);
      }

      operationMinMax = widget.operationMinMax;
      progressList = widget.progressList;

      _tabBarController = TabController(length: tabs.length, vsync: this);

      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }
      final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              debugPrint('WebView is loading (progress : $progress%)');
            },
            onPageStarted: (String url) {
              setState(() {
                pageIsLoading = true;
              });
              debugPrint('Page started loading: $url');
            },
            onPageFinished: (String url) async {
              debugPrint('Page finished loading: $url');
              // controller.runJavaScript("document.querySelector(\".module.active #txt[type='text']\").value = \"MalithG\"");
              // controller.runJavaScript(
              //     "if (document.querySelector(\".module.active #l_lbl@SYS4517_DT1\")) {document.querySelector(\".module.active #txt[type='text']\").value = \"MalithGx\"}");
              // controller.runJavaScript(
              //     "if (document.querySelectorAll(\".module.active [id\$=\"SYS4517_DT1\"]\")) {document.querySelector(\".module.active #txt[type='text']\").value = \"MalithGx\"}");
              // controller.runJavaScript("document.querySelector(\".module.active #txt[type='password']\").value = \"abc@123\"");
              // controller.runJavaScript("document.getElementById(\"NorthSailsReportAsFinished04_NorthSails01\").click();");

              // controller.runJavaScript("document.getElementById(\"Form1\").submit();");

              // controller.runJavaScript("\$('#txt[type='text']').val('dddxxxxxxxxxxxxx');");
              // controller.runJavaScript("\$('#txt[type='password']').val('1');");

              String jsString = setupData(await loadAsset());
              controller.runJavaScript(jsString);

              setState(() {
                pageIsLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
            },
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                debugPrint('blocking navigation to ${request.url}');
                return NavigationDecision.prevent;
              }
              debugPrint('allowing navigation to ${request.url}');
              return NavigationDecision.navigate;
            },
          ),
        )
        ..addJavaScriptChannel(
          'Toaster',
          onMessageReceived: (JavaScriptMessage message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          },
        )
        ..addJavaScriptChannel(
          "onError",
          onMessageReceived: (JavaScriptMessage) async {
            print("xxxxxxxxxxxxxxxxxxxxxx == > ${JavaScriptMessage.message}");
            userRFCredentials = await const AddRFCredentials().show(context);
          },
        )
        ..addJavaScriptChannel(
          "onSuccess",
          onMessageReceived: (JavaScriptMessage) {
            print("xxxxxxxxxxxxxxxxxxxxxx == > ${JavaScriptMessage.message}");
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("finished")));
            showFinishButton = true;
            setState(() {});
          },
        )
        // ..loadRequest(Uri.parse('https://www.facebook.com/'));
        ..loadRequest(Uri.parse('http://10.200.4.24/WebClient/default.aspx?ReturnUrl=%2fWebClient%2fRFSMenu.aspx'));
      // ..loadFlutterAsset(Res.RF_SMARTLogin);

      // #docregion platform_features
      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
        (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
      }
      // #enddocregion platform_features

      _controller = controller;

      print('');

      setState(() {
        loadingUserRFCredentials = false;
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

  // var erpNotWorking = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("progressList.length");
    print(progressList.length);
    // if (jsString.isNotEmpty) {
    return Scaffold(
        appBar: AppBar(elevation: 0, title: Text(ticket.mo ?? "")),
        body: loadingUserRFCredentials
            ? Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [CircularProgressIndicator(), Text("Loading RF Credentials")]),
              )
            : Column(
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
                                                  leading: progress.status == 1
                                                      ? const Icon(Icons.check_circle_outline_outlined, color: Colors.green)
                                                      : const Icon(Icons.pending_outlined),
                                                  title: now ? Text(progress.operation!) : Text(progress.operation!),
                                                  subtitle: const Text(""),
                                                  trailing: Wrap(
                                                    children: [Text(progress.operationNo.toString())],
                                                  )));
                                        }))
                              ])))),
                  const Divider(),
                  // Expanded(
                  //   child: Column(
                  //     children: [if (pageIsLoading) Center(child: CircularProgressIndicator()), WebViewWidget(controller: _controller)],
                  //   ),
                  // )

                  // if (_webView != null && (erpNotWorking))
                  // if (_webView != null)
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
                                        _controller.reload();
                                      },
                                      child: const Text("Retry")))
                            ],
                          ))
                        : WebViewWidget(controller: _controller),
                    // : _webView!,
                    if (pageIsLoading)
                      Container(color: Colors.white, height: double.infinity, width: double.infinity, child: const Center(child: Text("Loading", textScaleFactor: 1.5))),
                  ])),
                ],
              ),
        floatingActionButton: loadingUserRFCredentials
            ? null
            : showFinishButton
                ? FloatingActionButton.extended(
                    backgroundColor: Colors.red,
                    icon: const Icon(Icons.check_circle_outline_outlined),
                    label: const Text("Finish"),
                    onPressed: () async {
                      var v = await LoadingDialog(Api.post(EndPoints.tickets_finish,
                          {'erpDone': 0, 'ticket': ticket.id.toString(), 'userSectionId': AppUser.getSelectedSection()?.id, 'doAt': operationMinMax.doAt.toString()}).then((res) {
                        Map data = res.data;
                        print(data);

                        if (data["errorResponce"] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${data["errorResponce"]["message"]}"), backgroundColor: Colors.red));
                        }
                        return data["errorResponce"] == null;
                      }));
                      if (mounted) Navigator.pop(context, v);
                    })
                : null);
  }

  String jsString = "";

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
