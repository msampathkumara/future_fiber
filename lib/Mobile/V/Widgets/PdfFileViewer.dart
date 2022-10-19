import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
// import 'package:native_pdf_view/native_pdf_view.dart';

class PdfFileViewer extends StatefulWidget {
  // String pathPDF = "";
  // int fileID = 0;
  final File pdfFile;

  const PdfFileViewer(this.pdfFile, {super.key});

  @override
  _PdfFileViewerState createState() {
    return _PdfFileViewerState();
  }
}

class _PdfFileViewerState extends State<PdfFileViewer> {
  late String pdfPath;

  // var pdfView;

  @override
  void initState() {
    super.initState();
    pdfPath = widget.pdfFile.path;

    _pdfController = PdfController(
      document: PdfDocument.openFile(pdfPath),
      initialPage: _initialPage,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  static const int _initialPage = 2;
  bool isSampleDoc = true;
  late PdfController _pdfController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // title: Text((widget.ticket.mo ?? widget.ticket.oe ?? "") + " ${widget.ticket.mo != null ? "(${widget.ticket.oe})" : ""}  ", style: TextStyle(color: Colors.white)),
          actions: const <Widget>[],
        ),
        body: Stack(
          children: <Widget>[
            PdfView(
              // documentLoader: Center(child: CircularProgressIndicator()),
              // pageLoader: Center(child: CircularProgressIndicator()),
              controller: _pdfController,
              onDocumentLoaded: (document) {
                isReady = true;
                setState(() {});
              },
              onPageChanged: (page) {},
              scrollDirection: Axis.vertical,
            ),
            errorMessage.isEmpty ? ((!isReady) ? const Center(child: CircularProgressIndicator()) : Container()) : Center(child: Text(errorMessage))
          ],
        ));
  }
}
