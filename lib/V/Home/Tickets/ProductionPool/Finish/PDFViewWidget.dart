import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PDFViewWidget extends StatefulWidget {
  final String path;

  PDFViewWidget(this.path);

  @override
  _PDFViewWidget createState() => _PDFViewWidget();
}

class _PDFViewWidget extends State<PDFViewWidget> {
  late PDFView _pdfView;
  final Completer<PDFViewController> _pdfcontroller = Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // _pdfView = PDFView(
    //   filePath: widget.path,
    //   enableSwipe: true,
    //   swipeHorizontal: false,
    //   autoSpacing: false,
    //   pageFling: true,
    //   pageSnap: true,
    //   defaultPage: 1,
    //   fitPolicy: FitPolicy.BOTH,
    //   preventLinkNavigation: false,
    //   onRender: (_pages) {
    //     // setState(() {
    //     pages = _pages!;
    //     isReady = true;
    //     print('READYYYY');
    //     // });
    //   },
    //   onError: (error) {
    //     // setState(() {
    //     errorMessage = error.toString();
    //     // });
    //     print(error.toString());
    //   },
    //   onPageError: (page, error) {
    //     // setState(() {
    //     errorMessage = '$page: ${error.toString()}';
    //     // });
    //     print('$page: ${error.toString()}');
    //   },
    //   onViewCreated: (PDFViewController pdfViewController) {
    //     _pdfcontroller.complete(pdfViewController);
    //   },
    //   onLinkHandler: (String? uri) {
    //     print('goto uri: $uri');
    //   },
    //   onPageChanged: (int? page, int? total) {
    //     print('page change: $page/$total');
    //     // setState(() {
    //     currentPage = page!;
    //     // });
    //   },
    // );
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.path),
      initialPage: _initialPage,
    );
  }

  @override
  void dispose() {
    super.dispose();
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
  static final int _initialPage = 2;
  int _actualPageNumber = _initialPage, _allPagesCount = 0;
  bool isSampleDoc = true;
  late PdfController _pdfController;
  @override
  Widget build(BuildContext context) => PdfView(
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
    },scrollDirection: Axis.vertical,
  );
}
