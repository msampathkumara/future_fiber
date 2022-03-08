import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

class PdfFileViewer extends StatefulWidget {
  // String pathPDF = "";
  // int fileID = 0;
  final File pdfFile;

  PdfFileViewer(this.pdfFile);

  @override
  _PdfFileViewerState createState() {
    return _PdfFileViewerState();
  }
}

class _PdfFileViewerState extends State<PdfFileViewer> {
  var pdfPath;

  // var pdfView;

  @override
  void initState() {
    super.initState();
    pdfPath = widget.pdfFile.path;

    // pdfView = new PDFView(
    //   filePath: pdfPath,
    //   enableSwipe: true,
    //   swipeHorizontal: false,
    //   autoSpacing: false,
    //   pageFling: true,
    //   pageSnap: true,
    //   defaultPage: currentPage,
    //   fitPolicy: FitPolicy.BOTH,
    //   preventLinkNavigation: false,
    //   onRender: (_pages) {
    //     setState(() {
    //       pages = _pages!;
    //       isReady = true;
    //       print('READYYYY');
    //     });
    //   },
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
    //     _controller.complete(pdfViewController);
    //   },
    //   onLinkHandler: (String? uri) {
    //     print('goto uri: $uri');
    //   },
    //   onPageChanged: (int? page, int? total) {
    //     print('page change: $page/$total');
    //     setState(() {
    //       currentPage = page!;
    //     });
    //   },
    // );

    _pdfController = PdfController(
      document: PdfDocument.openFile(pdfPath),
      initialPage: _initialPage,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  static final int _initialPage = 2;
  int _actualPageNumber = _initialPage, _allPagesCount = 0;
  bool isSampleDoc = true;
  late PdfController _pdfController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // title: Text((widget.ticket.mo ?? widget.ticket.oe ?? "") + " ${widget.ticket.mo != null ? "(${widget.ticket.oe})" : ""}  ", style: TextStyle(color: Colors.white)),
          actions: <Widget>[],
        ),
        body: Container(
          child: Stack(
            children: <Widget>[
              PdfView(
                documentLoader: Center(child: CircularProgressIndicator()),
                pageLoader: Center(child: CircularProgressIndicator()),
                controller: _pdfController,
                onDocumentLoaded: (document) {
                  isReady = true;
                  setState(() {
                    _allPagesCount = document.pagesCount;
                  });
                },
                onPageChanged: (page) {
                  // setState(() {
                  _actualPageNumber = page;
                  // });
                },
                scrollDirection: Axis.vertical,
              ),
              errorMessage.isEmpty
                  ? ((!isReady)
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Container())
                  : Center(
                      child: Text(errorMessage),
                    )
            ],
          ),
        ));
  }
}
