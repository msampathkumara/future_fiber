import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PDFViewWidget extends StatefulWidget {
  final String path;

  const PDFViewWidget(this.path, {super.key});

  @override
  _PDFViewWidget createState() => _PDFViewWidget();
}

class _PDFViewWidget extends State<PDFViewWidget> {
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.path),
      initialPage: _initialPage,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  static const int _initialPage = 2;
  bool isSampleDoc = true;
  late PdfController _pdfController;

  @override
  Widget build(BuildContext context) => PdfView(
        controller: _pdfController,
        onDocumentLoaded: (document) {
          setState(() {});
        },
        onPageChanged: (page) {
          setState(() {});
        },
        scrollDirection: Axis.vertical,
      );
}
