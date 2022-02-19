import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/C/ServerResponce/OperationMinMax.dart';
import 'package:smartwind/C/ServerResponce/UserRFCredentials.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Home/BlueBook/BlueBookLogin.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/Loading.dart';
import 'package:smartwind/V/Widgets/PdfFileViewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

// import 'package:webview_flutter/webview_flutter.dart';

import 'BlueBookCredentials.dart';

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

  // WebView? _webView;
  // static InAppWebView? wv;
  static var wv;

  late WebViewController _webViewController;

  var pdfView;
  var path;
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
                  return BlurBookLogin();
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
    _pdfController = PdfController(
      document: PdfDocument.openFile(path),
      initialPage: _initialPage,
    );
  }

  static final int _initialPage = 2;
  int _actualPageNumber = _initialPage, _allPagesCount = 0;
  bool isSampleDoc = true;
  late PdfController _pdfController;

  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  late Completer<PDFViewController> _controller = Completer<PDFViewController>();
  late PDFViewController _pdfView;
  int x = 0;

  var tabs = ["All", "Cross Production"];

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text("Blue Book")),
      body: Column(
        children: [
          SizedBox(
            height: (ticket != null && (isPortrait)) ? height / 2 : 0,
            child: PdfView(
              renderer: (PdfPage page) => page.render(
                width: page.width * 3,
                height: page.height * 3,
                format: PdfPageImageFormat.webp,
                backgroundColor: '#ffffff',
              ),
              documentLoader: Center(child: CircularProgressIndicator()),
              pageLoader: Center(child: CircularProgressIndicator()),
              controller: _pdfController,
              onDocumentLoaded: (document) {
                setState(() {
                  _allPagesCount = document.pagesCount;
                });
              },
              onPageChanged: (page) {
                setState(() {
                  _actualPageNumber = page;
                });
              },
              scrollDirection: Axis.vertical,
            ),
          ),

          // ? Expanded(
          //     child: PDFView(
          //     filePath: path,
          //     enableSwipe: true,
          //     swipeHorizontal: false,
          //     autoSpacing: false,
          //     pageFling: true,
          //     pageSnap: true,
          //     defaultPage: 1,
          //     fitPolicy: FitPolicy.BOTH,
          //     preventLinkNavigation: false,
          //     onRender: (_pages) {
          //       // setState(() {
          //       pages = _pages!;
          //       isReady = true;
          //       print('READYYYY');
          //       // });
          //     },
          //     onError: (error) {
          //       // setState(() {
          //       errorMessage = error.toString();
          //       // });
          //       print(error.toString());
          //     },
          //     onPageError: (page, error) {
          //       // setState(() {
          //       errorMessage = '$page: ${error.toString()}';
          //       // });
          //       print('$page: ${error.toString()}');
          //     },
          //     onViewCreated: (PDFViewController pdfViewController) {
          //       _controller.complete(pdfViewController);
          //     },
          //     onLinkHandler: (String? uri) {
          //       print('goto uri: $uri');
          //     },
          //     onPageChanged: (int? page, int? total) {
          //       print('page change: $page/$total');
          //       // setState(() {
          //       currentPage = page!;
          //       // });
          //     },
          //   ))
          // : Container(),
          if (ticket != null && (isPortrait))
            Container(
              height: 20,
              color: Colors.blue,
              // child: ElevatedButton(
              //   onPressed: () {
              //     setState(() {});
              //   },
              //   child: Text("ddd"),
              // ),
            ),
          Expanded(child: Container(color: Colors.red, child: wv))
        ],
      ),
    );
  }

  Future<File> _getFile(context, url, BlueBookCredentials? credentials, {onReceiveProgress}) async {

    if(credentials==null){return Future.value(new File(""));}
    var loadingWidget = Loading(
      loadingText: "Downloading File",
      showProgress: false,
    );
    loadingWidget.show(context);

    var dio = Dio();
    var ed = await getExternalStorageDirectory();
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('${credentials.userName}:${credentials.password}'));
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers[HttpHeaders.authorizationHeader] = basicAuth;
    // dio.options.headers["authorization"] = '$idToken';
    // String queryString = Uri(queryParameters: {"id": id.toString()}).query;
    var id = UniqueKey();
    var filePath = ed!.path + '/blueBook/$id.pdf';

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
    File file = new File(filePath);
    return file;
  }
}
