import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

// import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';

class PDFScreen extends StatefulWidget {
  String pathPDF = "";
  int fileID = 0;

  PDFScreen(this.pathPDF, this.fileID);

  @override
  _PDFScreenState createState() {
    return _PDFScreenState();
  }
}

class _PDFScreenState extends State<PDFScreen> {
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            PDFView(
              filePath: widget.pathPDF,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              defaultPage: currentPage,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              onRender: (_pages) {
                setState(() {
                  pages = _pages!;
                  isReady = true;
                  print('READYYYY');
                });
              },
              onError: (error) {
                setState(() {
                  errorMessage = error.toString();
                });
                print(error.toString());
              },
              onPageError: (page, error) {
                setState(() {
                  errorMessage = '$page: ${error.toString()}';
                });
                print('$page: ${error.toString()}');
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _controller.complete(pdfViewController);
              },
              onLinkHandler: (String? uri) {
                print('goto uri: $uri');
              },
              onPageChanged: (int? page, int? total) {
                print('page change: $page/$total');
                setState(() {
                  currentPage = page!;
                });
              },
            ),
            // if (errorMessage.isEmpty)Center(
            //   child: Text(errorMessage),
            // ),
            // if(!isReady)

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
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            // return FloatingActionButton.extended(
            //   label: Text("Go to ${pages ~/ 2}"),
            //   onPressed: () async {
            //     await snapshot.data.setPage(pages ~/ 2);
            //   },
            // );

            return FloatingActionButton.extended(
              icon: Icon(Icons.edit_outlined),
              label: Text("Edit"),
              onPressed: () async {
                final int result = await platform.invokeMethod('editPdf', {'path': widget.pathPDF, 'fileID': widget.fileID});

                // await snapshot.data.setPage(pages ~/ 2);
              },
            );
          }

          return Container();
        },
      ),
    );
  }

  static const platform = const MethodChannel('editPdf');
}
