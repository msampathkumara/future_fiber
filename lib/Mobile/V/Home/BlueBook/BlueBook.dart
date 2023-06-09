import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';
import 'package:smartwind_future_fibers/M/UserRFCredentials.dart';
import 'package:smartwind_future_fibers/Mobile/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind_future_fibers/Mobile/V/Widgets/Loading.dart';

// import 'package:webview_flutter/webview_flutter.dart';

import '../../../../C/ServerResponse/OperationMinMax.dart';
import '../../Widgets/PdfFileViewer.dart';
import 'BlueBookCredentials.dart';
import 'BlueBookLogin.dart';

class BlueBook extends StatefulWidget {
  final Ticket? ticket;

  const BlueBook({Key? key, this.ticket}) : super(key: key);

  @override
  _BlueBookState createState() => _BlueBookState();
}

class _BlueBookState extends State<BlueBook> {
  Ticket? ticket;
  late UserRFCredentials userRFCredentials;
  late OperationMinMax operationMinMax;
  var showFinishButton = true;

  // WebView? _webView;
  static InAppWebView? wv;

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
        initialUrlRequest: URLRequest(
            url: Uri.parse(
                "https://login.microsoftonline.com/5b5a8c35-0130-488b-875f-e4deb88b2904/oauth2/authorize?client%5Fid=00000003%2D0000%2D0ff1%2Dce00%2D000000000000&response%5Fmode=form%5Fpost&response%5Ftype=code%20id%5Ftoken&resource=00000003%2D0000%2D0ff1%2Dce00%2D000000000000&scope=openid&nonce=037B0F7697D629D661FF8AACAEBF6D065074AB129FB876BF%2D88A29908F71D6A8685FF8016CF8FFE9A8CB6FE9CBA360E10853D61706054EBE9&redirect%5Furi=https%3A%2F%2Fntgmast%2Esharepoint%2Ecom%2F%5Fforms%2Fdefault%2Easpx&state=OD0w&claims=%7B%22id%5Ftoken%22%3A%7B%22xms%5Fcc%22%3A%7B%22values%22%3A%5B%22CP1%22%5D%7D%7D%7D&wsucxt=1&cobrandid=11bd8083%2D87e0%2D41b5%2Dbb78%2D0bc43c8a8e8a&client%2Drequest%2Did=2f9db6a0%2Df0d1%2D3000%2D9a46%2Ddb2eba0f402f")),
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
              if (mounted) Navigator.pop(context);
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
        onDownloadStartRequest: (InAppWebViewController controller, DownloadStartRequest downloadStartRequest) async {
          print("onDownloadStart ${downloadStartRequest.url}");
          await BlurBookLogin.getBlueBookCredentials().then((blueBookCredentials) async {
            _getFile(context, downloadStartRequest.url.toString(), blueBookCredentials).then((file) async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => PdfFileViewer(file)));
            });
          });
        });

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

  Future<File> _getFile(context, url, BlueBookCredentials? credentials) async {
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
    String basicAuth = 'Basic ${base64Encode(utf8.encode('${credentials.userName}:${credentials.password}'))}';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers[HttpHeaders.authorizationHeader] = basicAuth;
    // dio.options.headers["authorization"] = '$idToken';
    // String queryString = Uri(queryParameters: {"id": id.toString()}).query;
    var id = UniqueKey();
    var filePath = '${ed!.path}/blueBook/$id.pdf';

    Response response;
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
          var errorView = const ErrorMessageView(errorMessage: "File Not Found", icon: Icons.sd_card_alert);
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
