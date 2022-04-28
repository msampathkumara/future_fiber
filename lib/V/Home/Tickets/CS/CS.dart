import 'package:custom_webview/webview_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

// import 'package:native_pdf_view/native_pdf_view.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:smartwind/M/Ticket.dart';

import 'SelectPdfPage.dart';

class CS extends StatefulWidget {
  final Ticket ticket;

  CS(this.ticket);

  @override
  _CSState createState() => _CSState();
}

class _CSState extends State<CS> with TickerProviderStateMixin {
  var tabs = ["Ticket", "QC Page"];
  TabController? _tabBarController;

  late Ticket ticket;
  var selectedPage;

  late CustomWebView _webView;
  CustomWebViewController? _webViewController;

  @override
  initState() {
    super.initState();
    ticket = widget.ticket;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: " + _tabBarController!.index.toString());
      });
    });
    _webView = CustomWebView(
      initialUrl: "https://cs.northsails.com",
      // initialUrl: "https://ps.uci.edu/~franklin/doc/file_upload.html",
      javascriptMode: JavascriptMode.unrestricted,
      onCustomWebViewCreated: (CustomWebViewController webViewController) {
        _webViewController = webViewController;
        // webViewController.loadUrl("http://bluebook.northsails.com:8088/nsbb/app/blueBook.html", headers: {"Authorization": "Basic c3VtaXRyYUBsazpZeFpGZThIeA=="});
        // _controller.complete(webViewController);
      },
      onShowFileChooser: () {
        print("------------------------------------------------------------------x $selectedPage");
        return selectedPage;
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
    _pdfController = PdfController(
      document: PdfDocument.openFile(ticket.ticketFile!.path),
      initialPage: _initialPage,
    );
    _pdfController1 = PdfController(
      document: PdfDocument.openFile(selectedPage),
      initialPage: _initialPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return selectedPage == null
        ? SelectPdfPage(ticket, (selectedPage) {
            setState(() {
              this.selectedPage = selectedPage;
            });
          })
        : Scaffold(
            body: _tabBarController == null
                ? Container()
                : isPortrait
                    ? DefaultTabController(
                        length: tabs.length,
                        child: Scaffold(
                            backgroundColor: Colors.white,
                            appBar: AppBar(
                              toolbarHeight: 0,
                              automaticallyImplyLeading: false,
                              backgroundColor: Colors.green,
                              elevation: 4.0,
                              bottom: TabBar(
                                controller: _tabBarController,
                                indicatorWeight: 4.0,
                                indicatorColor: Colors.white,
                                isScrollable: true,
                                tabs: [
                                  for (final tab in tabs) Tab(text: tab),
                                ],
                              ),
                            ),
                            body: Column(
                              children: [
                                Expanded(
                                  child: TabBarView(physics: NeverScrollableScrollPhysics(), controller: _tabBarController, children: [getPdf(1), getPdf(2)]),
                                ),
                                Container(height: 30, color: Colors.blue),
                                Expanded(child: _webView)
                              ],
                            )),
                      )
                    : SafeArea(child: _webView));
  }

  var errorMessage;
  static final int _initialPage = 2;
  int _actualPageNumber = _initialPage, _allPagesCount = 0;
  bool isSampleDoc = true;
  late PdfController _pdfController;
  late PdfController _pdfController1;

  getPdf(id) {
    return PdfView(
      renderer: (PdfPage page) => page.render(
        width: page.width * 3,
        height: page.height * 3,
        format: PdfPageImageFormat.webp,
        backgroundColor: '#ffffff',
      ),
      // documentLoader: Center(child: CircularProgressIndicator()),
      // pageLoader: Center(child: CircularProgressIndicator()),
      controller: id == 1 ? _pdfController : _pdfController1,
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
    );
    // return PDFView(
    //   filePath: path,
    //   enableSwipe: true,
    //   swipeHorizontal: false,
    //   autoSpacing: true,
    //   pageFling: true,
    //   pageSnap: true,
    //   defaultPage: 0,
    //   fitPolicy: FitPolicy.BOTH,
    //   preventLinkNavigation: false,
    //   onRender: (_pages) {},
    //   onError: (error) {
    //     setState(() {
    //       errorMessage = error.toString();
    //     });
    //     print(error.toString());
    //   },
    //   onPageError: (page, error) {
    //     setState(() {
    //       errorMessage = '$page: ${error.toString()}';
    //     });
    //     print('$page: ${error.toString()}');
    //   },
    //   onViewCreated: (PDFViewController pdfViewController) {
    //     // _controller.complete(pdfViewController);
    //   },
    //   onLinkHandler: (String? uri) {
    //     print('goto uri: $uri');
    //   },
    //   onPageChanged: (int? page, int? total) {
    //     print('page change: $page/$total');
    //   },
    // );
  }
}
