import 'package:custom_webview/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:smartwind/M/Ticket.dart';

import 'SelectPdfPage.dart';

class CS extends StatefulWidget {
  final Ticket ticket;

  const CS(this.ticket, {Key? key}) : super(key: key);

  @override
  _CSState createState() => _CSState();
}

class _CSState extends State<CS> with TickerProviderStateMixin {
  var tabs = ["Ticket", "QC Page"];
  TabController? _tabBarController;

  late Ticket ticket;
  String? selectedPage;

  late CustomWebView _webView;
  late CustomWebViewController _webViewController;

  bool _loading = true;

  @override
  initState() {
    super.initState();
    ticket = widget.ticket;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: ${_tabBarController!.index}");
      });
    });
    _webView = CustomWebView(
      initialUrl: "https://cs.northsails.com",
      // initialUrl: "https://smartwind.nsslsupportservices.com",
      // initialUrl: "https://ps.uci.edu/~franklin/doc/file_upload.html",
      javascriptMode: JavascriptMode.unrestricted,
      onCustomWebViewCreated: (CustomWebViewController webViewController) {
        _webViewController = webViewController;
        print('llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll');
        _webViewController.evaluateJavascript(" setTimeout(function(){  console.log('Hello World');  }, 2000);");
        // webViewController.loadUrl("http://bluebook.northsails.com:8088/nsbb/app/blueBook.html", headers: {"Authorization": "Basic c3VtaXRyYUBsazpZeFpGZThIeA=="});
        // _controller.complete(webViewController);
        _webViewController.evaluateJavascript("console.log('sssssssssssssssssssssssss')");
      },
      onShowFileChooser: () {
        print("------------------------------------------------------------------x $selectedPage");
        return "$selectedPage";
      },
      onProgress: (int progress) {
        print("WebView is loading (progress : $progress%)");
      },
      javascriptChannels: const <JavascriptChannel>{},
      navigationDelegate: (NavigationRequest request) {
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
        // _controller!.evaluateJavascript(jsString);
        // _webViewController?.evaluateJavascript("document.getElementById('userName').value = 'My value';console.log('sssssssssssssssssssssssssxx')");
        _webViewController.evaluateJavascript("console.log('sssssssssssssssssssssssssxx')");

        setState(() {
          _loading = false;
        });
      },
      gestureNavigationEnabled: true,
    );
    _pdfController = PdfController(document: PdfDocument.openFile(ticket.ticketFile!.path), initialPage: 0);
  }

  @override
  dispose() {
    _pdfController.dispose();
    _pdfController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var height = MediaQuery.of(context).size.height;

    if (selectedPage == null) {
      return SelectPdfPage(ticket, (selectedPage) {
        setState(() {
          this.selectedPage = selectedPage;
          _pdfController1 = PdfController(document: PdfDocument.openFile(selectedPage), initialPage: 0);
        });
      });
    }
    return Scaffold(
        body: Stack(
      children: [
        Positioned(
          top: 0,
          height: (height / 2) - 24,
          left: 0,
          right: 0,
          child: DefaultTabController(
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
                body: TabBarView(physics: const NeverScrollableScrollPhysics(), controller: _tabBarController, children: [getPdf(1), getPdf(2)])),
          ),
        ),
        Positioned(top: height / 2, left: 0, right: 0, child: const Divider(height: 30, thickness: 30)),
        Positioned(
            bottom: 0,
            height: isPortrait ? (height / 2) - 24 : height,
            left: 0,
            right: 0,
            child: Stack(
              children: [_webView, if (_loading) const Center(child: CircularProgressIndicator())],
            ))
      ],
    ));
    // : SafeArea(child: _webView));
  }

  String? errorMessage;
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
        setState(() {});
      },
      onPageChanged: (page) {
        setState(() {});
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
