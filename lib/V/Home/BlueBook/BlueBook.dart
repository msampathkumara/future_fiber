import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/UserRFCredentials.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/Loading.dart';

// import 'package:webview_flutter/webview_flutter.dart';

import '../../../C/ServerResponse/OperationMinMax.dart';
import '../../Widgets/PdfFileViewer.dart';
import 'BlueBookCredentials.dart';
import 'BlueBookLogin.dart';

class BlueBook extends StatefulWidget {
  Ticket? ticket;

  BlueBook({Key? key, this.ticket}) : super(key: key);

  @override
  _BlueBookState createState() => _BlueBookState();
}

class _BlueBookState extends State<BlueBook> {
  Ticket? ticket;
  late UserRFCredentials userRFCredentials;
  late OperationMinMax operationMinMax;
  var showFinishButton = true;

  // WebView? _webView;
  // static InAppWebView? wv;
  static var wv;

  late PdfControllerPinch pdfPinchController;

  Widget pdfView() => PdfViewPinch(controller: pdfPinchController, padding: 10, scrollDirection: Axis.vertical);
  String path = "";

  int loginAttemps = 0;

  @override
  initState() {
    super.initState();
    ticket = widget.ticket;

    path = ticket == null ? "" : widget.ticket!.ticketFile!.path;

    wv = InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse("http://bluebook.northsails.com:8088/nsbb/app/blueBook.html")),
        // initialUrlRequest: URLRequest(url: Uri.parse("https://smartupwind.nsslsupportservices.com/FileBrowser/Files/ppp/upwind/upwind")),
        initialOptions: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions(useOnDownloadStart: true), android: AndroidInAppWebViewOptions(useHybridComposition: true)),
        onReceivedHttpAuthRequest: (InAppWebViewController controller, URLAuthenticationChallenge challenge) async {
          print('onReceivedHttpAuthRequest');
          loginAttemps++;
          if (loginAttemps > 2) {
            BlueBookCredentials? blueBookCredentials = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const BlurBookLogin();
                });
            if (blueBookCredentials != null) {
              return HttpAuthResponse(username: blueBookCredentials.userName, password: blueBookCredentials.password, action: HttpAuthResponseAction.PROCEED);
            } else {
              Navigator.pop(context);
            }
          } else {
            var blueBookCredentials = await BlurBookLogin.getBlueBookCredentials();
            if (blueBookCredentials != null) {
              return HttpAuthResponse(username: blueBookCredentials.userName, password: blueBookCredentials.password, action: HttpAuthResponseAction.PROCEED);
            } else {
              return HttpAuthResponse(action: HttpAuthResponseAction.PROCEED);
            }
          }

          return HttpAuthResponse(action: HttpAuthResponseAction.CANCEL);
        },
        onDownloadStart: (controller, url) async {
          print("onDownloadStart $url");
          var blueBookCredentials = await BlurBookLogin.getBlueBookCredentials();
          File file = await _getFile(context, url.toString(), blueBookCredentials);
          await Navigator.push(context, MaterialPageRoute(builder: (context) => PdfFileViewer(file)));
        });
    print('LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL');
    // _pdfController = PdfController(
    //   document: PdfDocument.openFile(path),
    //   initialPage: _initialPage,
    // );

    pdfPinchController = PdfControllerPinch(document: PdfDocument.openFile(path));
  }

  bool isSampleDoc = true;

  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  int x = 0;

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: const Text("Blue Book")),
      body: Column(
        children: [
          SizedBox(height: (ticket != null && (isPortrait)) ? height / 2 : 0, child: pdfView()),
          if (ticket != null && (isPortrait)) Container(height: 20, color: Colors.blue),
          Expanded(child: Container(color: Colors.white, child: wv))
        ],
      ),
    );
  }

  Future<File> _getFile(context, url, BlueBookCredentials? credentials, {onReceiveProgress}) async {
    if (credentials == null) {
      return Future.value(File(""));
    }
    var loadingWidget = const Loading(
      loadingText: "Downloading File",
      showProgress: false,
    );
    loadingWidget.show(context);

    var dio = Dio();
    var ed = await getExternalStorageDirectory();
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();
    String basicAuth = 'Basic ${base64Encode(utf8.encode('${credentials.userName}:${credentials.password}'))}';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers[HttpHeaders.authorizationHeader] = basicAuth;
    // dio.options.headers["authorization"] = '$idToken';
    // String queryString = Uri(queryParameters: {"id": id.toString()}).query;
    var id = UniqueKey();
    var filePath = '${ed!.path}/blueBook/$id.pdf';

    var response;
    try {
      await dio.download(url, filePath, onReceiveProgress: (received, total) {
        print('TOTAL = $total');
        print('received = $received');
        // int percentage = ((received / total) * 100).floor();
        // loadingWidget.setProgress(percentage);
        // if (onReceiveProgress != null) {
        //   onReceiveProgress(percentage);
        // }
      }).then((value) async {
        response = value;
        print('+++++++++++++++++++++++++++++++++++++++++++++');
        print(response.headers["fileVersion"]);
      });
    } on DioError catch (e) {
      if (e.response != null) {
        print('"******************************************** response');
        print(e.response);
        if (e.response!.statusCode == 404) {
          loadingWidget.close(context);
          var errorView = ErrorMessageView(
            errorMessage: "File Not Found",
            icon: Icons.sd_card_alert,
          );
          await errorView.show(context);
          return Future.value(null);
        }

        print(e.response!.statusCode);
        print(e.response!.data);
        print(e.response!.headers);
      } else {
        print(e.message);
      }
    }

    loadingWidget.close(context);
    File file = File(filePath);
    return file;
  }
}
